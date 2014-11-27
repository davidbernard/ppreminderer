//
//  PPRAction.m
//  ppreminderer
//
//  Created by David Bernard on 8/09/2014.
//  Copyright (c) 2014 Pegwing Pty Ltd. All rights reserved.
//

#import "PPRAction.h"
#import "PPRClientAction.h"

NSString * const kStatusScheduled = @"Scheduled";
NSString * const kStatusPostponed = @"Postponed";
NSString * const kStatusDue =       @"Due";
NSString * const kStatusCompleted = @"Completed";


@implementation PPRAction

-(id)initWithFacility:(PPRFacility *)facility scheduledEvent:(PPRScheduledEvent *)scheduledEvent parent:(PPRAction *)parent actions:(NSMutableArray *)actions
{
    self = [super init];
    if (self) {
        _facility = facility;
        _scheduledEvent = scheduledEvent;
        _parent = parent;
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
    if ([self.status isEqualToString:kStatusCompleted]) {
        time = self.completionTime;
    } else {
        time = self.dueTime;
        
    }
    NSString *dueTimeDescription = [dateFormatter stringFromDate:time];
//    NSLog(@"%s:scheduleDescription was %@",__func__,scheduleDescription);
    //NSLog(@"%s:dueTimeDescription  was %@",__func__,dueTimeDescription);
    return [NSString stringWithFormat:@"%@ - %@", scheduleDescription, dueTimeDescription];
}

- (NSArray *)instructionsForAction {
    return [[NSArray alloc]init];
}

- (NSString *)logTextForLabel {  // cf. textForLabel
    if([self isKindOfClass:[PPRClientAction class]]) {
        PPRClientAction *item = (PPRClientAction *)self;
        NSString *label = [NSString stringWithFormat:@"%@ - %@", item.client.name, item.context];
        return label;
    } else {
        NSString *const r =
            [NSString stringWithFormat:@"%@", self.context];
        return r;
    }
}

// For hacking grouping by adding spaces at the start of the textLabel and the detailTextLabel.
static const NSString *const ind0 = @"";
static const NSString *const ind4 = @"    ";
static const NSString *const ind8 = @"        ";

- (NSString *)textForLabel {
    if([self isKindOfClass:[PPRClientAction class]]) {
        PPRClientAction *item = (PPRClientAction *)self;
        NSString *label = [NSString stringWithFormat:@"%@ - %@", item.client.name, item.context];
        NSString *const labelMaybeIndented =
        [NSString stringWithFormat:@"%@%@",self.shouldGroup?ind4:ind0, label]; // Smaller indent for text rather than detail
        return labelMaybeIndented;
    } else {
        NSString *const contextMaybeIndented =
        [NSString stringWithFormat:@"%@%@",self.shouldGroup?ind4:ind0, self.context]; // Smaller indent for text rather than detail
        return contextMaybeIndented;
    }
}

- (NSString *)textForDetail {
    const BOOL sg = self.shouldGroup;
    NSString *const detailMaybeIndented =
        [NSString stringWithFormat:@"%@%@",sg?ind8:ind4, self.dueTimeDescription];
        // [NSString stringWithFormat:@"%@%@ [%@]",sg?ind8:ind4, self.dueTimeDescription, self.actionId];
    return detailMaybeIndented;
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
