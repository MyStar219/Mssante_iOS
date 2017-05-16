//
//  EmailCell.h
//  MSSante
//
//  Created by Labinnovation on 24/10/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmailCell : UITableViewCell {
    UILabel *emailLabel;
    UILabel *moreLabel;
    UIButton *toggleAttachments;
}

@property (nonatomic, strong) UILabel *emailLabel;
@property (nonatomic, strong) UILabel *moreLabel;
@property (nonatomic, strong) UIButton *toggleAttachments;

- (void)addMoreLabelToCell:(UILabel*)label;
- (void)addToggleAttachmentsToCell:(UIButton*)button;

@end
