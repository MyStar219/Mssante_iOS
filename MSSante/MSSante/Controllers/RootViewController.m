//
//  RootViewController.m
//  MSSante
//
//  Created by Labinnovation on 26/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "RootViewController.h"
#import "AccesToUserDefaults.h"
#import "AccueilController.h"
#import "ConnectionController.h"
#import "EnrollementController.h"
#import "ContainerViewController.h"
#import "NouveauMessageViewController2.h"
#import "DossierController.h"
#import "SyncAndLaunchModification.h"
#import "Request.h"
#import "SyncInput.h"
#import "ELCUIApplication.h"
#import "PasswordStore.h"
#import "RequestQueue.h"

#import "NPConverter.h"
#import "NPMessage.h"

#import "AttachmentManager.h"

#define IS_IOS_7_OR_EARLIER   ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)

@interface RootViewController () {
    BOOL isFirstConnection;
}

@end

@implementation RootViewController
@synthesize masterViewController, masterViewControllerDossier, navController;
BOOL isPanelIsOpen=NO;
NouveauMessageViewController2 *newMsgController;
ConnectionController *connectionController;

//static BOOL changeNotificationStateIsRunning;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        DLog(@"init RootViewController");
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    DLog(@"viewDidLoad RootViewController");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidTimeout:) name:kApplicationDidTimeoutNotification object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidTimeout:) name:APPLICATION_TIMEOUT_NOTIF object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess:) name:LOGIN_SUCCESSFUL_NOTIF object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ReEnrollement:) name:REENROLLEMENT_NOTIF object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Deconnexion:) name:DECONNEXION_NOTIF object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(slideToOpen:) name:SLIDE_BACK_MENU_NOTIF object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNewMsg:) name:SHOW_NEW_MSG_VIEW_NOTIF object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideNewMsg:) name:HIDE_NEW_MSG_VIEW_NOTIF object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMoveMsg:) name:SHOW_MOVE_MSG_VIEW_NOTIF object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideMoveMsg:) name:HIDE_MOVE_MSG_VIEW_NOTIF object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewAttachmentFromNewMsg:) name:VIEW_ATTACHMENT_FROM_NEW_MSG object:nil];
    
    navController = [[UINavigationController alloc] init];
    currentFolderId = [NSNumber numberWithInt:RECEPTION_ID_FOLDER];
    
    isLoginSuccess = NO;
    isReEnrollement = NO;
    isInit = YES;
    self.masterViewController.changeNotificationStateIsRunning = NO;
    //    changeNotificationStateIsRunning = NO;
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChangedPanel:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
}

-(void)setSessionTimer{
    if (sessionTimer) {
        [sessionTimer invalidate];
        sessionTimer=nil;
    }
    
    int timeout = TIMEOUT_LOGOUT_4H * 60 * 60;
    sessionTimer = [NSTimer scheduledTimerWithTimeInterval:timeout
                                                    target:self
                                                  selector:@selector(applicationDidTimeout:)
                                                  userInfo:nil
                                                   repeats:NO];
}

- (void)sessionExpired:(id)sender{
    DLog(@"sessionTimeout");
    [self Deconnexion:nil];
}
- (void) applicationDidTimeout:(NSNotification *) notif {
    DLog(@"applicationDidTimeout");
    //@TD 18018- on dismiss la vue nouveauMessageController lors du timeOut
    [newMsgController dismissViewControllerAnimated:YES completion:nil];
    [self Deconnexion:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    
    isPanelIsOpen=NO;
    DLog(@"viewDidAppear RootViewController");
    
    centerY = self.contentView.center.y;
    centerX = self.contentView.center.x;
    self.masterViewController = [self.containerViewController getMasterViewController];
    [self.masterViewController setBackMenuViewController:self.backMenuViewController];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePanel:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setDelegate:self];
    [self.contentView addGestureRecognizer:panRecognizer];
    
    
    if(![AccesToUserDefaults getUserInfoEnrollement]) {
        DLog(@"not enrolled show AccueilController");
        AccueilController *accueilController;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            accueilController = [[AccueilController alloc] initWithNibName:@"AccueilController_iPhone" bundle:nil];
        } else {
            accueilController = [[AccueilController alloc] initWithNibName:@"AccueilController_iPad" bundle:nil];
        }
        
        [accueilController.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [navController pushViewController:accueilController animated:YES];
        
        [self presentViewController:navController animated:YES completion:nil];
        DLog(@"presentViewController AccueilController");
    } else if (!isLoginSuccess && !isReEnrollement){
        
        ConnectionController *connectionController;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            connectionController = [[ConnectionController alloc] initWithNibName:@"ConnectionController_iPhone" bundle:nil];
        } else {
            connectionController = [[ConnectionController alloc] initWithNibName:@"ConnectionController_iPad" bundle:nil];
        }
        
        [connectionController.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [navController pushViewController:connectionController animated:YES];
        [self presentViewController:navController animated:YES completion:nil];
    }
    else if (isInit || isReturnOfMoveFolder){
        isReturnOfMoveFolder = FALSE;
        isInit = FALSE;
        // Résolution Anomalie 16188
        //[self setSessionTimer];
        [self.masterViewController mailTitleLabel].text = [AccesToUserDefaults getUserInfoChoiceMail];
        if (![AccesToUserDefaults getUserInfoEnrollement] && ![PasswordStore plainPasswordIsSet]) {
            NSLog(@"![PasswordStore plainPasswordIsSet])");
            [self.masterViewController.listMessagesMaster removeAllObjects];
        }
        [self.masterViewController loadMasterControllerWithFolder:currentFolderId inFolderSubView:NO isInit:YES];
        
    }
}

