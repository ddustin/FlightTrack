//
//  SearchByFlightNumber.m
//  FlightTrack
//
//  Created by Dustin Dettmer on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchByFlightNumber.h"

@interface SearchByFlightNumber ()

@end

@implementation SearchByFlightNumber

- (IBAction)resignResponderStatus:(UIView*)sender {
    
    [sender resignFirstResponder];
}

- (IBAction)cancel:(id)sender {
    
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

@end
