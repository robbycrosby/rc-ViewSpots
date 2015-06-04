//
//  SubmitViewController.h
//  ViewSpots
//
//  Created by Robert Crosby on 5/8/15.
//  Copyright (c) 2015 Robert Crosby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "SpotsCell.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface SubmitViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate,CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    float currentlat,currentlong;
    CLLocation *userlocation;
    float zipcode;
    PFGeoPoint* userloc;
    NSString *describe;
    NSString *emailtext;
}
- (IBAction)back:(id)sender;
- (IBAction)take:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *image;
- (IBAction)pick:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet MKMapView *map;
- (IBAction)submit:(id)sender;
- (IBAction)describe:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *adddescribe;

@end
