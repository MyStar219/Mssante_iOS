//
//  BackMenuViewController.h
//  MSSante
//
//  Created by labinnovation on 13/06/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FooterBackMenuView.h"
#import "HeaderBackMenuView.h"

@class MasterViewController;
@class SlideNavigationController;

@interface BackMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>{
    NSMutableArray *folderList;
    NSMutableArray *iconListDisable;
    FooterBackMenuView *footerBackMenuView;
    HeaderBackMenuView *headerBackMenuView;
    UIViewController *parentView;
    int selectedRow;
}

@property (strong, nonatomic) FooterBackMenuView *footerBackMenuView;
@property (nonatomic) int selectedRow;
@property (strong, nonatomic) MasterViewController *masterViewController;
@property (strong,nonatomic) NSString *nbMsgUnread;
@property (strong,nonatomic) NSString *nbDraft;
@property (strong,nonatomic) NSString *nbMsgWillSend;

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
