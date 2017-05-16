//
//  EnrollementCController.m
//  MSSante
//
//  Created by Work on 6/12/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "EnrollementCController.h"
#import "EnrollementController.h"
#import "ConnectionController.h"
#import "AccesToUserDefaults.h"
#import "PasswordStore.h"
#import "DAOFactory.h"
#import "Constant.h"

@interface EnrollementCController ()
@end

@implementation EnrollementCController

@synthesize spinnerView;

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - Managing View
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShowEnrol:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHideEnrol:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    UIImage *patternImage1 = [UIImage imageNamed:@"d1@2x.png"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:patternImage1];
    self.navigationItem.title = NSLocalizedString(@"AJOUTER_CET_APPAREIL", @"Ajouter cet appareil");
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.Password.leftView = paddingView;
    self.Password.leftViewMode = UITextFieldViewModeAlways;
    self.Password.secureTextEntry = YES;
    
    UIView *paddingView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.PasswordConfirm.leftView = paddingView2;
    self.PasswordConfirm.leftViewMode = UITextFieldViewModeAlways;
    self.PasswordConfirm.secureTextEntry = YES;
    
    self.Password.delegate = self;
    self.PasswordConfirm.delegate = self;
    
    [self.Password setReturnKeyType:UIReturnKeyNext];
    [self.PasswordConfirm setReturnKeyType:UIReturnKeyDone];
}

- (void)viewWillAppear:(BOOL)animated {
    CGRect frame = self.navigationController.navigationBar.frame;
    frame.origin.y = 20;
    [self.navigationController.navigationBar setFrame:frame];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Keyboard
- (void)keyboardDidShowEnrol:(NSNotification*)notif {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.view.center = CGPointMake(self.view.center.x, self.view.center.y - kOFFSET_FOR_KEYBOARD);
        
        /* @WX - Amélioration expérience client
         * Problème : Le clavier cache les champs de texte sur iPhone 4S (écran plus petit)
         * Solution : On identifie qu'on est sur iPhone 4S
         * Puis, on met le clavier à la bonne position
         */
        if (self.view.frame.size.height == 416) {
            self.view.center = CGPointMake(self.view.center.x, self.view.center.y - kOFFSET_FOR_KEYBOARD + 30);
        }
    } else {
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            /* @WX - Amélioration expérience client
             * En mode paysage, mettre le clavier en dessous des deux champs de texte
             */
            //self.view.center = CGPointMake(self.view.center.x, self.view.center.y - OFFSET_FOR_KEYBOARD - 50);
            self.view.center = CGPointMake(self.view.center.x, self.view.center.y - 2*kOFFSET_FOR_KEYBOARD - 100);
            /* @WX - Fin des modifications */
        }
    }
    
    [UIView commitAnimations];
}

- (void)keyboardDidHideEnrol:(NSNotification*)notif {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide down the view
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.view.center = CGPointMake(self.view.center.x, self.view.center.y + kOFFSET_FOR_KEYBOARD);
        
        /* @WX - Amélioration expérience client
         * Problème : Le clavier cache les champs de texte sur iPhone 4S (écran plus petit)
         * Solution : On identifie qu'on est sur iPhone 4S
         * Puis, on remet la vue à sa bonne place
         */
        if (self.view.frame.size.height == 416) {
            self.view.center = CGPointMake(self.view.center.x, self.view.center.y + kOFFSET_FOR_KEYBOARD - 30);
        }
        /* @WX - Fin des modifications */
    } else {
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            //@ TD 17990
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            self.view.center = CGPointMake(screenRect.size.width/2, screenRect.size.height/2 + 32);
        }
    }
    
    [UIView commitAnimations];
}


#pragma mark - Text Field
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.PasswordConfirm]) {
        [textField resignFirstResponder];
        [self Enregistrer:self.PasswordConfirm];
    } else {
        [self.PasswordConfirm becomeFirstResponder];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range
                                                                  withString:string];
    
    if ([textField isEqual:self.PasswordConfirm]) {
        confirmation = newString;
    } else {
        mdp = newString;
    }
    
    return YES;
}

- (void)textFieldDidEndEditing: (UITextField *)sender {
    if ([sender isEqual:self.Password]) {
        mdp = sender.text;
    }
    
    if ([sender isEqual:self.PasswordConfirm]) {
        confirmation = sender.text;
    }
}


#pragma mark - Other Functions 
- (BOOL)regexFindMatch:(NSString*)_string {
    NSString *_pattern = @"((?=.*[A-Z])|(?=.*[a-z]))(?=.*[0-9])";
    NSError  *regexError  = nil;
    NSString *result = @"";
    
    if ([_string length] > 0 && [_pattern length] > 0) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:_pattern
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&regexError];
        if(!regexError) {
            /*   NSTextCheckingResult *textCheckingResult = [regex firstMatchInString:_string options:0 range:NSMakeRange(0, _string.length)];
             NSRange matchRange = [textCheckingResult rangeAtIndex:1];
             result = [_string substringWithRange:matchRange];
             */
            int nb =[regex   numberOfMatchesInString:_string options:0 range:NSMakeRange(0, _string.length)];
            return nb != 0 ;
        }
    }
    
    return ![@"" isEqualToString:result];
}

- (void)comparePassword:(NSString*)password withConfirmPassword:(NSString*)confirmPassword {
    if (password.length < MIN_PASSWORD || password.length > MAX_PASSWORD
        || ![password isEqualToString:confirmPassword] || ![self regexFindMatch:password]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"ERREUR", @"Erreur")
                                                        message: NSLocalizedString(@"MDP_INVALIDE", @"Mot de passe est invalide")
                                                       delegate: nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                              otherButtonTitles:nil];
        
        [alert show];
    } else {
        // [AccesToUserDefaults setUserInfoPassword:password];
        
        [self.Password resignFirstResponder];
        [self.PasswordConfirm resignFirstResponder];
        
        [self EnregistrerCanal:password];
    }
}