-(void) checkNetworkStatus:(NSNotification *)notice {
    DLog(@"checkNetworkStatus");
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    //    DLog(@"[PasswordStore plainPasswordIsSet] %d",[PasswordStore plainPasswordIsSet]);
    //    DLog(@"[PasswordStore plainPassword] %@",[[PasswordStore getInstance] getPlainPassword]);
    if (internetStatus != NotReachable && [AccesToUserDefaults getUserInfoEnrollement] && [PasswordStore plainPasswordIsSet] && [AccesToUserDefaults getUserInfoSyncToken]){
        SyncAndLaunchModification *goModif = [[SyncAndLaunchModification alloc] init];
        [goModif syncOnlyFolderId:self.masterViewController.masterFolderId];
        goModif.delegate = self.masterViewController;
        [goModif execute];
    }
}

-(void)launchControllerWithSegue:(NSString*)segue{
    [self.containerViewController launchControllerWithSegue:segue];
}

//Au démarrage, on lance directement les deux controller contenu dans celui ci (à la manière d'un splitView)
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"BackMenuSegue"]) {
        self.backMenuViewController = (BackMenuViewController *) [segue destinationViewController];
    }
    if ([segueName isEqualToString:@"embedContainer"]) {
        self.containerViewController = segue.destinationViewController;
    }
    if ([segueName isEqualToString:@"segueToDetail"]) {
        self.detailViewController = [[(UINavigationController*) segue.destinationViewController childViewControllers] objectAtIndex:0];
    }
    if ([segueName isEqualToString:@"segueRootToSelectDossier"]) {
        SelectDossierController *selectDossierController;
        selectDossierController = [[(UINavigationController*) segue.destinationViewController childViewControllers] objectAtIndex:0];
        NSMutableDictionary* infos = sender;
        
        DLog(@"[infos objectForKey:CURRENT_FOLDER_ID] %@",[infos objectForKey:CURRENT_FOLDER_ID]);
        [selectDossierController setSelectedMessages:[infos objectForKey:SELECTED_MESSAGE]];
        [selectDossierController setMasterfolderId:[infos objectForKey:MASTER_FOLDER_ID]];
        [selectDossierController setMessageFolderId:currentFolderId];
    }
}

