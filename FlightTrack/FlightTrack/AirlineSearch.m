//
//  AirlineSearch.m
//  FlightTrack
//
//  Created by Dustin Dettmer on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AirlineSearch.h"
#import "FlightStats.h"

@interface AirlineSearch ()

@property (nonatomic, retain) NSArray *airlines;

@end

@implementation AirlineSearch

@synthesize airlines;

- (void)dealloc {
    
    self.airlines = nil;
    
    [super dealloc];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if(searchText.length) {
        
        static int searchNum = 0;
        
        int thisSearch = ++searchNum;
        
        [FlightStats airlineQuery:searchText onComplete:^(NSArray *value) {
            
            if(thisSearch == searchNum) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    self.airlines = value;
                    
                    [self.tableView reloadData];
                });
            }
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.airlines.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    NSDictionary *airlineInfo = [self.airlines objectAtIndex:indexPath.row];
    
    cell.detailTextLabel.text = [airlineInfo objectForKey:@"AirlineCode"];
    cell.textLabel.text = [airlineInfo objectForKey:@"Name"];
    
    return cell;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

@end
