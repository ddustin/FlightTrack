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

@implementation FlightStats

+ (dispatch_queue_t)queue {
    
    static dispatch_queue_t queue = nil;
    
    if(!queue)
        queue = dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT);
    
    return queue;
}

+ (void)executeService:(NSString*)service withParams:(NSDictionary*)paramsOrig
           onComplete:(void (^)(XmlParser *result))block {
    
    dispatch_async(self.queue, ^{
        
        @autoreleasepool {
            
            NSMutableDictionary *params = [[paramsOrig mutableCopy] autorelease];
            
            [params setObject:@"8461" forKey:@"login.accountID"];
            [params setObject:@"ddustin" forKey:@"login.userID"];
            [params setObject:@"60etcoms" forKey:@"login.password"];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest new] autorelease];
            
            NSString *urlString =
            [NSString stringWithFormat:@"http://www.pathfinder-xml.com/development/xml?Service=%@", service];
            
            [request setURL:[NSURL URLWithString:urlString]];
            
            [request setHTTPMethod:@"POST"];
            
            NSMutableString *string = [NSMutableString string];
            
            int index = 0;
            
            for(NSString *key in params) {
                
                if(index++)
                    [string appendString:@"&"];
                
                [string appendFormat:@"%@=%@", key, [params objectForKey:key]];
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
                
                block(parser);
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
    
    [self executeService:@"AirportGetAirportsService" withParams:dict onComplete:^(XmlParser *result) {
        
        block([self putInArrayIfNotArray:queryXmlResult(result,
                                                        @"AirportGetAirportsResponse",
                                                        @"Airport")]);
    }];
}

@end
