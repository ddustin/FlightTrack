//
//  SearchByRoute.m
//  FlightTrack
//
//  Created by Dustin Dettmer on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchByRoute.h"

@interface SearchByRoute ()

@end

@implementation SearchByRoute

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (IBAction)cancel:(id)sender {
    
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

@end
