//
//  FlightStats.h
//  FlightTrack
//
//  Created by Dustin Dettmer on 5/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FlightSearchQuery;

@interface FlightStats : NSObject

/// Queries for airLINES
/// 
/// Peforms a query on the existing airlines using 'query'. When complete the results are
/// passed to 'block'. 'airlines' is an array of NSDictionaries
+ (void)airlineQuery:(NSString*)query onComplete:(void(^)(NSArray *airlines))block;

/// Queries for airPORTS
/// 
/// 'airports' is an array of NSDictionaries
+ (void)airportQuery:(NSString*)query onComplete:(void(^)(NSArray *airports))block;

/// Aquires GPS and finds all nearby airports. If includeMinor is YES, minor airports will be returned
/// as well. 'airports' is an array of NSDictionaries
+ (void)nearbyAirportsIncludingMinor:(BOOL)includeMinor OnComplete:(void(^)(NSArray *airports))block;

/// 'flights' is an array of NSDictionaries.
+ (void)flightSearch:(FlightSearchQuery*)query onComplete:(void(^)(NSArray *flights))block;

/// Takes a FlightStats formatted date string and turns it into an NSDate object.
+ (NSDate*)dateFromString:(NSString*)string timeZone:(NSString*)timeZone;

@end

@interface FlightSearchQuery : NSObject

/// Only the day portion will be used.
@property (nonatomic, retain) NSDate *date;

/// Set this to YES to make date apply to the plane's arrival time.
/// The default (NO) make the dates apply to the plane's departure time.
@property (nonatomic, assign) BOOL isArrivalDate;

@property (nonatomic, retain) NSString *airlineCode;

@property (nonatomic, retain) NSString *flightNumber;

@property (nonatomic, retain) NSString *departureAirport;

@property (nonatomic, retain) NSString *arrivalAirport;

@end
