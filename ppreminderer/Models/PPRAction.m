//
//  PPRAction.m
//  ppreminderer
//
//  Created by David Bernard on 8/09/2014.
//  Copyright (c) 2014 Pegwing Pty Ltd. All rights reserved.
//

#import "PPRAction.h"

NSString * const kStatusScheduled = @"Scheduled";
NSString * const kStatusPostponed = @"Postponed";
NSString * const kStatusDue =       @"Due";
NSString * const kStatusCompleted = @"Completed";
NSString * const kStatusCompletedAway = @"CompletedAway";


@implementation PPRAction

-(id)initWithFacility:(PPRFacility *)facility scheduledEvent:(PPRScheduledEvent *)scheduledEvent parent:(PPRAction *)parent actions:(NSMutableArray *)actions
{
    self = [super init];
    if (self) {
        _facilityId = facility.facilityId;
        _facility = facility;
        _scheduledEvent = scheduledEvent;
        _parentId = parent.actionId;
        _actions = actions;
        _status = nil;
    }
    return self;
}

- (NSString *)notificationDescription {
    return [self dueTimeDescription];
}

-(BOOL) shouldGroup {
    const PPRScheduleTime *const t = self.scheduledEvent.scheduled;
    return t.type != PPRScheduleTimeTimeOfDay;
}

-(NSString *)dueTimeDescription {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    

    NSString *scheduleDescription = self.scheduledEvent.scheduled.description;
    NSDate *time;
    if ([self.status isEqualToString:kStatusCompleted] || [self.status isEqualToString:kStatusCompletedAway]) {
        time = self.completionTime;
    } else {
        time = self.dueTime;
        
    }
    NSString *dueTimeDescription = [dateFormatter stringFromDate:time];
    return [NSString stringWithFormat:@"%@ - %@", scheduleDescription, dueTimeDescription];
}

-(NSString *)rawTimeDescription {
    // Cheat and use code copied from the start of dueTimeDescription.  Then  remove the "At " from the start of the result to get what we want.  Please refactor.
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    NSString *fromDescription = self.scheduledEvent.scheduled.description;
    NSString const * assumedPrefix = @"At ";
    return [fromDescription substringFromIndex:[assumedPrefix length]];
}

- (NSArray *)instructionsForAction {
    return [[NSArray alloc]init];
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             
             
             };
}

- (NSString *)logTextForLabel {  // cf. textForLabel
    NSString *const r =
        [NSString stringWithFormat:@"%@", self.context];
    return r;
}

- (NSString *)textForLabel {
   NSString *const contextMaybeIndented = self.scheduledEvent.eventName; // Smaller indent for text rather than detail
   return contextMaybeIndented;
}

- (NSString *)textForDetail {
    // const BOOL sg = self.shouldGroup; // Groupedness once had an effect on the detail text;  maybe it will in future.
    NSString *const detailMaybeIndented = self.dueTimeDescription;
    return detailMaybeIndented;
}
+ (NSDictionary *)encodingBehaviorsByPropertyKey {
    return @{
             @"actionId": [NSNumber numberWithUnsignedInt:MTLModelEncodingBehaviorUnconditional],
             @"context": [NSNumber numberWithUnsignedInt:MTLModelEncodingBehaviorUnconditional],
             @"status": [NSNumber numberWithUnsignedInt:MTLModelEncodingBehaviorUnconditional],
             @"dueTime": [NSNumber numberWithUnsignedInt:MTLModelEncodingBehaviorUnconditional],
             @"completionTime": [NSNumber numberWithUnsignedInt:MTLModelEncodingBehaviorUnconditional],
             @"scheduledEvent": [NSNumber numberWithUnsignedInt:MTLModelEncodingBehaviorUnconditional],
             @"parentId": [NSNumber numberWithUnsignedInt:MTLModelEncodingBehaviorUnconditional],
             @"actions": [NSNumber numberWithUnsignedInt:MTLModelEncodingBehaviorExcluded],
             @"history": [NSNumber numberWithUnsignedInt:MTLModelEncodingBehaviorExcluded],
             @"facilityId": [NSNumber numberWithUnsignedInt:MTLModelEncodingBehaviorUnconditional],
             @"facility": [NSNumber numberWithUnsignedInt:MTLModelEncodingBehaviorExcluded]
             
             };
}