-(void)loginSuccess:(NSNotification*)pNotification{
    
    NSString *notifObject = @"";
    
    if (pNotification){
        notifObject = pNotification.object;
    }
    
    isFirstConnection = NO;
    if ([FIRST_CONNEXION isEqualToString:notifObject]) {
        isFirstConnection = YES;
        DLog(@"LoginProcess : Login Successful : First Connection");
    } else {
        DLog(@"LoginProcess : Login Successful : Not First Connection");
    }
    
    
    [self setSessionTimer];
    
    [(ELCUIApplication *)[UIApplication sharedApplication] setEnableTouchTimer:TRUE];
    [(ELCUIApplication *)[UIApplication sharedApplication] resetIdleTimer];
    
    [self enableUserInteractionForTableView:TRUE];
    
    [self.view setHidden:NO];
    isLoginSuccess = TRUE;
    [self.masterViewController mailTitleLabel].text = [AccesToUserDefaults getUserInfoChoiceMail];
    
    if (![AccesToUserDefaults getUserInfoEmailNotificationInitalized]) {
        DLog(@"changeNotificationStateIsRunning %d",self.masterViewController.changeNotificationStateIsRunning);
        if (!self.masterViewController.changeNotificationStateIsRunning) {
            [self runChangeNotificationState];
        }
    } else {
        
        if ([AccesToUserDefaults getUserInfoSyncToken]) {
            DLog(@"LoginProcess : Login Successful : EmailNotification is Initialized, sync token exists calling loadMasterControllerWithFolder");
            [self.masterViewController loadMasterControllerWithFolder:[NSNumber numberWithInt:RECEPTION_ID_FOLDER] inFolderSubView:NO isInit:isFirstConnection];
        } else {
            [self.masterViewController initialiserMessages];
            DLog(@"LoginProcess : Login Successful : EmailNotification is Initialized, sync token doesn't exists calling calling initialiserMessages");
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)runChangeNotificationState {
    DLog(@"LoginProcess : Login Successful : EmailNotification not Initialized, calling ChangeNotificationState");
    NSString *email = [AccesToUserDefaults getUserInfoChoiceMail];
    NSString *idPush = [AccesToUserDefaults getIdPush];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    //Pour éviter crash de l'application
    if (email==nil) {
        DLog(@"email: %@", email);
        email= @"";
    }
    NSMutableDictionary *changeNotificationStateInput = [NSMutableDictionary dictionary];
    
    [changeNotificationStateInput setObject:idPush forKey:PUSH_ID];
    [changeNotificationStateInput setObject:email forKey:EMAIL];
    [changeNotificationStateInput setObject:[NSNumber numberWithBool:YES] forKey:@"isActivated"];
    
    
    [params setObject:changeNotificationStateInput forKey:CHANGE_NOTIF_STATE_INPUT];
    
    Request *notificationRequest = [[Request alloc] initWithService:S_CHANGE_NOTIF_STATE method:HTTP_POST params:params];
    notificationRequest.delegate = self;
    
    //    [self.masterViewController.loadingView setHidden:NO];
    [self.masterViewController.whiteView setHidden:NO];
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.masterViewController.spinnerView];
    
    self.masterViewController.changeNotificationStateIsRunning = YES;
    [notificationRequest execute];
}

-(void)httpResponse:(id)_responseObject {
    DLog(@"RootResponse : responseObject : %@", _responseObject);
    if ([_responseObject isKindOfClass:[SyncMessagesResponse class]]){
        SyncMessagesResponse* syncMessagesResponse = _responseObject;
        [AccesToUserDefaults setUserInfoSyncToken:[syncMessagesResponse.syncDictionary objectForKey:TOKEN]];
    } else if([S_CHANGE_NOTIF_STATE isEqualToString:_responseObject]){
        [AccesToUserDefaults setUserInfoEmailNotification:YES];
        [AccesToUserDefaults setUserInfoEmailNotificationInitailized:YES];
        [self.masterViewController initialiserMessages];
        self.masterViewController.changeNotificationStateIsRunning = NO;
        DLog(@"LoginProcess : Login Successful : EmailNotification is Initialized, calling initialiserMessages");
    }
}

-(void)httpError:(Error *)_error {
    [self.masterViewController.spinnerView removeFromSuperview];
    DLog(@"RootError : _error : %@", _error);
    DLog(@"RootError : _error : msg : %@", _error.errorMsg);
    DLog(@"RootError : _error : code : %d", _error.errorCode);
    if (_error != nil){
        [self Deconnexion:nil];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[_error title]
                                                        message:[_error errorMsg]
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                              otherButtonTitles:nil];
        [alert show];
    }
    self.masterViewController.changeNotificationStateIsRunning = NO;
}

