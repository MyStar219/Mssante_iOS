//
//  EnrollementBController.m
//  MSSante
//
//  Created by Work on 6/12/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "EnrollementBController.h"
#import "EnrollementCController.h"
#import "AccesToUserDefaults.h"
#import "Constant.h"
#import "defaultUrl.h"

#define IS_IOS_7_OR_EARLIER     ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)

@interface EnrollementBController()
@end

@implementation EnrollementBController {
    ZBarReaderViewController *reader;
}

@synthesize resultText;

#pragma mark - Image View
@synthesize barreProgression;

#pragma mark - Label
@synthesize labelEtape;
@synthesize labelCode;
@synthesize labelCliquez;

#pragma mark - Button
@synthesize boutonContinuer;

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
    
    // Do any additional setup after loading the view from its nib.
    UIImage *patternImage1 = [UIImage imageNamed:@"d1@2x.png"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:patternImage1];
    
    /* @WX - Anomalie 18094
     * Problème : Mauvais message sur la flèche retour (iPad uniquement)
     *
     * Ici, on laisse pour l'iPhone pour deux raisons.
     * La première est qu'elle n'a pas d'impact sur la flèche retour.
     * La deuxième est purement design. L'affichage est plus appréciable.
     */
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.navigationItem.title = NSLocalizedString(@"AJOUTER_CET_APPAREIL", @"Ajouter cet appareil");
    }
    
    /* @WX - Evolution sur les écrans d'enrôlement
     * Pour mettre en place la détection d'un changement d'orientation des iPad
     */
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    /* @WX - Fin des modifications */
}

- (void)viewWillAppear:(BOOL)animated {
    DLog(@"viewWillAppear");
    
    /* @WX - Anomalie 18094
     * Problème : Mauvais message sur la flèche retour (iPad uniquement)
     *
     * Ici, on met à jour le titre du "navigation bar".
     * La raison pour laquelle on cache d'abord la navigation bar pour modifier le titre
     * puis de la réaparraître est purement design.
     */
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [[self navigationController] setNavigationBarHidden:YES animated:NO];
        [self.navigationItem setTitle:NSLocalizedString(@"AJOUTER_CET_APPAREIL", @"Ajouter cet appareil")];
        [[self navigationController] setNavigationBarHidden:NO animated:NO];
    }
    /* @WX - Fin des modifications */
    
    CGRect frame = self.navigationController.navigationBar.frame;
    frame.origin.y = 20;
    [self.navigationController.navigationBar setFrame:frame];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)viewWillDisappear:(BOOL)animated {
    DLog(@"viewWillDisappear");
    
    /* @WX - Anomalie 18094
     * Problème : Mauvais message sur la flèche retour (iPad uniquement)
     *
     * Ici, on met à jour le titre du "navigation bar".
     * On met le titre à nil car la flèche retour du prochain viewController dépend
     * du "titre de ce viewController".
     */
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.navigationItem setTitle:nil];
    }
    /* @WX - Fin des modifications */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    barreProgression = nil;
    
    labelEtape = nil;
    labelCode = nil;
    labelCliquez = nil;
    
    boutonContinuer = nil;
}


#pragma mark - Managing Device Orientation
- (void)orientationChanged:(NSNotification*)notification {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self updateOrientation];
    }
}

- (void)updateOrientation {
    reader.cameraOverlayView = [self commonOverlayScanning:@"Square focus QR code red.png" alpha:0.3];
}

#pragma mark - Scan QR code
- (IBAction)Scan:(id)sender {
    // ADD: present a barcode reader that scans from the camera feed
    reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    reader.showsHelpOnFail = NO;
    reader.tracksSymbols = NO;
    
    activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
    [activityView setBackgroundColor:[UIColor clearColor]];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, activityView.frame.size.height, activityView.frame.size.height)];
    spinner.color = [UIColor blackColor];
    [spinner startAnimating];
    
    UILabel *labelScanEnCours = [[UILabel alloc] initWithFrame:CGRectMake(spinner.frame.size.width, 0, activityView.frame.size.width-spinner.frame.size.width, activityView.frame.size.height)];
    [labelScanEnCours setBackgroundColor:[UIColor clearColor]];
    labelScanEnCours.text = NSLocalizedString(@"SCAN_EN_COURS", @"Traitement en cours");
    
    [activityView addSubview:spinner];
    [activityView addSubview:labelScanEnCours];
    
    reader.navigationItem.titleView = activityView;
    
    ZBarImageScanner *scanner = reader.scanner;
    reader.showsZBarControls = NO;
    reader.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
    reader.cameraOverlayView = [self commonOverlayScanning:@"Square focus QR code red.png" alpha:0.3];
    // TODO: (optional) additional reader configuration here
    
    // EXAMPLE: disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    [scanner setSymbology: ZBAR_NONE
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    [scanner setSymbology: ZBAR_QRCODE
                   config: ZBAR_CFG_ENABLE
                       to: 1];
    
    // Present and release the controller
    DLog(@"Scan");
    [self.navigationController pushViewController:reader animated:YES];
}

/* @WX - Evolution sur les écrans d'enrôlement
 * Pour centrer le viseur QR code (nécessaire sur iPad)
 */
