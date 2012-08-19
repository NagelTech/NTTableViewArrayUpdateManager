//
//  NTTableViewArrayUpdateManager.h
//  Clucks
//
//  Created by Ethan Nagel on 8/9/12.
//  Copyright (c) 2012 BitDonkey, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NTTableViewArrayUpdateManager : NSObject

@property (retain, readwrite, nonatomic)    NSString                *idKeyPath;
@property (retain, readwrite, nonatomic)    UITableView             *tableView;
@property (retain, readwrite, nonatomic)    NSArray                 *items;
@property (assign, readwrite, nonatomic)    int                      sectionIndex;
@property (assign, readwrite, nonatomic)    UITableViewRowAnimation  deleteAnimation;
@property (assign, readwrite, nonatomic)    UITableViewRowAnimation  updateAnimation;
@property (assign, readwrite, nonatomic)    UITableViewRowAnimation  insertAnimation;

@property (assign, readonly, nonatomic)     BOOL                     isUpdating;

-(id)init;
-(id)initWithIdKeyPath:(NSString *)idKeyPath tableView:(UITableView *)tableView sectionIndex:(int)sectionIndex items:(NSArray *)items;

-(int)getInserts:(NSIndexSet **)inserts deletes:(NSIndexSet **)deletes updates:(NSIndexSet **)updates;

-(void)beginUpdates;
-(int)endUpdates;
                                 
@end
