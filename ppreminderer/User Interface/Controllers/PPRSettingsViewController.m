//
//  PPRSettingsViewController.m
//  ppreminderer
//
//  Created by David Bernard on 17/09/2014.
//  Copyright (c) 2014 Pegwing Pty Ltd. All rights reserved.
//

#import "PPRSettingsViewController.h"
#import "PPRShift.h"
#import "PPRScheduler.h"
#import "PPRActionManager.h"
#import "PPRShiftManager.h"
#import "PPRNotificationManager.h"
#import "PPRTestInitialiser.h"

@interface PPRSettingsViewController ()
-(IBAction)resetDefaultSettings:(id)sender;
-(IBAction)setScheduleTime:(id)sender ;
-(IBAction)warpFactorDidChange:(id)sender;
@property (nonatomic,weak) IBOutlet UIDatePicker *datePicker;
@property (nonatomic,weak) IBOutlet UISlider *warpFactor;
@property (nonatomic,weak) IBOutlet UILabel *warpFactorDisplay;
@property (nonatomic,strong) PPRShiftManager *shiftManager;
@property (nonatomic,strong) PPRScheduler *scheduler;

@end

@implementation PPRSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _scheduler = (PPRScheduler *)[PPRScheduler sharedInstance];
        _shiftManager = [PPRShiftManager sharedInstance];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scheduler = (PPRScheduler *)[PPRScheduler sharedInstance];
    [self.warpFactor setValue: self.scheduler.warpFactor];
    self.warpFactorDisplay.text = [NSString stringWithFormat:@"%2.0f", (double)self.scheduler.warpFactor];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)resetDefaultSettings:(id)sender {
    
    [PPRActionManager sharedInstance].actions = [[NSMutableDictionary alloc] init];
    
   
    PPRShift *shift = self.shiftManager.shift;
    shift.shiftStatus = [NSNumber numberWithInt:PPRShiftStatusOn];
    shift.available = [NSNumber numberWithBool:true];
    shift.facilityId = @"FAC1";
    [self.shiftManager publishShift:self.shiftManager.shift];

}

- (IBAction) setScheduleTime:(id)sender {
    NSDate *date = self.datePicker.date;
    self.scheduler.schedulerTime = date;
    self.scheduler.lastTickTime = [NSDate date];
    [self.scheduler saveState];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSchedulerTimeChangedNotificationName object:nil];
    
}

- (IBAction)warpFactorDidChange:(UISlider *)sender {
    self.scheduler.warpFactor = sender.value;
    self.warpFactorDisplay.text = [NSString stringWithFormat:@"%2.0f", (double)self.scheduler.warpFactor];
}

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
