//
//  FooterBackMenuView.m
//  MSSante
//
//  Created by labinnovation on 14/06/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "FooterBackMenuView.h"
#import "Constant.h"

@implementation FooterBackMenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        self.separator = [[UIView alloc] initWithFrame:CGRectMake(0, -1, self.frame.size.width, 1)];
        [self.separator setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:self.separator];
        
        //Vue Annuaire
        UIView* viewAccount = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/2, self.frame.size.height)];
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openAnnuaire:)];
        [viewAccount addGestureRecognizer:singleFingerTap];
        
        UIImageView* accountImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_annuaire"]];
        [accountImageView setFrame:CGRectMake(viewAccount.frame.size.width/2-accountImageView.frame.size.width/2, 5, accountImageView.frame.size.width, accountImageView.frame.size.height)];
        accountImageView.contentMode = UIViewContentModeScaleToFill;
        [viewAccount addSubview:accountImageView];
        
        UILabel *accountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, viewAccount.frame.size.height/2, viewAccount.frame.size.width, viewAccount.frame.size.height/2)];
        accountLabel.text = @"Annuaire";
        [accountLabel setBackgroundColor:[UIColor clearColor]];
        [accountLabel setTextColor:[UIColor whiteColor]];
        accountLabel.textAlignment = NSTextAlignmentCenter;
        [viewAccount addSubview:accountLabel];
        
        [self addSubview:viewAccount];
        
        //Vue preference
        UIView* viewPref = [[UIView alloc] initWithFrame:CGRectMake(viewAccount.frame.size.width, 0, self.frame.size.width/2, self.frame.size.height)];
        UITapGestureRecognizer *tapOpenPref = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openPref:)];
        [viewPref addGestureRecognizer:tapOpenPref];

        UIImageView* prefImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_preferences"]];
        [prefImageView setFrame:CGRectMake(viewPref.frame.size.width/2-prefImageView.frame.size.width/2, 5, prefImageView.frame.size.width, prefImageView.frame.size.height)];
        prefImageView.contentMode = UIViewContentModeScaleToFill;
        [viewPref addSubview:prefImageView];
        
        UILabel *prefLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, viewPref.frame.size.height/2, viewPref.frame.size.width, viewPref.frame.size.height/2)];
        prefLabel.text = @"Préférences";
        [prefLabel setBackgroundColor:[UIColor clearColor]];
        [prefLabel setTextColor:[UIColor whiteColor]];
        prefLabel.textAlignment = NSTextAlignmentCenter;
        [viewPref addSubview:prefLabel];
        
        [self addSubview:viewPref];
        
        [self setBackgroundColor:[UIColor colorWithRed:0.2705 green:0.2431 blue:0.2549 alpha:1]];
    }
    return self;
}

-(void)openPref:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:OPEN_PREFERENCES object:nil];
}

-(void)openAnnuaire:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:OPEN_ANNUAIRE object:nil];
}


@end
