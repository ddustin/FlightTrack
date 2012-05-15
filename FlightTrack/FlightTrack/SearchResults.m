//
//  SearchResults.m
//  FlightTrack
//
//  Created by Dustin Dettmer on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchResults.h"
#import "FlightSearchCell.h"

@interface SearchResults ()

@property (nonatomic, retain) NSArray *flights;

@property (nonatomic, assign) BOOL searching;

@end

@implementation SearchResults
@synthesize query;
@synthesize flights;
@synthesize searching;

- (void)dealloc {
    
    self.query = nil;
    self.flights = nil;
    
    [super dealloc];
}

- (UITableViewRowAnimation)idealRowAnimation {
    
    NSString *reqSysVer = @"5.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
        return UITableViewRowAnimationAutomatic;
    
    return UITableViewRowAnimationFade;
}

- (void)load {
    
    self.searching = YES;
    
    [FlightStats flightSearch:self.query onComplete:^(NSArray *value) {
        
        self.searching = NO;
        self.flights = value;
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                      withRowAnimation:self.idealRowAnimation];
    }];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self load];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(self.searching || !self.flights.count)
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    FlightSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FlightSearchCell"];
    
    return cell.frame.size.height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(self.searching || !self.flights.count)
        return 1;
    
    return self.flights.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(self.searching)
        return [tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
    
    if(!self.flights.count)
        return [tableView dequeueReusableCellWithIdentifier:@"NoResultsCell"];
    
    FlightSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FlightSearchCell"];
    
    NSDictionary *flight = [self.flights objectAtIndex:indexPath.row];
    
    NSDictionary *airline = [flight objectForKey:@"Airline"];
    
    cell.airlineFlightLbl.text =
    [NSString stringWithFormat:@"%@ - %@",
     [airline objectForKey:@"Name"], [flight objectForKey:@"FlightNumber"]];
    
    NSDictionary *origin = [flight objectForKey:@"Origin"];
    NSDictionary *destination = [flight objectForKey:@"Destination"];
    
    cell.originDestinationLbl.text =
    [NSString stringWithFormat:@"%@ to %@",
     [origin objectForKey:@"AirportCode"], [destination objectForKey:@"AirportCode"]];
    
    NSDate *departureDate =
    [FlightStats dateFromString:[flight objectForKey:@"DepartureDate"]
                       timeZone:[flight objectForKey:@"DepartureAirportTimeZoneOffset"]];
    
    NSDate *arrivalDate =
    [FlightStats dateFromString:[flight objectForKey:@"ArrivalDate"]
                       timeZone:[flight objectForKey:@"ArrivalAirportTimeZoneOffset"]];
    
    NSDateFormatter *fmt = [[NSDateFormatter new] autorelease];
	
	[fmt setDateFormat:@"h:mm a"];
	
    cell.depatureLbl.text = [fmt stringFromDate:departureDate].lowercaseString;
    cell.arrivalLbl.text = [fmt stringFromDate:arrivalDate].lowercaseString;
    
    return cell;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
