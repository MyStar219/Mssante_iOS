//
//  ChangePasswordViewController.m
//  MSSante
//
//  Created by Labinnovation on 30/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "Constant.h"
#import "AccesToUserDefaults.h"
#import "Request.h"
#import "PasswordStore.h"

@interface ChangePasswordViewController ()

@end

@implementation ChangePasswordViewController {
    BOOL notificationActivated;
    BOOL errorShown;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        errorShown = NO;
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.oldPasswordTextField.leftView = paddingView;
    self.oldPasswordTextField.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *paddingView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.theNewPasswordTextField.leftView = paddingView2;
    self.theNewPasswordTextField.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *paddingView3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.confirmNewPasswordTextField.leftView = paddingView3;
    self.confirmNewPasswordTextField.leftViewMode = UITextFieldViewModeAlways;
    
    notificationActivated = [AccesToUserDefaults getUserInfoEmailNotification];
    
    DLog(@"notificationActivated %d",notificationActivated);
    
    [self toggleNotificationsCheckbox];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)annuler:(id)sender {
    if (![[self presentedViewController] isBeingDismissed]){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)enregistrerNewPassword:(id)sender {
    if ([PasswordStore  verifyPassword:oldMDP]) {
        NSLog(@"PasswordStore getInstance verify password");

//    if ([oldMDP isEqualToString:[AccesToUserDefaults getUserInfoPassword]]){
        [self comparePassword:passwordNew withConfirmPassword:confirmationNew];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"ERREUR", @"Erreur")
                                                        message: NSLocalizedString(@"OLD_MDP_INVALID", @"Ancien mot de passe invalide")
                                                       delegate: nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                              otherButtonTitles:nil];
        
        [alert show];
    }
}

- (BOOL)regexFindMatch:(NSString*)_string {
    NSString *_pattern = @"((?=.*[A-Z])|(?=.*[a-z]))(?=.*[0-9])";
    NSError  *regexError  = nil;
    NSString *result = @"";
    if ([_string length] > 0 && [_pattern length] > 0) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:_pattern options:NSRegularExpressionCaseInsensitive error:&regexError];
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
-(void)comparePassword:(NSString*)password withConfirmPassword:(NSString*)confirmPassword {
    if (password.length < MIN_PASSWORD || password.length > MAX_PASSWORD || ![password isEqualToString:confirmPassword]||![self regexFindMatch:password] ){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"ERREUR", @"Erreur")
                                                        message: NSLocalizedString(@"NEW_MDP_INVALID", @"Nouveau mot de passe invalide")
                                                       delegate: nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                              otherButtonTitles:nil];
        
        [alert show];
    }
    else {
        
        
        [self.theNewPasswordTextField resignFirstResponder];
        [self.confirmNewPasswordTextField resignFirstResponder];
        [self.oldPasswordTextField resignFirstResponder];
        [self keyboardDidHide:nil];
        
        [self changePassword];
        
    }
}

-(void)changePassword{
    NSString *idNat = [AccesToUserDefaults getUserInfoIdNat];
    NSString *idCanal = [AccesToUserDefaults getUserInfoIdCanal];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *modifierMDPInput = [NSMutableDictionary dictionary];
    
    [modifierMDPInput setObject:idCanal forKey:ID_CANAL];
    [modifierMDPInput setObject:idNat forKey:QR_IDNAT];
    [modifierMDPInput setObject:oldMDP forKey:ANCIEN_MDP];
    [modifierMDPInput setObject:passwordNew forKey:NOUVEAU_MDP];
    
    
    [params setObject:modifierMDPInput forKey:MODIFIER_MDP_INPUT];
    
    Request *request = [[Request alloc] initWithService:S_MODIFIER_MDP method:HTTP_POST params:params];
    request.delegate = self;
    if ([request isConnectedToInternet]) {
        [self.spinner setHidden:NO];
        [request execute];
        errorShown = NO;
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERREUR", @"Erreur")
                                                        message:NSLocalizedString(@"CONNEXION_IMPOSSIBLE", @"Connexion impossible")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                              otherButtonTitles:nil];
        [alert show];
    }
    
}

-(void)httpError:(Error *)_error{
    [self.spinner setHidden:YES];
    if (_error != nil){
        DLog(@"_error.errorCode %d",_error.errorCode);
        UIAlertView *alert;
        if (_error.errorCode == 29) {
            alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"ERREUR", @"Erreur")
                                                            message: NSLocalizedString(@"CANAL_PUSH_DOES_NOT_EXIST", @"Le canal push n'existe pas")
                                                           delegate: nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                                  otherButtonTitles:nil];
            
        } else if (_error.errorCode == 35) {
            alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERREUR", @"Erreur")
                                                            message:NSLocalizedString(@"CONNEXION_IMPOSSIBLE", @"Connexion impossible")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                                  otherButtonTitles:nil];
            
        } else {
            alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"ERREUR", @"Erreur")
                                                            message: NSLocalizedString(@"MDP_INVALIDE", @"L’ancien mot de passe est invalide")
                                                           delegate: nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                                  otherButtonTitles:nil];
            
        }
        
        if (!errorShown) {
            [alert show];
            errorShown = YES;
        }
    }
}

