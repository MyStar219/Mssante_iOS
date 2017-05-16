//
//  ConnectionController.m
//  MSSante
//
//  Controller permettant de se connecter
//  Fait appelle au service "recupérerBal" une fois cliquer sur Valider
//
//  Created by Work on 6/13/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <CommonCrypto/CommonDigest.h>
#import "ConnectionController.h"
#import "Constant.h"
#import "ChoixMessagerieViewController.h"
#import "Request.h"
#import "AccesToUserDefaults.h"
#import "FolderDAO.h"
#import "Folder.h"
#import "DAOFactory.h"
#import "SyncAndLaunchModification.h"
#import "PasswordStore.h"
#import "ListFoldersInput.h"
#import "ListFoldersResponse.h"
#import "AppDelegate.h"

#define LOGIN_STATUS_SUCCESS  0
#define LOGIN_STATUS_NO_EMAIL 1
#define LOGIN_STATUS_WRONG_CREDINTIALS 2
#define LOGIN_STATUS_ACCOUNT_BLOCKED 3
#define LOGIN_STATUS_ERROR  4

@interface ConnectionController ()

@end

@implementation ConnectionController {
    int loginOfflineStatus;
    BOOL firstConnection;
    BOOL isErrorShown;
    
    UIView *spinn;
}

@synthesize spinnerView, loginCounter, currentTime, lastLoginTime, auth, mdp;

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        spinn = [self createSpinnerView];
        [spinn setHidden:YES];
        [self.view addSubview:spinn];
    }
    return self;
}

