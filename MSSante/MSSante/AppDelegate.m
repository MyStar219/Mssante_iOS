//
//  AppDelegate.m
//  MSSante
//
//  Created by labinnovation on 10/06/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "AppDelegate.h"
#import "Constant.h"
#import "EnrollementController.h"
#import "BackMenuViewController.h"
#import "Message.h"
#import "Email.h"
#import "DAOFactory.h"
#import "AccesToUserDefaults.h"
#import "RootViewController.h"
#import "ELCUIApplication.h"
#import "PasswordStore.h"
#import "InitialisationFolders.h"
#import "NouveauMessageViewController2.h"
#import "SyncAndLaunchModification.h"
#import "defaultUrl.h"
#import "ShownFolder.h"

#define DEGREES_TO_RADIANS(x) (M_PI*(x)/180.0)
#define IS_IOS_7_OR_EARLIER   ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)

@implementation NSURLRequest(DataController)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
    return YES;
}
@end

@implementation AppDelegate {
    UIBackgroundTaskIdentifier bgTask;
    UIImageView *imageView;
    
    UIDeviceOrientation orientation;
}

@synthesize rootViewController;

void myExceptionHandler(NSException *exception) {
    DLog(@"Stack trace: %@", [exception callStackReturnAddresses]);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSaveDraftInBackground:)
                                                 name:DID_SAVE_DRAFT_NOTIF object:nil];
    
    NSSetUncaughtExceptionHandler(&myExceptionHandler);
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"FirstRun"]) {
        DLog(@"Resetting Keychain");
        [PasswordStore resetKeyChain];
        NSLog(@"PasswordStore resetKeyChain");
        
        [[NSUserDefaults standardUserDefaults] setValue:@"1strun" forKey:@"FirstRun"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [(ELCUIApplication *)[UIApplication sharedApplication] setEnableTouchTimer:FALSE];
    [[InitialisationFolders sharedInstance] setIsRunning:NO];
    
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    NSString * idEnv=[preferences objectForKey:@"DefaultEnv"];
    if(!idEnv||[idEnv isEqualToString:@""]){
        idEnv=DEFAULT_ENV;
    }
    NSLog(@"IDENV = %@",idEnv);
    NSLog(@"DEFAULT ENV = %@", DEFAULT_ENV);
    if (![AccesToUserDefaults getUserInfoIdEnv]){
        [AccesToUserDefaults setUserInfoIdEnv:idEnv];
    }
    [self makeEnv:idEnv];
    //autorisation d'utilisation des notifications push
    //@TD ajout de l'intanciation des notifications pour ios8
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert |
         UIUserNotificationTypeBadge |
         UIUserNotificationTypeSound
                                          categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
    }
    else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    
    //Initialisation de la persistance avec CoreData et la librairie
    [DAOFactory setStorePath:@"MSSante.sqlite"];
    NSLog(@"DAO setStorePath : Initialisation de la persistance avec CoreData et la librairie");
    
    PasswordStore *passwordInstance = [PasswordStore getInstance];
    NSLog(@"PasswordStore getInstance");
    
    if ([[passwordInstance getPlainPassword] length] > 0) {
        NSString *key = [passwordInstance getPlainDbEncryptionKey];
        [DAOFactory setKey:key];
        NSLog(@" AppDelegate DAO setKey: key = %@ ",key);
        
        DAOFactory *factory = [DAOFactory factory];
        if (factory.managedObjectContext == nil) {
            if ([factory resetManagedObjectContext] != nil) {
                [factory.managedObjectContext setRetainsRegisteredObjects:YES];
                DLog(@"[factory managedObjectContext] %@",factory.managedObjectContext );
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:NSLocalizedString(@"PROBLEME_BD", @"Problème d'initialisation de base de données")
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                                      otherButtonTitles:nil];
                [alert show];
                DLog(@"AppDelegate : probleme creating managedObjectContext");
                
                [PasswordStore resetPasswords];
                NSLog(@"PasswordStore resetPassword");
                
                [[NSNotificationCenter defaultCenter] postNotificationName:DECONNEXION_NOTIF object:ENROLLEMENT];
            }
        }
    }
    
    NSLog(@"Number version %ld",(long)[[NSUserDefaults standardUserDefaults] integerForKey:NUMBER_VERSION]);
    NSLog(@"Number version %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"FirstRun"] );
    NSLog(@"info id nat %@",[AccesToUserDefaults getUserInfoIdNat]);
    NSLog(@"info id ENV %@",[AccesToUserDefaults getUserInfoIdEnv]);
    
    //@TD Enrollement Forced
    if(![[NSUserDefaults standardUserDefaults] integerForKey:NUMBER_VERSION] && [AccesToUserDefaults getUserInfoIdNat]){
        [self showNeedReenrollment];
    }else {
        if([[NSUserDefaults standardUserDefaults] integerForKey:NUMBER_VERSION]){
            if( [[NSUserDefaults standardUserDefaults] integerForKey:NUMBER_VERSION] !=2){
                [self showNeedReenrollment];
            }
        }
    }
    
    
    rootViewController = (RootViewController *) self.window.rootViewController;
    
    // if enrollement was never set, initialize it with NO
    if (![AccesToUserDefaults getUserInfoEnrollement]) {
        [AccesToUserDefaults setUserInfoEnrollement:NO];
        [rootViewController.view setHidden:YES];
    }// else if (![AccesToUserDefaults getUserInfoRememberMe]){
    //        [rootViewController.view setHidden:YES];
    //        [self checkNotif];
    //    }
    //@TD 17867 : Controle de l'activation des notifications à chaque tentative de connexion
    [AppDelegate checkNotif];
    
    return YES;
}