-(void)Deconnexion:(NSNotification*)pNotification{
    DLog(@"RootViewController Deconnexion");
    
    /* @WX - Anomalie 18017
     * On mets en parallèle l'exécution saveDraft
     * (Mis en commentaire de la solution car anomalie pas totalement résolue)
     */
    /*dispatch_group_t group = dispatch_group_create();
     
     if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateBackground) {
     dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
     // Donne un peu de temps pour finir les autres tâches (les requêtes dans "RequestQueue", etc ...)
     [NSThread sleepForTimeInterval:6.0];
     
     //Permet de sauvegarder le brouillon quand on se déconnecte de l'application
     [[NSNotificationCenter defaultCenter] postNotificationName:@"saveDraft" object:@"saveDraft"];
     
     // Donne un peu de temps d'exécution pour la fonction saveDraft avant de finir nettoyer la file de requêtes
     [NSThread sleepForTimeInterval:6.0];
     });
     }*/
    /* @WX - Fin des modifications */
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        /* @WX - Anomalie 17878 (version iOS 7)
         * On fait d'abord apparaître la boîte de réception puis la déconnexion
         * Cas : Ecriture d'un nouveau message
         */
        if (IS_IOS_7_OR_EARLIER && [[self.masterViewController.navigationController visibleViewController] isKindOfClass:[NouveauMessageViewController2 class]]) {
            [self.masterViewController.navigationController popToRootViewControllerAnimated:NO];
        }
        
        /* @WX - Anomalie 17878
         * On fait d'abord apparaître la boîte de réception puis la déconnexion
         * Cas : Ouverture d'un message existant
         */
        if([[self.masterViewController.navigationController topViewController] isKindOfClass:[MessageDetailViewController class]]) {
            [self.masterViewController.navigationController popViewControllerAnimated:NO];
        }
        /* @WX - Fin des modifications */
        connectionController = [[ConnectionController alloc] initWithNibName:@"ConnectionController_iPhone" bundle:nil];
    } else {
        connectionController = [[ConnectionController alloc] initWithNibName:@"ConnectionController_iPad" bundle:nil];
    }
    
    //@TD
    //Permet de sauvegarder le brouillon quand on se deconnecte de l'application
    // [[NSNotificationCenter defaultCenter] postNotificationName:@"saveDraft" object:@"saveDraft"];
    
    /* @WX - Anomalie 18017
     * Remarque sur la modification par TD
     * Changement pour la sauvegarde du brouillon (voir plus haut)
     * Mis en commentaire de l'instruction saveDraft
     */
    
    DLog(@"Deconnexion");
    if ([ENROLLEMENT isEqualToString:pNotification.object]) {
        DLog(@"ENROLLEMENT : %@", pNotification.object);
        [self ReEnrollement:pNotification];
    }
    
    if (sessionTimer) {
        [sessionTimer invalidate];
    }
    
    [(ELCUIApplication *)[UIApplication sharedApplication] invalidateTimer];
    [(ELCUIApplication *)[UIApplication sharedApplication] setEnableTouchTimer:FALSE];
    
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage]cookies];
    for (NSHTTPCookie *cookie in cookies){
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    
    [self enableUserInteractionForTableView:TRUE];
    
    /*if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
     connectionController = [[ConnectionController alloc] initWithNibName:@"ConnectionController_iPhone" bundle:nil];
     } else {
     connectionController = [[ConnectionController alloc] initWithNibName:@"ConnectionController_iPad" bundle:nil];
     }*/
    
    isInit = TRUE;
    
    //    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    //        //[self dismissViewControllerAnimated:NO completion:^{}];
    //         [navController popViewControllerAnimated:YES];
    //    } else {
    //
    //    }
    
    //@TD : Correctif bogue: infinite reload connection view
    [navController popViewControllerAnimated:YES];
    
    currentFolderId = [NSNumber numberWithInt:RECEPTION_ID_FOLDER];
    [self.backMenuViewController setSelectedRow:0];
    navController = [[UINavigationController alloc] init];
    [connectionController.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [navController pushViewController:connectionController animated:YES];
    [self presentViewController:navController animated:YES completion:nil];
    [self.containerViewController launchControllerWithSegue:MASTER_SEGUE];
    [PasswordStore deletePlainPassword];
    NSLog(@"PasswordStore deletePlainPassword");
    
    /* @WX - Anomalie 18017
     * A la fin de l'exécution saveDraft, on vide la file de requêtes
     * (Mis en commentaire de la solution car anomalie pas totalement résolue)
     */
    [[RequestQueue sharedInstanceQueue] empty];
    /*dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
     [[RequestQueue sharedInstanceQueue] empty];
     });*/
    /* @WX - Fin de la modification */
    
    [AccesToUserDefaults setUserInfoLoginCounter:[NSNumber numberWithInt:0]];
    
    /* @WX - Anomalie liée au 18017
     * Problème survenu : Pendant l'écriture d'un nouveau message (ou lecture d'un message),
     * l'utilisateur désire se déconnecter sans changer de page (ou de vue). L'aplication se déconnecte bien
     * mais elle se reconnecte automatiquement sans que l'utilisateur ait besoin de mettre son mot de passe.
     * (cf. LOGIN_SUCCESSFUL_NOTIF dans "Request" & dans "ConnectionController" -> "loginOffline"
     *
     * Solution apportée : Mettre un booléen permettant de savoir si l'utilisateur s'est connecté ou pas
     *
     * Ici, on met à jour le booléen à "NO" pour montrer que l'utilisateur s'est déconnecté
     */
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:IS_ABLE_TO_CONNECT];
    /* @WX - Fin des modifications */
    
    [[Authentification sharedInstance] reset];
    
    /* @WX - Anomalie liée à 18112
     * Problème : En se déconnectant à partir de n'importe quel dossier sauf la boîte de réception,
     * le titre de la boîte de réception est le nom du dossier dernièrement utilisé.
     */
    [[[self masterViewController] titleLabel] setText:@"Réception"];
    [[self masterViewController] displayMessageOfFolder:[NSNumber numberWithInt:RECEPTION_ID_FOLDER]];
    /* @WX - Fin des modifications */
}

