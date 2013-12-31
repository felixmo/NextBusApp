//
//  RootViewController.h
//  NextBusApp
//
//  Created by Felix Mo on 2013-09-16.
//  Copyright (c) 2013 Felix Mo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "StopsMapViewController.h"


@interface RootViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, StopsMapViewControllerDelegate>

@end
