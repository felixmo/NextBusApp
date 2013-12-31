//
//  Stop.m
//  NextBusApp
//
//  Created by Felix Mo on 2013-09-18.
//  Copyright (c) 2013 Felix Mo. All rights reserved.
//

#import "Stop.h"

@implementation Stop


#pragma mark - Property synthesizations

@synthesize coordinate = _coordinate;
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize stopCode;
@synthesize stopName;


#pragma mark - Initialization

- (id)initAtCoordindate:(CLLocationCoordinate2D)coord withStopCode:(NSString *)code andName:(NSString *)name {
    
    if (self = [super init]) {
        
        _coordinate = coord;
        stopCode = code;
        stopName = name;
        
        return self;
    }
    else {
        return nil;
    }
}


#pragma mark - Properties

- (NSString *)title {
    return stopCode;
}

- (NSString *)subtitle {
    return stopName;
}

@end
