//
//  EnrollementBControllerTest.m
//  MSSante
//
//  Created by Labinnovation on 14/04/2015.
//  Copyright (c) 2015 Capgemini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SenTestingKit/SenTestingKit.h>
#import "EnrollementBController.h"
#import "AccesToUserDefaults.h"
#import "defaultUrl.h"
#import "Constant.h"
@interface EnrollementBControllerTest : SenTestCase

@property (strong, nonatomic) EnrollementBController *enrollementBControllerIPhone;
@property (strong, nonatomic) EnrollementBController *enrollementBControllerIPad;
@property (strong, nonatomic) EnrollementBController *enrolB;
@end

@implementation EnrollementBControllerTest

@synthesize enrollementBControllerIPhone;
@synthesize enrollementBControllerIPad;
@synthesize enrolB;

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    enrollementBControllerIPhone = [[EnrollementBController alloc] initWithNibName:@"EnrollementBController_iPhone"
                                                                          bundle:nil];
    enrollementBControllerIPad = [[EnrollementBController alloc] initWithNibName:@"EnrollementBController_iPad"
                                                                        bundle:nil];
    
    
    enrolB = [[EnrollementBController alloc]init];
   
    /* @WX - Important (from StackOverFlow - XIB Outlet Unit Testing)
     * To test IBOutlet from Nib, it needs to call
     * --> viewController.view
     * If it is not called, the test fails because the view is never fetched.
     */
    [enrollementBControllerIPhone view];
    [enrollementBControllerIPad view];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    enrollementBControllerIPhone = nil;
    enrollementBControllerIPad = nil;
    
    [super tearDown];
}

#pragma mark - Managing Test
- (void)nibAndViewNotNil:(EnrollementBController *)enrollementBController {
    STAssertNotNil(enrollementBController, @"Nib is nil");
    STAssertNotNil(enrollementBController.view, @"View is nil");
}

- (void)IBOutletNil:(EnrollementBController *)enrollementBController type:(NSString *)type {
    STAssertNil(enrollementBController.barreProgression, @"Progress bar is %@", type);
    
    STAssertNil(enrollementBController.labelEtape, @"Label \"Etape\" is %@", type);
    STAssertNil(enrollementBController.labelCode, @"Label \"Depuis ...\" is %@", type);
    STAssertNil(enrollementBController.labelCliquez, @"Label \"Connectez ...\" is %@", type);
    
    STAssertNil(enrollementBController.boutonContinuer, @"Button \"Continuer\" is %@", type);
}

- (void)IBOutletNotNil:(EnrollementBController *)enrollementBController type:(NSString *)type {
    STAssertNotNil(enrollementBController.barreProgression, @"Progress bar is %@", type);
    
    STAssertNotNil(enrollementBController.labelEtape, @"Label \"Etape\" is %@", type);
    STAssertNotNil(enrollementBController.labelCode, @"Label \"Depuis ...\" is %@", type);
    STAssertNotNil(enrollementBController.labelCliquez, @"Label \"Connectez ...\" is %@", type);
    
    STAssertNotNil(enrollementBController.boutonContinuer, @"Button \"Continuer\" is %@", type);
}

#pragma mark - View Binding
- (void)testViewBinding {
    [self nibAndViewNotNil:enrollementBControllerIPhone];
    [self nibAndViewNotNil:enrollementBControllerIPad];
    
    [self IBOutletNotNil:enrollementBControllerIPhone type:@"not binded"];
    [self IBOutletNotNil:enrollementBControllerIPad type:@"not binded"];
}

#pragma mark - View Unloading
- (void)testViewUnloading {
    [self nibAndViewNotNil:enrollementBControllerIPhone];
    [self nibAndViewNotNil:enrollementBControllerIPad];
    
    [self IBOutletNotNil:enrollementBControllerIPhone type:@"released"];
    [self IBOutletNotNil:enrollementBControllerIPad type:@"released"];
    
    [enrollementBControllerIPhone didReceiveMemoryWarning];
    [enrollementBControllerIPad didReceiveMemoryWarning];
    [self IBOutletNil:enrollementBControllerIPhone type:@"not released"];
    [self IBOutletNil:enrollementBControllerIPad type:@"not released"];
}

