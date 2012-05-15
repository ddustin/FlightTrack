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

@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation AirlineSearch
@synthesize airlines;
@synthesize searchBar;
@synthesize delegate;

- (void)dealloc {
    
    self.airlines = nil;
    
    [searchBar release];
    [super dealloc];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.searchBar becomeFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    static int searchNum = 0;
    
    int thisSearch = ++searchNum;
    
    if(searchText.length) {
        
        [FlightStats airlineQuery:searchText onComplete:^(NSArray *value) {
            
            if(thisSearch == searchNum) {
                
                self.airlines = value;
                
                [self.tableView reloadData];
            }
        }];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.delegate airlineSearchComplete:self result:[self.airlines objectAtIndex:indexPath.row]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (void)viewDidUnload {
    [self setSearchBar:nil];
    [super viewDidUnload];
}
@end
