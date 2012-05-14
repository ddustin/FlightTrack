//
//  NearbyAirports.h
//  FlightTrack
//
//  Created by Dustin Dettmer on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NearbyAirports;

@protocol NearbyAirportsDelegate <NSObject>

- (void)nearbyAirports:(NearbyAirports*)instance AirportChosen:(NSDictionary*)airport;

@end

@interface NearbyAirports : UITableViewController

@property (nonatomic, assign) id<NearbyAirportsDelegate> delegate;

@end
