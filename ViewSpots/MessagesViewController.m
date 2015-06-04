//
//  MessagesViewController.m
//  ViewSpots
//
//  Created by Robert Crosby on 5/11/15.
//  Copyright (c) 2015 Robert Crosby. All rights reserved.
//

#import "MessagesViewController.h"

@interface MessagesViewController ()

@end

@implementation MessagesViewController

- (void)viewDidLoad {
    [self getinboxmessages];
    [super viewDidLoad];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [_tableview addSubview:refreshControl];

    // Do any additional setup after loading the view.
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    if (isinbox == YES) {
        [self getinboxmessages];
        [refreshControl endRefreshing];
    } else {
        [self getsentmessages];
        [refreshControl endRefreshing];
    }
    
}

- (void)getinboxmessages {
    isinbox = YES;
    NSString *currentuser = [[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
    PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
    [query whereKey:@"rec" equalTo:currentuser];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"%lu messages",(unsigned long)objects.count);
            messages = objects;
            [_tableview reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

}

- (void)getsentmessages {
    isinbox = NO;
    NSString *currentuser = [[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
    PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
    [query whereKey:@"sender" equalTo:currentuser];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"%lu messages",(unsigned long)objects.count);
            messages = objects;
            [_tableview reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
    }
    if (isinbox == YES) {
        PFObject *message = [messages objectAtIndex:indexPath.row];
        cell.backgroundColor = [UIColor blackColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.text = [message objectForKey:@"message"];
        cell.detailTextLabel.text = [message objectForKey:@"sender"];
    } else {
        PFObject *message = [messages objectAtIndex:indexPath.row];
        cell.backgroundColor = [UIColor blackColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.text = [message objectForKey:@"message"];
        cell.detailTextLabel.text = [message objectForKey:@"rec"];
    }
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    PFObject *commentthingy = [messages objectAtIndex:indexPath.row];
    destination = [commentthingy objectForKey:@"sender"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message To:"
                                                    message:[commentthingy objectForKey:@"sender"]
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Send", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert setTag:1];
    [alert show];

    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            NSString *message = [alertView textFieldAtIndex:0].text;
            PFObject *gameScore = [PFObject objectWithClassName:@"Messages"];
            gameScore[@"message"] = message;
            gameScore[@"sender"] = [[NSUserDefaults standardUserDefaults] stringForKey:@"email"];
            gameScore[@"rec"] = destination;
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

        }
        }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return messages.count;
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}
- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)signout:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"email"];
    [PFUser logOut];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)segment:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    
    if (selectedSegment == 0) {
        //toggle the correct view to be visible
        [self getinboxmessages];
        isinbox = YES;
    }
    else{
        //toggle the correct view to be visible
        [self getsentmessages];
        isinbox = NO;
    }
}
@end
