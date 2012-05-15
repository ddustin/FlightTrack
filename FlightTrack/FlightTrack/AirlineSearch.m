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
        
        double delayInSeconds = 0.33;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            if(thisSearch != searchNum)
                return;
            
            [FlightStats airlineQuery:searchText onComplete:^(NSArray *value) {
                
                if(thisSearch == searchNum) {
                    
                    self.airlines = value;
                    
                    [self.tableView reloadData];
                }
            }];
        });
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)value {
    
    [value resignFirstResponder];
    
    if(self.airlines.count == 1)
        [self.delegate airlineSearchComplete:self result:self.airlines.lastObject];
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
