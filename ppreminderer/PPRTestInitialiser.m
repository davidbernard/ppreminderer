//
//  PPRTestInitialiser.m
//  ppreminderer
//
//  Created by David Bernard on 9/09/2014.
//  Renamed by David Vincent on 17/10/14.
//  Copyright (c) 2014 Pegwing Pty Ltd. All rights reserved.
//

#import "PPRTestInitialiser.h"

static PPRFacility * createTestFacility1() {
    
    // Facility 1
    PPRFacility *facility1 = [[PPRFacility alloc] initWithName:@"Group Home 1" address:@"1 Smith Street Somewhere"];
    NSDateComponents *eightOclock = [[NSDateComponents alloc] init];
    eightOclock.hour = 8;
    eightOclock.minute = 0;
    NSDateComponents *twelveThirty = [[NSDateComponents alloc] init];
    twelveThirty.hour = 12;
    twelveThirty.minute = 30;
    
    NSDateComponents *sixThirty = [[NSDateComponents alloc] init];
    sixThirty.hour = 18;
    sixThirty.minute = 30;
    NSDateComponents *ninePm = [[NSDateComponents alloc] init];
    ninePm.hour = 21;
    ninePm.minute = 0;
    NSMutableArray *events1 =
    [NSMutableArray arrayWithObjects:
     [[PPRScheduledEvent alloc] initWithEventName:@"Breakfast"
                                    scheduledTime: [[PPRScheduleTime alloc] initWithTimeOfDay:eightOclock]],
     [[PPRScheduledEvent alloc] initWithEventName:@"Lunch"
                                    scheduledTime: [[PPRScheduleTime alloc] initWithTimeOfDay:twelveThirty]],
     [[PPRScheduledEvent alloc] initWithEventName:@"Dinner"
                                    scheduledTime: [[PPRScheduleTime alloc] initWithTimeOfDay:sixThirty]],
     [[PPRScheduledEvent alloc] initWithEventName:@"Bed"
                                    scheduledTime: [[PPRScheduleTime alloc] initWithTimeOfDay:ninePm]],
     nil];
    facility1.events = events1;
    NSMutableArray *instructions1 =
    [NSMutableArray arrayWithObjects:
     [[PPRFacilityInstruction alloc]initWithContext:@"Breakfast"
                                        instruction:@"At outside table if warm"],
     nil
     ];
    facility1.instructions = instructions1;
    return facility1;
}

static PPRFacility *createTestFacility2()
{
    // Facility 2
    PPRFacility *facility2 = [[PPRFacility alloc] initWithName:@"Group Home 2" address:@"2 Jones Street Somewhereelse"];
    NSDateComponents *sevenThirty = [[NSDateComponents alloc] init];
    sevenThirty.hour = 7;
    sevenThirty.minute = 30;
    NSDateComponents *twelveOclock = [[NSDateComponents alloc] init];
    twelveOclock.hour = 12;
    twelveOclock.minute = 0;
    
    NSDateComponents *sixThirty = [[NSDateComponents alloc] init];
    sixThirty.hour = 18;
    sixThirty.minute = 30;
    NSDateComponents *ninePm = [[NSDateComponents alloc] init];
    ninePm.hour = 21;
    ninePm.minute = 0;
    NSMutableArray *events2 =
    [NSMutableArray arrayWithObjects:
     [[PPRScheduledEvent alloc] initWithEventName:@"Breakfast"
                                    scheduledTime: [[PPRScheduleTime alloc] initWithTimeOfDay:sevenThirty]],
     [[PPRScheduledEvent alloc] initWithEventName:@"Lunch"
                                    scheduledTime: [[PPRScheduleTime alloc] initWithTimeOfDay:twelveOclock]],
     [[PPRScheduledEvent alloc] initWithEventName:@"Dinner"
                                    scheduledTime: [[PPRScheduleTime alloc] initWithTimeOfDay:sixThirty]],
     [[PPRScheduledEvent alloc] initWithEventName:@"Bed"
                                    scheduledTime: [[PPRScheduleTime alloc] initWithTimeOfDay:ninePm]],
     nil];
    facility2.events = events2;
    return facility2;
}