-(void)ReEnrollement:(NSNotification*)pNotification{
    //TO CHECK
    
    DLog(@"ReEnrollement");
    [self.masterViewController deleteTableViewContent];
    //@ANO 16053
    //currentFolderId = [NSNumber numberWithInt:RECEPTION_ID_FOLDER];
    isReEnrollement = TRUE;
    isInit = NO;
    [self.view setHidden:YES];
    //@ANO 16053
    //[self.containerViewController launchControllerWithSegue:MASTER_SEGUE];
    [self dismissViewControllerAnimated:NO completion:^{
        [DAOFactory deleteFactory];
        NSLog(@"DAO deleteFactory");
        [self emptyDatabase];
        
        [AccesToUserDefaults resetUserInfo];
        [PasswordStore resetPasswords];
        NSLog(@"PasswordStore deletePlainPassword");
        
        // @WX & TD Correction Anomalie 17873
        if (self.masterViewController.detailViewController) {
            [self.masterViewController.detailViewController setDetailItem:nil];
        }
        
        EnrollementController *enrollementController;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            enrollementController = [[EnrollementController alloc] initWithNibName:@"EnrollementController_iPhone" bundle:nil];
        } else {
            enrollementController = [[EnrollementController alloc] initWithNibName:@"EnrollementController_iPad" bundle:nil];
        }
        //@ANO 16053 - ne pas accéder au backMenuViewController
        //[self.backMenuViewController setSelectedRow:0];
        navController = [[UINavigationController alloc] init];
        
        BOOL present = YES;
        if ([self.presentedViewController isMemberOfClass:[UINavigationController class]]) {
            navController = (UINavigationController*) self.presentedViewController;
            present = NO;
        }
        
        [navController pushViewController:enrollementController animated:YES];
        if (present) {
            [self presentViewController:navController animated:YES completion:nil];
        }
        
        
    }];
    
}

-(void)emptyDatabase {
    //    NSError *error = nil;
    //    if ([[[PasswordStore getInstance] getPlainPassword] length] > 0) {
    //
    //        DAOFactory *factory = [DAOFactory factory];
    //        if ([factory.managedObjectContext hasChanges] && ![factory save:&error]) {
    //            /*
    //             Replace this implementation with code to handle the error appropriately.
    //
    //             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
    //             */
    //            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
    //            abort();
    //        }
    //
    //        NSPersistentStoreCoordinator *persistentStoreCoordinator = [[DAOFactory factory] persistentStoreCoordinator];
    //        NSArray *stores = [persistentStoreCoordinator persistentStores];
    //        NSURL *storeURL = nil;
    //        for(NSPersistentStore *store in stores) {
    //            DLog(@"STORE: %@",store);
    //            [persistentStoreCoordinator removePersistentStore:store error:nil];
    //            [[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:nil];
    //            storeURL = store.URL;
    //        }
    //
    //        if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
    //            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
    //            abort();
    //        }
    //    } else {
    DLog(@"DAOFactory %@",[DAOFactory factory]);
    NSString *dbPath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"MSSante.sqlite"];
    NSLog(@"in emptyDatabase  : removeItemAtPath : DbPath ");
    [[NSFileManager defaultManager] removeItemAtPath:dbPath error:nil];
    //    }
}


- (NSString *)applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