#pragma mark - Managing View
- (void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideLoading:)
                                                 name:DECONNEXION_NOTIF object:nil];
    
    /* @WX - Amélioration */
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    /* @WX - Fin des modifications */
    
    loginCounter = nil;
    loginOfflineStatus = LOGIN_STATUS_ERROR;
    
    if ([AccesToUserDefaults getUserInfoLoginCounter]) {
        loginCounter = [AccesToUserDefaults getUserInfoLoginCounter];
    }
    
    [super viewDidLoad];
    
    self.SelectUserLabel.text = [NSString stringWithFormat:@"%@ %@",
                                 [AccesToUserDefaults getUserInfoNom],
                                 [AccesToUserDefaults getUserInfoPrenom]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShowController:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHideController:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    UIImage *patternImage1 = [UIImage imageNamed:@"d1@2x.png"];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    UIImage *patternImage2 = [UIImage imageNamed:@"d2@2x.png"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:patternImage1];
    self.LoginView.backgroundColor = [UIColor colorWithPatternImage:patternImage2];
    self.Password.leftView = paddingView;
    self.Password.leftViewMode = UITextFieldViewModeAlways;
    self.Password.secureTextEntry = YES;
    self.Password.delegate = self;
    
    mdp = @"";
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(NoAccountAction:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [self.NoAccountLabel addGestureRecognizer:tapGestureRecognizer];
}

- (void) viewWillAppear:(BOOL)animated {
    DLog(@"viewWillAppear");
    
    // Hide navigation bar from the welcome screen
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    toggleUsers = YES;
    isErrorShown = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Request
- (void)runGetBalRequestWithIdPS :(NSString*) userId {
    if ([AccesToUserDefaults getUserInfoChoiceMail] == nil
        || [AccesToUserDefaults getUserInfoSyncToken] == nil) {
        firstConnection = YES;
    }
    
    Request *request;
    
    if (![AccesToUserDefaults getUserInfoChoiceMail]) {
        DLog(@"LoginProcess : User Didn't choose Email, calling ListEmail");
        
        [[PasswordStore getInstance] setFirstConnection:YES];
        NSLog(@"PasswordStore getInstance set first connexion yes");
        
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        NSMutableDictionary *userIdDict =  [NSMutableDictionary dictionary];
        
        [userIdDict setValue:userId forKey:USER_ID];
        [param setValue:userIdDict forKey:LIST_EMAILS_INPUT];
        
        request = [[Request alloc] initWithService:S_ANNUAIRE_LIST_EMAILS
                                            method:HTTP_POST
                                           headers:nil
                                            params:param];
    } else {
        DLog(@"LoginProcess : User chose Email, calling List Folders");
        
        [[PasswordStore getInstance] setFirstConnection:NO];
        NSLog(@"PasswordStore getInstance set first connexion no");
        
        ListFoldersInput *listInput = [[ListFoldersInput alloc] init];
        request = [[Request alloc] initWithService:S_FOLDER_LIST
                                            method:HTTP_POST
                                           headers:nil
                                            params:[listInput generate]];
    }
    
    request.tmpPassword = mdp;
    request.delegate = self;
    [request execute];
}

//Appeler si Request (dans la méthode runGetBalRequestWithIdPS) à réussi grâce au delegate
- (void)httpResponse:(id)_responseObject {
    [self hideLoading:nil];
    [self.popupView setHidden:YES];
    
    if ([_responseObject isKindOfClass:[ListEmailsResponse class]]) {
        ListEmailsResponse *response = _responseObject;
        
        //Recuperation des comptes dans CoreData
        NSMutableArray *listEmails = [[response emails] copy];
        
        if ([listEmails count] > 0){
            //Si on recoit un tableau avec une seule entrée, c'est qu'on n'a pas le choix du mail non plus,
            //donc même commentaire que 10 lignes au dessus
            if ([listEmails count] == 1) {
                if ([[listEmails objectAtIndex:0] length] > 0) {
                    [AccesToUserDefaults setUserInfoChoiceMail:[listEmails objectAtIndex:0]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_SUCCESSFUL_NOTIF
                                                                        object:FIRST_CONNEXION];
                } else {
                    [self displayAlertWithMessage:NSLocalizedString(@"ERREUR_NO_MESSAGERIE",
                                                                    @"Pas de messagerie associé")];
                    [spinn setHidden:YES];
                }
                //Si plusieurs mail, affichage de ChoixMessagerie
            } else {
                ChoixMessagerieViewController *choixMsgViewController;
                
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                    choixMsgViewController = [[ChoixMessagerieViewController alloc] initWithNibName:@"ChoixMessagerieController_iPhone" bundle:nil];
                } else {
                    choixMsgViewController = [[ChoixMessagerieViewController alloc] initWithNibName:@"ChoixMessagerieController_iPad" bundle:nil];
                }
                
                [choixMsgViewController.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
                [self.navigationController pushViewController:choixMsgViewController animated:YES];
                [choixMsgViewController reloadListMails:listEmails];
            }
        } else {
            [self displayAlertWithMessage:NSLocalizedString(@"ERREUR_NO_MESSAGERIE", @"Pas de messagerie associé")];
            [spinn setHidden:YES];
        }
    } else if ([_responseObject isKindOfClass:[ListFoldersResponse class]]) {
        id obj = nil;
        if (firstConnection) {
            obj = FIRST_CONNEXION;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_SUCCESSFUL_NOTIF object:obj];
    } else {
        [self displayAlertWithMessage:NSLocalizedString(@"ERREUR_WEB_SERVICE", @"Le Web Service n'a pas renvoyé la bonne information")];
        [spinn setHidden:YES];
    }
}

//Appeler si Request (dans la méthode runGetBalRequestWithIdPS) à échoué grâce au delegate
-(void)httpError:(Error*)error {
    [self hideLoading:nil];
    
    if (error != nil) {
        DLog(@"ConnectionView Error Msg: %@", [error errorMsg]);
        DLog(@"ConnectionView Status Code: %d", [error httpStatusCode]);
        DLog(@"ConnectionView Error Code: %d", [error errorCode]);
        
        [self.popupView setHidden:YES];
        if ([error errorCode] == ERROR_TO_DISPLAY_IN_CONTROLER && [AccesToUserDefaults getUserInfoChoiceMail] != nil && [AccesToUserDefaults getUserInfoSyncToken] !=nil) {
            //[self loginOffline];
            if ([error errorCode ] == 35 && [[NSUserDefaults standardUserDefaults] boolForKey:IS_ABLE_TO_CONNECT]){
                [spinn setHidden:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_SUCCESSFUL_NOTIF object:nil];
            }
            
        } else {
            NSString *errorMsg = [error errorMsg];
            if ([error errorCode] == 34){
                errorMsg = NSLocalizedString(@"ERREUR_NO_MESSAGERIE", @"Authentification impossible : l’utilisateur n’a pas d’adresse de messagerie");
            } else if ([error errorCode] == 0){
                errorMsg = NSLocalizedString(@"INFO_CONNEXION_INVALID", @"Les informations de connexion sont invalides");
            }
            
            [self.Password setText:@""];
            [self displayAlertWithMessage:errorMsg];
            
            DLog(@"Showing Error %@", errorMsg);
        }
    }
}

- (void)syncSucces:(id)responseObject {
    DLog(@"syncSucces : %@", [responseObject description]);
    
    [self hideLoading:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_SUCCESSFUL_NOTIF object:nil];
}

- (void)syncError:(id)_error {
    DLog(@"syncError: %@", [_error description]);
    DLog(@"errorCode: %d", [_error errorCode]);
    DLog(@"errorMsg: %@", [_error errorMsg]);
    
    [self hideLoading:nil];
    if (_error != nil && [_error errorCode] != 0) {
        [self displayAlertWithMessage:[_error errorMsg]];
    }
}


#pragma mark - Text Field
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    mdp = newString;
    
    return YES;
}

- (void)textFieldDidEndEditing: (UITextField *)sender {
    if ([sender isEqual:self.Password]) {
        mdp = sender.text;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Keyboard
- (void)keyboardDidShowController:(NSNotification*)notification {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.view.center = CGPointMake(self.view.center.x, self.view.center.y - kOFFSET_FOR_KEYBOARD);
    } else {
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            self.view.center = CGPointMake(self.view.center.x, self.view.center.y - kOFFSET_FOR_KEYBOARD - 70);
        }
    }
    
    [UIView commitAnimations];
}

- (void)keyboardDidHideController:(NSNotification*)notification {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.view.center = CGPointMake(self.view.center.x, self.view.center.y + kOFFSET_FOR_KEYBOARD);
    } else {
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            //@ TD 17990
            //self.view.center = CGPointMake(self.view.center.x, self.view.center.y + kOFFSET_FOR_KEYBOARD + 70);
            self.view.center = CGPointMake(screenRect.size.width/2, screenRect.size.height/2);
        }
    }
    
    [UIView commitAnimations];
}