static PPRFacility *createTestFacility3()
{
    // Facility 3
    PPRFacility *facility = [[PPRFacility alloc] initWithName:@"Group Home 3" address:@"Mascot"];
    NSDateComponents *seven45 = [[NSDateComponents alloc] init];
    seven45.hour = 7;
    seven45.minute = 45;
    NSDateComponents *twelve15 = [[NSDateComponents alloc] init];
    twelve15.hour = 12;
    twelve15.minute = 15;
    
    NSDateComponents *six15 = [[NSDateComponents alloc] init];
    six15.hour = 18;
    six15.minute = 15;
    NSMutableArray *events =
    [NSMutableArray arrayWithObjects:
     [[PPRScheduledEvent alloc] initWithEventName:@"Breakfast"
                                    scheduledTime: [[PPRScheduleTime alloc] initWithTimeOfDay:seven45]],
     [[PPRScheduledEvent alloc] initWithEventName:@"Lunch"
                                    scheduledTime: [[PPRScheduleTime alloc] initWithTimeOfDay:twelve15]],
     [[PPRScheduledEvent alloc] initWithEventName:@"Dinner"
                                    scheduledTime: [[PPRScheduleTime alloc] initWithTimeOfDay:six15]],
     nil];
    facility.events = events;
    return facility;
}

static PPRClient *createTestClient1(PPRFacility *facility1)
{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSDateComponents *nowComponents;
    NSDate *birthDate;
    
    nowComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:now];
    nowComponents.year -= 67;
    nowComponents.month -= 1;
    nowComponents.day += 4;
    
    birthDate = [calendar dateFromComponents:nowComponents];
    PPRClient *client1 = [[PPRClient alloc] initWithName:@"Dave Smith" birthDate:birthDate];
    
    
    NSMutableArray *notes1 = [NSMutableArray arrayWithObjects:
                              @"Dave has parkinson and cannot take pills using his hands",
                              @"Dave has schizophenia", nil
                              ];
    
    NSMutableArray *instructions1 =
    [NSMutableArray arrayWithObjects:
     [[PPRClientInstruction alloc]initWithContext:@"Pills"
                                      instruction:@"Taken on desert spoon"],
     [[PPRClientInstruction alloc]initWithContext:@"Communication"
                                      instruction:@"Nonverbal but has signing"],
     [[PPRClientInstruction alloc]initWithContext:@"Medication"
                                      instruction:@"Usually compliant taking medication"],
     nil
     ];
    client1.notes = notes1;
    client1.instructions = instructions1;
    client1.facility = facility1;
    
    // Pills 30 minutes before lunch
    NSDateComponents *offset1 = [[NSDateComponents alloc] init];
    offset1.day = 0;
    offset1.minute  = -30;
    offset1.hour = 0;
    PPRScheduleTime *scheduleTime1 =
    [[PPRScheduleTime alloc] initWithDailyEvent:@"Lunch" offset:offset1];
    PPRClientScheduleItem *item1 =
    [[PPRClientScheduleItem alloc] initWithContext:@"Pills" eventName:@"Pills" scheduledTime:scheduleTime1];
    [client1.scheduleItems addObject:item1];
    
    
    // Pills at breakfast
    NSDateComponents *offset2 = [[NSDateComponents alloc] init];
    offset2.day = 0;
    offset2.hour = 0;
    offset2.minute = 0;
    PPRScheduleTime *scheduleTime2 =
    [[PPRScheduleTime alloc] initWithDailyEvent:@"Breakfast" offset:offset2];
    PPRClientScheduleItem *item2 =
    [[PPRClientScheduleItem alloc] initWithContext:@"Pills" eventName:@"Pills" scheduledTime:scheduleTime2];
    [client1.scheduleItems addObject:item2];
    return client1;
}


