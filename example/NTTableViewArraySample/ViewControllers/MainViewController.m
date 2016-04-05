//
//  MainViewController.m
//  NTTableViewArraySample
//
//  Created by Ethan Nagel on 8/10/12.
//  Copyright (c) 2012 Nagel Technologies, Inc. All rights reserved.
//

#import "MainViewController.h"

#import "NTTableViewArrayUpdateManager.h"


@interface MainViewController ()
{
    NTTableViewArrayUpdateManager *mUpdateManager;
    NSMutableArray                *mItems;
}

@end


@interface SampleItem : NSObject

@property (readwrite, retain, nonatomic)    NSString        *itemId;
@property (readwrite, retain, nonatomic)    NSString        *text;

-(NSUInteger)hash;

+(id)itemWithId:(NSString *)itemId text:(NSString *)text;

@end


@implementation SampleItem


+(id)itemWithId:(NSString *)itemId text:(NSString *)text
{
    SampleItem *item = [[SampleItem alloc] init];
    
    item.itemId = itemId;
    item.text = text;
    
    return item;
}


-(NSUInteger)hash
{
    return [self.itemId hash] ^ [self.text hash];
}

@end


@implementation MainViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)resetItems
{
    [mItems setArray:@[
     [SampleItem itemWithId:@"00" text:@"Zero"],
     [SampleItem itemWithId:@"01" text:@"One"],
     [SampleItem itemWithId:@"02" text:@"Two"],
     [SampleItem itemWithId:@"03" text:@"Three"],
     [SampleItem itemWithId:@"04" text:@"Four"],
     [SampleItem itemWithId:@"05" text:@"Five"],
     [SampleItem itemWithId:@"06" text:@"Six"],
     [SampleItem itemWithId:@"07" text:@"Seven"],
     [SampleItem itemWithId:@"08" text:@"Eight"],
     [SampleItem itemWithId:@"09" text:@"Nine"],
     [SampleItem itemWithId:@"10" text:@"Ten"],
     [SampleItem itemWithId:@"11" text:@"Eleven"],
     [SampleItem itemWithId:@"12" text:@"Twelve"],
     [SampleItem itemWithId:@"13" text:@"Thirteen"],
     [SampleItem itemWithId:@"14" text:@"Fourteen"],
     [SampleItem itemWithId:@"15" text:@"Fifteen"],
     [SampleItem itemWithId:@"16" text:@"Sixteen"],
     [SampleItem itemWithId:@"17" text:@"Seventeen"],
     [SampleItem itemWithId:@"18" text:@"Eighteen"],
     [SampleItem itemWithId:@"19" text:@"Nineteen"],
    ]];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mItems = [NSMutableArray array];
    
    [self resetItems];

    mUpdateManager = [[NTTableViewArrayUpdateManager alloc] initWithIdKeyPath:@"itemId" tableView:self.tableView sectionIndex:0 items:mItems];
    
    self.navigationItem.title = @"NTTableViewArray Sample";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStyleBordered target:self action:@selector(resetButtonSelected)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Test" style:UIBarButtonItemStyleBordered target:self action:@selector(testButtonSelected)];
}


-(void)resetButtonSelected
{
    [mUpdateManager beginUpdates];
    
    [self resetItems];
        
    [mUpdateManager endUpdates];
}


-(void)testButtonSelected
{
    [mUpdateManager beginUpdates];
    
    [mItems removeObjectAtIndex:2];
    [mItems removeObjectAtIndex:2];
    [mItems removeObjectAtIndex:2];
    
    SampleItem *item = [mItems objectAtIndex:7];
    item.text = [NSString stringWithFormat:@"%@,%@", item.text, item.text];
    
    [mItems insertObject:[SampleItem itemWithId:[NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]] text:@"New Item (At 5)"] atIndex:5];

/*
    [mItems exchangeObjectAtIndex:5 withObjectAtIndex:8];
    [mItems removeObjectAtIndex:0];
*/

    [mUpdateManager endUpdates];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return mItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ( !cell )
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    SampleItem *item = [mItems objectAtIndex:indexPath.row];
    
    cell.textLabel.text = item.itemId;
    cell.detailTextLabel.text = item.text;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
