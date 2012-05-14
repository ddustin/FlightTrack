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

+ (void)airlineQuery:(NSString *)query onComplete:(void (^)(NSArray *))block {
    
    dispatch_async(self.queue, ^{
        
        NSURL *url = [NSURL URLWithString:@"http://www.pathfinder-xml.com/development/xml?Service=AirlineGetAirlinesService"];
        
        NSMutableString *string = [NSMutableString string];
        
        [string appendFormat:@"airlineGetAirlinesInfo.specificationMatching.matchString=%@", query];
        [string appendFormat:@"&login.guid=%@", @""];
        [string appendFormat:@"&login.accountID=%@", @"8461"];
        [string appendFormat:@"&login.userID=%@", @"ddustin"];
        [string appendFormat:@"&login.password=%@", @"60etcoms"];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest new] autorelease];
        
        [request setHTTPMethod:@"POST"];
        
        [request setURL:url];
        
        request.HTTPBody = [string dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *error = nil;
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
        
        if(error)
            NSLog(@"Request error: %@", error);
        
        if(!data)
            return;
        
        XmlParser *parser = [XmlParser new];
        
        if([parser parseData:data]) {
            
            NSArray *array = queryXmlResult(parser, @"AirlineGetAirlinesResponse", @"Airline");
            
            if(![array isKindOfClass:NSArray.class])
                array = [NSArray arrayWithObject:array];
            
            block(array);
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
    });
}

@end
