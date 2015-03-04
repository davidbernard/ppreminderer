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



// Note about the above:  'blank' is related to a 'Not done' state, perhaps for historical reasons only.

@interface PPRScheduleTableViewController ()

@end

@implementation PPRScheduleTableViewController{
    NSArray *_scheduleSections;
    NSString *_currentActionID;
    PPRAction *_currentAction;
}

- (IBAction)tick:(UIStoryboardSegue *) sender
{
    // If not done then update to done and record completion time
    if (![_currentAction.status isEqualToString:kStatusCompleted] && ![_currentAction.status isEqualToString:kStatusCompletedAway]) {
        NSDate *completionTime = ((PPRScheduler *)[PPRScheduler sharedInstance]).schedulerTime;
        [[PPRActionManager sharedInstance] updateAction: _currentActionID
                                                                     status: kStatusCompleted completionTime:completionTime
                                                                    success:^(PPRAction *action)            {
                                                                        [self loadActions];
                                                                        [self.tableView reloadData]
                                                                        ;}
                                                                    failure:^(NSError * dummy) {
                                                                        // TODO error handling
                                                                    }];
    }
}


- (IBAction)cross:(UIStoryboardSegue *) sender
{
    // if done then "Undo" done
    if ([_currentAction.status isEqualToString:kStatusCompleted] || [_currentAction.status isEqualToString:kStatusCompletedAway]) {
        [[PPRActionManager sharedInstance] updateStatusOf: _currentActionID to: kStatusScheduled
                                                                      success:^(PPRAction *action)            {
                                                                          [self loadActions];
                                                                          [self.tableView reloadData];}
                                                                      failure:^(NSError * dummy) {
                                                                      // TODO error handling
                                                                      }];
    }
}

- (IBAction)postpone:(UIStoryboardSegue *)sender
{
    NSDate *newDueTime = [[PPRActionScheduler sharedInstance] dueTimeForAction:_currentAction
                                                                                           delayedBy:300.0
                          ];
    [[PPRActionManager sharedInstance] updateAction:_currentActionID
     status:kStatusPostponed
     dueTime:newDueTime
     success:^(PPRAction *action)
     {
         [self loadActions];
         [self.tableView reloadData];
     }
     
     failure:^(NSError * dummy) {}];
}

