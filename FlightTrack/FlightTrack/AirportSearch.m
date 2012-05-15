//
//  AirportSearch.m
//  FlightTrack
//
//  Created by Dustin Dettmer on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AirportSearch.h"
#import "FlightStats.h"

@interface AirportSearch ()

@property (nonatomic, retain) NSArray *majorAirports;
@property (nonatomic, retain) NSArray *minorAirports;

/// Keys are two letter country codes (NSString) and values are full country name (NSString).
@property (nonatomic, retain) NSDictionary *countryCodes;

@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation AirportSearch
@synthesize delegate;
@synthesize majorAirports, minorAirports;
@synthesize countryCodes;
@synthesize searchBar;

- (void)dealloc {
    
    self.majorAirports = nil;
    self.minorAirports = nil;
    self.countryCodes = nil;
    
    [searchBar release];
    [super dealloc];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.searchBar becomeFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)value {
    
    [value resignFirstResponder];
    
    if(self.majorAirports.count == 1 && self.minorAirports.count == 0)
        [self.delegate airportSearch:self completed:self.majorAirports.lastObject];
    
    if(self.majorAirports.count == 0 && self.minorAirports.count == 1)
        [self.delegate airportSearch:self completed:self.minorAirports.lastObject];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    static int searchNum = 0;
    
    int thisSearch = ++searchNum;
    
    if(searchText.length) {
        
        [FlightStats airportQuery:searchText onComplete:^(NSArray *value) {
            
            if(thisSearch == searchNum) {
                
                NSMutableArray *majorArray = [NSMutableArray array];
                NSMutableArray *minorArray = [NSMutableArray array];
                
                for(NSDictionary *airport in value) {
                    
                    if([[airport objectForKey:@"IsMajorAirport"] isEqual:@"true"])
                        [majorArray addObject:airport];
                    else
                        [minorArray addObject:airport];
                }
                
                self.minorAirports = minorArray;
                self.majorAirports = majorArray;
                
                [self.tableView reloadData];
            }
        }];
    }
}

- (NSDictionary*)countryCodes {
    
    if(!countryCodes) {
        
        NSString *file = [[NSBundle mainBundle] pathForResource:@"countryCodes" ofType:@"plist"];
        
        self.countryCodes = [NSDictionary dictionaryWithContentsOfFile:file];
    }
    
    return countryCodes;
}

- (BOOL)hasTwoSections {
    
    return self.minorAirports.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if(self.hasTwoSections)
        return 2;
    
    return 1;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(self.hasTwoSections) {
        
        if(section == 0)
            return @"Major Airports";
        
        if(section == 1)
            return @"Minor Airports";
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(section == 0)
        return self.majorAirports.count;
    
    return self.minorAirports.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    NSDictionary *airport = nil;
    
    if(indexPath.section == 0)
        airport = [self.majorAirports objectAtIndex:indexPath.row];
    else
        airport = [self.minorAirports objectAtIndex:indexPath.row];
    
    NSString *airportString = [NSString stringWithFormat:@"%@ - %@",
                               [airport objectForKey:@"AirportCode"], [airport objectForKey:@"Name"]];
    
    NSMutableString *locationStr = [NSMutableString string];
    
    if([[airport objectForKey:@"City"] length]) {
        
        [locationStr appendString:[airport objectForKey:@"City"]];
    }
    
    if([[airport objectForKey:@"StateCode"] length]) {
        
        if(locationStr.length)
            [locationStr appendString:@", "];
        
        [locationStr appendString:[airport objectForKey:@"StateCode"]];
    }
    
    if([[airport objectForKey:@"CountryCode"] length]) {
        
        if(locationStr.length)
            [locationStr appendString:@", "];
        
        NSString *country = [airport objectForKey:@"CountryCode"];
        
        if([self.countryCodes objectForKey:country])
            country = [[self.countryCodes objectForKey:country] capitalizedString];
        
        [locationStr appendString:country];
    }
    
    cell.detailTextLabel.text = airportString;
    cell.textLabel.text = locationStr;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *airport = nil;
    
    if(indexPath.section == 0)
        airport = [self.majorAirports objectAtIndex:indexPath.row];
    else
        airport = [self.minorAirports objectAtIndex:indexPath.row];
    
    [self.delegate airportSearch:self completed:airport];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (void)nearbyAirports:(NearbyAirports *)instance AirportChosen:(NSDictionary *)airport {
    
    [instance.navigationController popViewControllerAnimated:NO];
    
    [self.delegate airportSearch:self completed:airport];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqual:@"nearbyAirports"]) {
        
        [segue.destinationViewController setDelegate:self];
    }
}

- (void)viewDidUnload {
    [self setSearchBar:nil];
    [super viewDidUnload];
}
@end
