//
//  StopsManager.m
//  NextBusApp
//
//  Created by Felix Mo on 2013-09-18.
//  Copyright (c) 2013 Felix Mo. All rights reserved.
//

#import "StopsManager.h"
#import "FMDatabase.h"

#pragma mark - Private interface

@interface StopsManager ()

@property (nonatomic, strong) FMDatabase *db;

@end


#pragma mark - Implementation

@implementation StopsManager


// - Static variables -
static StopsManager *sharedManager = nil;   // Shared instance


#pragma mark - Class methods

+ (StopsManager *)sharedManager {
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [[StopsManager alloc] init];
    });
    return sharedManager;
}


#pragma mark - Initialization

- (id)init {
    
    if (self = [super init]) {
        
        _db = [FMDatabase databaseWithPath:[[NSBundle mainBundle] pathForResource:@"stops" ofType:@"db"]];
        if (![_db open]) {
            NSLog(@"Could not open database!");
        }
        
        return self;
    }
    else {
        return nil;
    }
}


#pragma mark - Finding stops

- (Stop *)nearestStopForLocation:(CLLocation *)location {
    
    float rad = 0.00001f;
    
    NSArray *stops = [self stopsInRadius:rad ofCoordinate:location.coordinate];
    
    while ([stops count] == 0) {
        rad += 0.00001f;
        stops = [self stopsInRadius:rad ofCoordinate:location.coordinate];
    }
    
    return [stops objectAtIndex:0];
}

- (NSArray *)stopsInRadius:(CGFloat)rad ofCoordinate:(CLLocationCoordinate2D)coord {
    
    NSMutableArray *stops = [[NSMutableArray alloc] init];
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM stops WHERE stop_lat >= (%1.5f-%1.5f) AND stop_lat <= (%1.5f+%1.5f) AND stop_lon >= (%1.5f-%1.5f) AND stop_lon <= (%1.5f+%1.5f);", coord.latitude, rad, coord.latitude, rad, coord.longitude, rad, coord.longitude, rad];
    
    FMResultSet *resultSet = [_db executeQuery:query];
    
    while ([resultSet next]) {
        Stop *stop = [[Stop alloc] initAtCoordindate:CLLocationCoordinate2DMake([resultSet doubleForColumn:@"stop_lat"],
                                                                                [resultSet doubleForColumn:@"stop_lon"])
                                        withStopCode:[resultSet stringForColumn:@"stop_code"]
                                             andName:[resultSet stringForColumn:@"stop_name"]];
        [stops addObject:stop];
    }
    
    return stops;
}

@end