static PPRClient *createTestClient2(PPRFacility *facility1)
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSDateComponents *nowComponents;
    NSDate *birthDate;
    
    nowComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:now];
    nowComponents.year -= 42;
    nowComponents.month += 4;
    nowComponents.day -= 5;
    
    birthDate = [calendar dateFromComponents:nowComponents];
    PPRClient *client2 = [[PPRClient alloc] initWithName:@"Julie Jones" birthDate:birthDate];
    
    NSMutableArray *notes2 = [NSMutableArray arrayWithObjects:
                              @"Julie has down's syndrom",
                              @"Julie has schizophenia",
                              @"In good health ",
                              @"If resistant to medication check if she belives the medication poisoned",
                              @"Try (I, mother) have check medication",
                              nil
                              ];
    
    NSMutableArray *instructions2 =
    [NSMutableArray arrayWithObjects:
     [[PPRClientInstruction alloc]initWithContext:@"Food" instruction:@"Delusional - people poising her food"],
     [[PPRClientInstruction alloc]initWithContext:@"Pills" instruction:@"On hand"],
     [[PPRClientInstruction alloc]initWithContext:@"Communications" instruction:@"Verbal and can make her wants and needs known"],
     [[PPRClientInstruction alloc]initWithContext:@"Medication" instruction:@"Can be non-compliant"],
     [[PPRClientInstruction alloc]initWithContext:@"Medication" instruction:@"If resistant check if she believes medication poisoned - see notes"],
     nil
     ];
    
    
    client2.notes = notes2;
    client2.instructions = instructions2;
    client2.facility = facility1;
    
    // Pills 10 minutes before dinner
    NSDateComponents *offset1 = [[NSDateComponents alloc] init];
    offset1.minute  = -10;
    offset1.day = 0;
    offset1.hour = 0;
    PPRScheduleTime *scheduleTime1 =
    [[PPRScheduleTime alloc] initWithDailyEvent:@"Dinner" offset:offset1];
    PPRClientScheduleItem *item1 =
    [[PPRClientScheduleItem alloc] initWithContext:@"Pills" eventName:@"Pills" scheduledTime:scheduleTime1];
    [client2.scheduleItems addObject:item1];
    
    
    // Pills at breakfast
    NSDateComponents *offset2 = [[NSDateComponents alloc] init];
    offset2.day = 0;
    offset2.hour = 0;
    offset2.minute = 0;
    PPRScheduleTime *scheduleTime2 =
    [[PPRScheduleTime alloc] initWithDailyEvent:@"Breakfast" offset:offset2];
    PPRClientScheduleItem *item2 =
    [[PPRClientScheduleItem alloc] initWithContext:@"Pills" eventName:@"Pills" scheduledTime:scheduleTime2];
    [client2.scheduleItems addObject:item2];
    
    return client2;
}

static PPRClient *createTestClient3(PPRFacility *facility2)
{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSDateComponents *nowComponents;
    NSDate *birthDate;
    
    nowComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:now];
    nowComponents.year -= 42;
    nowComponents.month += 4;
    nowComponents.day -= 5;
    
    
    birthDate = [calendar dateFromComponents:nowComponents];
    PPRClient *client3 = [[PPRClient alloc] initWithName:@"Stevie Thompson" birthDate:birthDate];
    
    NSMutableArray *notes3 = [NSMutableArray arrayWithObjects:
                              @"Stevie has cerebal palsy and mild intellectual disability",
                              @"Epilepsy mild and well controlled",
                              @"Seizures 1 per year",
                              @"In good health ",
                              nil
                              ];
    
    NSMutableArray *instructions3 =
    [NSMutableArray arrayWithObjects:
     [[PPRClientInstruction alloc]initWithContext:@"Food" instruction:@"PEG fed"],
     [[PPRClientInstruction alloc]initWithContext:@"Medication" instruction:@"Visiting Nurse"],
     [[PPRClientInstruction alloc]initWithContext:@"Communications" instruction:@"Nonverbal uses ipad with good receptive language"],
     [[PPRClientInstruction alloc]initWithContext:@"Bed" instruction:@"Can go to bed with feed connected but uncoomfortable"],
     [[PPRClientInstruction alloc]initWithContext:@"medication" instruction:@"If resistant check if she believes medication poisoned - see notes"],
     nil
     ];
    
    client3.notes = notes3;
    client3.instructions = instructions3;
    client3.facility = facility2;
    
    // Medication - visiting nurse at 8am
    NSDateComponents *offset1 = [[NSDateComponents alloc] init];
    offset1.hour  = 8;
    offset1.day = 0;
    offset1.minute = 0;
    PPRScheduleTime *scheduleTime1 =
    [[PPRScheduleTime alloc] initWithTimeOfDay:offset1];
    PPRClientScheduleItem *item1 =
    [[PPRClientScheduleItem alloc] initWithContext:@"Medication" eventName:@"Visiting Nurse" scheduledTime:scheduleTime1];
    [client3.scheduleItems addObject:item1];
    
    // Medication - visiting nurse 4pm
    NSDateComponents *offset2 = [[NSDateComponents alloc] init];
    offset2.hour  = 16;
    offset2.day = 0;
    offset2.minute = 0;
    PPRScheduleTime *scheduleTime2 =
    [[PPRScheduleTime alloc] initWithTimeOfDay:offset2];
    PPRClientScheduleItem *item2 =
    [[PPRClientScheduleItem alloc] initWithContext:@"Medication" eventName:@"Visiting Nurse" scheduledTime:scheduleTime2];
    [client3.scheduleItems addObject:item2];
    
    return client3;
    
}

