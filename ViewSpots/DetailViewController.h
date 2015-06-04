//
//  DetailViewController.h
//  ViewSpots
//
//  Created by Robert Crosby on 5/7/15.
//  Copyright (c) 2015 Robert Crosby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>
#import "CommentsCell.h"
#import <QuartzCore/QuartzCore.h>
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>


@interface DetailViewController : UIViewController <UITableViewDataSource,UITableViewDelegate, UIAlertViewDelegate,UIActionSheetDelegate,MFMessageComposeViewControllerDelegate>
{
    CLLocationCoordinate2D location;
    PFObject *post;
    NSArray *comments;
    NSInteger selectedcell;
    NSString *comment;
    NSString *emailtext;
}

- (IBAction)comment:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *backback;

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UIImageView *star1;
@property (weak, nonatomic) IBOutlet UIImageView *star2;
@property (weak, nonatomic) IBOutlet UIImageView *star3;
@property (weak, nonatomic) IBOutlet UIImageView *star4;
@property (weak, nonatomic) IBOutlet UIImageView *star5;
@property (weak, nonatomic) IBOutlet UINavigationBar *menubar;

- (IBAction)close:(id)sender;
@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (weak, nonatomic) IBOutlet UIScrollView *scroll;
- (IBAction)directions:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *table;
- (IBAction)share:(id)sender;
- (IBAction)rate:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *spotdesc;

@end
