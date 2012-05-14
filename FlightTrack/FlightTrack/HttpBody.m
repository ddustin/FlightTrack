//
//  HttpBody.m
//  POSHero
//
//  Created by Dustin Dettmer on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HttpBody.h"

@interface HttpBody ()

@property (nonatomic, retain) NSMutableData *httpData;

@end

@implementation HttpBody

@synthesize addParameterHook;
@synthesize httpData;

- (void)dealloc {
    
    self.addParameterHook = nil;
    self.httpData = nil;
    
    [super dealloc];
}

- (NSMutableData*)httpData {
    
    if(!httpData)
        self.httpData = [NSMutableData data];
    
    return httpData;
}

- (NSString*)boundary {
    
    return @"---------------------------147344444499882746641449";
}

- (void)appendFormat:(NSString*)format, ... {
    
    va_list args;
	va_start (args, format);
    
    NSString *string = [[NSString alloc] initWithFormat:format arguments:args];
    
    [self.httpData appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    
    [string release];
    
    va_end(args);
}

- (void)addParameter:(NSString *)name data:(NSData *)data {
    
    if(self.addParameterHook)
        self.addParameterHook(name, data);
    
    // Parameter Start
    [self appendFormat:@"--%@\r\n", self.boundary];
    
    [self appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", name];
    [self.httpData appendData:data];
    [self appendFormat:@"\r\n"];
}

- (void)addParameter:(NSString*)name string:(NSString*)string {
    
    @autoreleasepool {
        
        [self addParameter:name data:[string dataUsingEncoding:NSUTF8StringEncoding]];
    }
}

- (void)addParameter:(NSString *)name format:(NSString *)format, ... {
    
    va_list list;
    va_start(list, format);
    
    NSString *str = [[NSString alloc] initWithFormat:format arguments:list];
    
    [self addParameter:name string:str];
    
    [str release];
    
    va_end(list);
}

- (NSMutableURLRequest*)finish {
    
    NSMutableURLRequest *request = [[NSMutableURLRequest new] autorelease];
    
    [request setHTTPMethod:@"POST"];
    
    [request
     addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", self.boundary]
     forHTTPHeaderField:@"Content-Type"];
    
    // close form
    [self appendFormat:@"--%@--\r\n", self.boundary];
    
    [request setHTTPBody:self.httpData];
    
    return request;
}

- (id)copy {
    
    HttpBody *ret = [HttpBody new];
    
    ret.addParameterHook = self.addParameterHook;
    [ret.httpData setData:self.httpData];
    
    return ret;
}

@end
