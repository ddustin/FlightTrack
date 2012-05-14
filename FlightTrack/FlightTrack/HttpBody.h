//
//  HttpBody.h
//  POSHero
//
//  Created by Dustin Dettmer on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpBody : NSObject

- (void)addParameter:(NSString*)name data:(NSData*)data;

/// Assumes string is in UTF8 format
- (void)addParameter:(NSString*)name string:(NSString*)string;

/// Assumes string is in UTF8 format
- (void)addParameter:(NSString *)name format:(NSString*)format, ...;

- (NSMutableURLRequest*)finish;

- (id)copy;

typedef void(^HttpBodyHookBlock)(NSString *name, NSData *data);

/// If set, this block will be called for each addParameter call.
@property (nonatomic, copy) HttpBodyHookBlock addParameterHook;


@end
