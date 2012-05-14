//
//  AirlineSearch.h
//  FlightTrack
//
//  Created by Dustin Dettmer on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AirlineSearch;

@protocol AirlineSearchDelegate <NSObject>

- (void)airlineSearchComplete:(AirlineSearch*)instance result:(NSDictionary*)airline;

@end

@interface AirlineSearch : UITableViewController<UISearchBarDelegate>

@property (nonatomic, assign) id<AirlineSearchDelegate> delegate;

@end
