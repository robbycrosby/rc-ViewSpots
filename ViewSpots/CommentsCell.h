//
//  CommentsCell.h
//  ViewSpots
//
//  Created by Robert Crosby on 5/7/15.
//  Copyright (c) 2015 Robert Crosby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentsCell : UITableViewCell {
    
}

@property (weak, nonatomic) IBOutlet UILabel *user;
@property (weak, nonatomic) IBOutlet UILabel *comment;
@property (weak, nonatomic) IBOutlet UIButton *contact;
@property (weak, nonatomic) IBOutlet UIButton *report;
@property (weak, nonatomic) IBOutlet UIScrollView *scroll;

@end
