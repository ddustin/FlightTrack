//
//  DateDepartOrArrive.m
//  FlightTrack
//
//  Created by Dustin Dettmer on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DateDepartOrArrive.h"
#import "KalLogic.h"
#import "KalDate.h"
#import "NSDateAdditions.h"

@interface DateDepartOrArrive ()

@property (retain, nonatomic) IBOutlet KalView *kal;
@property (retain, nonatomic) IBOutlet SimpleKalDataSource *kalDataSource;

@property (retain, nonatomic) IBOutlet UISegmentedControl *departOrArriveSegment;

@end

@implementation DateDepartOrArrive
@synthesize kal;
@synthesize kalDataSource;
@synthesize departOrArriveSegment;
@synthesize selectedDate;
@synthesize dateSearchRelation;

- (void)dealloc {
    [kal release];
    [kalDataSource release];
    self.selectedDate = nil;
    [departOrArriveSegment release];
    [super dealloc];
}

- (NSDate*)selectedDate {
    
    if(!selectedDate)
        selectedDate = [NSDate new];
    
    return selectedDate;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.kal.tableView.dataSource = self.kalDataSource;
    
    self.kal.delegate = self;
    self.kal.logic = [[[KalLogic alloc] initForDate:self.selectedDate] autorelease];
    
    [self.kal selectDate:[KalDate dateFromNSDate:self.selectedDate]];
    
    self.departOrArriveSegment.selectedSegmentIndex = self.dateSearchRelation;
}

- (IBAction)departOrArriveChange:(id)sender {
    
    self.dateSearchRelation = self.departOrArriveSegment.selectedSegmentIndex;
}

- (void)showPreviousMonth
{
    [self.kalDataSource removeAllItems];
    [self.kal.logic retreatToPreviousMonth];
    
    [self.kal slideDown];
    
    [self.kalDataSource presentingDatesFrom:self.kal.logic.fromDate
                                         to:self.kal.logic.toDate delegate:nil];
}

- (void)showFollowingMonth
{
    [self.kalDataSource removeAllItems];
    [self.kal.logic advanceToFollowingMonth];
    
    [self.kal slideUp];
    
    [self.kalDataSource presentingDatesFrom:self.kal.logic.fromDate
                                         to:self.kal.logic.toDate delegate:nil];
}

- (void)didSelectDate:(KalDate *)date {
    
    NSDate *from = [[date NSDate] cc_dateByMovingToBeginningOfDay];
    NSDate *to = [[date NSDate] cc_dateByMovingToEndOfDay];
    
    [self.kalDataSource removeAllItems];
    
    [self.kalDataSource loadItemsFromDate:from toDate:to];
    
    self.selectedDate = date.NSDate;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (void)viewDidUnload {
    [self setKal:nil];
    [self setKalDataSource:nil];
    [self setDepartOrArriveSegment:nil];
    [super viewDidUnload];
}
@end
