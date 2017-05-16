//
//  EnrollementCController.h
//  MSSante
//
//  Created by Work on 6/12/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Request.h"
#import "RequestFinishedDelegate.h"
#import "EnregistrerCanalResponse.h"
#import "BPXLUUIDHandler.h"

@interface EnrollementCController : UIViewController <UITextFieldDelegate, RequestFinishedDelegate, UIAlertViewDelegate>{
    NSString *mdp;
    NSString *confirmation;
}

- (IBAction)Enregistrer:(id)sender;
- (IBAction)Continuer:(id)sender;
- (void)comparePassword:(NSString*)password withConfirmPassword:(NSString*)confirmPassword;

@property (weak, nonatomic) IBOutlet UITextField *PasswordConfirm;
@property (weak, nonatomic) IBOutlet UITextField *Password;
@property (strong, nonatomic) UIView *spinnerView;

//this means that the class must conform to UITextFieldDelegate protocol.
@property (weak, nonatomic) IBOutlet UIView *popupView;
@property(nonatomic, assign) id<UITextFieldDelegate> delegate;

@end