-(void)showNewMsg:(NSNotification *)pNotification{
    newMsgController = [[NouveauMessageViewController2 alloc] init];
    
    id contents = pNotification.object;
    NPMessage* npMessage = nil;
    if ([[contents objectForKey:MESSAGE] isKindOfClass:[Message class]]) {
        Message* message = [contents objectForKey:MESSAGE];
        if (message != nil){
            npMessage = [NPConverter convertMessage:message];
            
            if([FORWARDED isEqualToString:[contents objectForKey:REPLY_TYPE]] || [REPLIED isEqualToString:[contents objectForKey:REPLY_TYPE]] ){
                npMessage.messageTransferedId = npMessage.messageId;
            }
            if(npMessage && npMessage.messageId != nil && 0<[[contents objectForKey:ATTACHMENTS] count]){
                //@TD on ajoute les PJ aux nouveaux messages
                [newMsgController updateWithAttachments:[AttachmentManager getAttachementsByIdMessage:npMessage.messageId]];
            }
            if(![contents objectForKey:Q_DRAFT] ){
                npMessage.messageId = nil;
            }
            [newMsgController updateWithMessage:npMessage];
            
        }
    }
    else if ([[contents objectForKey:MESSAGE] isKindOfClass:[NPMessage class]]) {
        npMessage = [contents objectForKey:MESSAGE];
        if (npMessage != nil){
            if([FORWARDED isEqualToString:[contents objectForKey:REPLY_TYPE]] || [REPLIED isEqualToString:[contents objectForKey:REPLY_TYPE]]){
                npMessage.messageTransferedId = npMessage.messageId;
            }
            if(npMessage && npMessage.messageId != nil && 0<[[contents objectForKey:ATTACHMENTS] count]){
                //@TD on ajoute les PJ aux nouveaux messages
                
                [newMsgController updateWithAttachments:[AttachmentManager getAttachementsByIdMessage:npMessage.messageId]];
            }
            if(![contents objectForKey:Q_DRAFT] ){
                npMessage.messageId = nil;
            }
            
            [newMsgController updateWithMessage:npMessage];
        }
    }
    
    if ([[contents objectForKey:CURRENT_NAV_CONTROLLER] isKindOfClass:[UINavigationController class]]) {
        navController = (UINavigationController*)[contents objectForKey:CURRENT_NAV_CONTROLLER];
    } else {
        navController = self.masterViewController.navigationController;
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if ([contents objectForKey:CURRENT_VIEW_CONTROLLER]) {
            //         [newMsgController setPreviousViewController:[contents objectForKey:CURRENT_VIEW_CONTROLLER]];
        }
        navController = [[UINavigationController alloc] init];
        [navController pushViewController:newMsgController animated:YES];
        [self presentViewController:navController animated:YES completion:^{
            //Si il y a un message, c'est une réponse ou un transfert, sinon c un nouveau message vide, donc rien a setter
            /*    if (message) {
             if ([contents objectForKey:ATTACHMENTS]) {
             NSMutableArray *listAttachments = [contents objectForKey:ATTACHMENTS];
             for (Attachment* attachement in listAttachments) {
             [newMsgController addAttachment:attachement];
             }
             }
             */
            //                [newMsgController setMessageId:message.messageId];
            //              [newMsgController setMessageTransferedId:message.messageId];
            //[newMsgController setIsActive:YES];
            [newMsgController.tableView reloadData];
            //        }
            
        }];
    } else {
        [navController pushViewController:newMsgController animated:YES];
    }
}