- (UIView *) commonOverlayScanning:(NSString *)name alpha:(CGFloat)alpha {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat screenWidth = screenSize.width;
    CGFloat screenHeight = screenSize.height - 64;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat statusBarHeight = 20;
    
    UIImageView *squareQRCodeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
    squareQRCodeView.alpha = alpha;
    
    if (orientation == UIInterfaceOrientationPortrait
        || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        squareQRCodeView.frame = CGRectMake(screenWidth/2 - screenWidth/3,
                                            screenHeight/2 - screenWidth/3 + navBarHeight + statusBarHeight,
                                            2*screenWidth/3,
                                            2*screenWidth/3);
    } else {
        /* @WX - Evolution sur les écrans d'enrôlement
         * Avant le début des évolutions (03/04/2015), on utilisait ces instructions
         * Ce changement est peut-être dû au passage de l'iOS 7 à l'iOS 8
         */
        if (IS_IOS_7_OR_EARLIER) {
            screenHeight = screenSize.width - 64;
            screenWidth = screenSize.height;
        }
        
        squareQRCodeView.frame = CGRectMake(screenWidth/2 - screenHeight/3,
                                            screenHeight/2 - screenHeight/3 + navBarHeight + statusBarHeight,
                                            2*screenHeight/3,
                                            2*screenHeight/3);
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    [view addSubview:squareQRCodeView];
    
    DLog(@"commonOverlayScanning");
    
    return view;
}
/* @WX - Fin des modifications */

- (void) imagePickerController: (UIImagePickerController*) reader_arg //Avant, on avait reader mais ça crée une confusion
 didFinishPickingMediaWithInfo: (NSDictionary*) info {
    // ADD: get the decode results
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // EXAMPLE: just grab the first barcode
        break;
    
    NSString *qrString = symbol.data;
    // look for misinterpreted acute characters and convert them to UTF-8
    if ([qrString canBeConvertedToEncoding:NSShiftJISStringEncoding]) {
        qrString = [NSString stringWithCString:[symbol.data cStringUsingEncoding: NSShiftJISStringEncoding] encoding:NSUTF8StringEncoding];
    }
    NSLog(@"qrString %@",qrString);
    
    NSError *error = nil;
    NSData* jsonData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    
    if(!error) {
        [self readQrCode:jsonObject];
    } else {
        [self showErrorQRcode];
        return;
    }
    
    /* @WX - Evolution sur les écrans d'enrôlement
     * Pour prendre en compte le scan d'un QR code
     * et émettre un son qui confirme le scan
     */
    reader.cameraOverlayView = [self commonOverlayScanning:@"Square focus QR code green.png" alpha:0.8];
    AudioServicesPlayAlertSound(1052);
    
    [self performSelector:@selector(enrolementCController) withObject:nil afterDelay:0.5];
    /* @WX - Fin des modifications */
}

- (void)enrolementCController {
    EnrollementCController *enrollementCController;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        enrollementCController = [[EnrollementCController alloc] initWithNibName:@"EnrollementCController_iPhone"
                                                                          bundle:nil];
    } else {
        enrollementCController = [[EnrollementCController alloc] initWithNibName:@"EnrollementCController_iPad"
                                                                          bundle:nil];
    }
    
    reader.cameraOverlayView = [self commonOverlayScanning:@"Square focus QR code red.png" alpha:0.3];
    [self.navigationController pushViewController:enrollementCController animated:YES];
}

- (void)readQrCode:(id)jsonObject {
    NSString *code = @"";
    NSString *idNat = @"";
    NSString *nom = @"";
    NSString *prenom = @"";
    NSString *idEnv=@"";
    
    if([jsonObject objectForKey:QR_CODE]) {
        code = [jsonObject objectForKey:QR_CODE];
    } else {
        [self showErrorQRcode];
        return;
    }
    
    if([jsonObject objectForKey:QR_IDNAT]) {
        idNat = [jsonObject objectForKey:QR_IDNAT];
    } else {
        [self showErrorQRcode];
        return;
    }
    
    if([jsonObject objectForKey:QR_NOM]) {
        nom = [jsonObject objectForKey:QR_NOM];
    } else {
        [self showErrorQRcode];
        return;
    }
    
    if([jsonObject objectForKey:QR_PRENOM]) {
        prenom = [jsonObject objectForKey:QR_PRENOM];
    } else {
        [self showErrorQRcode];
        return;
    }
    
    if([jsonObject objectForKey:QR_IDENV]) {
        idEnv = [jsonObject objectForKey:QR_IDENV];
        [[NSUserDefaults standardUserDefaults] setObject:idEnv forKey:@"DefaultEnv"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"SPECIAL ENVIRONNEMENT ->  %@",idEnv);
        
    } else {
        //[self showErrorQRcode];
        idEnv = DEFAULT_ENV;
        [[NSUserDefaults standardUserDefaults] setObject:DEFAULT_ENV forKey:@"DefaultEnv"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"DEFAULT ENVIRONNEMENT ->  %@",idEnv);
        
    }
    [self makeEnv:idEnv];
    
    [AccesToUserDefaults setUserInfoCode:code];
    [AccesToUserDefaults setUserInfoIdNat:idNat];
    [AccesToUserDefaults setUserInfoNom:nom];
    [AccesToUserDefaults setUserInfoPrenom:prenom];
    [AccesToUserDefaults setUserInfoIdEnv:idEnv];
}

- (void)showErrorQRcode {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERREUR", @"Erreur")
                                                    message:NSLocalizedString(@"ERREUR_QRCODE", @"Le QR Code est invalide")
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                          otherButtonTitles:nil];
    [alert show];
}


#pragma mark - Environnement et Certificat
//@TD Fonction qui assemble l'ENV
- (void) makeEnv:(NSString*)idEnv {
    NSString* path = [[NSBundle mainBundle] pathForResource:@"cacert" ofType:@"der" inDirectory:idEnv];
    NSData* content = [NSData dataWithContentsOfFile:path];
    
    [self addCertToKeychain:content];
    [[NSUserDefaults standardUserDefaults] setObject:idEnv forKey:@"target_preference"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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

@end
