//
//  DateDepartOrArrive.h
//  FlightTrack
//
//  Created by Dustin Dettmer on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Kal.h"

enum DateSearchRelation {
    DateSearchRelationDepart = 0,
    DateSearchRelationArrive
};

@interface DateDepartOrArrive : UIViewController<KalViewDelegate>

/// Defaults to now.
@property (nonatomic, retain) NSDate *selectedDate;

@property (nonatomic, assign) enum DateSearchRelation dateSearchRelation;

@end
