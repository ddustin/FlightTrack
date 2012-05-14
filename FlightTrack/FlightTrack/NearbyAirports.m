//
//  NearbyAirports.m
//  FlightTrack
//
//  Created by Dustin Dettmer on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NearbyAirports.h"
#import "FlightStats.h"

@interface NearbyAirports ()

@property (nonatomic, retain) NSArray *majorAirports;
@property (nonatomic, retain) NSArray *minorAirports;

@property (nonatomic, assign) BOOL includeMinor;

@end

@implementation NearbyAirports
@synthesize delegate;
@synthesize minorAirports, majorAirports;
@synthesize includeMinor;

- (void)dealloc {
    
    self.majorAirports = nil;
    self.minorAirports = nil;
    
    [super dealloc];
}

- (UITableViewRowAnimation)idealRowAnimation {
    
    NSString *reqSysVer = @"5.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
        return UITableViewRowAnimationAutomatic;
    
    return UITableViewRowAnimationFade;
}

- (BOOL)hasTwoSections {
    
    if(!self.includeMinor || self.minorAirports.count)
        return YES;
    
    return NO;
}

- (void)load {
    
    [FlightStats nearbyAirportsIncludingMinor:self.includeMinor OnComplete:^(NSArray *value) {
        
        self.majorAirports = [NSArray array];
        self.minorAirports = [NSArray array];
        
        [self.tableView reloadData];
        
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
        
        [self.tableView beginUpdates];
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                      withRowAnimation:self.idealRowAnimation];
        
        if(self.minorAirports.count) {
            
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1]
                          withRowAnimation:self.idealRowAnimation];
        }
        
        [self.tableView endUpdates];
    }];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self load];
}

- (IBAction)reload:(id)sender {
    
    [self load];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if(self.hasTwoSections)
        return 2;
    
    return 1;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(self.minorAirports.count && self.includeMinor) {
        
        if(section == 0)
            return @"Major Airports";
        
        if(section == 1)
            return @"Minor Airports";
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(section == 1) {
        
        if(!self.includeMinor)
            return 1;
        
        return self.minorAirports.count;
    }
    
    return self.majorAirports.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 1 && !self.includeMinor) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IncludeMinorCell"];
        
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    NSDictionary *airport = nil;
    
    if(indexPath.section == 0)
        airport = [self.majorAirports objectAtIndex:indexPath.row];
    else
        airport = [self.minorAirports objectAtIndex:indexPath.row];
    
    NSString *airportString = [NSString stringWithFormat:@"%@ - %@",
                               [airport objectForKey:@"AirportCode"], [airport objectForKey:@"Name"]];
    
    NSString *distanceString = nil;
    
    if([[NSLocale.currentLocale objectForKey:NSLocaleUsesMetricSystem] boolValue]) {
        
        distanceString = [NSString stringWithFormat:@"%.1fk",
                          [[airport objectForKey:@"DistanceK"] doubleValue]];
    }
    else {
        
        distanceString = [NSString stringWithFormat:@"%.1fm",
                          [[airport objectForKey:@"DistanceM"] doubleValue]];
    }
    
    cell.textLabel.text = distanceString;
    cell.detailTextLabel.text = airportString;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 1) {
        
        self.includeMinor = YES;
        
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1]
                      withRowAnimation:self.idealRowAnimation];
        
        [self load];
        
        return;
    }
    
    NSDictionary *airport = nil;
    
    if(indexPath.section == 0)
        airport = [self.majorAirports objectAtIndex:indexPath.row];
    else
        airport = [self.minorAirports objectAtIndex:indexPath.row];
    
    [self.delegate nearbyAirports:self AirportChosen:airport];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
