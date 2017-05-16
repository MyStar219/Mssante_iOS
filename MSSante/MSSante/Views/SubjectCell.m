//
//  SubjectCell.m
//  MSSante
//
//  Created by Labinnovation on 24/10/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "SubjectCell.h"

@implementation SubjectCell
@synthesize subjectLabel;
@synthesize bottomSeparator;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Custom initialization
        subjectLabel = [[UILabel alloc]init];
        [subjectLabel setNumberOfLines:0];
        [subjectLabel setBackgroundColor:[UIColor clearColor]];
        
        CGRect sepratorFrame = CGRectMake(0, 0, CGFLOAT_MAX, 1);
        bottomSeparator = [[UIView alloc] initWithFrame:sepratorFrame];
        [bottomSeparator setBackgroundColor:[UIColor lightGrayColor]];
        
        [self.contentView addSubview:subjectLabel];
        [self.contentView addSubview:bottomSeparator];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [subjectLabel removeFromSuperview];
    [self setSubjectLabel:[[UILabel alloc] init]];
    [subjectLabel setNumberOfLines:0];
    [subjectLabel setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:subjectLabel];
}

- (void)updateSubjectLabelFrame:(CGRect)subjectLabelFrame
        andBottomSeparatorFrame:(CGRect)bottomSeparatorFrame
                andSetLabelText:(NSAttributedString *)text {
    [subjectLabel setAttributedText:text];
    [subjectLabel setFrame:subjectLabelFrame];
    [bottomSeparator setFrame:bottomSeparatorFrame];
}

@end