- (void)viewAttachmentFromNewMsg:(NSNotification*)notification {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    }
    
    if (!navController) {
        navController = [[UINavigationController alloc] init];
    }
    
    if ([notification.object isKindOfClass:[UIImage class]]) {
        ImageViewerController *imageViewController = (ImageViewerController *)[storyboard instantiateViewControllerWithIdentifier:@"ImageViewerController"];
        [imageViewController setImage:notification.object];
        [imageViewController setIsComingFromNewMsg:YES];
        [navController pushViewController:imageViewController animated:YES];
        
    } else if ([notification.object isKindOfClass:[NSString class]]) {
        WebViewController *webViewController = (WebViewController *)[storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
        [webViewController setFilePath:notification.object];
        [webViewController setIsComingFromNewMsg:YES];
        [navController pushViewController:webViewController animated:YES];
    }
}
- (void)error:(Error *)error {
    DLog(@"NouveauMessageView Error Msg: %@", [error errorMsg]);
    DLog(@"NouveauMessageView Http Code: %d", [error httpStatusCode]);
    DLog(@"NouveauMessageView Error Code: %d", [error errorCode]);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error title]
                                                    message:[error errorMsg]
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)hideNewMsg:(NSNotification *)pNotification {
    __block NouveauMessageViewController2 *newMsgController = nil;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self dismissViewControllerAnimated:NO completion:^{
            if ([pNotification.object isKindOfClass:[NouveauMessageViewController2 class]]) {
                newMsgController = (NouveauMessageViewController2*)pNotification.object;
                
                
                /*       if (newMsgController.isComingFromAnnuaire && newMsgController.previousViewController) {
                 [self presentViewController:newMsgController.previousViewController animated:NO completion:nil];
                 }
                 */       [newMsgController reset];
                //    [newMsgController setIsActive:NO];
                //                else if (newMsgController.isComingFromMessageDetail) {
                //                    if (newMsgController.message.messageId) {
                //                        DLog(@"newMsgController.message.messageId %@",newMsgController.message.messageId);
                //                        [self.masterViewController selectMessageByMessageId:newMsgController.message.messageId];
                //                    }
                //                }
            }
        }];
    } else {
        [navController popViewControllerAnimated:YES];
    }
    
    //    if ([self.presentedViewController isKindOfClass:[UINavigationController class]]) {
    //
    //        UINavigationController *currentNavController = (UINavigationController*) self.presentedViewController;
    //
    //        if (currentNavController.childViewControllers.count > 0) {
    //            if ([[currentNavController.childViewControllers objectAtIndex:0] isKindOfClass:[NouveauMessageViewController class]]) {
    //                newMsgController = (NouveauMessageViewController*)[currentNavController.childViewControllers objectAtIndex:0] ;
    //            }
    //        }
    //    }
    
    
    
    
    //    [self dismissViewControllerAnimated:YES completion:^{
    //        if ([pNotification.object isKindOfClass:[NouveauMessageViewController class]]) {
    //            newMsgController = (NouveauMessageViewController*)pNotification.object;
    //            if (newMsgController.isComingFromMessageDetail) {
    //                DLog(@"[self.masterViewController.navigationController topViewController] %@",[self.masterViewController.navigationController topViewController]);
    //                if ([[self.masterViewController.navigationController topViewController] isKindOfClass:[MessageDetailViewController class]]) {
    //                    MessageDetailViewController *msgDetailViewController = (MessageDetailViewController *)[self.masterViewController.navigationController topViewController];
    //                    DLog(@"newMsgController message.messageId %@",newMsgController.message.messageId);
    //                    DLog(@"newMsgController messageId %@",newMsgController.messageId);
    //                    if (newMsgController.message.messageId) {
    //                        MessageDAO* messageDAO = (MessageDAO*)[[DAOFactory factory] newDAO:MessageDAO.class];
    //                        Message *message = [messageDAO findMessageByMessageId:newMsgController.message.messageId];
    //                        [msgDetailViewController setDetailItem:message];
    //                        [msgDetailViewController reloadDetailsView];
    //                        DLog(@"Setting Msg Details");
    //                    } else {
    //
    //                        DLog(@"NO MSG ID");
    //
    //                    }
    //
    //                } else {
    //                    DLog(@"not MessageDetailViewController");
    //
    //                }
    //            } else if (newMsgController.isComingFromAnnuaire) {
    //                DLog(@"[self.masterViewController.navigationController topViewController] %@",[self.masterViewController.navigationController topViewController] );
    //
    //            }
    //            [newMsgController reset];
    //            [newMsgController setIsActive:NO];
    //        } else{
    //            DLog(@"not NouveauMessageViewController");
    //
    //        }
    //    }];
}

