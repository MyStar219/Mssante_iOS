//
//  SubjectCell.h
//  MSSante
//
//  Created by Labinnovation on 24/10/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubjectCell : UITableViewCell {
    UILabel *subjectLabel;
    UIView *bottomSeparator;
}

@property (nonatomic, strong) UILabel *subjectLabel;
@property (nonatomic, strong) UIView *bottomSeparator;

- (void)updateSubjectLabelFrame:(CGRect)subjectLabelFrame andBottomSeparatorFrame:(CGRect)bottomSeparatorFrame andSetLabelText:(NSAttributedString*)text;
@end
