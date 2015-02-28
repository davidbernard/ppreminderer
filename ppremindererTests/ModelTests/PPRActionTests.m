//
//  PPRActionTests.m
//  ppreminderer
//
//  Created by David Bernard on 2/10/2014.
//  Copyright (c) 2014 Pegwing Pty Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PPRAction.h"
#import "PPRScheduler.h"

@interface PPRActionTests : XCTestCase

@end

@implementation PPRActionTests

- (void)setUp
{
    [super setUp];
    // Ensure the the scheudler is initialised
    (void)[[PPRScheduler sharedInstance]init];
}

- (void)tearDown
{
    [super tearDown];
}

PPRScheduleTime * Nine15scheduleTime()
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc]init];
    dateComponents.hour = 9;
    dateComponents.minute = 15;
    
    return [[PPRScheduleTime alloc]initWithTimeOfDay:dateComponents
                                     ];
}

- (void)testNotificationDueTimeDescription
{

    
    PPRScheduleTime *scheduleTime = Nine15scheduleTime();
    PPRScheduledEvent *scheduledEvent =
    [[PPRScheduledEvent alloc]initWithEventName:@"TestEventName" scheduledTime:scheduleTime];
    PPRFacility *facility = [[PPRFacility alloc]init];
    
    PPRAction *action = [[PPRAction alloc ]initWithFacility:facility scheduledEvent:scheduledEvent parent:nil actions:nil];
    action.status = kStatusScheduled;
    
    NSDateComponents *dueDateComponents = [[NSDateComponents alloc]init];
    dueDateComponents.hour = 9;
    dueDateComponents.minute = 20;
    action.dueTime = [[NSCalendar currentCalendar] dateFromComponents:dueDateComponents];
    
    NSString *dueTimeDescription = [action dueTimeDescription];
    
    XCTAssertEqualObjects(dueTimeDescription, @"At 9:15 AM - 9:20:00 AM");
    
 
}

- (void)testNotificationRawTimeDescription
{
    
    
    PPRScheduleTime *scheduleTime = Nine15scheduleTime();
    PPRScheduledEvent *scheduledEvent =
    [[PPRScheduledEvent alloc]initWithEventName:@"TestEventName" scheduledTime:scheduleTime];
    PPRFacility *facility = [[PPRFacility alloc]init];
    
    PPRAction *action = [[PPRAction alloc ]initWithFacility:facility scheduledEvent:scheduledEvent parent:nil actions:nil];
    action.status = kStatusCompleted;
    
    NSDateComponents *dueDateComponents = [[NSDateComponents alloc]init];
    dueDateComponents.hour = 9;
    dueDateComponents.minute = 20;
    action.dueTime = [[NSCalendar currentCalendar] dateFromComponents:dueDateComponents];
    
    NSDateComponents *completionDateComponents = [[NSDateComponents alloc]init];
    completionDateComponents.hour = 9;
    completionDateComponents.minute = 21;
    action.completionTime = [[NSCalendar currentCalendar] dateFromComponents:completionDateComponents];

    NSString *t = [action rawTimeDescription];
    
    XCTAssertEqualObjects(t, @"9:15 AM");
    
    
}

- (void)testTextForDetail
{
    PPRScheduleTime *scheduleTime = Nine15scheduleTime();
    PPRScheduledEvent *scheduledEvent =
    [[PPRScheduledEvent alloc]initWithEventName:@"TestEventName" scheduledTime:scheduleTime];
    PPRFacility *facility = [[PPRFacility alloc]init];
    
    PPRAction *action = [[PPRAction alloc ]initWithFacility:facility scheduledEvent:scheduledEvent parent:nil actions:nil];
    action.status = kStatusCompleted;
    XCTAssertEqualObjects(action.textForDetail, @"At 9:15 AM - (null)");
}

- (void)testTextForLabel
{
    PPRScheduleTime *scheduleTime = Nine15scheduleTime();
    PPRScheduledEvent *scheduledEvent =
    [[PPRScheduledEvent alloc]initWithEventName:@"TestEventName" scheduledTime:scheduleTime];
    PPRFacility *facility = [[PPRFacility alloc]init];
    
    PPRAction *action = [[PPRAction alloc ]initWithFacility:facility scheduledEvent:scheduledEvent parent:nil actions:nil];
    action.status = kStatusCompleted;
    XCTAssertEqualObjects(action.textForLabel, @"TestEventName");
}

- (void)testTextForGroupedLabel
{
    PPRScheduleTime *scheduleTime = Nine15scheduleTime();
    PPRScheduledEvent *scheduledEvent =
    [[PPRScheduledEvent alloc]initWithEventName:@"TestEventName" scheduledTime:scheduleTime];
    PPRFacility *facility = [[PPRFacility alloc]init];
    
    PPRAction *action = [[PPRAction alloc ]initWithFacility:facility scheduledEvent:scheduledEvent parent:nil actions:nil];
    action.status = kStatusCompleted;
    NSDateComponents * offset5min = [[NSDateComponents alloc] init];
    offset5min.minute = 5;
    PPRScheduleTime *childScheduleTime = [[PPRScheduleTime alloc] initWithType:PPRScheduleTimeRelativeToStartOfParent dailyEvent:@"TestEventName" offset:offset5min];
    PPRScheduledEvent *childScheduledEvent =
    [[PPRScheduledEvent alloc]initWithEventName:@"ChildTestEventName" scheduledTime:childScheduleTime];
    const PPRAction *const childAction = [[PPRAction alloc] initWithFacility:facility scheduledEvent:childScheduledEvent parent:action actions:nil];
    const BOOL startsWithSpace = [childAction.textForLabel hasPrefix:@" "];
    XCTAssert(!startsWithSpace,  @"label shouldn't start with space, for child action with typical name");
}

- (void)testNotificationDueTimeDescription_MAYBE_MISTAKEN_COPY
{
    
    
    PPRScheduleTime *scheduleTime = Nine15scheduleTime();
    PPRScheduledEvent *scheduledEvent =
    [[PPRScheduledEvent alloc]initWithEventName:@"TestEventName" scheduledTime:scheduleTime];
    PPRFacility *facility = [[PPRFacility alloc]init];
    
    PPRAction *action = [[PPRAction alloc ]initWithFacility:facility scheduledEvent:scheduledEvent parent:nil actions:nil];
    action.status = kStatusScheduled;
    
    NSDateComponents *dueDateComponents = [[NSDateComponents alloc]init];
    dueDateComponents.hour = 9;
    dueDateComponents.minute = 20;
    action.dueTime = [[NSCalendar currentCalendar] dateFromComponents:dueDateComponents];
    
    NSString *dueTimeDescription = [action dueTimeDescription];
    
    XCTAssertEqualObjects(dueTimeDescription, @"At 9:15 AM - 9:20:00 AM");
    
    
}



@end
