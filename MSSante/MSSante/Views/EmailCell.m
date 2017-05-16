//
//  EmailCell.m
//  MSSante
//
//  Created by Labinnovation on 24/10/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "EmailCell.h"

@implementation EmailCell {
    UIView *contentSubView;
}

@synthesize emailLabel, moreLabel, toggleAttachments;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        emailLabel = [[UILabel alloc]init];
        [emailLabel setNumberOfLines:0];
        [self.contentView addSubview:contentSubView];
        [self.contentView addSubview:emailLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [emailLabel removeFromSuperview];
    // [moreLabel removeFromSuperview];
    [toggleAttachments removeFromSuperview];
    [self setEmailLabel:[[UILabel alloc]init]];
    [emailLabel setNumberOfLines:0];
    [self.contentView addSubview:emailLabel];
}

- (void)addMoreLabelToCell:(UILabel*)label {
    [self setMoreLabel:label];
    [self.contentView addSubview:moreLabel];
}

- (void)addToggleAttachmentsToCell:(UIButton*)button {
    [self setToggleAttachments:button];
    [self.contentView addSubview:toggleAttachments];
}

@end
