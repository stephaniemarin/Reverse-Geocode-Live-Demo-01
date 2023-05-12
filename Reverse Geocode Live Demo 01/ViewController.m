//
//  ViewController.m
//  Reverse Geocode Live Demo 01
//
//  Created by Stephanie Marin Velasquez on 5/10/23.
//

#import "ViewController.h"
@import CoreLocation;
@import MapKit;

@interface ViewController () <MKMapViewDelegate>
//core location geocoder

@property (strong, nonatomic) CLGeocoder *geocoder;
@property (weak, nonatomic) IBOutlet MKMapView *MapView;
@property (weak, nonatomic) IBOutlet UILabel *geocodeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *pinIcon;
@property (assign, nonatomic) BOOL lookupUp;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.geocoder = [[CLGeocoder alloc] init];
    self.geocodeLabel.text = nil;
    self.geocodeLabel.alpha = 0.5;
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [self executeTheLookUp];
}
- (void) executeTheLookUp {
    if (self.lookupUp == NO) {
        self.lookupUp = YES;
        //create a coodinate based on current map orientation
        CLLocationCoordinate2D coord = [self locationAtCenterOfMapView];
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
        [self startReverseGeocodeLocation: loc];
    }
}
- (CLLocationCoordinate2D)locationAtCenterOfMapView {
    CGPoint centerOfPin = CGPointMake(CGRectGetMidX(self.pinIcon.bounds), CGRectGetMidY(self.pinIcon.bounds)); // in ImageView coord space
    return [self.MapView convertPoint:centerOfPin toCoordinateFromView:self.pinIcon];  // getting the location at center of pin
}

- (void)startReverseGeocodeLocation : (CLLocation *)location //getting the request from the cloud
{
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error) {
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"There was a problem reverse geocoding" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:ac animated: YES completion:nil];
            return;
        }
        //Grab some interesting bits of CLPlacemark and show it.
        // but no dupes.
        
        NSMutableSet *mappedPlaceDescs = [NSMutableSet new];
        for (CLPlacemark *p in placemarks) {
            if (p.name != nil)
                [mappedPlaceDescs addObject:p.name];
            if (p.administrativeArea != nil)
                [mappedPlaceDescs addObject:p.administrativeArea];
            if (p.country != nil)
                [mappedPlaceDescs addObject:p.country];
        }
        self.geocodeLabel.text = [[mappedPlaceDescs allObjects]
            componentsJoinedByString:@"\n"];
        self.geocodeLabel.alpha = 1.0;
        self.lookupUp = NO;
        
    }];
}
@end

