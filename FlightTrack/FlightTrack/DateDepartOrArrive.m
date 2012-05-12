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

@end

@implementation DateDepartOrArrive
@synthesize kal;
@synthesize kalDataSource;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.kal.tableView.dataSource = self.kalDataSource;
    
    self.kal.delegate = self;
    self.kal.logic = [[[KalLogic alloc] initForDate:[NSDate date]] autorelease];
    
    [self.kal selectDate:[KalDate dateFromNSDate:[NSDate date]]];
}

- (void)showPreviousMonth
{
    [self.kalDataSource removeAllItems];
    [self.kal.logic retreatToPreviousMonth];
    
    [self.kal slideDown];
    
    [self.kalDataSource presentingDatesFrom:self.kal.logic.fromDate to:self.kal.logic.toDate delegate:nil];
}

- (void)showFollowingMonth
{
    [self.kalDataSource removeAllItems];
    [self.kal.logic advanceToFollowingMonth];
    
    [self.kal slideUp];
    
    [self.kalDataSource presentingDatesFrom:self.kal.logic.fromDate to:self.kal.logic.toDate delegate:nil];
}

- (void)didSelectDate:(KalDate *)date {
    
    NSDate *from = [[date NSDate] cc_dateByMovingToBeginningOfDay];
    NSDate *to = [[date NSDate] cc_dateByMovingToEndOfDay];
    
    [self.kalDataSource removeAllItems];
    
    [self.kalDataSource loadItemsFromDate:from toDate:to];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (void)dealloc {
    [kal release];
    [kalDataSource release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setKal:nil];
    [self setKalDataSource:nil];
    [super viewDidUnload];
}
@end