#pragma mark - Connection
- (IBAction)reEnrolement:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:REENROLLEMENT_NOTIF object:nil];
    [spinn setHidden:YES];
}

- (IBAction)ResterConnecte:(id)sender {
    // [self toggleRememberMe];
}

- (IBAction)Login:(id)sender {
    [spinn setHidden:NO];
    [self textFieldShouldReturn:[self Password]];
    //[self.Password resignFirstResponder];
    
    NSString *currentPush = [AccesToUserDefaults getIdPush];
    DLog(@"currentPush %@",currentPush);
    
    /* @WX - Amélioration
     * En mettant ces 3 conditions, le temps d'attente est plus court
     * Ceci a pour but de donner une meilleure expérience client
     */
    if ([self isValidNbCharPassword] && ![self isBlockAccount] && [self isValidPassword]) {
        /* @WX - Anomalie 18112
         * Problème : Dédoublement des brouillons enregistrés
         * Solution : Laisser un peu de temps à la requête de s'exécuter (la requête qui crée le brouillon)
         */
        dispatch_group_t group = dispatch_group_create();
        
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            // Donne un peu de temps pour savoir s'il y a d'autres requêtes à exécuter
            // avant de lancer la synchronisation entre la BDD et l'application
            [NSThread sleepForTimeInterval:2.0];
            
            while (![[RequestQueue sharedInstanceQueue] isEmpty]) {
                [NSThread sleepForTimeInterval:6.0];
            }
        });

        // Cette étape est exécutée lorsque la partie du dessus est terminée
        dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            /* @WX - Anomalie 18086
             * Problème : A l'étape 1 d'enrôlement, on a un affichage d'erreur "Veuillez vous enrôler de nouveau"
             * Solution : Mettre un booléen pour savoir si on est bien à cette étape
             *
             * (cf. MasterViewController -> syncError & Request -> handleRequestError)
             */
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IS_NOT_ENROLLEMENT];
            
            /* @WX - Anomalie liée au 18017
             * Problème survenu : Pendant l'écriture d'un nouveau message (ou lecture d'un message),
             * l'utilisateur désire se déconnecter sans changer de page (ou de vue). L'aplication se déconnecte bien
             * mais elle se reconnecte automatiquement sans que l'utilisateur ait besoin de mettre son mot de passe.
             * (cf. LOGIN_SUCCESSFUL_NOTIF dans "Request" & dans "ConnectionController" -> "loginOffline"
             *
             * Solution apportée : Mettre un booléen permettant de savoir si l'utilisateur s'est connecté ou pas
             *
             * Ici, on met à jour le booléen à "YES" pour montrer que l'utilisateur s'est connecté
             */
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IS_ABLE_TO_CONNECT];
            /* @WX - Fin des modifications */
            
            DLog(@"[AccesToUserDefaults getIdPushEnrolement] %@",[AccesToUserDefaults getIdPushEnrolement]);
            if (![currentPush isEqualToString:[AccesToUserDefaults getIdPushEnrolement]]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERREUR", @"Erreur")
                                                                message:NSLocalizedString(@"VEUILLEZ_VOUS_ENROLLER_DE_NOUVEAU", @"Veuillez vous enrôler de nouveau")
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                                      otherButtonTitles:nil];
                [alert show];
                
                DLog(@"VEUILLEZ_VOUS_ENROLLER_DE_NOUVEAU [AccesToUserDefaults getIdPushEnrolement] %@", [AccesToUserDefaults getIdPushEnrolement]);
                [spinn setHidden:YES];
            } else {
                if([AppDelegate checkNotif]) {
                    [self Continuer:nil];
                } else {
                    [spinn setHidden:YES];
                }
            }
        });
    }
}

