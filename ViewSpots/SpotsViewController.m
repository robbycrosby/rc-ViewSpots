//
//  SpotsViewController.m
//  ParseStarterProject
//
//  Created by Robert Crosby on 5/6/15.
//
//

#import "SpotsViewController.h"

@interface SpotsViewController ()

@end

@implementation SpotsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [_feedtable addSubview:refreshControl];
    [self getuserlocation];
    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    
    [self getuserlocation];
    [refreshControl endRefreshing];
    
}



-(void)getviews{
    PFQuery *query = [PFQuery queryWithClassName:@"Spots"];
    float min = zipcode - 50;
    float max = zipcode + 50;
    [query whereKey:@"Zip" greaterThanOrEqualTo:@(min)];
    [query whereKey:@"Zip" lessThanOrEqualTo:@(max)];
    [query orderByDescending:@"Rating"];
    [query setLimit:25];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            spots = objects;
            [_feedtable reloadData];
            if (objects.count == 0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Spots In Your Area"
                                                                message:@"Submit and spread the word!"
                                                               delegate:self
                                                      cancelButtonTitle:@"Ok!"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}
- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
-(void)getuserlocation{
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            userloc = geoPoint;
            NSLog(@"User is currently at %f, %f", geoPoint.latitude, geoPoint.longitude);
            CLGeocoder *ceo = [[CLGeocoder alloc]init];
            CLLocation *loc = [[CLLocation alloc]initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude]; //insert your coordinates
            userlocation = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
            [[NSUserDefaults standardUserDefaults] setFloat:geoPoint.latitude forKey:@"userlat"];
            float x = geoPoint.longitude - geoPoint.longitude - geoPoint.longitude;
            [[NSUserDefaults standardUserDefaults] setFloat:x forKey:@"userlon"];
            [ceo reverseGeocodeLocation:loc
                      completionHandler:^(NSArray *placemarks, NSError *error) {
                          CLPlacemark *placemark = [placemarks objectAtIndex:0];
                          NSLog(@"%@ %@, %@",placemark.subThoroughfare ,placemark.thoroughfare, placemark.postalCode);
                          zipcode = placemark.postalCode.floatValue;
                        [self getviews];
                          
                          
                          
                      }
             ];
            
        }
    }];

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *post = [spots objectAtIndex:indexPath.row];
    NSString *objid = [post objectId];
    [[NSUserDefaults standardUserDefaults] setObject:objid forKey:@"spotid" ];
    CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
    
    if (iOSDeviceScreenSize.height == 568)
    {   // iPhone 5
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"i5" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"detailView"];
        [self presentViewController:vc animated:YES completion:nil];
        
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"i6" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"detailView"];
        [self presentViewController:vc animated:YES completion:nil];
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SpotsCell";
    
    SpotsCell *cell = (SpotsCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        
        if (iOSDeviceScreenSize.height == 568)
        {   // iPhone 5
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SpotsCell5" owner:self options:nil];
            cell = [nib objectAtIndex:0];
            
        } else {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SpotsCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }

        
    }
    if (spots.count > 0) {
        PFObject *post = [spots objectAtIndex:indexPath.row];
        cell.name.text = [post objectForKey:@"Name"];
        //cell.place.text = [post objectForKey:@"Location"];
        //cell.distance.text = @"3.9 Miles Away";
        //cell.difficulty.text = @"Easy";
        float rate = [[post objectForKey:@"Rating"] floatValue];
        float outof = [[post objectForKey:@"Out"] floatValue];
        double average = rate / outof;
        NSLog(@"%f",average);
        if (average < .25) {
            cell.star1.alpha = 1.0f;
        }
        else if ((average > .24) && (average < .5)) {
            cell.star1.alpha = 1.0f;
            cell.star2.alpha = 1.0f;
        }
        else if ((average > .49) && (average < .7)) {
            cell.star1.alpha = 1.0f;
            cell.star2.alpha = 1.0f;
            cell.star3.alpha = 1.0f;
        }
        else if ((average > .69) && (average < .8)) {
            cell.star1.alpha = 1.0f;
            cell.star2.alpha = 1.0f;
            cell.star3.alpha = 1.0f;
            cell.star4.alpha = 1.0f;
        }
        else if (average > .79) {
            cell.star1.alpha = 1.0f;
            cell.star2.alpha = 1.0f;
            cell.star3.alpha = 1.0f;
            cell.star4.alpha = 1.0f;
            cell.star5.alpha = 1.0f;
        }
        float negLong = [[post objectForKey:@"Lon"] floatValue] - [[post objectForKey:@"Lon"] floatValue] -[[post objectForKey:@"Lon"] floatValue] ;
        CLLocation *destination = [[CLLocation alloc] initWithLatitude:[[post objectForKey:@"Lat"] floatValue] longitude:negLong];
        CLLocationDistance distance = [destination distanceFromLocation:userlocation];
        float x = distance * 0.00062137;
        cell.place.text = [NSString stringWithFormat: @"About %.2f Miles Away",x];
        __block UIImage *postedimage;
        PFFile *imageFile = [post objectForKey:@"Image"];
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                postedimage = [UIImage imageWithData:data];
                cell.back.image = postedimage;
                cell.back.clipsToBounds = YES;
            }
        }];


    } else {
        cell.name.text = @"No Places In Area";
        cell.place.text = @"Submit One!";
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    /*
    cell.bg.clipsToBounds = YES;
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    visualEffectView.frame = CGRectMake(0, 0, 320, 141);
    [cell.blur addSubview:visualEffectView];
    */
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 242;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return spots.count;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
    
    if (buttonIndex == 1) {
        // Sign Up
        emailtext = [alertView textFieldAtIndex:0].text;
        NSString *name = [alertView textFieldAtIndex:0].text;
        NSString *password = [alertView textFieldAtIndex:1].text;
        PFUser *user = [PFUser user];
        user.password = password;
        user.username = name;
        user.email = name;
        
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"email"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
            } else {
                
            }
        }];
    }
    if (buttonIndex == 2) {
        // Sign In
         emailtext = [alertView textFieldAtIndex:0].text;
        NSString *name = [alertView textFieldAtIndex:0].text;
        NSString *password = [alertView textFieldAtIndex:1].text;
        [PFUser logInWithUsernameInBackground:name password:password
                                        block:^(PFUser *user, NSError *error) {
                                            if (user) {
                                                [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"email"];
                                                [[NSUserDefaults standardUserDefaults] synchronize];
                                                
                                                    } else {
                                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wrong User. Make sure you enter an email."
                                                                                                        message:@"Reset Password?"
                                                                                                       delegate:self
                                                                                              cancelButtonTitle:@"No"
                                                                                              otherButtonTitles:@"Try Again",@"Reset Password", nil];
                                                                                                                [alert setTag:2];
                                                        [alert show];
                                                    }
                                                }];
                                                
                                                // Insert whatever needs to be done with "name"
    }
    
}
    if (alertView.tag == 2) {
        if (buttonIndex == 1) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You need an account to do this."
                                                            message:@"It just takes a minute. You'll never be spammed."
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Sign Up",@"Sign In", nil];
            alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
            [alert setTag:1];
            [alert show];
        } else if (alertView.tag == 2) {
            [PFUser requestPasswordResetForEmailInBackground:emailtext];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Check The Email Associated With Your Account."
                                                            message:@"Follow the link in the email."
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (IBAction)messages:(id)sender {
    NSString *emaillngth = [[NSUserDefaults standardUserDefaults] stringForKey:@"email"];
    if (emaillngth.length < 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You need an account to do this."
                                                        message:@"It just takes a minute. You'll never be spammed."
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Sign Up",@"Sign In", nil];
        alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        [alert setTag:1];
        [alert show];
    } else {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        
        if (iOSDeviceScreenSize.height == 568)
        {   // iPhone 5
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"i5" bundle:nil];
            UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"messageView"];
            [self presentViewController:vc animated:YES completion:nil];
            
        } else {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"i6" bundle:nil];
            UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"messageView"];
            [self presentViewController:vc animated:YES completion:nil];
        }
    }
    
    
    
}
@end