- (void)showNeedReenrollment {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:NSLocalizedString(@"MISE_A_JOUR", @"La mise à jour de l’application a fait évoluer les paramètres de sécurité, nous vous remercions d’associer de nouveau votre appareil à votre compte MSSanté")
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                          otherButtonTitles:nil];
    
    [PasswordStore resetPasswords];
    NSLog(@"PasswordStore resetPassword");
    [[NSNotificationCenter defaultCenter] postNotificationName:DECONNEXION_NOTIF object:ENROLLEMENT];
    [AccesToUserDefaults setUserInfoEnrollement:NO];
    [rootViewController.view setHidden:YES];
    [alert show];
}


+(BOOL)checkNotif{
    bool notifEnabled=true;
    //@TD on ajoute le check pour les notifications iOS 8
    
    NSLog(@"OS Version %i", [UIDevice currentDevice].systemVersion.intValue);
    if (
        ([UIDevice currentDevice].systemVersion.intValue >= 8 && [[UIApplication sharedApplication] currentUserNotificationSettings].types == UIUserNotificationTypeNone) ||
        (([UIDevice currentDevice].systemVersion.intValue < 8) && [[UIApplication sharedApplication] enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone )
        ){
        //@TD on Déconnecte l'utilisateur si il est connecté
        [[NSNotificationCenter defaultCenter] postNotificationName:DECONNEXION_NOTIF object:nil];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"ERREUR", @"Erreur")
                                                        message: NSLocalizedString(@"ERREUR_PUSH", @"Les notifications sont désactivées, vous ne pourrez plus vous connecter au serveur. Vous pouvez aller dans Réglages/Notifications pour réactiver celles-ci")
                                                       delegate: nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                              otherButtonTitles:nil];
        
        [alert show];
        notifEnabled=false;
    }
    return notifEnabled;
}

CFDataRef persistentRefForIdentity(SecIdentityRef identity) {
    OSStatus status = errSecSuccess;
    
    CFTypeRef  persistent_ref = NULL;
    const void *keys[] =   { kSecReturnPersistentRef, kSecValueRef };
    const void *values[] = { kCFBooleanTrue,          identity };
    CFDictionaryRef dict = CFDictionaryCreate(NULL, keys, values,
                                              2, NULL, NULL);
    status = SecItemAdd(dict, &persistent_ref);
    
    if (dict)
        CFRelease(dict);
    
    return (CFDataRef)persistent_ref;
}


# pragma mark - Push Notifications
//Méthode appelé lorsqu'on recoit un push
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    DLog(@"My token is: %@", deviceToken);
    
    NSString *token = [[[deviceToken description]
                        stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]
                       stringByReplacingOccurrencesOfString:@" "
                       withString:@""];
    
    [AccesToUserDefaults setIdPush:token];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
    DLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)notification {
    DLog(@"Received notification: %@", notification);
    [self handleRemoteNotification:notification];
}


- (void)handleRemoteNotification:(NSDictionary*)notification {
    // check if OTP notificationd
    DLog(@"notification %@",notification);
    
    NSString *otp = [notification objectForKey:@"otp"];
    DLog(@"handleRemoteNotification OTP:%@",otp);
    Authentification *auth = [Authentification sharedInstance];
    
    if (otp.length > 0 && !auth.canceled) {
        [auth validerOtp:otp];
    }
    
    [MasterViewController load];
    [MasterViewController majWhenReceivedNotification];
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    DLog(@"applicationWillResignActive");
    
    // Replace the current image by an other
    imageView = [[UIImageView alloc] initWithFrame:[self.window frame]];
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        //[imageView setImage:[UIImage imageNamed:@"Default@2x.png"]];
        //[imageView setImage:[UIImage imageNamed:@"Splashscreen_MSS_320x470.png"]];
        [imageView setImage:[UIImage imageNamed:@"Splashscreen_MSS_640x1136.png"]];
    } else {
        //[imageView setImage:[UIImage imageNamed:@"Default-Portrait@2x~ipad.png"]];
        orientation = [[UIDevice currentDevice] orientation];
        
        if (orientation == UIInterfaceOrientationLandscapeLeft
            || orientation == UIInterfaceOrientationLandscapeRight) {
            DLog(@"Landscape mode");
            [imageView setImage:[UIImage imageNamed:@"Splashscreen_MSS_1536x2048.png"]];
            
            if (IS_IOS_7_OR_EARLIER && orientation == UIInterfaceOrientationLandscapeLeft) {
                // CGAffineTransformMakeRotation expects angle in radians, not in degrees
                imageView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(180));
            }
        } else {
            DLog(@"Portrait mode");
            [imageView setImage:[UIImage imageNamed:@"Splashscreen_MSS_2048x1536.png"]];
            
            if (IS_IOS_7_OR_EARLIER && orientation == UIInterfaceOrientationPortraitUpsideDown) {
                // CGAffineTransformMakeRotation expects angle in radians, not in degrees
                imageView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(180));
            }
        }
    }
    
    [self.window addSubview:imageView];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    DLog(@"applicationDidEnterBackground");
    
    /*UIApplication *app = [UIApplication sharedApplication];
     DLog(@"====>backgroundTimeRemaining:%.1f seconds", app.backgroundTimeRemaining);
     __block UIBackgroundTaskIdentifier tid = bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
     [app endBackgroundTask:tid];
     dispatch_async(dispatch_get_main_queue(), ^{
     [[NSNotificationCenter defaultCenter] postNotificationName:@"saveDraft" object:@"saveDraft"];
     bgTask = UIBackgroundTaskInvalid;
     });
     }];*/
}

