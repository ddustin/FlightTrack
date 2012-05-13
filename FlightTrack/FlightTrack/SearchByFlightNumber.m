//
//  SearchByFlightNumber.m
//  FlightTrack
//
//  Created by Dustin Dettmer on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchByFlightNumber.h"

@interface SearchByFlightNumber ()

@property (retain, nonatomic) IBOutlet UILabel *departsOrArrivesLbl;
@property (retain, nonatomic) IBOutlet UITextField *dateText;
@property (retain, nonatomic) IBOutlet UITextField *flightNumberText;
@property (retain, nonatomic) IBOutlet UITextField *airlineText;

@property (nonatomic, retain) NSDate *searchDate;

@property (nonatomic, assign) enum DateSearchRelation departOrArrive;

@end

@implementation SearchByFlightNumber
@synthesize departsOrArrivesLbl;
@synthesize dateText;
@synthesize flightNumberText;
@synthesize airlineText;
@synthesize searchDate,departOrArrive;

- (void)dealloc {
    
    self.searchDate = nil;
    
    [departsOrArrivesLbl release];
    [dateText release];
    [flightNumberText release];
    [airlineText release];
    [super dealloc];
}

- (IBAction)resignResponderStatus:(UIView*)sender {
    
    [sender resignFirstResponder];
}

- (IBAction)cancel:(id)sender {
    
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)dateDepartOrArriveCanceled:(DateDepartOrArrive *)instance {
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)updateViews {
    
    if(self.departOrArrive == DateSearchRelationDepart)
        self.departsOrArrivesLbl.text = @"Departs";
    else
        self.departsOrArrivesLbl.text = @"Arrives";
    
    if(self.searchDate) {
        
        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
        
        [fmt setDateFormat:@"EEE, MMM d"];
        
        self.dateText.text = [fmt stringFromDate:self.searchDate];
        
        [fmt release];
    }
}

- (void)dateDepartOrArriveDone:(DateDepartOrArrive *)instance {
    
    self.searchDate = instance.selectedDate;
    self.departOrArrive = instance.dateSearchRelation;
    
    [self dismissModalViewControllerAnimated:YES];
    
    [self updateViews];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateViews];
}

- (void)viewDidUnload
{
    [self setDepartsOrArrivesLbl:nil];
    [self setDateText:nil];
    [self setFlightNumberText:nil];
    [self setAirlineText:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqual:@"dateDepartsOrArrives"]) {
        
        DateDepartOrArrive *controller = segue.destinationViewController;
        
        controller.delegate = self;
        
        controller.selectedDate = self.searchDate;
        controller.dateSearchRelation = self.departOrArrive;
    }
}

@end
