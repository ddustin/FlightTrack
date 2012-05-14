//
//  FlightStats.h
//  FlightTrack
//
//  Created by Dustin Dettmer on 5/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlightStats : NSObject

/// Peforms a query on the existing airlines using 'query'. When complete the results are
/// passed to 'block'.
+ (void)airlineQuery:(NSString*)query onComplete:(void(^)(NSArray *airlines))block;

+ (void)airportQuery:(NSString*)query onComplete:(void(^)(NSArray *airports))block;

@end
