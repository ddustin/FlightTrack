//
//  SearchByFlightNumber.h
//  FlightTrack
//
//  Created by Dustin Dettmer on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DateDepartOrArrive.h"
#import "AirlineSearch.h"

@interface SearchByFlightNumber : UITableViewController<DateDepartOrArriveDelegate, AirlineSearchDelegate>

@end
