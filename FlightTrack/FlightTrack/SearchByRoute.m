//
//  SearchByRoute.m
//  FlightTrack
//
//  Created by Dustin Dettmer on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchByRoute.h"

@interface SearchByRoute ()

@property (retain, nonatomic) IBOutlet UILabel *departsOrArrivesLbl;
@property (retain, nonatomic) IBOutlet UITextField *dateText;

@property (retain, nonatomic) IBOutlet UITextField *fromAirportLbl;
@property (retain, nonatomic) IBOutlet UITextField *toAirportLbl;

@property (retain, nonatomic) IBOutlet UITextField *airlineLbl;

@property (nonatomic, retain) id fromAirportSearchController;
@property (nonatomic, retain) id toAirportSearchController;

@property (nonatomic, retain) NSDate *searchDate;
@property (nonatomic, retain) NSDictionary *fromAirport;
@property (nonatomic, retain) NSDictionary *toAirport;
@property (nonatomic, retain) NSDictionary *airline;

@property (nonatomic, assign) enum DateSearchRelation departOrArrive;

- (void)updateViews;

@end

@implementation SearchByRoute
@synthesize departsOrArrivesLbl;
@synthesize dateText;
@synthesize fromAirportLbl;
@synthesize toAirportLbl;
@synthesize airlineLbl;
@synthesize fromAirportSearchController, toAirportSearchController;
@synthesize searchDate, fromAirport, toAirport, airline;
@synthesize departOrArrive;

- (void)dealloc {
    
    self.fromAirportSearchController = nil;
    self.toAirportSearchController = nil;
    
    self.fromAirport = nil;
    self.toAirport = nil;
    self.airline = nil;
    
    self.searchDate = nil;
    
    [departsOrArrivesLbl release];
    [dateText release];
    [fromAirportLbl release];
    [toAirportLbl release];
    [airlineLbl release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(!self.searchDate)
        self.searchDate = [NSDate date];
    
    [self updateViews];
}

- (void)viewDidUnload
{
    [self setDepartsOrArrivesLbl:nil];
    [self setDateText:nil];
    [self setFromAirportLbl:nil];
    [self setToAirportLbl:nil];
    [self setAirlineLbl:nil];
    [super viewDidUnload];
}

- (IBAction)cancel:(id)sender {
    
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
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
    
    if(self.fromAirport)
        self.fromAirportLbl.text = [self.fromAirport objectForKey:@"AirportCode"];
    
    if(self.toAirport)
        self.toAirportLbl.text = [self.toAirport objectForKey:@"AirportCode"];
    
    if(self.airline)
        self.airlineLbl.text = [self.airline objectForKey:@"AirlineCode"];
}

- (void)airportSearch:(AirportSearch *)instance completed:(NSDictionary *)airport {
    
    if(instance == fromAirportSearchController) {
        
        self.fromAirport = airport;
    }
    
    if(instance == toAirportSearchController) {
        
        self.toAirport = airport;
    }
    
    [instance.navigationController popViewControllerAnimated:YES];
    
    [self updateViews];
}

- (void)airlineSearchComplete:(AirlineSearch *)instance result:(NSDictionary *)value {
    
    self.airline = value;
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [self updateViews];
}

- (void)dateDepartOrArriveCanceled:(DateDepartOrArrive *)instance {
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)dateDepartOrArriveDone:(DateDepartOrArrive *)instance {
    
    self.searchDate = instance.selectedDate;
    self.departOrArrive = instance.dateSearchRelation;
    
    [self dismissModalViewControllerAnimated:YES];
    
    [self updateViews];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqual:@"dateDepartsOrArrives"]) {
        
        DateDepartOrArrive *controller = segue.destinationViewController;
        
        controller.delegate = self;
        
        controller.selectedDate = self.searchDate;
        controller.dateSearchRelation = self.departOrArrive;
    }
    
    if([segue.identifier isEqual:@"airlineSearch"]) {
        
        [segue.destinationViewController setDelegate:self];
    }
    
    if([segue.identifier isEqual:@"fromAirportSearch"]) {
        
        self.fromAirportSearchController = segue.destinationViewController;
        
        [segue.destinationViewController setDelegate:self];
    }
    
    if([segue.identifier isEqual:@"toAirportSearch"]) {
        
        self.toAirportSearchController = segue.destinationViewController;
        
        [segue.destinationViewController setDelegate:self];
    }
}

@end