// Con
static PPRClient *createTestClient4(PPRFacility *facility)
{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSDateComponents *nowComponents;
    NSDate *birthDate;
    
    nowComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:now];
    nowComponents.year -= 59;
    nowComponents.month += 0;
    nowComponents.day -= 0;
    
    
    birthDate = [calendar dateFromComponents:nowComponents];
    PPRClient *client = [[PPRClient alloc] initWithName:@"Con" birthDate:birthDate];
    
    NSMutableArray *notes = [NSMutableArray arrayWithObjects:
                             @"Notes about Con",
                             nil
                             ];
    
    NSMutableArray *instructions =
    [NSMutableArray arrayWithObjects:
     [[PPRClientInstruction alloc]initWithContext:@"Pills" instruction:@"On desert spoon"],
     [[PPRClientInstruction alloc]initWithContext:@"Toilet" instruction:@"Needs to be woken up to go to the toilet at night"],
     nil
     ];
    
    client.notes = notes;
    client.instructions = instructions;
    client.facility = facility;
    
    
    NSDateComponents *offset1 = [[NSDateComponents alloc] init];
    offset1.minute  = 0;
    offset1.day = 0;
    offset1.hour = 0;
    PPRScheduleTime *scheduleTime1 =
    [[PPRScheduleTime alloc] initWithDailyEvent:@"Breakfast" offset:offset1];
    PPRClientScheduleItem *item1 =
    [[PPRClientScheduleItem alloc] initWithContext:@"Pills" eventName:@"Pills" scheduledTime:scheduleTime1];
    [client.scheduleItems addObject:item1];
    
    NSDateComponents *offset2 = [[NSDateComponents alloc] init];
    offset2.minute  = 0;
    offset2.day = 0;
    offset2.hour = 0;
    PPRScheduleTime *scheduleTime2 =
    [[PPRScheduleTime alloc] initWithDailyEvent:@"Dinner" offset:offset2];
    PPRClientScheduleItem *item2 =
    [[PPRClientScheduleItem alloc] initWithContext:@"Pills" eventName:@"Pills" scheduledTime:scheduleTime2];
    [client.scheduleItems addObject:item2];
    
    
    // Toilet at night
    NSDateComponents *offset3 = [[NSDateComponents alloc] init];
    offset3.hour  = 2;
    offset3.day = 0;
    offset3.minute = 0;
    PPRScheduleTime *scheduleTime3 =
    [[PPRScheduleTime alloc] initWithTimeOfDay:offset3];
    PPRClientScheduleItem *item3 =
    [[PPRClientScheduleItem alloc] initWithContext:@"Toilet" eventName:@"Toilet" scheduledTime:scheduleTime3];
    [client.scheduleItems addObject:item3];
    
    
    return client;
    
}

// Robert
static PPRClient *createTestClient5(PPRFacility *facility)
{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSDateComponents *nowComponents;
    NSDate *birthDate;
    
    nowComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:now];
    nowComponents.year -= 74;
    nowComponents.month += 0;
    nowComponents.day -= 0;
    
    
    birthDate = [calendar dateFromComponents:nowComponents];
    PPRClient *client = [[PPRClient alloc] initWithName:@"Robert" birthDate:birthDate];
    
    NSMutableArray *notes = [NSMutableArray arrayWithObjects:
                             @"Notes about Robert",
                             nil
                             ];
    
    NSMutableArray *instructions =
    [NSMutableArray arrayWithObjects:
     [[PPRClientInstruction alloc]initWithContext:@"Pills" instruction:@"On hand with water"],
     [[PPRClientInstruction alloc]initWithContext:@"Pads" instruction:@"Need change of pad at night"],
     [[PPRClientInstruction alloc]initWithContext:@"Pads" instruction:@"Pads in bedroom"],
     nil
     ];
    
    client.notes = notes;
    client.instructions = instructions;
    client.facility = facility;
    
    
    NSDateComponents *offset1 = [[NSDateComponents alloc] init];
    offset1.minute  = 0;
    offset1.day = 0;
    offset1.hour = 0;
    PPRScheduleTime *scheduleTime1 =
    [[PPRScheduleTime alloc] initWithDailyEvent:@"Breakfast" offset:offset1];
    PPRClientScheduleItem *item1 =
    [[PPRClientScheduleItem alloc] initWithContext:@"Pills" eventName:@"Pills" scheduledTime:scheduleTime1];
    [client.scheduleItems addObject:item1];
    
    NSDateComponents *offset2 = [[NSDateComponents alloc] init];
    offset2.minute  = 0;
    offset2.day = 0;
    offset2.hour = 0;
    PPRScheduleTime *scheduleTime2 =
    [[PPRScheduleTime alloc] initWithDailyEvent:@"Dinner" offset:offset2];
    PPRClientScheduleItem *item2 =
    [[PPRClientScheduleItem alloc] initWithContext:@"Pills" eventName:@"Pills" scheduledTime:scheduleTime2];
    [client.scheduleItems addObject:item2];
    
    
    // Pad at night
    NSDateComponents *offset3 = [[NSDateComponents alloc] init];
    offset3.day = 0;
    offset3.hour  = 22;
    offset3.minute = 30;
    PPRScheduleTime *scheduleTime3 =
    [[PPRScheduleTime alloc] initWithTimeOfDay:offset3];
    PPRClientScheduleItem *item3 =
    [[PPRClientScheduleItem alloc] initWithContext:@"Pad" eventName:@"Pad Change" scheduledTime:scheduleTime3];
    [client.scheduleItems addObject:item3];
    
    // Pad at night
    NSDateComponents *offset4 = [[NSDateComponents alloc] init];
    offset4.day = 0;
    offset4.hour  = 2;
    offset4.minute = 0;
    PPRScheduleTime *scheduleTime4 =
    [[PPRScheduleTime alloc] initWithTimeOfDay:offset4];
    PPRClientScheduleItem *item4 =
    [[PPRClientScheduleItem alloc] initWithContext:@"Pad" eventName:@"Pad Change" scheduledTime:scheduleTime4];
    [client.scheduleItems addObject:item4];
    
    
    return client;
    
}

