//
//  HeaderMenuCorbeilleView.h
//  MSSante
//
//  Created by Labinnovation on 09/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MasterViewController;

@interface HeaderMenuCorbeilleView : UIView


@property (retain, nonatomic) IBOutlet UIView *deleteView;
@property (retain, nonatomic) IBOutlet UIView *viderCorbeilleView;
@property (retain, nonatomic) IBOutlet UIView *restoreView;
@property (retain, nonatomic) MasterViewController *masterViewController;

- (id)initWithFrame:(CGRect)frame;
-(void)justVider:(BOOL)isHide;

@end
