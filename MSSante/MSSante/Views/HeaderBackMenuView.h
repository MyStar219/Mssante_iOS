//
//  HeaderBackMenuView.h
//  MSSante
//
//  Created by labinnovation on 14/06/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeaderBackMenuView : UIView{
}

@property (retain, nonatomic) IBOutlet UILabel *name;
@property (retain, nonatomic) IBOutlet UIButton *deconnexionButton;
@property (retain, nonatomic) IBOutlet UIView *separator;

@property (retain, nonatomic) IBOutlet NSString *userMail;

-(void)setName;

@end
