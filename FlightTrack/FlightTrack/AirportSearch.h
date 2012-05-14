//
//  AirportSearch.h
//  FlightTrack
//
//  Created by Dustin Dettmer on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NearbyAirports.h"

@class AirportSearch;

@protocol AirportSearchDelegate <NSObject>

- (void)airportSearch:(AirportSearch*)instance completed:(NSDictionary*)airport;

@end

@interface AirportSearch : UITableViewController<NearbyAirportsDelegate, UISearchBarDelegate>

@property (nonatomic, assign) id<AirportSearchDelegate> delegate;

@end