#pragma mark - View Reloading
- (void)testViewReloading {
    [self nibAndViewNotNil:enrollementBControllerIPhone];
    [self nibAndViewNotNil:enrollementBControllerIPad];
    
    [enrollementBControllerIPhone didReceiveMemoryWarning];
    [enrollementBControllerIPad didReceiveMemoryWarning];
    [self IBOutletNil:enrollementBControllerIPhone type:@"not released"];
    [self IBOutletNil:enrollementBControllerIPad type:@"not released"];
    
    [enrollementBControllerIPhone loadView];
    [enrollementBControllerIPad loadView];
    [self IBOutletNotNil:enrollementBControllerIPhone type:@"released"];
    [self IBOutletNotNil:enrollementBControllerIPad type:@"released"];
}

#pragma mark - View Label Text
- (void)testViewLabelText {
    [self nibAndViewNotNil:enrollementBControllerIPhone];
    [self nibAndViewNotNil:enrollementBControllerIPad];
    
    NSData *checkImageDataOrigin = UIImagePNGRepresentation([UIImage imageNamed:@"barre_progression2.png"]);
    NSData *checkImageDataFromNibIPhone = UIImagePNGRepresentation(enrollementBControllerIPhone.barreProgression.image);
    NSData *checkImageDataFromNibIPad = UIImagePNGRepresentation(enrollementBControllerIPad.barreProgression.image);
    STAssertTrue([checkImageDataFromNibIPhone isEqualToData:checkImageDataOrigin], @"Should be equal");
    STAssertTrue([checkImageDataFromNibIPad isEqualToData:checkImageDataOrigin], @"Should be equal");
    
    NSString *comparedText1 = @"Etape 2/3";
    STAssertTrue([enrollementBControllerIPhone.labelEtape.text isEqualToString:comparedText1], @"Should be equal");
    STAssertTrue([enrollementBControllerIPad.labelEtape.text isEqualToString:comparedText1], @"Should be equal");
    
    NSString *comparedText2 = @"Un QR code apparait sur votre ordinateur.";
    STAssertTrue([enrollementBControllerIPhone.labelCode.text isEqualToString:comparedText2], @"Should be equal");
    STAssertTrue([enrollementBControllerIPad.labelCode.text isEqualToString:comparedText2], @"Should be equal");
    
    NSString *comparedText3 = @"Cliquez sur le bouton « Continuer » pour lancer l'appareil photo de votre mobile et visez le QR code.";
    STAssertTrue([enrollementBControllerIPhone.labelCliquez.text isEqualToString:comparedText3], @"Should be equal");
    STAssertTrue([enrollementBControllerIPad.labelCliquez.text isEqualToString:comparedText3], @"Should be equal");
}

#pragma mark - Test Bascule Env
- (void)testBasculeEnv {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:USER];
    
    NSString *jsonString = @"{\"code\" : \"1234567890\","
                              "\"nom\" : \"Nicco\","
                           "\"prenom\" : \"Julien\","
                            "\"idNat\" : \"1\" \","
                            "\"idEnv\" : \"test1\"}";
    
    NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    
    [enrolB readQrCode:jsonObject];
    STAssertFalse([DEFAULT_ENV isEqualToString:[defaults objectForKey:QR_IDENV]], @"TEST IDENV");
}

- (void)testBasculeEnv2{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:USER];
    
    NSString *jsonString = @"{\"code\" : \"1234567890\","
                              "\"nom\" : \"Nicco\","
                           "\"prenom\" : \"Julien\","
                            "\"idNat\" : \"1\"}";
    
    NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    
    [enrolB readQrCode:jsonObject];
    STAssertTrue([DEFAULT_ENV isEqualToString:[AccesToUserDefaults getUserInfoIdEnv]], @"TEST IDENV");
}

@end
