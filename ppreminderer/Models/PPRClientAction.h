//
//  PPRClientAction.h
//  ppreminderer
//
//  Created by David Bernard on 9/09/2014.
//  Copyright (c) 2014 Pegwing Pty Ltd. All rights reserved.
//

#import "PPRAction.h"
#import "PPRClient.h"

@interface PPRClientAction : PPRAction
@property (nonatomic,strong) PPRClient *client;

-(id)initWithClient:(PPRClient *)client scheduledEvent:(PPRScheduledEvent *)scheduledEvent;
@end