// Renata
static PPRClient *createTestClient6(PPRFacility *facility)
{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSDateComponents *nowComponents;
    NSDate *birthDate;
    
    nowComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:now];
    nowComponents.year -= 56;
    nowComponents.month += 0;
    nowComponents.day -= 0;
    
    
    birthDate = [calendar dateFromComponents:nowComponents];
    PPRClient *client = [[PPRClient alloc] initWithName:@"Renata" birthDate:birthDate];
    
    NSMutableArray *notes = [NSMutableArray arrayWithObjects:
                             @"Notes about Renata",
                             nil
                             ];
    
    NSMutableArray *instructions =
    [NSMutableArray arrayWithObjects:
     [[PPRClientInstruction alloc]initWithContext:@"Pills" instruction:@"Handed to her in blue pill bob"],
     [[PPRClientInstruction alloc]initWithContext:@"Pills" instruction:@"Must be observed"],
     nil
     ];
    
    client.notes = notes;
    client.instructions = instructions;
    client.facility = facility;
    
    
    NSDateComponents *offset1 = [[NSDateComponents alloc] init];
    offset1.minute  = 0;
    offset1.day = 0;
    offset1.hour = 0;
    PPRScheduleTime *scheduleTime1 =
    [[PPRScheduleTime alloc] initWithDailyEvent:@"Breakfast" offset:offset1];
    PPRClientScheduleItem *item1 =
    [[PPRClientScheduleItem alloc] initWithContext:@"Pills" eventName:@"Pills" scheduledTime:scheduleTime1];
    [client.scheduleItems addObject:item1];
    
    NSDateComponents *offset2 = [[NSDateComponents alloc] init];
    offset2.minute  = 0;
    offset2.day = 0;
    offset2.hour = 0;
    PPRScheduleTime *scheduleTime2 =
    [[PPRScheduleTime alloc] initWithDailyEvent:@"Dinner" offset:offset2];
    PPRClientScheduleItem *item2 =
    [[PPRClientScheduleItem alloc] initWithContext:@"Pills" eventName:@"Pills" scheduledTime:scheduleTime2];
    [client.scheduleItems addObject:item2];
    
    
    return client;
    
}