- (IBAction)Continuer:(id)sender {
    [self.popupView setHidden:YES];
    [[Authentification sharedInstance] setCanceled:NO];
    
    if ([AccesToUserDefaults getUserInfoChoiceMail] != nil && [AccesToUserDefaults getUserInfoSyncToken] != nil) {
        DLog(@"Not First Time Login");
        [self loginOffline];
    } else {
        DLog(@"First Time Login");
        loginOfflineStatus = LOGIN_STATUS_NO_EMAIL;
    }
    
    DLog(@"loginOfflineStatus %d", loginOfflineStatus);
    if ([self isConnectedToInternet]) {
        if ([self isValidNbCharPassword]) {
            [[Authentification sharedInstance] setUserPassword:mdp];
            [self runGetBalRequestWithIdPS:[AccesToUserDefaults getUserInfoIdNat]];
        }
    } else if(loginOfflineStatus == LOGIN_STATUS_NO_EMAIL) {
        [self displayAlertWithMessage:NSLocalizedString(@"CONNEXION_IMPOSSIBLE", @"Connexion impossible")];
        [spinn setHidden:YES];
    }
}

- (void)loginOffline {
    loginOfflineStatus = LOGIN_STATUS_ERROR;
    
    if ([self isValidNbCharPassword] && ![self isBlockAccount] && [self isValidPassword]) {
        DLog(@"Login offline validPassword");
        
        PasswordStore *passwordInstance = [PasswordStore getInstanceWithPlainPassword:mdp];
        
        [[Authentification sharedInstance] setUserPassword:mdp];
        
        NSString *key = [passwordInstance getPlainDbEncryptionKey];
        DLog(@"ConnectionController - loginOffline - setKey : %@", key);
        
        [DAOFactory setKey:key];
        
        DAOFactory *factory = [DAOFactory factory];
        DLog(@"factory %@",factory);
        
        loginOfflineStatus = LOGIN_STATUS_SUCCESS;
        
        if (factory.managedObjectContext == nil) {
            DLog(@"Request : HandleSuccess : creating managedObjectContext");
            
            if ([factory resetManagedObjectContext] != nil) {
                [factory.managedObjectContext setRetainsRegisteredObjects:YES];
                DLog(@"[factory managedObjectContext] %@",factory.managedObjectContext );
                
            } else {
                DLog(@"Request : HandleSuccess : probleme creating managedObjectContext");
                loginOfflineStatus = LOGIN_STATUS_ERROR;
                [PasswordStore resetPasswords];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:DECONNEXION_NOTIF object:ENROLLEMENT];
                [self displayAlertWithMessage:NSLocalizedString(@"PROBLEME_BD", @"Problème d'initialisation de base de données")];
                [spinn setHidden:YES];
            }
        }
        
        if (loginOfflineStatus == LOGIN_STATUS_SUCCESS) {
            //@TD 16670
            /* @WX - Anomalie liée au 18017
             * Problème survenu : Pendant l'écriture d'un nouveau message (ou lecture d'un message),
             * l'utilisateur désire se déconnecter sans changer de page (ou de vue). L'aplication se déconnecte bien
             * mais elle se reconnecte automatiquement sans que l'utilisateur ait besoin de mettre son mot de passe.
             *
             * Solution apportée : Mettre un booléen permettant de savoir si l'utilisateur s'est connecté ou pas
             * [[NSUserDefaults standardUserDefaults] boolForKey:@"isAbleToConnect"]
             * (Mis en commentaire de la solution car anomalie pas totalement résolue)
             */
            if (![self isConnectedToInternet] &&  ([AccesToUserDefaults getUserInfoChoiceMail] != nil && [AccesToUserDefaults getUserInfoSyncToken] !=nil) && [[NSUserDefaults standardUserDefaults] boolForKey:IS_ABLE_TO_CONNECT]){
                [spinn setHidden:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_SUCCESSFUL_NOTIF object:nil];
            } else {
                NSLog(@"NOP");
            }
        }
    }
}

