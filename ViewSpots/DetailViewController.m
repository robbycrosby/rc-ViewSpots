//
//  DetailViewController.m
//  ViewSpots
//
//  Created by Robert Crosby on 5/7/15.
//  Copyright (c) 2015 Robert Crosby. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getSpot];
    CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
    
    if (iOSDeviceScreenSize.height == 568)
    {
    [_scroll setContentSize:CGSizeMake(320, 940)];
    } else {
        [_scroll setContentSize:CGSizeMake(375, 1039)];
        // iPhone 5 and iPod Touch 5th generation: 4 inch screen (diagonally measured)
        
    }

    
    
    // Do any additional setup after loading the view.
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)getSpot{
    NSString *objid = [[NSUserDefaults standardUserDefaults] objectForKey:@"spotid"];
    PFQuery *query = [PFQuery queryWithClassName:@"Spots"];
    [query getObjectInBackgroundWithId:objid block:^(PFObject *spot, NSError *error) {
        // Do something with the returned PFObject in the gameScore variable.
        post = spot;
        _menubar.topItem.title = spot[@"Name"];
        _spotdesc.text = spot[@"Description"];
        float negLong = [[spot objectForKey:@"Lon"] floatValue] - [[spot objectForKey:@"Lon"] floatValue] -[[spot objectForKey:@"Lon"] floatValue] ;
        float lat = [[spot objectForKey:@"Lat"] floatValue];
        location = CLLocationCoordinate2DMake(lat, negLong);
        
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        [annotation setCoordinate:location];
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location, 750,   600);
        MKCoordinateRegion adjustedRegion = [_map regionThatFits:viewRegion];
        [_map setRegion:adjustedRegion animated:YES];
        //_map.showsUserLocation = YES;
        [annotation setTitle:spot[@"Name"]];
        //float ulon = [[spot objectForKey:@"userlon"] floatValue];
        //float ulat = [[spot objectForKey:@"userlat"] floatValue];
        //You can set the subtitle too
        [_map addAnnotation:annotation];
        float rate = [[post objectForKey:@"Rating"] floatValue];
        float outof = [[post objectForKey:@"Out"] floatValue];
        double average = rate / outof;
        NSLog(@"%f",average);
        if (average < .25) {
            _star1.alpha = 1.0f;
        }
        else if ((average > .24) && (average < .5)) {
            _star1.alpha = 1.0f;
            _star2.alpha = 1.0f;
        }
        else if ((average > .49) && (average < .7)) {
            _star1.alpha = 1.0f;
            _star2.alpha = 1.0f;
            _star3.alpha = 1.0f;
        }
        else if ((average > .69) && (average < .8)) {
            _star1.alpha = 1.0f;
            _star2.alpha = 1.0f;
            _star3.alpha = 1.0f;
            _star4.alpha = 1.0f;
        }
        else if (average > .79) {
            _star1.alpha = 1.0f;
            _star2.alpha = 1.0f;
            _star3.alpha = 1.0f;
            _star4.alpha = 1.0f;
            _star5.alpha = 1.0f;
        }
        __block UIImage *postedimage;
        [self getcomments];
        PFFile *imageFile = [spot objectForKey:@"Image"];
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                postedimage = [UIImage imageWithData:data];
                _image.image = postedimage;
                _image.clipsToBounds = YES;
                _backback.image = postedimage;
                _backback.clipsToBounds = YES;
            }
            
        }];
        
    }];

}

-(void)getcomments{
    PFQuery *query = [PFQuery queryWithClassName:@"Comments"];
    [query whereKey:@"spot" equalTo:_menubar.topItem.title];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            comments = objects;
            [_table reloadData];
        }
         else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
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

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)directions:(id)sender {
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:location
                                                   addressDictionary:nil];
    MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
    item.name = [post objectForKey:@"Name"];
    [item openInMapsWithLaunchOptions:nil];
}