// Tom
static PPRClient *createTestClient7(PPRFacility *facility)
{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSDateComponents *nowComponents;
    NSDate *birthDate;
    
    nowComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:now];
    nowComponents.year -= 42;
    nowComponents.month += 4;
    nowComponents.day -= 5;
    
    
    birthDate = [calendar dateFromComponents:nowComponents];
    PPRClient *client = [[PPRClient alloc] initWithName:@"Tom" birthDate:birthDate];
    
    NSMutableArray *notes3 = [NSMutableArray arrayWithObjects:
                              @"Notes about Tom",
                              nil
                              ];
    
    NSMutableArray *instructions3 =
    [NSMutableArray arrayWithObjects:
     [[PPRClientInstruction alloc]initWithContext:@"Feed" instruction:@"PEG fed"],
     [[PPRClientInstruction alloc]initWithContext:@"Medication" instruction:@"Visiting Nurse"],
     [[PPRClientInstruction alloc]initWithContext:@"Medication" instruction:@"Through JPEG tube"],
     nil
     ];
    
    client.notes = notes3;
    client.instructions = instructions3;
    client.facility = facility;
    
    // Medication - visiting nurse at 8am
    NSDateComponents *offset1 = [[NSDateComponents alloc] init];
    offset1.day = 0;
    offset1.hour  = 7;
    offset1.minute = 30;
    PPRScheduleTime *scheduleTime1 =
    [[PPRScheduleTime alloc] initWithTimeOfDay:offset1];
    PPRClientScheduleItem *item1 =
    [[PPRClientScheduleItem alloc] initWithContext:@"Shower" eventName:@"Shower" scheduledTime:scheduleTime1];
    [client.scheduleItems addObject:item1];
    
    // Medication - visiting nurse 830
    NSDateComponents *offset2 = [[NSDateComponents alloc] init];
    offset2.day = 0;
    offset2.hour  = 8;
    offset2.minute = 30;
    PPRScheduleTime *scheduleTime2 =
    [[PPRScheduleTime alloc] initWithTimeOfDay:offset2];
    PPRClientScheduleItem *item2 =
    [[PPRClientScheduleItem alloc] initWithContext:@"Medication" eventName:@"Visiting Nurse" scheduledTime:scheduleTime2];
    [client.scheduleItems addObject:item2];
    
    // Medication - visiting nurse 4pm
    NSDateComponents *offset3 = [[NSDateComponents alloc] init];
    offset3.hour  = 17;
    offset3.day = 0;
    offset3.minute = 0;
    PPRScheduleTime *scheduleTime3 =
    [[PPRScheduleTime alloc] initWithTimeOfDay:offset3];
    PPRClientScheduleItem *item3 =
    [[PPRClientScheduleItem alloc] initWithContext:@"Medication" eventName:@"Visiting Nurse" scheduledTime:scheduleTime3];
    [client.scheduleItems addObject:item3];
    
    // Feed - Start Feed
    NSDateComponents *offset4 = [[NSDateComponents alloc] init];
    offset4.hour  = 8;
    offset4.day = 0;
    offset4.minute = 0;
    PPRScheduleTime *scheduleTime4 =
    [[PPRScheduleTime alloc] initWithTimeOfDay:offset4];
    PPRClientScheduleItem *item4 =
    [[PPRClientScheduleItem alloc] initWithContext:@"Feed" eventName:@"Start Feed" scheduledTime:scheduleTime4];
    [client.scheduleItems addObject:item4];
    
    // Feed - Flush
    NSDateComponents *offset5 = [[NSDateComponents alloc] init];
    offset5.hour  = 10;
    offset5.day = 0;
    offset5.minute = 0;
    PPRScheduleTime *scheduleTime5 =
    [[PPRScheduleTime alloc] initWithTimeOfDay:offset5];
    PPRClientScheduleItem *item5 =
    [[PPRClientScheduleItem alloc] initWithContext:@"Feed" eventName:@"Flush" scheduledTime:scheduleTime5];
    [client.scheduleItems addObject:item5];
    
    // Feed - Flush
    NSDateComponents *offset6 = [[NSDateComponents alloc] init];
    offset6.hour  = 12;
    offset6.day = 0;
    offset6.minute = 0;
    PPRScheduleTime *scheduleTime6 =
    [[PPRScheduleTime alloc] initWithTimeOfDay:offset6];
    PPRClientScheduleItem *item6 =
    [[PPRClientScheduleItem alloc] initWithContext:@"Feed" eventName:@"Flush" scheduledTime:scheduleTime6];
    [client.scheduleItems addObject:item6];
    
    // Feed - Flush
    NSDateComponents *offset7 = [[NSDateComponents alloc] init];
    offset7.hour  = 14;
    offset7.day = 0;
    offset7.minute = 0;
    PPRScheduleTime *scheduleTime7 =
    [[PPRScheduleTime alloc] initWithTimeOfDay:offset7];
    PPRClientScheduleItem *item7 =
    [[PPRClientScheduleItem alloc] initWithContext:@"Feed" eventName:@"Flush" scheduledTime:scheduleTime7];
    [client.scheduleItems addObject:item7];
    
    // Feed - Flush
    NSDateComponents *offset8 = [[NSDateComponents alloc] init];
    offset8.hour  = 16;
    offset8.day = 0;
    offset8.minute = 0;
    PPRScheduleTime *scheduleTime8 =
    [[PPRScheduleTime alloc] initWithTimeOfDay:offset8];
    PPRClientScheduleItem *item8 =
    [[PPRClientScheduleItem alloc] initWithContext:@"Feed" eventName:@"Flush" scheduledTime:scheduleTime8];
    [client.scheduleItems addObject:item8];
    
    // Feed - Flush
    NSDateComponents *offset9 = [[NSDateComponents alloc] init];
    offset9.hour  = 18;
    offset9.day = 0;
    offset9.minute = 0;
    PPRScheduleTime *scheduleTime9 =
    [[PPRScheduleTime alloc] initWithTimeOfDay:offset9];
    PPRClientScheduleItem *item9 =
    [[PPRClientScheduleItem alloc] initWithContext:@"Feed" eventName:@"Flush" scheduledTime:scheduleTime9];
    [client.scheduleItems addObject:item9];
    
    // Feed - Flush
    NSDateComponents *offset10 = [[NSDateComponents alloc] init];
    offset10.hour  = 20;
    offset10.day = 30;
    offset10.minute = 0;
    PPRScheduleTime *scheduleTime10 =
    [[PPRScheduleTime alloc] initWithTimeOfDay:offset10];
    PPRClientScheduleItem *item10 =
    [[PPRClientScheduleItem alloc] initWithContext:@"Feed" eventName:@"Feed Off and Flush" scheduledTime:scheduleTime10];
    [client.scheduleItems addObject:item10];
    
    // Feed - Flush
    NSDateComponents *offset11 = [[NSDateComponents alloc] init];
    offset11.hour  = 22;
    offset11.day = 0;
    offset11.minute = 0;
    PPRScheduleTime *scheduleTime11 =
    [[PPRScheduleTime alloc] initWithTimeOfDay:offset11];
    PPRClientScheduleItem *item11 =
    [[PPRClientScheduleItem alloc] initWithContext:@"Feed" eventName:@"Flush" scheduledTime:scheduleTime11];
    [client.scheduleItems addObject:item11];
    
    
    // Feed - Flush
    NSDateComponents *offset12 = [[NSDateComponents alloc] init];
    offset12.hour  = 0;
    offset12.day = 0;
    offset12.minute = 0;
    PPRScheduleTime *scheduleTime12 =
    [[PPRScheduleTime alloc] initWithTimeOfDay:offset12];
    PPRClientScheduleItem *item12 =
    [[PPRClientScheduleItem alloc] initWithContext:@"Feed" eventName:@"Flush" scheduledTime:scheduleTime12];
    [client.scheduleItems addObject:item12];
    
    
    return client;
    
}

