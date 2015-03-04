//
//  PPRActionManager.m
//  ppreminderer
//
//  Created by David A Vincent on 22/08/2014.
//  Copyright (c) 2014 Pegwing Pty Ltd. All rights reserved.
//

#import "PPRActionManager.h"

NSString *const  kActionDirectory = @"Actions";



NSString *const kActionStateChangedNotificationName = @"ActionStateChangedNotification";


@implementation PPRActionManager

- (id) init {
    self = [super init];
    if (self) {
        _actions = [[NSMutableDictionary alloc] init];
        _dataStore = [PPRDataStore sharedInstance];
        [_dataStore createPrivateDocsDirFor:kActionDirectory];
    }
    return self;
}

- (void) loadActions {
    NSArray *actions = [_dataStore loadObjectsFromDirectory:kActionDirectory];
    for (id object in actions) {
        // Check type
        PPRAction *action = (PPRAction *)object;
        
        _actions[action.actionId] = action;
    }
}

- (void) getAction: (PPRAction *)prototype success: (void(^)(NSArray *))success failure: (void(^)(NSError *)) failure {
    if ( prototype == nil) {
        success(self.actions.allValues);
        
    } else {
        if (prototype.actionId != nil){
            
            PPRAction *foundAction = self.actions[prototype.actionId];
            if (foundAction)
                success([NSArray arrayWithObject:foundAction]);
            else
                failure([NSError errorWithDomain:@"ActionManager" code:1 userInfo:nil]);
        }
        else  {
            NSSet *actionSet = [self.actions keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
                return  [(PPRAction *)obj isEquivalentTo:prototype];
            }];
            success([self.actions objectsForKeys:[actionSet allObjects] notFoundMarker:[[PPRAction alloc] init]]);
        }
        
        
    }
}

- (void) getActionById: (NSString *)actionId success: (void(^)(PPRAction *))success failure: (void(^)(NSError *)) failure {
    
    PPRAction *foundAction = self.actions[actionId];
    if (foundAction)
        success(foundAction);
    else
        failure([NSError errorWithDomain:@"ActionManager" code:1 userInfo:nil]);
    
}

- (void) updateStatusOf: (NSString *) actionID
                     to: (NSString *) newStatus
                success: (void(^)(PPRAction *action)) success
                failure: (void(^)(NSError *)) failure
{
    PPRAction *action = self.actions[actionID];
    [self updateAction:action status:newStatus dueTime:action.dueTime completionTime:action.completionTime success:success failure:failure];
}

- (void) updateAction: (NSString *) actionID
               status: (NSString *) newStatus
              dueTime: (NSDate *)dueTime
              success: (void(^)(PPRAction *action)) success
              failure: (void(^)(NSError *)) failure
{
    PPRAction *action = self.actions[actionID];
    [self updateAction:action status:newStatus dueTime:dueTime completionTime:action.completionTime success:success failure:failure];
}

- (void) updateAction: (NSString *) actionID
               status: (NSString *) newStatus
              completionTime:(NSDate *)completionTime
              success: (void(^)(PPRAction *action)) success
              failure: (void(^)(NSError *)) failure
{
    PPRAction *action = self.actions[actionID];
    [self updateAction:action status:newStatus dueTime:action.dueTime completionTime:completionTime success:success failure:failure];
}

- (void) updateAction: (PPRAction *) action
               status: (NSString *) newStatus
              dueTime: (NSDate *)dueTime
       completionTime:(NSDate *)completionTime
              success: (void(^)(PPRAction *action)) success
              failure: (void(^)(NSError *)) failure
{
    action.dueTime = dueTime;
    action.completionTime = completionTime;
    action.status = newStatus;
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kActionStateChangedNotificationName object:nil userInfo:@{@"ActionId":action.actionId}];
    [self.dataStore saveObject:action objectId:action.actionId directory:kActionDirectory];
    success(action);
}
- (void)insertAction:(PPRAction *)action
             success:(void (^)(PPRAction *))success
             failure:(void (^)(NSError *))failure {
    
    
    NSString *actionId = [@"ACT-" stringByAppendingString:
                          [[NSUUID UUID] UUIDString]];
    action.actionId = actionId;
    self.actions[actionId] = action;
    [self.dataStore saveObject:action objectId:action.actionId directory:kActionDirectory];
    success(action);
}


@end
