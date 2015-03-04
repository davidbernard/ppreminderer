//
//  PPRAction.h
//  ppreminderer
//
//  Created by David Bernard on 8/09/2014.
//  Copyright (c) 2014 Pegwing Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPRClientScheduleItem.h"
#import "PPRFacility.h"
#import "Mantle.h"

@interface PPRAction : MTLModel <MTLJSONSerializing>
@property (nonatomic,strong) NSString *actionId;
@property (nonatomic,strong) NSString *context;
@property (nonatomic,strong) NSString *status;
@property (nonatomic,strong) NSDate *dueTime;
@property (nonatomic,strong) NSDate *completionTime;
@property (nonatomic,strong) PPRScheduledEvent *scheduledEvent;
@property (nonatomic,weak) PPRAction *parent;
@property (nonatomic,strong) NSString *parentId;
@property (nonatomic,strong) NSMutableArray *actions;
@property (nonatomic,strong) NSMutableArray *history;
@property (nonatomic,strong) NSString *facilityId;
@property (nonatomic, strong) PPRFacility *facility;

-(id)initWithFacility:(PPRFacility *)facility scheduledEvent:(PPRScheduledEvent *)scheduledEvent parent:(PPRAction *)parent actions:(NSMutableArray *)actions;

-(NSString *)dueTimeDescription;

-(NSString *)rawTimeDescription;

-(NSString *)notificationDescription;

-(NSArray *)instructionsForAction;

/**
 Whether this action is equivalent to another
 @param action Action to check for equivalence
 @return true if equvalent, otherwise false;
 */
- (BOOL)isEquivalentTo:(PPRAction *)action;
-(NSString *)textForLabel;

-(NSString *)logTextForLabel;

-(NSString *)textForDetail;

-(NSComparisonResult)compareForSchedule:(PPRAction *)other;

-(BOOL)shouldGroup;

@end
