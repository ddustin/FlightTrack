//
//  FlightStats.m
//  FlightTrack
//
//  Created by Dustin Dettmer on 5/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlightStats.h"
#import "XmlParser.h"
#import "HttpBody.h"
#import <CoreLocation/CoreLocation.h>

@implementation FlightStats

+ (dispatch_queue_t)queue {
    
    static dispatch_queue_t queue = nil;
    
    if(!queue)
        queue = dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT);
    
    return queue;
}

static NSString* encodeToPercentEscapeString(NSString *string) {
    
	return [(NSString *)CFURLCreateStringByAddingPercentEscapes
            (NULL,
             (CFStringRef) string,
             NULL,
             (CFStringRef) @"!*'();:@&=+$,/?%#[]",
             kCFStringEncodingUTF8) autorelease];
}

static NSString* decodeFromPercentEscapeString(NSString *string) {
    
	return [(NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding
            (NULL,
             (CFStringRef) string,
             CFSTR(""),
             kCFStringEncodingUTF8) autorelease];
}

+ (void)executeService:(NSString*)service withParams:(NSDictionary*)paramsOrig
           onComplete:(void (^)(XmlParser *result))block {
    
    dispatch_async(self.queue, ^{
        
        @autoreleasepool {
            
            NSMutableDictionary *params = [[paramsOrig mutableCopy] autorelease];
            
            NSString *appId = @"17df6e9e";
            NSString *appKey = @"018db42573413fe8a050380207cff14a";
            
            NSMutableURLRequest *request = [[NSMutableURLRequest new] autorelease];
            
            NSString *urlString =
            [NSString stringWithFormat:@"https://api.flightstats.com/flex/flightstatus/v9/xml/"
            "%@?appId=%@&appKey=%@", service, appId, appKey];
            
            [request setURL:[NSURL URLWithString:urlString]];
            
            [request setHTTPMethod:@"POST"];
            
            NSMutableString *string = [NSMutableString string];
            
            int index = 0;
            
            for(NSString *key in params) {
                
                if(index++)
                    [string appendString:@"&"];
                
                [string appendFormat:@"%@=%@", encodeToPercentEscapeString(key),
                 encodeToPercentEscapeString([params objectForKey:key])];
            }
            
            request.HTTPBody = [string dataUsingEncoding:NSUTF8StringEncoding];
            
            NSError *error = nil;
            
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
            
            if(error)
                NSLog(@"Request error: %@", error);
            
            if(!data)
                return;
            
            XmlParser *parser = [XmlParser new];
            
            if([parser parseData:data]) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    block(parser);
                });
            }
            else {
                
                NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
                UIAlertView *alert = [UIAlertView new];
                
                alert.title = @"Trouble";
                alert.message = [@"Unable to parse Flight Stats XML.\n\n" stringByAppendingString:str];
                
                [alert addButtonWithTitle:@"Okay"];
                
                [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                
                [alert release];
                [str release];
            }
            
            [parser release];
        }
    });
}

+ (NSArray*)putInArrayIfNotArray:(id)object {
    
    if([object isKindOfClass:NSArray.class])
        return object;
    
    if(!object)
        return [NSArray array];
    
    return [NSArray arrayWithObject:object];
}

+ (void)airlineQuery:(NSString *)query onComplete:(void (^)(NSArray *))block {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setObject:query forKey:@"airlineGetAirlinesInfo.specificationMatching.matchString"];
    
    [self executeService:@"AirlineGetAirlinesService" withParams:dict onComplete:^(XmlParser *result) {
        
        block([self putInArrayIfNotArray:queryXmlResult(result,
                                                        @"AirlineGetAirlinesResponse",
                                                        @"Airline")]);
    }];
}

+ (void)airportQuery:(NSString*)query onComplete:(void(^)(NSArray *airports))block {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setObject:query forKey:@"airportGetAirportsInfo.specificationMatching.matchString"];
    
    [dict setObject:@"true" forKey:@"airportGetAirportsInfo.airportGetAirportsRequestedData.airportDetails"];
    
    [self executeService:@"AirportGetAirportsService" withParams:dict onComplete:^(XmlParser *result) {
        
        NSArray *airports = [self putInArrayIfNotArray:queryXmlResult(result,
                                                                      @"AirportGetAirportsResponse",
                                                                      @"AirportDetail")];
        
        NSMutableArray *sortedAirports = [NSMutableArray array];
        
        for(NSDictionary *airport in airports)
            if([[airport objectForKey:@"IsMajorAirport"] isEqual:@"true"])
                [sortedAirports addObject:airport];
        
        for(NSDictionary *airport in airports)
            if(![[airport objectForKey:@"IsMajorAirport"] isEqual:@"true"])
                [sortedAirports addObject:airport];
        
        block(sortedAirports);
    }];
}

static void (^nearbyAirportsOnComplete)(NSArray *) = nil;
static BOOL includeMinor = NO;

