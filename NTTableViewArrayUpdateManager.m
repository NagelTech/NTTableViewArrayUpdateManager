//
//  NTTableViewArrayUpdateManager.m
//  Clucks
//
//  Created by Ethan Nagel on 8/9/12.
//  Copyright (c) 2012 BitDonkey, LLC. All rights reserved.
//

#import "NTTableViewArrayUpdateManager.h"


//#define DEBUG_UPDATE_MANAGER


#ifdef DEBUG_UPDATE_MANAGER
#   define DBG(...)  NSLog(__VA_ARGS__)
#else
#   define DBG(...)
#endif

#define ERR(...)  NSLog(__VA_ARGS__)



@interface NTTableViewArrayUpdateManager () // private
{
    NSMutableArray  *mSnapshot;
}

@property (assign, readwrite, nonatomic)     BOOL             isUpdating;

@end


@interface NTTTableViewArraySnapshotItem : NSObject

@property (readwrite, retain, nonatomic)    id  itemId;
@property (readwrite, assign, nonatomic)    int itemHash;

@end


@implementation NTTTableViewArraySnapshotItem

@end


@implementation NTTableViewArrayUpdateManager


-(id)init
{
    if ( (self=[super init]) )
    {
        self.idKeyPath = nil;
        self.tableView = nil;
        self.items = nil;
        self.sectionIndex = 0;
        self.deleteAnimation = UITableViewRowAnimationAutomatic;
        self.updateAnimation = UITableViewRowAnimationAutomatic;
        self.insertAnimation = UITableViewRowAnimationAutomatic;
    }
    
    return self;
}


-(id)initWithIdKeyPath:(NSString *)idKeyPath tableView:(UITableView *)tableView sectionIndex:(int)sectionIndex items:(NSArray *)items
{
    if ( (self=[self init]) )
    {
        self.idKeyPath = idKeyPath;
        self.tableView = tableView;
        self.items = items;
        self.sectionIndex = sectionIndex;
    }
    
    return self;
}


-(id)getIdForItem:(id)item
{
    return (self.idKeyPath) ? [item valueForKeyPath:self.idKeyPath] : [NSNumber numberWithInteger:(int)item];
}


-(int)itemsCount
{
    return (self.items) ? self.items.count : 0;
}


-(void)beginUpdates
{
    self.isUpdating = YES;
    
    // create our snapshot...
    
    mSnapshot = [NSMutableArray arrayWithCapacity:[self itemsCount]];
    
    if ( [self itemsCount] > 0 )
    {
        for(id item in self.items)
        {
            NTTTableViewArraySnapshotItem *snapshotItem = [[NTTTableViewArraySnapshotItem alloc] init];
            
            snapshotItem.itemId = [self getIdForItem:item];
            snapshotItem.itemHash = [item hash];
            
            if ( !snapshotItem.itemId )
                snapshotItem.itemId = [NSNull null];
            
            [mSnapshot addObject:snapshotItem];
        }
    }
    
    // Tell the tableview we are doing updates...
    
    if ( !self.disableTableViewBeginEndUpdates )
        [self.tableView beginUpdates];
}


-(NSArray *)indexPathsForIndexSet:(NSIndexSet *)indexSet
{
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:indexSet.count];
    
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
    {
        [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:self.sectionIndex]];
    }];
    
    return indexPaths;
}


-(BOOL)validateDeletes:(NSIndexSet *)deletes updates:(NSIndexSet *)updates inserts:(NSIndexSet *)inserts
{
    int expectedCount = mSnapshot.count - deletes.count + inserts.count;
    
    if ( [self itemsCount]  != expectedCount )
    {
        ERR(@"ERROR: NTTableViewArrayUpdateManager failed: actual count = %d, expected: %d original - %d deletes + %d inserts = %d", [self itemsCount], mSnapshot.count, deletes.count, inserts.count, expectedCount);
        
        return NO;
    }
    
    return YES;
}


#ifdef DEBUG_UPDATE_MANAGER


-(void)dumpDeletes:(NSIndexSet *)deletes updates:(NSIndexSet *)updates inserts:(NSIndexSet *)inserts
{
    DBG(@"Action  |Original|New     |ID              ");
    DBG(@"--------|--------|--------|----------------");
    
    int snapshotIndex = 0;
    int index = 0;
    
    while ( snapshotIndex < mSnapshot.count || index < [self itemsCount] )
    {
        NSString *action = nil;
        BOOL snapshotUsed = NO;
        BOOL itemsUsed = NO;
        
        if ( [deletes containsIndex:snapshotIndex] )
        {
            action = @"Delete";
            snapshotUsed = YES;
        }
        
        else if ( [inserts containsIndex:index] )
        {
            action = @"Insert";
            itemsUsed = YES;
        }
        
        else if ( [updates containsIndex:index] )
        {
            action = @"Update";
            snapshotUsed = YES;
            itemsUsed = YES;
        }
        
        else
        {
            action = @"";
            snapshotUsed = YES;
            itemsUsed = YES;
        }
        
        NSString *idText = @"";
        NSString *originalText = @"";
        NSString *newText = @"";
        
        if ( snapshotUsed )
        {
            if ( snapshotIndex < mSnapshot.count )
            {
                NTTTableViewArraySnapshotItem *snapshotItem = [mSnapshot objectAtIndex:snapshotIndex];
                
                idText = [snapshotItem.itemId description];
                originalText = [NSString stringWithFormat:@"#%d", snapshotIndex];
                
                ++snapshotIndex;
            }
            else
                originalText = @"ERROR";
        }
        
        if ( itemsUsed )
        {
            if ( index < [self itemsCount] )
            {
                id item = [self.items objectAtIndex:index];
                id itemId = [self getIdForItem:item];
                
                idText = [itemId description];
                newText = [NSString stringWithFormat:@"#%d", index];
                
                ++index;
            }
            else
                newText = @"ERROR";
        }
        
        DBG(@"%-8s|%-8s|%-8s|%-16s", [action UTF8String], [originalText UTF8String], [newText UTF8String], [idText UTF8String]);
    }   
}


