//
//  SearchByFlightNumber.m
//  FlightTrack
//
//  Created by Dustin Dettmer on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchByFlightNumber.h"
#import "FlightStats.h"
#import "SearchResults.h"

@interface SearchByFlightNumber ()

@property (retain, nonatomic) IBOutlet UILabel *departsOrArrivesLbl;
@property (retain, nonatomic) IBOutlet UITextField *dateText;
@property (retain, nonatomic) IBOutlet UITextField *flightNumberText;
@property (retain, nonatomic) IBOutlet UITextField *airlineText;

@property (nonatomic, retain) NSDate *searchDate;
@property (nonatomic, retain) NSString *flightNumber;
@property (nonatomic, retain) NSDictionary *airline;

@property (nonatomic, assign) enum DateSearchRelation departOrArrive;

- (void)updateViews;

@end

@implementation SearchByFlightNumber
@synthesize departsOrArrivesLbl;
@synthesize dateText;
@synthesize flightNumberText;
@synthesize airlineText;
@synthesize searchDate, flightNumber, airline;
@synthesize departOrArrive;

- (void)dealloc {
    
    self.searchDate = nil;
    self.flightNumber = nil;
    self.airline = nil;
    
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
    
    if(self.flightNumber)
        self.flightNumberText.text = self.flightNumber;
    
    if(self.airline)
        self.airlineText.text = [NSString stringWithFormat:@"%@ - %@",
                                 [self.airline objectForKey:@"AirlineCode"],
                                 [self.airline objectForKey:@"Name"]];
}

- (IBAction)flightNumberChanged:(UITextField*)sender {
    
    NSString *searchText = sender.text;
    
    self.flightNumber = sender.text;
    
    // Perform query for airline are a 1/3rd second delay and no text updates
    
    static int searchNum = 0;
    
    int thisSearch = ++searchNum;
    
    if(searchText.length) {
        
        double delayInSeconds = 0.33;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            if(thisSearch != searchNum)
                return;
            
            [FlightStats airlineQuery:sender.text onComplete:^(NSArray *airlines) {
                
                NSDictionary *matchingAirline = nil;
                
                if(airlines.count == 1) {
                    
                    matchingAirline = airlines.lastObject;
                }
                else {
                    
                    BOOL tooManyMatches = NO;
                    
                    for(NSDictionary *airlineInfo in airlines) {
                        
                        NSString *airlineCode = [airlineInfo objectForKey:@"AirlineCode"];
                        
                        if([airlineCode.lowercaseString isEqual:sender.text.lowercaseString]) {
                            
                            if(matchingAirline) {
                                
                                matchingAirline = nil;
                                tooManyMatches = YES;
                                break;
                            }
                            
                            matchingAirline = airlineInfo;
                        }
                    }
                    
                    if(!tooManyMatches && !matchingAirline) {
                        
                        for(NSDictionary *airlineInfo in airlines) {
                            
                            NSString *airlineCode = [airlineInfo objectForKey:@"AirlineCode"];
                            
                            if([sender.text.lowercaseString rangeOfString:airlineCode.lowercaseString].location != NSNotFound) {
                                
                                matchingAirline = airlineInfo;
                                break;
                            }
                        }
                    }
                }
                
                if(matchingAirline) {
                    
                    self.airline = matchingAirline;
                    
                    self.airlineText.text = [NSString stringWithFormat:@"%@ - %@",
                                             [self.airline objectForKey:@"AirlineCode"],
                                             [self.airline objectForKey:@"Name"]];
                }
            }];
        });
    }
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

- (void)airlineSearchComplete:(AirlineSearch *)instance result:(NSDictionary *)value {
    
    self.airline = value;
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [self updateViews];
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
    
    if([segue.identifier isEqual:@"airlineSearch"]) {
        
        [segue.destinationViewController setDelegate:self];
    }
    
    if([segue.identifier isEqual:@"searchResults"]) {
        
        FlightSearchQuery *query = [[FlightSearchQuery new] autorelease];
        
        query.date = self.searchDate;
        query.isArrivalDate = (self.departOrArrive == DateSearchRelationArrive);
        
        query.flightNumber = self.flightNumber;
        query.airlineCode = [self.airline objectForKey:@"AirlineCode"];
        
        [segue.destinationViewController setQuery:query];
    }
}

@end
