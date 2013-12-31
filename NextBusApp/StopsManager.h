//
//  StopsManager.h
//  NextBusApp
//
//  Created by Felix Mo on 2013-09-18.
//  Copyright (c) 2013 Felix Mo. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "Stop.h"

@interface StopsManager : NSObject

+ (StopsManager *)sharedManager;

// - Finding stops -
- (Stop *)nearestStopForLocation:(CLLocation *)location;
- (NSArray *)stopsInRadius:(CGFloat)rad ofCoordinate:(CLLocationCoordinate2D)coord;

@end