-(void)httpResponse:(id)_responseObject{
            [self.spinner setHidden:YES];
    if ([S_MODIFIER_MDP isEqualToString:_responseObject]) {
        DLog(@"change Password");
        [[PasswordStore getInstance] changePassword:passwordNew];
        NSLog(@"PasswordStore getInstance change passwd ");

//
//        [AccesToUserDefaults setUserInfoPassword:passwordNew];
//        [AccesToUserDefaults setUserInfoSaltedPassword:passwordNew];
//        
//        DAOFactory *factory = [DAOFactory factory];
//        
//        [factory resetDatabaseKey:passwordNew];
//        
//        //delete all attachments
//        NSFileManager *fm = [NSFileManager defaultManager];
//        NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//        NSString *attachmentsDir = [documentsPath stringByAppendingPathComponent:ATTACHMENTS];
//        NSError *error = nil;
//        for (NSString *file in [fm contentsOfDirectoryAtPath:attachmentsDir error:&error]) {
//            BOOL success = [fm removeItemAtPath:[attachmentsDir stringByAppendingPathComponent:file] error:&error];
//            if (!success || error) {
//                DLog(@"Error deleting file %@, Error details %@",file, error);
//                // it failed.
//            }
//        }
        
        
        self.theNewPasswordTextField.text = @"";
        self.confirmNewPasswordTextField.text = @"";
        self.oldPasswordTextField.text = @"";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"MDP_MAJ", @"Mot de passe mis à jour")
                                                        message: nil
                                                       delegate: nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                              otherButtonTitles:nil];
        
        [alert show];
    } else if([S_CHANGE_NOTIF_STATE isEqualToString:_responseObject]){

        notificationActivated = !notificationActivated;
        [self toggleNotificationsCheckbox];
        
        [AccesToUserDefaults setUserInfoEmailNotification:notificationActivated];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"NOTIFICATION_MAJ", @"Etat notification mis à jour")
                                                        message: nil
                                                       delegate: nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                              otherButtonTitles:nil];
        
        [alert show];

    }
    
//    if (![[self presentedViewController] isBeingDismissed]){
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([textField isEqual:self.confirmNewPasswordTextField]){
        confirmationNew = newString;
    }
    else if ([textField isEqual:self.theNewPasswordTextField]){
        passwordNew = newString;
    }
    else if ([textField isEqual:self.oldPasswordTextField]){
        oldMDP = newString;
    }
    
    return YES;
}


-(void) textFieldDidBeginEditing:(UITextField *)textField{
    if ([textField isEqual:self.oldPasswordTextField])
    {
        [self keyboardDidShow:40];
    }
    if ([textField isEqual:self.theNewPasswordTextField])
    {
        [self keyboardDidShow:80];
    }
    if ([textField isEqual:self.confirmNewPasswordTextField])
    {
        [self keyboardDidShow:120];
    }
}
-(void) textFieldDidEndEditing: (UITextField *)sender{
    if ([sender isEqual:self.oldPasswordTextField])
    {
        oldMDP = sender.text;
    }
    if ([sender isEqual:self.theNewPasswordTextField])
    {
        passwordNew = sender.text;
    }
    if ([sender isEqual:self.confirmNewPasswordTextField])
    {
        confirmationNew = sender.text;
    }
    
}
-(void)viewWillAppear:(BOOL)animated{
    centerX = self.view.center.x;
    centerY = self.view.center.y;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.oldPasswordTextField]){
        [self.theNewPasswordTextField becomeFirstResponder];
    }
    else if ([textField isEqual:self.theNewPasswordTextField]){
        [self.confirmNewPasswordTextField becomeFirstResponder];
    }
    else {
        [self keyboardDidHide:nil];
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)keyboardDidShow:(int)offset{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        offsetKeyboard = offset;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3]; // if you want to slide up the view
        self.view.center = CGPointMake(self.view.center.x, centerY - offsetKeyboard);
        [UIView commitAnimations];
    }
    
}

-(void)keyboardDidHide:(id)sender{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3]; // if you want to slide up the view
        self.view.center = CGPointMake(self.view.center.x, centerY);
        
        [UIView commitAnimations];
    }
}

-(void)toggleNotificationsCheckbox {
    if (notificationActivated) {
        [self.notificationsCheckbox setImage:[UIImage imageNamed:@"check_box2"] forState:UIControlStateNormal];
    } else {
        [self.notificationsCheckbox setImage:[UIImage imageNamed:@"check_box1"] forState:UIControlStateNormal];
    }
}

- (IBAction)changeNotifications:(id)sender {
    
    NSString *email = [AccesToUserDefaults getUserInfoChoiceMail];
    NSString *idPush = [AccesToUserDefaults getIdPush];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *changeNotificationStateInput = [NSMutableDictionary dictionary];
    
    [changeNotificationStateInput setObject:idPush forKey:PUSH_ID];
    [changeNotificationStateInput setObject:email forKey:EMAIL];
    [changeNotificationStateInput setObject:[NSNumber numberWithBool:!notificationActivated] forKey:@"isActivated"];
    
    
    [params setObject:changeNotificationStateInput forKey:CHANGE_NOTIF_STATE_INPUT];
    
    Request *request = [[Request alloc] initWithService:S_CHANGE_NOTIF_STATE method:HTTP_POST params:params];
    request.delegate = self;
    if ([request isConnectedToInternet]) {
        [self.spinner setHidden:NO];
        [request execute];
        errorShown = NO;
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERREUR", @"Erreur")
                                                        message:NSLocalizedString(@"CONNEXION_IMPOSSIBLE", @"Connexion impossible")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                              otherButtonTitles:nil];
        [alert show];
    }
}
@end
