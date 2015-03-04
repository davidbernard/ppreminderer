//
//  PPRClientActionScheduler.m
//  ppreminderer
//
//  Created by David Bernard on 23/09/2014.
//  Copyright (c) 2014 Pegwing Pty Ltd. All rights reserved.
//

#import "PPRClientActionScheduler.h"
#import "PPRClientAction.h"

@implementation PPRClientActionScheduler

- (void)scheduleEventsForClient:(PPRClient *)client forParentAction:(PPRAction*)parent {
    [client.scheduleItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PPRScheduledEvent * event = (PPRClientScheduleItem *)obj;
        if ((parent != nil &&
            event.scheduled.type == PPRScheduleTimeRelativeToDailyEvent
             && [event.scheduled.atDailyEvent isEqualToString: parent.scheduledEvent.eventName])
             || (parent == nil && event.scheduled.type !=PPRScheduleTimeRelativeToDailyEvent)) {
            PPRClientAction *action = [[PPRClientAction alloc] init];
            action.scheduledEvent = event;
            action.context = event.eventName;
            action.client = client;
            action.facility = client.facility;
            action.clientId = client.clientId;
            action.facilityId = client.facility.facilityId;
            action.parent = parent;

            [self.actionManager getAction:action success:^(NSArray *actions) {
                if ( actions.count == 0) {

                    action.dueTime = [self.scheduler dueTimeForScheduleTime:event.scheduled parentDueTime:nil previousDueTime:nil events:client.facility.events];
                    action.status = kStatusScheduled;
                    
                    [self.actionManager insertAction:action success:^(PPRAction *action) {
                        // FIXME
                        NSLog(@"Inserted action");
                    } failure:^(NSError *error) {
                        NSLog(@"Failure to insert action");
                    }];
                }
            } failure:^(NSError *error) {
                    NSLog(@"Error searching for equivalent action");
                    
            }];
                
        }
    }];
}


    

@end