+ (void)gotLocation:(CLLocation*)location {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setObject:[NSString stringWithFormat:@"%lf", location.coordinate.latitude]
             forKey:@"airportGetAirportsInfo.specificationRegion.latitude"];
    
    [dict setObject:[NSString stringWithFormat:@"%lf", location.coordinate.longitude]
             forKey:@"airportGetAirportsInfo.specificationRegion.longitude"];
    
    if(!includeMinor)
        [dict setObject:@"true" forKey:@"airportGetAirportsInfo.criterionAirports.majorAirportsOnly"];
    
    [dict setObject:@"true" forKey:@"airportGetAirportsInfo.airportGetAirportsRequestedData.airportDetails"];
    
    [self executeService:@"AirportGetAirportsService" withParams:dict onComplete:^(XmlParser *result) {
        
        NSMutableArray *airports =
        [[[self putInArrayIfNotArray:queryXmlResult(result,
                                                    @"AirportGetAirportsResponse",
                                                    @"AirportDetail")] mutableCopy] autorelease];
        
        int index = 0;
        
        for(NSDictionary *distanceInfo in queryXmlResult(result,
                                                         @"AirportGetAirportsResponse",
                                                         @"DistanceFromOrigin")) {
            
            if(index >= airports.count)
                break;
            
            NSMutableDictionary *dict = [[[airports objectAtIndex:index] mutableCopy] autorelease];
            
            [dict addEntriesFromDictionary:distanceInfo];
            
            [airports replaceObjectAtIndex:index withObject:dict];
            
            index++;
        }
        
        NSMutableArray *sortedAirports = [NSMutableArray array];
        
        for(NSDictionary *airport in airports)
            if([[airport objectForKey:@"IsMajorAirport"] isEqual:@"true"])
                [sortedAirports addObject:airport];
        
        for(NSDictionary *airport in airports)
            if(![[airport objectForKey:@"IsMajorAirport"] isEqual:@"true"])
                [sortedAirports addObject:airport];
        
        if(nearbyAirportsOnComplete)
            nearbyAirportsOnComplete(sortedAirports);
        
        [nearbyAirportsOnComplete release];
        nearbyAirportsOnComplete = nil;
    }];
}

+ (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [(id)self performSelector:@selector(gotLocation:) withObject:newLocation afterDelay:0.15];
    
    [manager stopUpdatingLocation];
}

+ (void)nearbyAirportsIncludingMinor:(BOOL)includeMinorValue OnComplete:(void (^)(NSArray *))block {
    
    static CLLocationManager *locationManager = nil;
    
    [nearbyAirportsOnComplete release];
    nearbyAirportsOnComplete = [block copy];
    includeMinor = includeMinorValue;
    
    if(!locationManager) {
        
        locationManager = [CLLocationManager new];
        
        locationManager.delegate = (id)self;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    }
    
    [locationManager startUpdatingLocation];
}

+ (NSString*)dateToDayStartString:(NSDate*)date addDays:(int)numDays {
    
    NSDateComponents *comps =
    [NSCalendar.currentCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                fromDate:date];
    
    comps.day += numDays;
    
    date = [NSCalendar.currentCalendar dateFromComponents:comps];
    
    NSDateFormatter *format = [[NSDateFormatter new] autorelease];
    
    [format setDateFormat:@"yyyy-MM-dd'T'HH:mm"];
    
    return [format stringFromDate:date];
}

+ (void)flightSearch:(FlightSearchQuery*)query onComplete:(void(^)(NSArray *flights))block {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if(!query.date)
        query.date = [NSDate date];
    
    if(query.isArrivalDate) {
        
        [dict setObject:[self dateToDayStartString:query.date addDays:0]
                 forKey:@"info.specificationDateRange.departureDateTimeMin"];
        
        [dict setObject:[self dateToDayStartString:query.date addDays:1]
                 forKey:@"info.specificationDateRange.departureDateTimeMax"];
    }
    else {
        
        [dict setObject:[self dateToDayStartString:query.date addDays:0]
                 forKey:@"info.specificationDateRange.arrivalDateTimeMin"];
        
        [dict setObject:[self dateToDayStartString:query.date addDays:1]
                 forKey:@"info.specificationDateRange.arrivalDateTimeMax"];
    }
    
    if(query.airlineCode)
        [dict setObject:query.airlineCode forKey:@"info.specificationFlights[0].airline.airlineCode"];
    
    if(query.departureAirport)
        [dict setObject:query.departureAirport forKey:@"info.specificationDepartures[0].airport.airportCode"];
    
    if(query.flightNumber) {
        
        [dict setObject:[query.flightNumber stringByTrimmingCharactersInSet:
                         [NSCharacterSet.decimalDigitCharacterSet invertedSet]]
                 forKey:@"info.specificationFlights[0].flightNumber"];
    }
    
    if(query.arrivalAirport)
        [dict setObject:query.arrivalAirport forKey:@"info.specificationArrivals[0].airport.airportCode"];
    
//    [dict setObject:@"true" forKey:@"info.specificationFlights[0].searchCodeshares"];
//    [dict setObject:@"true" forKey:@"info.flightHistoryGetRecordsRequestedData.codeshares"];
    
    [self executeService:@"FlightHistoryGetRecordsService" withParams:dict onComplete:^(XmlParser *result) {
        
        block([self putInArrayIfNotArray:
               queryXmlResult(result,
                              @"FlightHistoryGetRecordsResponse",
                              @"FlightHistory")]);
    }];
}

+ (NSDate*)dateFromString:(NSString*)string timeZone:(NSString*)timeZone {
    
    NSDateFormatter *format = [[NSDateFormatter new] autorelease];
    
    [format setTimeZone:[NSTimeZone timeZoneWithAbbreviation:timeZone]];
    
    [format setDateFormat:@"yyyy-MM-dd'T'HH:mm"];
    [format setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.sss"];
    
    return [format dateFromString:string];
}

@end

@implementation FlightSearchQuery
@synthesize date, isArrivalDate, airlineCode, flightNumber, departureAirport, arrivalAirport;

- (void)dealloc {
    
    self.date = nil;
    self.airlineCode = nil;
    self.flightNumber = nil;
    self.departureAirport = nil;
    self.arrivalAirport = nil;
    
    [super dealloc];
}

@end
