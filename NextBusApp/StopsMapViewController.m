//
//  StopsMapViewController.m
//  NextBusApp
//
//  Created by Felix Mo on 2013-09-18.
//  Copyright (c) 2013 Felix Mo. All rights reserved.
//

#import "StopsMapViewController.h"
#import "StopsManager.h"
#import "Stop.h"

#pragma mark - Private interface 

@interface StopsMapViewController ()

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, assign) BOOL didShowLocation;

- (IBAction)close:(id)sender;

@end


#pragma mark - Implementation

@implementation StopsMapViewController


#pragma mark - Property synthesizations

@synthesize mapView;
@synthesize delegate;
@synthesize didShowLocation;


#pragma mark - Memory management

- (void)dealloc {
    
    delegate = nil;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.tintColor = [UIColor redColor];
    self.navigationController.navigationBar.tintColor = [UIColor redColor];
    
    // Default region
    [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(43.658547, -79.396367), MKCoordinateSpanMake(0.01f, 0.01f))];
}


#pragma mark - Actions

- (IBAction)close:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - MKMapView delegate

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (!didShowLocation) {
                
        MKCoordinateRegion mapRegion;
        mapRegion.center = self.mapView.userLocation.coordinate;
        mapRegion.span.latitudeDelta = 0.005;
        mapRegion.span.longitudeDelta = 0.005;
        
        [self.mapView setRegion:mapRegion animated:YES];
        
        didShowLocation = YES;
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    NSMutableArray *remove = [[NSMutableArray alloc] initWithArray:self.mapView.annotations copyItems:NO];
    [remove removeObject:self.mapView.userLocation];    
    [self.mapView removeAnnotations:remove];
    
    if (self.mapView.region.span.latitudeDelta <= 0.05) {
        
        [self.mapView addAnnotations:[[StopsManager sharedManager] stopsInRadius:self.mapView.region.span.latitudeDelta/2 ofCoordinate:self.mapView.centerCoordinate]];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation {
    
    if (annotation != self.mapView.userLocation) {
        
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
        
        if (pinView == nil) {
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
            pinView.pinColor = MKPinAnnotationColorRed;
            pinView.animatesDrop = NO;
            pinView.canShowCallout = YES;
            pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }

        pinView.annotation = annotation;
        
        return pinView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    [delegate didSelectStopWithStopCode:[(Stop *)[view annotation] stopCode]];
    [self close:nil];
}

@end