// Bruce
static PPRClient *createTestClient8(PPRFacility *facility)
{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSDateComponents *nowComponents;
    NSDate *birthDate;
    
    nowComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:now];
    nowComponents.year -= 67;
    nowComponents.month += 0;
    nowComponents.day -= 0;
    
    
    birthDate = [calendar dateFromComponents:nowComponents];
    PPRClient *client = [[PPRClient alloc] initWithName:@"Bruce" birthDate:birthDate];
    
    NSMutableArray *notes3 = [NSMutableArray arrayWithObjects:
                              @"Retired and independent",
                              nil
                              ];
    
    NSMutableArray *instructions3 =
    [NSMutableArray arrayWithObjects:
     [[PPRClientInstruction alloc]initWithContext:@"Meals" instruction:@"Eats by self"],
     [[PPRClientInstruction alloc]initWithContext:@"Meals" instruction:@"May get own lunch at store"],
     [[PPRClientInstruction alloc]initWithContext:@"Pills" instruction:@"Self administers from webster"],
     [[PPRClientInstruction alloc]initWithContext:@"Pills" instruction:@"When he wakes up"],
     nil
     ];
    
    client.notes = notes3;
    client.instructions = instructions3;
    client.facility = facility;
    
    // Pills at 9am
    NSDateComponents *offset1 = [[NSDateComponents alloc] init];
    offset1.hour  = 9;
    offset1.day = 0;
    offset1.minute = 0;
    PPRScheduleTime *scheduleTime1 =
    [[PPRScheduleTime alloc] initWithTimeOfDay:offset1];
    PPRClientScheduleItem *item1 =
    [[PPRClientScheduleItem alloc] initWithContext:@"Pills" eventName:@"Pills" scheduledTime:scheduleTime1];
    [client.scheduleItems addObject:item1];
    
    // Dinner at 8pm
    NSDateComponents *offset2 = [[NSDateComponents alloc] init];
    offset2.day = 0;
    offset2.hour  = 20;
    offset2.minute = 00;
    PPRScheduleTime *scheduleTime2 =
    [[PPRScheduleTime alloc] initWithTimeOfDay:offset2];
    PPRClientScheduleItem *item2 =
    [[PPRClientScheduleItem alloc] initWithContext:@"Meals" eventName:@"Dinner" scheduledTime:scheduleTime2];
    [client.scheduleItems addObject:item2];
    
    // Pills at 8pm
    NSDateComponents *offset3 = [[NSDateComponents alloc] init];
    offset3.hour  = 20;
    offset3.day = 0;
    offset3.minute = 0;
    PPRScheduleTime *scheduleTime3 =
    [[PPRScheduleTime alloc] initWithTimeOfDay:offset3];
    PPRClientScheduleItem *item3 =
    [[PPRClientScheduleItem alloc] initWithContext:@"Pills" eventName:@"Pills" scheduledTime:scheduleTime3];
    [client.scheduleItems addObject:item3];
    
    return client;
    
}


