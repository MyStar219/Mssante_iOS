//
//  ChangePasswordViewController.h
//  MSSante
//
//  Created by Labinnovation on 30/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequestFinishedDelegate.h"
#import "DAOFactory.h"

@interface ChangePasswordViewController : UIViewController <UITextFieldDelegate, RequestFinishedDelegate>{
    NSString* oldMDP;
    NSString* passwordNew;
    NSString* confirmationNew;
    int offsetKeyboard;
    float centerY;
    float centerX;
}
- (IBAction)changeNotifications:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *notificationsCheckbox;

@property (weak, nonatomic) IBOutlet UITextField *oldPasswordTextField;

@property (weak, nonatomic) IBOutlet UITextField *theNewPasswordTextField;

@property (weak, nonatomic) IBOutlet UITextField *confirmNewPasswordTextField;

- (IBAction)annuler:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *spinner;
- (IBAction)enregistrerNewPassword:(id)sender;
@end
