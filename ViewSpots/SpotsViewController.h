//
//  SpotsViewController.h
//  ParseStarterProject
//
//  Created by Robert Crosby on 5/6/15.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "SpotsCell.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface SpotsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate,UITabBarDelegate> {
    NSArray *spots;
    CLLocationManager *locationManager;
    float currentlat,currentlong;
    CLLocation *userlocation;
    float zipcode;
    PFGeoPoint *userloc;
    NSString *emailtext;
}

@property (weak, nonatomic) IBOutlet UITableView *feedtable;
- (IBAction)messages:(id)sender;

@end
