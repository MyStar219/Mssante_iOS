//
//  HeaderBackMenuView.m
//  MSSante
//
//  Created by labinnovation on 14/06/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "HeaderBackMenuView.h"
#import "Constant.h"
#import "AccesToUserDefaults.h"

@implementation HeaderBackMenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        
        UIImage *deconnexionImage = [UIImage imageNamed:@"bouton_deconexion_def"];
        self.deconnexionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.deconnexionButton setImage:deconnexionImage forState:UIControlStateNormal];
        [self.deconnexionButton setFrame:CGRectMake(-10, 0, 95, 60)];
        [self.deconnexionButton addTarget:self action:@selector(Deconnexion:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.deconnexionButton];
        
        self.name = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 170, self.frame.size.height)];
        [self.name setFont:[UIFont systemFontOfSize:20]];
        [self.name setBackgroundColor:[UIColor clearColor]];
        [self.name setTextColor:[UIColor whiteColor]];
        self.name.text = [NSString stringWithFormat:@"%@ %@",[AccesToUserDefaults getUserInfoNom], [AccesToUserDefaults getUserInfoPrenom]];
        [self addSubview:self.name];
        

        self.separator = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, 1)];
        [self.separator setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:self.separator];
        
        [self setBackgroundColor:[UIColor colorWithRed:0.2705 green:0.2431 blue:0.2549 alpha:1]];
    }
    return self;
}

-(void)Deconnexion:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:DECONNEXION_NOTIF object:nil];
}

-(void)setName{
    self.name.text = [NSString stringWithFormat:@"%@ %@",[AccesToUserDefaults getUserInfoNom], [AccesToUserDefaults getUserInfoPrenom]];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
