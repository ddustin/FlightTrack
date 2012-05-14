//
//  SearchByRoute.h
//  FlightTrack
//
//  Created by Dustin Dettmer on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DateDepartOrArrive.h"
#import "AirportSearch.h"
#import "AirlineSearch.h"

@interface SearchByRoute : UITableViewController<DateDepartOrArriveDelegate, AirportSearchDelegate, AirlineSearchDelegate>

@end
