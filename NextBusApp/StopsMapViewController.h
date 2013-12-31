//
//  StopsMapViewController.h
//  NextBusApp
//
//  Created by Felix Mo on 2013-09-18.
//  Copyright (c) 2013 Felix Mo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol StopsMapViewControllerDelegate
@optional

- (void)didSelectStopWithStopCode:(NSString *)code;

@end


@interface StopsMapViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, unsafe_unretained) id <StopsMapViewControllerDelegate> delegate;

@end
