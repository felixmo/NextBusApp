//
//  RootViewController.m
//  NextBusApp
//
//  Created by Felix Mo on 2013-09-16.
//  Copyright (c) 2013 Felix Mo. All rights reserved.
//

#import "RootViewController.h"
#import "PredictionTableViewCell.h"
#import "FMNextBus.h"
#import "StopsManager.h"
#import "Stop.h"


#pragma mark - Private interface

@interface RootViewController ()

// UI
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UITextField *stopField;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *checkBtn;

// Data
@property (nonatomic, strong) NSArray *directions;

// Location
@property (nonatomic, strong) CLLocationManager *locationManager;

//
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) int timeElapsed;

// Actions
- (IBAction)fetchPredictions:(id)sender;
- (IBAction)nearestStop:(id)sender;

@end


#pragma mark - Implementation

@implementation RootViewController


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.tintColor = [UIColor redColor];
    self.navigationController.navigationBar.tintColor = [UIColor redColor];
    
    // Add border underneath toolbar
    UIView *border = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 107.0f, 320.0f, 0.5f)];
    [border setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.25f]];
    [self.view addSubview:border];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"StopsMapViewControllerModalSegue"]) {
        [(StopsMapViewController *)[[segue destinationViewController] topViewController] setDelegate:self];
    }
}


#pragma mark - Actions

- (IBAction)fetchPredictions:(id)sender {
    
    [_stopField resignFirstResponder];
    
    _checkBtn.enabled = NO;
    _activityView.hidden = NO;
    
    FMStop *stop = [FMStop stopWithId:[NSNumber numberWithInt:[_stopField.text intValue]]
                            forAgency:[FMAgency agencyWithTag:@"ttc"]
                              onRoute:nil];
    [stop getPredictionsOnSuccess:^(NSArray *predictionSets) {
        
        _checkBtn.enabled = YES;
        _activityView.hidden = YES;
        
        NSMutableArray *dirs = [[NSMutableArray alloc] init];
        for (FMPredictionSet *set in predictionSets) {
            [dirs addObjectsFromArray:set.directions];
        }
        self.directions = dirs;
        
        [self.tableView reloadData];
        
        // Update predictions every second
        _timeElapsed = 0;
        [_timer invalidate];
        _timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(tick:)
                                                userInfo:nil
                                                 repeats:YES];
        [_timer fire];
    }
                          failure:^(NSError *error) {
                              _checkBtn.enabled = YES;
                              _activityView.hidden = YES;
                              
                              NSLog(@"Failed to fetch predictions. %@", [error description]);
                          }];
}

- (IBAction)nearestStop:(id)sender {
    
    // Create the location manager if this object does not already have one.
    if (!_locationManager)
        _locationManager = [[CLLocationManager alloc] init];
    
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    // Set a movement threshold for new events.
    _locationManager.distanceFilter = 500; // meters
    
    [_locationManager startUpdatingLocation];
}


#pragma mark -

- (void)tick:(id)sender {
    
    _timeElapsed++;
    
    if (_timeElapsed == 10) {
        // @ 10 secs
        
        [self fetchPredictions:nil];
    }
    else {
        // < 10 secs
        
        for (FMDirection *dir in self.directions) {
            for (FMPrediction *prediction in dir.predictions) {
                prediction.seconds = [NSNumber numberWithInt:[prediction.seconds intValue] - 1];
            }
        }
        
        [self.tableView reloadData];
    }
}


#pragma mark - Core Location delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *location = [locations lastObject];
    
    Stop *stop = [[StopsManager sharedManager] nearestStopForLocation:location];
    if (stop) {
        [_locationManager stopUpdatingLocation];
        
        self.stopField.text = stop.stopCode;
        [self fetchPredictions:nil];
    }
}


#pragma mark - Stops map view controller delegate

- (void)didSelectStopWithStopCode:(NSString *)code {
    self.stopField.text = code;
    [self fetchPredictions:nil];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return [self.directions count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[[self.directions objectAtIndex:section] predictions] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"RootViewController.PredictionTableViewCell";
    
    PredictionTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    FMPrediction *prediction = [[[self.directions objectAtIndex:indexPath.section] predictions] objectAtIndex:indexPath.row];
    int minutes = [prediction.seconds intValue] / 60;
    int seconds = [prediction.seconds intValue] % 60;
    
    if ([prediction.seconds intValue] <= 0) {
        cell.predictionLabel.text = @"Due";
        cell.predictionLabel.textColor = [UIColor redColor];
    }
    else {
        cell.predictionLabel.text = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
        cell.predictionLabel.textColor = [UIColor blackColor];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    FMDirection *direction = [self.directions objectAtIndex:section];
    
    return [NSString stringWithFormat:@"%@", direction.title];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