- (void)EnregistrerCanal:(NSString*)password {
    NSString *code = [AccesToUserDefaults getUserInfoCode];
    NSString *idPush = @"";
    
    if ([AccesToUserDefaults getIdPush]) {
        idPush = [AccesToUserDefaults getIdPush];
    }
    
    NSString *idNat = [AccesToUserDefaults getUserInfoIdNat];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *deviceId =[[[UIDevice currentDevice] identifierForVendor] UUIDString] ;
    NSString *uuid = [BPXLUUIDHandler UUID];
    DLog(@"uuid %@", uuid);
    DLog(@"deviceId %@",deviceId);
    NSMutableDictionary *enregistrerCanalInput = [NSMutableDictionary dictionary];
    
    [enregistrerCanalInput setObject:uuid forKey:ID_MOBILE];
    [enregistrerCanalInput setObject:code forKey:CODE_APPAREILLEMENT];
    [enregistrerCanalInput setObject:IOS forKey:OS];
    [enregistrerCanalInput setObject:idPush forKey:ID_PUSH];
    [enregistrerCanalInput setObject:idNat forKey:QR_IDNAT];
    [enregistrerCanalInput setObject:password forKey:MOT_DE_PASSE];
    [enregistrerCanalInput setObject:MSSANTE forKey:CODE_SERVICE];
#ifdef DEBUG
    [enregistrerCanalInput setObject:@"test"forKey:@"pushMode"];
#else
    [enregistrerCanalInput setObject:kProd forKey:@"pushMode"];
#endif
    
    [params setObject:enregistrerCanalInput forKey:ENREGISTRER_CANAL_INPUT];

    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    spinnerView = [[UIView alloc] initWithFrame: CGRectMake (0, 0, screenRect.size.width, screenRect.size.height)];
    [spinnerView setBackgroundColor:[UIColor blackColor]];
    [spinnerView setAlpha:0.5];
    [window addSubview:spinnerView];
    
    UIActivityIndicatorView *activityIndicator;
    activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] ;
    activityIndicator.frame = CGRectMake(0.0, 0.0, 20,20);
    activityIndicator.center = spinnerView.center;
    activityIndicator.color = [UIColor whiteColor];
    [activityIndicator startAnimating];
    [spinnerView addSubview:activityIndicator];
    
    Request *request = [[Request alloc] initWithService:S_ENREGISTRER_CANAL method:HTTP_POST params:params];
    request.delegate = self;
    [request setIsEnrolmentRequest:YES];
    [request execute];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[EnrollementController class]]) {
                [self.navigationController popToViewController:controller animated:YES];
            }
        }
    }
}


#pragma mark - HTTP
- (void)httpResponse:(id)_responseObject {
    [spinnerView removeFromSuperview];
    
    if ([_responseObject isKindOfClass:[EnregistrerCanalResponse class]]) {
        PasswordStore *passwordInstance = [PasswordStore getInstanceWithPlainPasswordForEnrollment:mdp];
        
        [[Authentification sharedInstance] setUserPassword:mdp];
        
        NSString *key = [passwordInstance getPlainDbEncryptionKey];
        
        [DAOFactory setKey:key];
        
        [AccesToUserDefaults setUserInfoIdCanal:[(EnregistrerCanalResponse*)_responseObject idCanal]];
        [AccesToUserDefaults setIdPushEnrolement:[AccesToUserDefaults getIdPush]];
    }
    
    [self.popupView setHidden:NO];
    
    [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:NUMBER_VERSION];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)httpError:(Error*)error {
    [spinnerView removeFromSuperview];
    
    if (error != nil) {
        NSString *errorMsg = @"";
        if ([error errorCode] == 21) {
            errorMsg = NSLocalizedString(@"ERREUR_QR_CODE_EXPIRE", @"Le QR Code est expiré, veuillez vous enrôler de nouveau");
        } else if ([error errorCode] == 12 || [error errorCode] == 38) {
            errorMsg = NSLocalizedString(@"NOT_AUTHORIZE_ENROLLEMENT", @"Vous n'êtes pas autorisé à vous enrôler");
        } else if ([error errorCode] == 13 || [error errorCode] == 28) {
            errorMsg = NSLocalizedString(@"FORMAT_INVALIDE", @"Format de champ invalide");
        } else if ([error errorCode] == ERROR_TO_DISPLAY_IN_CONTROLER) {
            errorMsg = [error errorMsg];
        } else if ([error.errorMsg isEqualToString:@""]) {
            errorMsg = NSLocalizedString(@"SERVICE_INDISPONIBLE", @"Service momentanément indisponible");
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error title]
                                                        message:errorMsg
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                              otherButtonTitles:nil];
        [alert show];
    }
}


#pragma mark - IBAction
- (IBAction)Enregistrer:(id)sender {
    DLog(@"Enregistrer");
    [self comparePassword:mdp withConfirmPassword:confirmation];
}

- (IBAction)Continuer:(id)sender {
    [AccesToUserDefaults setUserInfoEnrollement:YES];
    ConnectionController *connectionController;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        connectionController = [[ConnectionController alloc] initWithNibName:@"ConnectionController_iPhone" bundle:nil];
    } else {
        connectionController = [[ConnectionController alloc] initWithNibName:@"ConnectionController_iPad" bundle:nil];
    }
    
    [connectionController.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.navigationController pushViewController:connectionController animated:YES];
}

@end