- (void)hideMoveMsg:(NSNotification *)pNotification {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showMoveMsg:(NSNotification *)pNotification {
    self.masterViewController.isShown = NO;
    NSMutableDictionary *dict = pNotification.object;
    currentFolderId = [dict objectForKey:MASTER_FOLDER_ID];
    isReturnOfMoveFolder = TRUE;
    [self performSegueWithIdentifier:@"segueRootToSelectDossier" sender:dict];
}

- (BOOL)shouldAutomaticallyForwardRotationMethods {
    //    @TD :Résoud les problème de vues lors  de la rotation (rootcause iOS 8)
    //    centerY = self.contentView.center.y;
    //    centerX = self.contentView.center.x;
    centerY=([UIScreen mainScreen].bounds.size.height)/2;
    centerX=([UIScreen mainScreen].bounds.size.width)/2 ;
    NSLog(@"RotationMethods center:%f %f ",centerX, centerY);
    
    return YES;
}

- (void)movePanel:(id)sender {
    [[[(UITapGestureRecognizer*)sender view] layer] removeAllAnimations];
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
    CGPoint velocity = [(UIPanGestureRecognizer*)sender velocityInView:[sender view]];
    
    //    if (!([[self.masterViewController.navigationController topViewController] isKindOfClass:[MessageDetailViewController class]]
    //          && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)) {
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        
        if(velocity.x > 0) {
            [self movePanelRight];
        } else {
            [self movePanelToOriginalPosition];
        }
    }
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateChanged) {
        _showPanel = [sender view].center.x > centerX;
        BOOL endShowPanel = [sender view].center.x > centerX + WIDTH_BACK_MENU;
        if (velocity.x > 0){
            if (!endShowPanel){
                [sender view].center = CGPointMake([sender view].center.x + translatedPoint.x, [sender view].center.y);
                [(UIPanGestureRecognizer*)sender setTranslation:CGPointMake(0,0) inView:self.view];
            }
        }
        if (velocity.x < 0){
            if (!endShowPanel && _showPanel){
                [sender view].center = CGPointMake([sender view].center.x + translatedPoint.x, [sender view].center.y);
                [(UIPanGestureRecognizer*)sender setTranslation:CGPointMake(0,0) inView:self.view];
            }
        }
    }
    //}
    
    
}

-(void)movePanelRight {
    [self shouldAutomaticallyForwardRotationMethods];
    //Get view of splitviewController since it is going to shift
    UIView *contentView = self.contentView;
    
    CGPoint newCenter;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        //        contentView = self.masterViewController.view;
        //On coupe l'interaction utilisateur quand on ouvre le panel
        [self enableUserInteractionForTableView:FALSE];
        
    }
    newCenter = CGPointMake(centerX+WIDTH_BACK_MENU, centerY);
    NSLog(@"SlidePanel SHOW center:%f %f ",newCenter.x, newCenter.y);
    
    [UIView animateWithDuration: 0.1
                          delay: 0
                        options: (UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{contentView.center = newCenter;}
                     completion:^(BOOL finished) { }
     ];
    isPanelIsOpen=YES;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self enableUserInteractionForTableView:FALSE];
    }
}
- (void)orientationChangedPanel:(NSNotification*)notification {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        isPanelIsOpen=NO;
    }
}

-(void)movePanelToOriginalPosition {
    [self shouldAutomaticallyForwardRotationMethods];
    UIView *contentView = self.contentView;
    CGPoint newCenter;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self enableUserInteractionForTableView:TRUE ];
    }
    newCenter = CGPointMake(centerX, centerY);
    NSLog(@"SlidePanel HIDE NEW center:%f %f ",newCenter.x, newCenter.y);
    [UIView animateWithDuration: 0.1
                          delay: 0
                        options: (UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{contentView.center = newCenter;}
                     completion:^(BOOL finished) { }
     ];
    
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        // contentView.center = newCenter;
        [self.contentView setCenter:newCenter];
    }
                     completion:nil];
    isPanelIsOpen=NO;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self enableUserInteractionForTableView:TRUE];
    }
    
}

//Method appelé pour faire ouvrir le backMenu et le refermé
- (void)slideToOpen:(NSNotification *)pNotification{
    if([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone){
        
        
        if(!isPanelIsOpen){
            [self movePanelRight];
        }else{
            [self movePanelToOriginalPosition];
        }
    }else {
        
        //Get view of splitviewController since it is going to shift
        UIView *contentView = self.contentView;
        
        CGPoint newCenter;
        if (centerX == contentView.center.x){
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [self enableUserInteractionForTableView:FALSE];
            }
            newCenter = CGPointMake(contentView.center.x+WIDTH_BACK_MENU, centerY);
        }
        else {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [self enableUserInteractionForTableView:TRUE];
            }
            newCenter = CGPointMake(centerX, centerY);
        }
        [UIView animateWithDuration: 0.1
                              delay: 0
                            options: (UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction)
                         animations:^{contentView.center = newCenter;}
                         completion:^(BOOL finished) { }
         ];
    }
}
-(void)enableUserInteractionForTableView:(BOOL)enableInteraction{
    self.masterViewController.tableView.userInteractionEnabled = enableInteraction;
    if(newMsgController){
        newMsgController.tableView.userInteractionEnabled=enableInteraction;
        newMsgController.navigationItem.leftBarButtonItem.enabled=enableInteraction;
    }
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
