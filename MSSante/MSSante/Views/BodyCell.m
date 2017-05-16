//
//  BodyCell.m
//  MSSante
//
//  Created by Labinnovation on 24/10/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "BodyCell.h"

@implementation BodyCell

@synthesize bodyTextView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self initBodyTextView];
    }
    return self;
}

- (void)initBodyTextView {
    bodyTextView = [[UITextView alloc]init];
    bodyTextView.backgroundColor = [UIColor clearColor];
    bodyTextView.font = [UIFont fontWithName:@"Helvetica" size:14];
    bodyTextView.editable = NO;
    bodyTextView.dataDetectorTypes = UIDataDetectorTypeLink;
    bodyTextView.scrollEnabled = NO;
    
    UIImage *image = [UIImage imageNamed:@"d1@2x.png"];
    [self.contentView setBackgroundColor:[UIColor colorWithPatternImage:image]];
    [self.contentView addSubview:bodyTextView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [bodyTextView removeFromSuperview];
    [self initBodyTextView];
}

@end