- (IBAction)CancelNoAccount:(id)sender {
    [self.popupNoAccount setHidden:YES];
}

- (void)NoAccountAction:(id)sender {
    [self.popupNoAccount setHidden:NO];
}


#pragma mark - Checking Functions
- (BOOL)isBlockAccount {
    currentTime = [NSNumber numberWithDouble:CACurrentMediaTime()];
    lastLoginTime = nil;
    
    if ([AccesToUserDefaults getUserInfoLoginTimestamp]) {
        lastLoginTime = [AccesToUserDefaults getUserInfoLoginTimestamp];
    }
    
    BOOL isBlock = YES;
    if ([loginCounter intValue] < 3) {
        isBlock = NO;
    } else {
        
        if (lastLoginTime && [currentTime doubleValue] - [lastLoginTime doubleValue] < TIMEOUT_LOGOUT_15MIN * 60) {
            [self displayAlertWithMessage:NSLocalizedString(@"COMPTE_BLOQUE", @"Compte bloqué")];
            loginOfflineStatus = LOGIN_STATUS_ACCOUNT_BLOCKED;
        } else {
            isBlock = NO;
            /* @WX - Amélioration Sonar
             * [NSNumber numberWithInt:0] <=> @0
             */
            loginCounter = @0;
        }
        
    }
    loginCounter = [NSNumber numberWithInt:[loginCounter intValue]+1];
    [AccesToUserDefaults setUserInfoLoginCounter:loginCounter];
    
    if([loginCounter intValue] == 3) {
        [AccesToUserDefaults setUserInfoLoginTimestamp:currentTime];
    }
    
    return isBlock;
}

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
            int nb = [regex   numberOfMatchesInString:_string options:0 range:NSMakeRange(0, _string.length)];
            return nb != 0 ;
        }
    }
    
    return ![@"" isEqualToString:result];
}