- (void)didSaveDraftInBackground:(NSNotification*)notification {
    UIApplication *app = [UIApplication sharedApplication];
    
    if (bgTask != UIBackgroundTaskInvalid) {
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }
    
    DLog(@"didSaveDraftInBackground");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    DLog(@"applicationWillEnterForeground");
    //@TD 17867 : Controle de l'activation des notifications à chaque tentative de connexion
    [AppDelegate checkNotif];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    // Remove the image replaced from "applicationWillResignActive"
    if(imageView != nil) {
        [imageView removeFromSuperview];
        imageView = nil;
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    DLog(@"applicationDidBecomeActive");
    BOOL isExpired = NO;
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if ([(ELCUIApplication *)[UIApplication sharedApplication] enableTouchTimer]) {
        NSTimeInterval lastActivityTime = [AccesToUserDefaults getUserInfoLastActivityTime];
        NSTimeInterval timeNow = [[NSDate date] timeIntervalSince1970];
        
        int difference = floor(timeNow-lastActivityTime);
        
        if (difference > TIMEOUT_LOGOUT_15MIN * 60) {
            isExpired = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:kApplicationDidTimeoutNotification object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_CURRENT_FOLDER_NOTIF object:[[ShownFolder sharedInstance] folderId]];
        }
    }
    
    // Remove the image replaced from "applicationWillResignActive"
    if(imageView != nil) {
        [imageView removeFromSuperview];
        imageView = nil;
    }
}

// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
- (void)applicationWillTerminate:(UIApplication *)application {
    NSError *error = nil;
    DAOFactory *factory = [DAOFactory factory];
    NSLog(@"DAO Appel a hasManageObjectContext");
    
    if ([factory hasManageObjectContext] && [factory.managedObjectContext hasChanges] && ![factory save:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    /* @WX - Anomalie liée à 18097
     * Problème : Lorsqu'on écrit un message et qu'on met l'application en arrière-plan,
     * on ré-ouvre l'application et on est sur la boîte "brouillons" avec le message enregistré
     *
     * Résultat attendu : Le message devrait apparaître lorsqu'on ouvre l'application
     *
     * Sauvegarder le brouillon en cas de crash
     * ou en cas de fermeture de l'application par l'utilisateur
     */
    if ([[[self.rootViewController.masterViewController navigationController] visibleViewController]
         isKindOfClass:[NouveauMessageViewController2 class]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"saveDraft"
                                                            object:@"saveDraft"];
        
        // Laisser un peu de temps d'exécution pour le "saveDraft"
        [NSThread sleepForTimeInterval:1.0];
    }
    /* @WX - Fin des modifications */
}

//@TD Fonction qui assemble l'ENV
- (void) makeEnv:(NSString*)idEnv{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"cacert" ofType:@"der" inDirectory:idEnv];
    NSData* content = [NSData dataWithContentsOfFile:path];
    [self addCertToKeychain:content];
}

//@TD Fonction qui ajoute le bon certificat pour la connexion server
- (void) addCertToKeychain:(NSData*)certInDer {
    OSStatus            err = noErr;
    SecCertificateRef   cert;
    
    cert = SecCertificateCreateWithData(NULL, (__bridge CFDataRef) certInDer);
    
    CFTypeRef result;
    
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          (__bridge id)kSecClassCertificate, kSecClass,
                          cert, kSecValueRef,
                          nil];
    //removing item if it exists
    SecItemDelete((__bridge CFDictionaryRef)dict);
    
    err = SecItemAdd((__bridge CFDictionaryRef)dict, &result);
    if(err) {
        DLog(@"Keychain error occured: %ld (statuscode)", err);
    }
    assert(err == noErr || err == errSecDuplicateItem);
    
}

/* @WX - Anomalie 18112
 * Problème : Dédoublement d'un brouillon
 * Cette fonction est utilisée dans la fonction "applicationDidEnterBackground"
 */
- (BOOL)isConnectedToInternet {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        DLog(@"NO INTERNET");
        return NO;
    } else {
        DLog(@"INTERNET ACCESS OK");
        return YES;
    }
}
/* @WX - Fin des modifications */

@end