-(void)sendmessage{
    }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"comments";
    
    CommentsCell *cell = (CommentsCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        
        if (iOSDeviceScreenSize.height == 568)
        {   // iPhone 5
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CommentsCell5" owner:self options:nil];
            cell = [nib objectAtIndex:0];
            
        } else {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CommentsCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
    }
    if (comments.count > 0) {
        PFObject *commentobject = [comments objectAtIndex:indexPath.row];
        cell.user.text = [commentobject objectForKey:@"user"];
        cell.comment.text = [commentobject objectForKey:@"comment"];
        //[cell.scroll setContentSize:CGSizeMake(750, 85)];
        
    } else {
                
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
    
    return 86;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger x;
    if (comments.count > 0) {
        x = comments.count;
    } else {
        x = 1;
    }
    return x;
}

- (IBAction)comment:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Leave Comment"
                                                    message:@"Be Nice!"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Submit", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert setTag:0];
    [alert show];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        nil;
    } else {
        PFObject *commentobject = [comments objectAtIndex:indexPath.row];
        selectedcell = indexPath.row;
        NSString *username = [commentobject objectForKey:@"user"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Take Action"
                                                        message:username
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Contact User",@"Report Spam",nil];
        [alert setTag:5];
        [alert show];

    }
    
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 0) {
        if (buttonIndex == 1) {
            comment = [alertView textFieldAtIndex:0].text;
            NSString *email = [[NSUserDefaults standardUserDefaults] stringForKey:@"email"];
            if (email.length < 1) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You need an account to do this."
                                                                message:@"It just takes a minute. You'll never be spammed."
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"Sign Up",@"Sign In", nil];
                alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
                [alert setTag:3];
                [alert show];
            } else {
                NSString *name = [alertView textFieldAtIndex:0].text;
                PFObject *gameScore = [PFObject objectWithClassName:@"Comments"];
                gameScore[@"comment"] = name;
                gameScore[@"user"] = [[NSUserDefaults standardUserDefaults] stringForKey:@"email"];
                gameScore[@"spot"] = _menubar.topItem.title;
                [gameScore saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        [self getcomments];
                        UIAlertView *done = [[UIAlertView alloc] initWithTitle:nil
                                                                       message:@"Comment Submitted"
                                                                      delegate:nil
                                                             cancelButtonTitle:nil
                                                             otherButtonTitles:nil, nil];
                        [done show];// duration in seconds
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            [done dismissWithClickedButtonIndex:0 animated:YES];
                            
                        });

                    } else {
                        // There was a problem, check error.description
                    }
                }];
            }
            
            // Insert whatever needs to be done with "name"
        }

    } else if (alertView.tag == 2) {
        if (buttonIndex == 1) {
            NSMutableArray *didtheyrate = [[NSMutableArray alloc] init];
            didtheyrate = [[NSUserDefaults standardUserDefaults] objectForKey:@"rates"];
            [didtheyrate addObject:post.objectId];
            [[NSUserDefaults standardUserDefaults] setObject:didtheyrate forKey:@"rates"];
            PFQuery *query = [PFQuery queryWithClassName:@"Spots"];
            
            // Retrieve the object by id
            [query getObjectInBackgroundWithId:post.objectId
                                         block:^(PFObject *gameScore, NSError *error) {
                                             NSInteger rate = [gameScore[@"Rating"] integerValue];
                                             NSInteger outof = [gameScore[@"Out"] integerValue];
                                             gameScore[@"Rating"] = @(rate + 1);
                                             gameScore[@"Out"] = @(outof + 5);
                                             [gameScore saveInBackground];
                                             
                                         }];
        }
        if (buttonIndex == 2) {
            NSMutableArray *didtheyrate = [[NSMutableArray alloc] init];
            didtheyrate = [[NSUserDefaults standardUserDefaults] objectForKey:@"rates"];
            [didtheyrate addObject:post.objectId];
            [[NSUserDefaults standardUserDefaults] setObject:didtheyrate forKey:@"rates"];
            PFQuery *query = [PFQuery queryWithClassName:@"Spots"];
            
            // Retrieve the object by id
            [query getObjectInBackgroundWithId:post.objectId
                                         block:^(PFObject *gameScore, NSError *error) {
                                             NSInteger rate = [gameScore[@"Rating"] integerValue];
                                             NSInteger outof = [gameScore[@"Out"] integerValue];
                                             gameScore[@"Rating"] = @(rate + 2);
                                             gameScore[@"Out"] = @(outof + 5);
                                             [gameScore saveInBackground];
                                             
                                         }];
            // Insert whatever needs to be done with "name"
        }
        if (buttonIndex == 3) {
            NSMutableArray *didtheyrate = [[NSMutableArray alloc] init];
            didtheyrate = [[NSUserDefaults standardUserDefaults] objectForKey:@"rates"];
            [didtheyrate addObject:post.objectId];
            [[NSUserDefaults standardUserDefaults] setObject:didtheyrate forKey:@"rates"];
            PFQuery *query = [PFQuery queryWithClassName:@"Spots"];
            
            // Retrieve the object by id
            [query getObjectInBackgroundWithId:post.objectId
                                         block:^(PFObject *gameScore, NSError *error) {
                                             NSInteger rate = [gameScore[@"Rating"] integerValue];
                                             NSInteger outof = [gameScore[@"Out"] integerValue];
                                             gameScore[@"Rating"] = @(rate + 3);
                                             gameScore[@"Out"] = @(outof + 5);
                                             [gameScore saveInBackground];
                                             
                                         }];
            // Insert whatever needs to be done with "name"
        }
        if (buttonIndex == 4) {
            NSMutableArray *didtheyrate = [[NSMutableArray alloc] init];
            didtheyrate = [[NSUserDefaults standardUserDefaults] objectForKey:@"rates"];
            [didtheyrate addObject:post.objectId];
            [[NSUserDefaults standardUserDefaults] setObject:didtheyrate forKey:@"rates"];
            PFQuery *query = [PFQuery queryWithClassName:@"Spots"];
            
            // Retrieve the object by id
            [query getObjectInBackgroundWithId:post.objectId
                                         block:^(PFObject *gameScore, NSError *error) {
                                             NSInteger rate = [gameScore[@"Rating"] integerValue];
                                             NSInteger outof = [gameScore[@"Out"] integerValue];
                                             gameScore[@"Rating"] = @(rate + 4);
                                             gameScore[@"Out"] = @(outof + 5);
                                             [gameScore saveInBackground];
                                             
                                         }];
            // Insert whatever needs to be done with "name"
        }
        if (buttonIndex == 5) {
            NSMutableArray *didtheyrate = [[NSMutableArray alloc] init];
            didtheyrate = [[NSUserDefaults standardUserDefaults] objectForKey:@"rates"];
            [didtheyrate addObject:post.objectId];
            [[NSUserDefaults standardUserDefaults] setObject:didtheyrate forKey:@"rates"];
            PFQuery *query = [PFQuery queryWithClassName:@"Spots"];
            
            // Retrieve the object by id
            [query getObjectInBackgroundWithId:post.objectId
                                         block:^(PFObject *gameScore, NSError *error) {
                                             NSInteger rate = [gameScore[@"Rating"] integerValue];
                                             NSInteger outof = [gameScore[@"Out"] integerValue];
                                             gameScore[@"Rating"] = @(rate + 5);
                                             gameScore[@"Out"] = @(outof + 5);
                                             [gameScore saveInBackground];
                                             
                                         }];
            // Insert whatever needs to be done with "name"
        }

    }
    else if (alertView.tag == 3) {
        
        if (buttonIndex == 1) {
            // Sign Up
            NSString *name = [alertView textFieldAtIndex:0].text;
            NSString *password = [alertView textFieldAtIndex:1].text;
            PFUser *user = [PFUser user];
            user.password = password;
            user.username = name;
            user.email = name;
            emailtext = [alertView textFieldAtIndex:0].text;
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"email"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    PFObject *gameScore = [PFObject objectWithClassName:@"Comments"];
                    gameScore[@"comment"] = comment;
                    gameScore[@"spot"] = _menubar.topItem.title;
                    gameScore[@"user"] = name;
                    [gameScore saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            UIAlertView *done = [[UIAlertView alloc] initWithTitle:nil
                                                                           message:@"Comment Submitted"
                                                                          delegate:nil
                                                                 cancelButtonTitle:nil
                                                                 otherButtonTitles:nil, nil];
                            [done show];// duration in seconds
                            
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                [done dismissWithClickedButtonIndex:0 animated:YES];
                            });

                            [self getcomments];
                        } else {
                            
                        }
                    }];

                    
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wrong User."
                                                                    message:@"Reset Password?"
                                                                   delegate:self
                                                          cancelButtonTitle:@"No"
                                                          otherButtonTitles:@"Try Again",@"Reset Password", nil];
                    [alert setTag:11];
                    [alert show];
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
                                                    PFObject *gameScore = [PFObject objectWithClassName:@"Comments"];
                                                    gameScore[@"comment"] = comment;
                                                    gameScore[@"spot"] = _menubar.topItem.title;
                                                    gameScore[@"user"] = name;
                                                    [gameScore saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                                        if (succeeded) {
                                                            UIAlertView *done = [[UIAlertView alloc] initWithTitle:nil
                                                                                                           message:@"Comment Submitted"
                                                                                                          delegate:nil
                                                                                                 cancelButtonTitle:nil
                                                                                                 otherButtonTitles:nil, nil];
                                                            [done show];// duration in seconds
                                                            
                                                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                                                [done dismissWithClickedButtonIndex:0 animated:YES];
                                                                
                                                            });

                                                            [self getcomments];
                                                        } else {
                                                            // There was a problem, check error.description
                                                        }
                                                    }];

                                                } else {
                                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wrong User."
                                                                                                    message:@"Reset Password?"
                                                                                                   delegate:self
                                                                                          cancelButtonTitle:@"No"
                                                                                          otherButtonTitles:@"Try Again",@"Reset Password", nil];
                                                    [alert setTag:11];
                                                    [alert show];
                                                }
                                            }];
            // Insert whatever needs to be done with "name"
        }

    }  else if (alertView.tag == 5) {
        if (buttonIndex == 1) {
            NSString *email = [[NSUserDefaults standardUserDefaults] stringForKey:@"email"];
            if (email.length < 1) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You need an account to do this."
                                                                message:@"It just takes a minute. You'll never be spammed."
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"Sign Up",@"Sign In", nil];
                alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
                [alert setTag:6];
                [alert show];
            }
            else {
                PFObject *commentthingy = [comments objectAtIndex:selectedcell];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message To:"
                                                                message:[commentthingy objectForKey:@"user"]
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"Send", nil];
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                [alert setTag:7];
                [alert show];
                

                }
            
        } else if (buttonIndex == 2) {
            PFObject *commentthing = [comments objectAtIndex:selectedcell];
            PFObject *gameScore = [PFObject objectWithClassName:@"CommentReport"];
            gameScore[@"commentid"] = commentthing.objectId;
            [gameScore saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    UIAlertView *done = [[UIAlertView alloc] initWithTitle:@"Comment Reported"
                                                                   message:@"Will we review the comment in question and take appropriate action. \nThank You."
                                                                  delegate:nil
                                                         cancelButtonTitle:nil
                                                         otherButtonTitles:nil, nil];
                    [done show];// duration in seconds
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [done dismissWithClickedButtonIndex:0 animated:YES];
                        
                    });
                    
                } else {
                    // There was a problem, check error.description
                }
            }];

        }
    }
    else if (alertView.tag == 11) {
        if (buttonIndex == 1) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You need an account to do this."
                                                            message:@"It just takes a minute. You'll never be spammed."
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Sign Up",@"Sign In", nil];
            alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
            [alert setTag:3];
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
    else if (alertView.tag == 6) {
        if (buttonIndex == 1) {
            // Sign Up
            NSString *name = [alertView textFieldAtIndex:0].text;
            NSString *password = [alertView textFieldAtIndex:1].text;
            PFUser *user = [PFUser user];
            user.password = password;
            user.username = name;
            user.email = name;
            PFObject *commentobject = [comments objectAtIndex:selectedcell];
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"email"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    NSString *username = [commentobject objectForKey:@"user"];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Take Action"
                                                                    message:username
                                                                   delegate:self
                                                          cancelButtonTitle:@"Cancel"
                                                          otherButtonTitles:@"Contact User",@"Report Spam",nil];
                    [alert setTag:5];
                    [alert show];
                            
                            
                        } else {
                            // There was a problem, check error.description
                        }
                    }];
                    
                    
                }
        
        
        if (buttonIndex == 2) {
            // Sign In
            NSString *name = [alertView textFieldAtIndex:0].text;
            NSString *password = [alertView textFieldAtIndex:1].text;
            [PFUser logInWithUsernameInBackground:name password:password
                                            block:^(PFUser *user, NSError *error) {
                                                if (user) {
                                                    PFObject *commentobject = [comments objectAtIndex:selectedcell];
                                                    [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"email"];
                                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                                    NSString *username = [commentobject objectForKey:@"user"];
                                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Take Action"
                                                                                                    message:username
                                                                                                   delegate:self
                                                                                          cancelButtonTitle:@"Cancel"
                                                                                          otherButtonTitles:@"Contact User",@"Report Spam",nil];
                                                    [alert setTag:5];
                                                    [alert show];
                                                
                                                } else {
                                                            // There was a problem, check error.description
                                                        }
                                                
                                                    
                                               
                                            }];
            // Insert whatever needs to be done with "name"
        }
    }
        else if (alertView.tag == 7) {
            if (buttonIndex == 1) {
                NSString *name = [alertView textFieldAtIndex:0].text;
                PFObject *commentthing = [comments objectAtIndex:selectedcell];
                PFObject *gameScore = [PFObject objectWithClassName:@"Messages"];
                gameScore[@"message"] = name;
                gameScore[@"sender"] = [[NSUserDefaults standardUserDefaults] stringForKey:@"email"];
                gameScore[@"rec"] = [commentthing objectForKey:@"user"];
                [gameScore saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        UIAlertView *done = [[UIAlertView alloc] initWithTitle:nil
                                                                       message:@"Message Sent"
                                                                      delegate:nil
                                                             cancelButtonTitle:nil
                                                             otherButtonTitles:nil, nil];
                        [done show];// duration in seconds
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            [done dismissWithClickedButtonIndex:0 animated:YES];
                            
                        });
                        
                    } else {
                        // There was a problem, check error.description
                    }
                }];
            }
        // Insert whatever needs to be done with "name"
    }

    }
