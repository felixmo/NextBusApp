//
//  Stop.h
//  NextBusApp
//
//  Created by Felix Mo on 2013-09-18.
//  Copyright (c) 2013 Felix Mo. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface Stop : NSObject <MKAnnotation>

// - MKAnnotation -
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;

// - Stop -
@property (nonatomic, strong) NSString *stopCode;
@property (nonatomic, strong) NSString *stopName;

- (id)initAtCoordindate:(CLLocationCoordinate2D)coord withStopCode:(NSString *)code andName:(NSString *)name;

@end