#endif


-(int)getInserts:(NSIndexSet **)retInserts deletes:(NSIndexSet **)retDeletes updates:(NSIndexSet **)retUpdates
{
    //  Create a lookup of all id's that were in the snapshot...
    
    NSMutableSet *snapshotIds = [NSMutableSet setWithCapacity:mSnapshot.count];
    
    for(NTTTableViewArraySnapshotItem *snapshotItem in mSnapshot)
        [snapshotIds addObject:snapshotItem.itemId];
    
    NSMutableSet *itemIds = [NSMutableSet setWithCapacity:[self itemsCount]];
    
    if ( [self itemsCount] > 0 )
    {
        for(id item in self.items)
        {
            id value = [self getIdForItem:item];
            
            if ( !value )
                value = [NSNull null];
            
            [itemIds addObject:value];
        }
    }
    
    // First, Figure out what deletes or updates will need to be done...
    
    NSMutableIndexSet *inserts = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *deletes = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *updates = [NSMutableIndexSet indexSet];
    
    int snapshotIndex = 0;
    
    for(int index=0; index<[self itemsCount]; index++)
    {
        id item = [self.items objectAtIndex:index];
        id itemId = [self getIdForItem:item];
        
        if ( !itemId )
            itemId = [NSNull null];
        
        //        DBG(@" --> index=%d, id=%@", index, itemId);
        
        if ( ![snapshotIds containsObject:itemId] )     // if it's not in our snapshot, it's an add, go ahead and track that...
        {
            DBG(@"insert: %d", index);
            [inserts addIndex:index];
            continue;   // all done!
        }
        
        int itemHash = [item hash];
        
        while( snapshotIndex < mSnapshot.count )
        {
            NTTTableViewArraySnapshotItem *snapshotItem = [mSnapshot objectAtIndex:snapshotIndex];
            //            DBG(@"     snapshotIndex=%d, id=%@", snapshotIndex, snapshotItem.itemId);
            
            if ( [snapshotItem.itemId isEqual:itemId] )        // ahh we have found the matching item.
            {
                // The id's match, let's see if the object hashes match...
                
                if ( snapshotItem.itemHash != itemHash )
                {
                    // if hashes don't match, then it must be an update...
                    DBG(@"update: %d", snapshotIndex);
                    
                    [updates addIndex:snapshotIndex];
                }
                
                ++snapshotIndex;
                break;
            }
            
            if ( [itemIds containsObject:snapshotItem.itemId] )
            {
                // If it's in both the old and new set, but not in the same order, just do a reload...
                DBG(@"update: %d (move)", snapshotIndex);
                [updates addIndex:snapshotIndex];
                ++snapshotIndex;
                
                break;
            }
            
            // the items don't match & not an update, track as a deletion...
            
            DBG(@"delete: %d", snapshotIndex);
            
            [deletes addIndex:snapshotIndex];
            
            [snapshotIds removeObject:snapshotItem.itemId];
            ++snapshotIndex;
        }
        
    }
    
    // If there are any remaining items in our snapshot, they must be deletes or possibly updates...
    
    while( snapshotIndex < mSnapshot.count )
    {
        NTTTableViewArraySnapshotItem *snapshotItem = [mSnapshot objectAtIndex:snapshotIndex];
        
        if ( [itemIds containsObject:snapshotItem.itemId] )
        {
            // If it's in both the old and new set, but not in the same order, just do a reload...
            DBG(@"update: %d (move)", snapshotIndex);
            [updates addIndex:snapshotIndex];
            ++snapshotIndex;
            
            break;
        }
        
        // the items don't match & not an update, track as a deletion...
        
        DBG(@"delete: %d", snapshotIndex);
        
        [deletes addIndex:snapshotIndex];
        
        [snapshotIds removeObject:snapshotItem.itemId];
        ++snapshotIndex;
    }
    
    if ( retInserts )
        *retInserts = inserts;
    
    if ( retDeletes )
        *retDeletes = deletes;
    
    if ( retUpdates )
        *retUpdates = updates;
    
    return (inserts.count + updates.count + deletes.count);
    
}


-(int)endUpdates
{
    
    NSIndexSet *inserts;
    NSIndexSet *deletes;
    NSIndexSet *updates;
    
    int numChanges = [self getInserts:&inserts deletes:&deletes updates:&updates];

#ifdef DEBUG_UPDATE_MANAGER
    [self dumpDeletes:deletes updates:updates inserts:inserts];
#endif

    // let's validate our results...
    
    if ( ![self validateDeletes:deletes updates:updates inserts:inserts] )
    {
        // Ok we failed to calcule the inserts/deletes correctly, let's just do a reload...
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:self.sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    else
    {
        // Now let's do the actual animations...
        
        [self.tableView deleteRowsAtIndexPaths:[self indexPathsForIndexSet:deletes] withRowAnimation:self.deleteAnimation];
        [self.tableView reloadRowsAtIndexPaths:[self indexPathsForIndexSet:updates] withRowAnimation:self.updateAnimation];
        [self.tableView insertRowsAtIndexPaths:[self indexPathsForIndexSet:inserts] withRowAnimation:self.insertAnimation];
    }

    if ( !self.disableTableViewBeginEndUpdates )
        [self.tableView endUpdates];
    
    self.isUpdating = NO;
    mSnapshot = nil;
    
    return numChanges;
}


@end
