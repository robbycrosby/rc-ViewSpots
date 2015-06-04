//
//  SubmitViewController.m
//  ViewSpots
//
//  Created by Robert Crosby on 5/8/15.
//  Copyright (c) 2015 Robert Crosby. All rights reserved.
//

#import "SubmitViewController.h"

@interface SubmitViewController ()

@end

@implementation SubmitViewController

- (void)viewDidLoad {
    self.image.clipsToBounds = true;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
 
*/

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)take:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.image.image = chosenImage;
    
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self getuserlocation];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (IBAction)pick:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

-(void)getuserlocation{
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            userloc = geoPoint;
            NSLog(@"User is currently at %f, %f", geoPoint.latitude, geoPoint.longitude);
            CLGeocoder *ceo = [[CLGeocoder alloc]init];
            CLLocation *loc = [[CLLocation alloc]initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude]; //insert your coordinates
            userlocation = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
            CLLocationCoordinate2D location = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
            currentlat = geoPoint.latitude;
            currentlong = geoPoint.longitude - geoPoint.longitude - geoPoint.longitude;
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            [annotation setCoordinate:location];
            MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location, 228, 228);
            MKCoordinateRegion adjustedRegion = [_map regionThatFits:viewRegion];
            [_map setRegion:adjustedRegion animated:YES];
            //_map.showsUserLocation = YES;
            [annotation setTitle:_name.text];
            //float ulon = [[spot objectForKey:@"userlon"] floatValue];
            //float ulat = [[spot objectForKey:@"userlat"] floatValue];
            //You can set the subtitle too
            [_map addAnnotation:annotation];
            [ceo reverseGeocodeLocation:loc
                      completionHandler:^(NSArray *placemarks, NSError *error) {
                          CLPlacemark *placemark = [placemarks objectAtIndex:0];
                          //NSLog(@"%@ %@, %@",placemark.subThoroughfare ,placemark.thoroughfare, placemark.postalCode);
                          zipcode = placemark.postalCode.floatValue;
                          
                          
                          
                      }
             ];
            
        }
    }];
    
}
- (IBAction)submit:(id)sender {
    NSString *email = [[NSUserDefaults standardUserDefaults] stringForKey:@"email"];
    if (email.length < 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You need an account to do this."
                                                        message:@"It just takes a minute. You'll never be spammed."
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Sign Up",@"Sign In", nil];
        alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        [alert setTag:2];
        [alert show];
    } else {
        CGImageRef cgref = [_image.image CGImage];
        CIImage *cim = [_image.image CIImage];
        if ((cim == nil && cgref == NULL) || (_name.text.length < 1)) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You Forgot Something"
                                                            message:@"Make sure you have an image as well as a title for the spot."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert show];
            
        } else {
            if (describe.length < 1) {
                describe = @" ";
            }
            NSData *imageData = UIImagePNGRepresentation(self.image.image);
            PFFile *imageFile = [PFFile fileWithName:@"Spot.png" data:imageData];
            PFObject *gameScore = [PFObject objectWithClassName:@"Spots"];
            gameScore[@"Image"] = imageFile;
            gameScore[@"Name"] = _name.text;
            gameScore[@"Description"] = describe;
            
            gameScore[@"Lat"] = @(currentlat);
            gameScore[@"Lon"] = @(currentlong);
            gameScore[@"Zip"] = @(zipcode);
            
            UIAlertView *toast = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"Processing..."
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:nil, nil];
            [toast show];
            
            
            [gameScore saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [toast dismissWithClickedButtonIndex:0 animated:YES];
                    UIAlertView *done = [[UIAlertView alloc] initWithTitle:nil
                                                                   message:@"Success!"
                                                                  delegate:nil
                                                         cancelButtonTitle:nil
                                                         otherButtonTitles:nil, nil];
                    [done show];// duration in seconds
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [done dismissWithClickedButtonIndex:0 animated:YES];
                        [self dismissViewControllerAnimated:true completion:nil];
                    });
                    
                } else {
                    // There was a problem, check error.description
                }
            }];
            
        }
    }
    
    }

- (IBAction)describe:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Describe It"
                                                    message:@"100 Characters or less"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Done", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alert textFieldAtIndex:0];
    [alert setTag:1];
    textField.text = describe;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            NSString *name = [alertView textFieldAtIndex:0].text;
            
            if (name.length > 100) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"That's More Than 100"
                                                                message:@"100 Characters or less"
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"Done", nil];
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                UITextField *textField = [alert textFieldAtIndex:0];
                textField.text = name;
                [alert show];
            } else {
                describe = name;
                [_adddescribe setTitle:@"Edit Description" forState:UIControlStateNormal];
            }
        } else {
            describe = @"";
        }
    } else if (alertView.tag == 2) {
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
                    [self submit:self];
                    
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
                                                    [self submit:self];
                                                } else {
                                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wrong User."
                                                                                                    message:@"Reset Password?"
                                                                                                   delegate:self
                                                                                          cancelButtonTitle:@"No"
                                                                                          otherButtonTitles:@"Try Again",@"Reset Password", nil];
                                                    [alert setTag:3];
                                                    [alert show];

                                                }
                                            }];
            
            // Insert whatever needs to be done with "name"
        }
        if (alertView.tag == 3) {
            if (buttonIndex == 1) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You need an account to do this."
                                                                message:@"It just takes a minute. You'll never be spammed."
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"Sign Up",@"Sign In", nil];
                alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
                [alert setTag:1];
                [alert show];
            } else if (buttonIndex == 2) {
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
    
}
@end
