//
//  HeaderMenuBarView.h
//  MSSante
//
//  Created by Labinnovation on 06/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MasterViewController;
@class MessageDetailViewController;

@interface HeaderMenuBarView : UIView

@property (retain, nonatomic) IBOutlet UIView *deleteView;
@property (retain, nonatomic) IBOutlet UIView *unreadView;
@property (retain, nonatomic) IBOutlet UIView *followView;
@property (retain, nonatomic) IBOutlet UIView *folderView;
@property (retain, nonatomic) MasterViewController *masterViewController;
@property (retain, nonatomic) MessageDetailViewController *detailViewController;

- (id)initWithFrame:(CGRect)frame;
-(void)setView:(CGRect)frame;
-(void)hideForDraft:(BOOL)isHide;
-(void)isOutbox:(BOOL)isOutbox;
@end
