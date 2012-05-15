//
//  FlightSearchCell.h
//  FlightTrack
//
//  Created by Dustin Dettmer on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlightSearchCell : UITableViewCell

@property (nonatomic, assign) IBOutlet UILabel *airlineFlightLbl;
@property (nonatomic, assign) IBOutlet UILabel *originDestinationLbl;
@property (nonatomic, assign) IBOutlet UILabel *arrivalLbl;
@property (nonatomic, assign) IBOutlet UILabel *depatureLbl;

@end
