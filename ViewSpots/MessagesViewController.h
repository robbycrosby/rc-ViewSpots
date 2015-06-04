//
//  MessagesViewController.h
//  ViewSpots
//
//  Created by Robert Crosby on 5/11/15.
//  Copyright (c) 2015 Robert Crosby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface MessagesViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate> {
    NSArray *messages;
    NSString *destination;
    bool isinbox;
}
- (IBAction)close:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
- (IBAction)signout:(id)sender;
- (IBAction)segment:(id)sender;

@end
