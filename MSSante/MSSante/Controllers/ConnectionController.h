//
//  ConnectionController.h
//  MSSante
//
//  Created by Work on 6/13/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SyncAndSendModifDelegate.h"
#import "RequestFinishedDelegate.h"
#import "ListEmailsResponse.h"
#import "Authentification.h"

@interface ConnectionController : UIViewController <SyncAndSendModifDelegate, RequestFinishedDelegate, UITextFieldDelegate, UIAlertViewDelegate> {
    BOOL toggleUsers;
    //BOOL rememberMe;
    BOOL accountBlocked;
    NSString *mdp;
    BOOL isKeyboardShowing;
    NSNumber *loginCounter;
    NSNumber *currentTime;
    NSNumber *lastLoginTime;
    Authentification *auth;
}

@property (strong, nonatomic) UIView *spinnerView;

@property (weak, nonatomic) IBOutlet UIButton *RememberMeButton;
@property (weak, nonatomic) IBOutlet UIView *LoginView;
@property (weak, nonatomic) IBOutlet UILabel *SelectUserLabel;
@property (weak, nonatomic) IBOutlet UITextField *Password;
@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (weak, nonatomic) IBOutlet UIView *popupNoAccount;
@property (weak, nonatomic) IBOutlet UILabel *NoAccountLabel;

@property (nonatomic, strong) NSNumber *loginCounter;
@property (nonatomic, strong) NSNumber *currentTime;
@property (nonatomic, strong) NSNumber *lastLoginTime;
@property (nonatomic, strong) Authentification *auth;
@property (nonatomic, strong) NSString* mdp;

- (IBAction)reEnrolement:(id)sender;
- (IBAction)ResterConnecte:(id)sender;
- (IBAction)Login:(id)sender;
- (IBAction)Continuer:(id)sender;
- (IBAction)CancelNoAccount:(id)sender;

@end
