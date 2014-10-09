//
//  PPRScheduleViewController.m
//  ppreminderer
//
//  Created by David Bernard on 13/08/2014.
//  Copyright (c) 2014 Pegwing Pty Ltd. All rights reserved.
//

#import "PPRScheduleTableViewController.h"
#import "PPRActionViewController.h"
#import "PPRActionManager.h"
#import "PPRClientAction.h"
#import "PPRActionScheduler.h"
#import "PPRScheduler.h"
#import "PPRShiftManager.h"



NSString * const kDueKey =    @"Due";
NSString * const kActionKey = @"Action";
NSString * const kStatusKey = @"Status";
NSString * const kClientKey = @"Client";
NSString * const kIdKey =     @"Key";


// Note about the above:  'blank' is related to a 'Not done' state, perhaps for historical reasons only.

@interface PPRScheduleTableViewController ()

@end

@implementation PPRScheduleTableViewController{
    NSArray *_scheduleEntries;
    NSString *_currentActionID;
    PPRAction *_currentAction;
}

- (IBAction)tick:(UIStoryboardSegue *) sender
{
    NSDate *completionTime = ((PPRScheduler *)[PPRScheduler sharedInstance]).schedulerTime;
    [(PPRActionManager *)[PPRActionManager sharedInstance] updateAction: _currentActionID status: kStatusDone completionTime:completionTime
                                            success:^(PPRAction *action)            {[self.tableView reloadData];}
                                            failure:^(NSError * dummy) {}];
}

- (IBAction)cross:(UIStoryboardSegue *) sender
{
    [(PPRActionManager *)[PPRActionManager sharedInstance] updateStatusOf: _currentActionID to: kStatusBlank
                                            success:^(PPRAction *action)            {[self.tableView reloadData];}
                                            failure:^(NSError * dummy) {}];
}

- (IBAction)postpone:(UIStoryboardSegue *)sender
{
    NSDate *newDueTime = [(PPRActionScheduler *)[PPRActionScheduler sharedInstance] dueTimeForAction:_currentAction delayedBy:300.0 ];
    [(PPRActionManager *)[PPRActionManager sharedInstance]
     updateAction:_currentActionID
     status:kStatusPostponed
     dueTime:newDueTime
     
     success:^(PPRAction *action)
    {[self.tableView reloadData];}
     
     failure:^(NSError * dummy) {}];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *dest = [segue destinationViewController];
    if ([dest isKindOfClass:[PPRActionViewController class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        PPRAction *item = _scheduleEntries[indexPath.row];
        _currentActionID = item.actionId;
        _currentAction = item;
        [(PPRActionViewController *)dest setAction:_currentAction];
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadActions {
    PPRAction *actionFilter = [[PPRAction alloc]init];
    PPRFacility *facility = [[PPRFacility alloc] init];
    actionFilter.facility = facility;
    actionFilter.facility.facilityId =
    ((PPRShiftManager *)[PPRShiftManager sharedInstance]).shift.facilityId;
    
    [(PPRActionManager *)[PPRActionManager sharedInstance]
     getAction:actionFilter
     success:^(NSArray * actions) {
         _scheduleEntries = [actions sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        PPRAction *action1 = (PPRAction *)obj1;
        PPRAction *action2 = obj2;
        return [action1.dueTime compare: action2.dueTime ];
        
    }];
     }
     failure:^(NSError * dummy)   { } ];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserverForName:kShiftChangedNotificationName object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self loadActions];
        [self.tableView reloadData];
    }];

    [self loadActions];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_scheduleEntries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ActionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PPRAction *action = (PPRAction *)(_scheduleEntries[indexPath.row]);
    if ( [action isKindOfClass:[PPRAction class]]) {
        PPRAction *item = (PPRAction *)action;
        
        [cell.detailTextLabel setText:item.dueTimeDescription];
        
        if ([item.status isEqualToString:        kStatusDone]){
            [cell setBackgroundColor: [UIColor                          greenColor  ]];
        } else if ([item.status isEqualToString: kStatusPostponed]){
            [cell setBackgroundColor: [UIColor                          grayColor   ]];
        } else if ([item.status isEqualToString: kStatusBlank]){
            [cell setBackgroundColor: [UIColor                          whiteColor  ]];
        } else if ([item.status isEqualToString: kStatusNotified]){
            [cell setBackgroundColor: [UIColor                          redColor  ]];
        } else if ([item.status isEqualToString: kStatusScheduled]){
            [cell setBackgroundColor: [UIColor                          yellowColor  ]];
       }
    }
    if ( [action isKindOfClass:[PPRClientAction class]]) {
        PPRClientAction *item = (PPRClientAction *)action;
        NSString *label = [NSString stringWithFormat:@"%@ - %@", item.client.name, item.context];
        [cell.textLabel setText:label ];
    }
    else {
        [cell.textLabel setText:action.context];
        [cell.detailTextLabel setText:action.dueTimeDescription];
    }
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
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