- (IBAction)share:(id)sender {
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"More" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            @"Share on Twitter",
                            @"Invite Someone To This Spot",
                            @"Report This Spot",
                            nil];
    popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
}

- (IBAction)rate:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rate"
                                                    message:@"How was your time at this spot?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"1 Star",@"2 Stars",@"3 Stars",@"4 Stars",@"5 Stars",nil];
    [alert setTag:2];
    [alert show];
}

-(void)reportspot{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Report"
                                                    message:@"Are you sure you want to report this spot for our review?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes",nil];
    [alert setTag:3];
    [alert show];
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
                    {
                        SLComposeViewController *tweetSheet = [SLComposeViewController
                                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
                        [tweetSheet setInitialText:[NSString stringWithFormat:@"Found out about %@ thanks to #ViewSpots",_menubar.topItem.title]];
                        [tweetSheet addImage:_image.image];
                        [self presentViewController:tweetSheet animated:YES completion:nil];
                    }
                    break;
                case 1:
                   [self showSMS];
                    break;
                case 2:
                    [self reportspot];
                    break;
               
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showSMS {
    
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    

    NSString *message = [NSString stringWithFormat:@"Just found out about %@, wanna head to it?", _menubar.topItem.title];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:nil];
    [messageController setBody:message];
    NSData* attachment = UIImageJPEGRepresentation(_image.image, 1.0);
    
    [messageController addAttachmentData:attachment typeIdentifier:@"png" filename:@"viewspot.png"];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}
@end