@implementation PPRTestInitialiser
- (PPRTestInitialiser *) init {
    
    self = [super init];
    if (self) {
        
        _dataStore = [[PPRDataStore sharedInstance]init];
        _facilityManager = [[PPRFacilityManager sharedInstance] init];
        _clientManager = [[PPRClientManager sharedInstance] init];
        _actionManager = [[PPRActionManager sharedInstance] init];
        
        _shiftManager = [[PPRShiftManager sharedInstance] init];
        _scheduler = [[PPRScheduler sharedInstance]init];
        _clientActionScheduler =[[PPRClientActionScheduler sharedInstance]init];
        _facilityActionScheduler =[[PPRFacilityActionScheduler sharedInstance]
  initWithScheduler:_scheduler actionManager:_actionManager clientActionScheduler:_clientActionScheduler];
        _actionScheduler = [[PPRActionScheduler sharedInstance]init];
        
        // Load test clients and facilities
        [self loadTestData];
        
        // Load stored actions
        [_actionManager loadActions];

        // Schedule actions
        [self loadSchedule];
    }
    return self;
}

- (void)loadTestData {
    
    [self.shiftManager loadShift];
    
    self.facility1 = createTestFacility1();
    
    [self.facilityManager insertFacility:self.facility1 success:
     ^{
     } failure:^(NSError *error) {
         NSLog(@"Error saving facility 1");
     }];
    
    self.facility2 = createTestFacility2();
    
    [self.facilityManager insertFacility:self.facility2 success:
     ^{
     } failure:^(NSError *error) {
         NSLog(@"Error saving facility 2");
     }];
    
    self.facility3 = createTestFacility3();

    [self.facilityManager insertFacility:self.facility3 success:
     ^{
     } failure:^(NSError *error) {
         NSLog(@"Error saving facility 3");
     }];

    self.client1 = createTestClient1(self.facility1);
    [self.clientManager insertClient:self.client1 success:^(PPRClient *client){
        {}
    } failure:^(NSError *error) {
        NSLog(@"Error saving client 1");
    }];
    
    self.client2 = createTestClient2(self.facility1);
    [self.clientManager insertClient:self.client2 success:^(PPRClient *client){
        {}
    } failure:^(NSError *error) {
        NSLog(@"Error saving client 2");
    }];
    
    self.client3 = createTestClient3(self.facility2);
    [self.clientManager insertClient:self.client3 success:^(PPRClient *client){
        {}
    } failure:^(NSError *error) {
        NSLog(@"Error saving client 3");
    }];

    self.client4 = createTestClient4(self.facility3);
    [self.clientManager insertClient:self.client4 success:^(PPRClient *client){
        {}
    } failure:^(NSError *error) {
        NSLog(@"Error saving client 4");
    }];

    self.client5 = createTestClient5(self.facility3);
    [self.clientManager insertClient:self.client5 success:^(PPRClient *client){
        {}
    } failure:^(NSError *error) {
        NSLog(@"Error saving client 5");
    }];
    
    self.client6 = createTestClient6(self.facility3);
    [self.clientManager insertClient:self.client6 success:^(PPRClient *client){
        {}
    } failure:^(NSError *error) {
        NSLog(@"Error saving client 6");
    }];
    self.client7 = createTestClient7(self.facility3);
    [self.clientManager insertClient:self.client7 success:^(PPRClient *client){
        {}
    } failure:^(NSError *error) {
        NSLog(@"Error saving client 7");
    }];

    self.client8 = createTestClient8(self.facility3);
    [self.clientManager insertClient:self.client8 success:^(PPRClient *client){
        {}
    } failure:^(NSError *error) {
        NSLog(@"Error saving client 8");
    }];

}
- (void) loadSchedule
{

    // FIXME what does this mean
    self.notificationManager.notifications = [[NSMutableArray alloc] init];
    
    [self.facilityActionScheduler scheduleEventsForFacility:self.facility1];
    [self.facilityActionScheduler scheduleEventsForFacility:self.facility2];
    [self.facilityActionScheduler scheduleEventsForFacility:self.facility3];
    
}
@end