- (BOOL)isValidNbCharPassword {
    BOOL isValidNbCharPassword = NO;
    
    NSString *passwordToCheck = [mdp stringByReplacingOccurrencesOfString:@" "
                                                               withString:@""];
    if ([passwordToCheck length] >= MIN_PASSWORD && [passwordToCheck length] <= MAX_PASSWORD
        && [passwordToCheck isEqualToString:mdp] && [self regexFindMatch:passwordToCheck]) {
        isValidNbCharPassword = YES;
    } else {
        [self displayAlertWithMessage:NSLocalizedString(@"INFO_CONNEXION_INVALID", @"Les informations de connexion sont invalides")];
        [self.Password setText:@""];
        loginOfflineStatus = LOGIN_STATUS_WRONG_CREDINTIALS;
    }
    return isValidNbCharPassword;
}

- (BOOL)isValidPassword {
    BOOL isValidPassword;
    
    if ([PasswordStore verifyPassword:mdp]) {
        /* @WX - Amélioration Sonar
         * [NSNumber numberWithInt:0] <=> @0
         */
        loginCounter = @0;
        [AccesToUserDefaults setUserInfoLoginCounter:loginCounter];
        isValidPassword = YES;
    } else {
        isValidPassword = NO;
        [self displayAlertWithMessage:NSLocalizedString(@"INFO_CONNEXION_INVALID", @"Les informations de connexion sont invalides")];
        loginOfflineStatus = LOGIN_STATUS_WRONG_CREDINTIALS;
        [self.Password setText:@""];
        [spinn setHidden:YES];
    }
    
    return isValidPassword;
}

- (BOOL)isConnectedToInternet {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    if (networkStatus == NotReachable) {
        DLog(@"NO INTERNET");
        return NO;
    }
    
    DLog(@"INTERNET ACCESS OK");
    return YES;
}


#pragma mark - Alert View
- (void)displayAlertWithMessage:(NSString*)_message {
    DLog(@"displayAlertWithMessage");
    
    if (!isErrorShown) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERREUR", @"Erreur")
                                                        message:_message
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                              otherButtonTitles:nil];
        
        [alert show];
        isErrorShown = YES;
        [spinn setHidden:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    isErrorShown = NO;
}


#pragma mark - Spinner View
- (void)hideLoading:(NSNotification*)notification {
    [spinnerView removeFromSuperview];
    [spinn setHidden:YES];
}

- (UIView *)createSpinnerView {
    UIActivityIndicatorView *activityIndicator;
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    activityIndicator.frame = CGRectMake(0.0, 0.0, 20,20);
    activityIndicator.color = [UIColor whiteColor];
    [activityIndicator startAnimating];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIView *spinnerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    
    [spinnerV setBackgroundColor:[UIColor blackColor]];
    [spinnerV setAlpha:0.5];
    [spinnerV setHidden:YES];
    [spinnerV addSubview:activityIndicator];
    
    NSLayoutConstraint *myConstraint = [NSLayoutConstraint constraintWithItem:activityIndicator
                                                                    attribute:NSLayoutAttributeCenterX
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:spinnerV
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:1
                                                                     constant:0];
    [spinnerV addConstraint:myConstraint];
    
    myConstraint = [NSLayoutConstraint constraintWithItem:activityIndicator
                                                attribute:NSLayoutAttributeCenterY
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:spinnerV
                                                attribute:NSLayoutAttributeCenterY
                                               multiplier:1
                                                 constant:0];
    [spinnerV addConstraint:myConstraint];
    
    return spinnerV;
}

#pragma mark - Managing Orientation
- (void)orientationChanged:(NSNotification*)notification {
    /* @WX - Amélioration */
    [spinn setFrame:[[UIScreen mainScreen] bounds]];
    /* @WX - Fin des modifications */
}

@end