- (IBAction)away:(UIStoryboardSegue *)sender
{
    // If not done then update to done and record completion time
    if (![_currentAction.status isEqualToString:kStatusCompleted] && ![_currentAction.status isEqualToString:kStatusCompletedAway] ) {
        NSDate *completionTime = ((PPRScheduler *)[PPRScheduler sharedInstance]).schedulerTime;
        [[PPRActionManager sharedInstance] updateAction: _currentActionID
                                                 status: kStatusCompletedAway completionTime:completionTime
                                                success:^(PPRAction *action)            {
                                                    [self loadActions];
                                                    [self.tableView reloadData]
                                                    ;}
                                                failure:^(NSError * dummy) {
                                                    // TODO error handling
                                                }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *dest = [segue destinationViewController];
    if ([dest isKindOfClass:[PPRActionViewController class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        PPRAction *item = _scheduleSections[indexPath.section][indexPath.row];
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

// Construct the sections for the table view controller from a 'scheduleEntries' array of PPRActions.  This is an array that has been sorted a particular way - see the compareForSchedule comparator and the loadActions method.
NSArray* sectionsFrom(const NSArray *const schedEntries)
{
    const NSInteger N = [schedEntries count];
    NSInteger i = 0; // current schedule entry index
    NSMutableArray * sections = [[NSMutableArray alloc] init];
    const BOOL oneItemPerSection = NO;
    if (!oneItemPerSection) {
        BOOL last_asg = NO; // Last value of asg (see below), if any;  otherwise NO.
        while (i < N) {
            PPRAction * a = (PPRAction *) schedEntries[i];
            const BOOL asg = [a shouldGroup];
            if (i+1 == N) {
                // at the last entry
                if (last_asg && (!asg)) {
                    [sections addObject:[[NSMutableArray alloc] init]];
                }
            } else {
                // a is not the last entry;  look at the following entry
                PPRAction * b = (PPRAction *) schedEntries[i+1];
                const BOOL bsg = [b shouldGroup];
                if (asg) {
                    // a should be grouped, in a section that started before a; no need for a new one
                } else if (last_asg && (!asg)) {
                    // previous a was in a group, current isn't; so start a new top level section
                    [sections addObject:[[NSMutableArray alloc] init]];
                } else if ((!asg) && (!bsg)) {
                    // a & b both at the 'top level'; no need for a new one
                } else if ((!asg) && bsg) {
                    // a shouldn't be grouped with previous, but followed by something that should be grouped with it
                    [sections addObject:[[NSMutableArray alloc] init]];
                } else {
                    assert(NO); // shouldn't be reached
                }
            }
            if ([sections count] == 0) {
                // We don't have any section yet.  But we have an item that must go into a section.  This can happen when the first two items are both not to be grouped.
                [sections addObject:[[NSMutableArray alloc] init]];
            }
            NSInteger csi; // current section index
            csi = [sections count] - 1;
            [sections[csi] addObject:a];
            ++ i;
            last_asg = asg;
        }
    } else {
        assert(oneItemPerSection);
        for (PPRAction *item in schedEntries) {
            NSArray * thisSection = [[NSArray alloc] initWithObjects: item, nil];
            [sections addObject:thisSection];
        }
    }
    return [[NSArray alloc] initWithArray:sections];
}

- (void)loadActions {
    PPRAction *actionFilter = [[PPRAction alloc]init];
    actionFilter.facilityId =[PPRShiftManager sharedInstance].shift.facilityId;
    
    [(PPRActionManager *)[PPRActionManager sharedInstance]
     getAction:actionFilter
     success:^(NSArray * actions) {
         NSArray *_scheduleEntries = [actions sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
             PPRAction *action1 = (PPRAction *)obj1;
             PPRAction *action2 = obj2;
             return [action1 compareForSchedule: action2];
             
         }];
         _scheduleSections = sectionsFrom(_scheduleEntries);
     }
     failure:^(NSError * dummy)   { } ];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserverForName:kShiftChangedNotificationName
                                                      object:nil queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
        [self loadActions];
        [self.tableView reloadData];
    }];

    [[NSNotificationCenter defaultCenter] addObserverForName:kScheduleChangedNotificationName
                                                      object:nil queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
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
    return [_scheduleSections count];
}

// Decide whether the section looks like one that starts with a parent action.
BOOL hasParent(const NSArray *const section)
{
    const NSInteger N = [section count];
    if (0 == N) {
        return NO;
    } else if (1 == N) {
        return NO; // Not checking whether it is a section with something that counts as a parent, but with no children.
    } else {
        assert(2 <= N);
        // PPRAction * firstAction = (PPRAction*) section[0];
        PPRAction * secondAction = (PPRAction*) section[1];
        return [secondAction shouldGroup];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)sectionNo {
    const NSInteger N = [_scheduleSections count];
    if (0 == N) {
        return @"(section with no entries!)"; // degenerate case - I'm not even sure this is possible
    } else if (1 == N) {
        return nil;             // If only one section in table, don't have a title.
    } else {
        assert(1 < N);
        const NSArray *const section = _scheduleSections;
        PPRAction * firstAction = (PPRAction*) section[sectionNo][0]; // 1st action important in describing section
        if (hasParent(section[sectionNo])) {
            return [NSString stringWithFormat:@"Around %@", [firstAction context]];
        } else {
            return [NSString stringWithFormat:@"From %@", [firstAction rawTimeDescription]];
        }
        // maybe not reached
        return @"(section title under construction)";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_scheduleSections[section] count];
}

UIColor * colorForStatus(PPRAction *item) {
    

if ([item.status isEqualToString:        kStatusCompleted] ) {
    return [UIColor                          greenColor  ];
} else if ([item.status isEqualToString: kStatusCompletedAway]){
    return [UIColor                           cyanColor  ];
} else if ([item.status isEqualToString: kStatusPostponed]){
    return[ UIColor                          orangeColor   ];
} else if ([item.status isEqualToString: kStatusScheduled]){
    if ( [item.dueTime compare:[PPRScheduler sharedInstance].schedulerTime] == NSOrderedAscending)
        return  [UIColor                            redColor];
    else
        return [UIColor                          yellowColor  ];
}
    return [UIColor clearColor];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    PPRAction *action = (PPRAction *) ( _scheduleSections[indexPath.section][indexPath.row]);
    if ( [action isKindOfClass:[PPRAction class]]) {
        PPRAction *item = (PPRAction *)action;
        [cell setBackgroundColor:colorForStatus(item)];
        cell.indentationLevel = action.shouldGroup      ? 1 : 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ActionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PPRAction *action = (PPRAction *) ( _scheduleSections[indexPath.section][indexPath.row]);
    if ( [action isKindOfClass:[PPRAction class]]) {
        PPRAction *item = (PPRAction *)action;
        
        [cell.detailTextLabel setText:item.textForDetail];
        
        
    }
    [cell.textLabel setText: action.textForLabel];
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
