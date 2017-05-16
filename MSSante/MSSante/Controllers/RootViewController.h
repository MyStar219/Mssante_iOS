//
//  RootViewController.h
//  MSSante
//
//  Created by Labinnovation on 26/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BackMenuViewController.h"
#import "MasterViewController.h"
#import "SelectDossierController.h"
#import "Folder.h"
#import "Reachability.h"
#import "MessageDetailViewController.h"

@class ContainerViewController, MessageDetailViewController;

@interface RootViewController : UIViewController <RequestFinishedDelegate, UIGestureRecognizerDelegate>{
    float centerY;
    float centerX;
    BOOL isLoginSuccess;
    BOOL isReEnrollement;
    BOOL isInit;
    BOOL isReturnOfMoveFolder;
    NSNumber *currentFolderId;
    Reachability *internetReachable;
    NSTimer *sessionTimer;
}

@property BOOL internetActive;
@property BOOL hostActive;

@property (nonatomic, assign) BOOL showPanel;

//@property (nonatomic, assign) BOOL changeNotificationStateIsRunning;
@property (nonatomic, assign) CGPoint preVelocity;

@property (strong, nonatomic) ContainerViewController *containerViewController;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIView *rootView;
@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) BackMenuViewController *backMenuViewController;
@property (strong, nonatomic) MasterViewController *masterViewController;
@property (strong, nonatomic) MasterViewController *masterViewControllerDossier;
@property (strong, nonatomic) MessageDetailViewController *detailViewController;

- (void)launchControllerWithSegue:(NSString*)segue;
- (void) checkNetworkStatus:(NSNotification *)notice;
- (void)enableUserInteractionForTableView:(BOOL)enableInteraction;
- (void)Deconnexion;

@end