- (BOOL)isEquivalentTo:(PPRAction *)action {
    // Should match facility and schedule event
    BOOL equivalent =
        (action.facilityId == nil || [self.facilityId isEqualToString:action.facilityId]) &&
        (action.context == nil || [self.context isEqualToString:action.context]) &&
        (action.scheduledEvent == nil || [self.scheduledEvent isEquivalentTo:action.scheduledEvent]);
    return equivalent;
}

// Helpers for compareForSchedule.
BOOL isParentOf(const PPRAction *const p, const PPRAction *const c);
BOOL isChildOf( const PPRAction *const c, const PPRAction *const p);
NSComparisonResult inOrderOld(const PPRAction *const a, const PPRAction *const b);

const NSString *const ComparisonResultDescription(const NSComparisonResult r)
{
    switch (r) {
        case NSOrderedAscending:
            return @"NSOrderedAscending";
            break;
        case NSOrderedSame:
            return @"NSOrderedSame";
            break;
        default:
            assert(r == NSOrderedDescending);
            return @"NSOrderedDescending";
            break;
    }
    assert(NO); // notreached
}

-(NSComparisonResult)compareForSchedule:(PPRAction *)other{
    const PPRAction *const a = self;    // alias to avoid renames in code below, for now
    const PPRAction *const b = other;   // alias ditto
    NSComparisonResult r;
    if (isParentOf(a,b)) {
        r = NSOrderedAscending;
    } else {
        assert(!isParentOf(a,b));
        if(!isChildOf(a,b)) {
            r = inOrderOld(a, b);
        } else {
            assert(isChildOf(a,b));
            assert(isParentOf(b,a));
            r = NSOrderedDescending;
        }
    }
    const NSString *const aDescribed = a.actionId; // or - a.logTextForLabel;
    const NSString *const bDescribed = b.actionId; // or - b.logTextForLabel;
    const NSString *const rDescribed = ComparisonResultDescription(r);
    NSLog(@"%@ compareForSchedule: %@?  %@",aDescribed,bDescribed,rDescribed);
    return r;
}

// This is the first implementation of several helper functions for compareSchedule.
NSComparisonResult inOrderOld(const PPRAction *const a, const PPRAction *const b) {
    return [a.dueTime compare: b.dueTime];
}

BOOL isParentOf(const PPRAction *const a, const PPRAction *const b) {
    // a is parent of b; i.e. b's parent is a.
    BOOL r = (a == b.parent);
    NSLog(@"isParentOf(%@,%@) - maybe %@ ",a.actionId,b.actionId, r?@"YES":@"NO");
//    // Hack some results to come out right.
//    if ([a.actionId isEqualToString:@"ACT0"]) {
//        if ([b.actionId isEqualToString:@"ACT11"]) {
//            r = YES;
//        } else if ([b.actionId isEqualToString:@"ACT9"]){
//            r = YES;
//        }
//    } else if ([a.actionId isEqualToString:@"ACT1"]){
//        // to do check ACT8
//        if ([b.actionId isEqualToString:@"ACT8"]) {
//            r = YES;
//        }
//    } else if ([a.actionId isEqualToString:@"ACT2"]){
//        if ([b.actionId isEqualToString:@"ACT10"]) {
//            r = YES;
//        }
//    }
//    NSLog(@"possibly assumed stuff about test data");
    return r;
}

BOOL isChildOf(PPRAction *const a, PPRAction *const b) {
    return isParentOf(b,a);
}


@end
