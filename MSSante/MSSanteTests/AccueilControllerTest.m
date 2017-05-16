//
//  AccueilControllerTest.m
//  MSSante
//
//  Created by Labinnovation on 13/04/2015.
//  Copyright (c) 2015 Capgemini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SenTestingKit/SenTestingKit.h>
#import "AccueilController.h"

@interface AccueilControllerTest : SenTestCase

@property (strong, nonatomic) AccueilController *accueilControllerIPhone;
@property (strong, nonatomic) AccueilController *accueilControllerIPad;

@end

@implementation AccueilControllerTest

@synthesize accueilControllerIPhone;
@synthesize accueilControllerIPad;

#pragma mark - Initialization
- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    accueilControllerIPhone = [[AccueilController alloc] initWithNibName:@"AccueilController_iPhone"
                                                                   bundle:nil];
    accueilControllerIPad = [[AccueilController alloc] initWithNibName:@"AccueilController_iPad"
                                                                 bundle:nil];
    
    /* @TD - Important (from StackOverFlow - XIB Outlet Unit Testing)
     * To test IBOutlet from Nib, it needs to call
     * --> viewController.view
     * If it is not called, the test fails because the view is never fetched.
     */
    [accueilControllerIPhone view];
    [accueilControllerIPad view];
}

#pragma mark - Clean Up
- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    accueilControllerIPhone = nil;
    accueilControllerIPad = nil;
    
    [super tearDown];
}

#pragma mark - Managing Test
- (void)nibAndViewNotNil:(AccueilController *)accueilController {
    STAssertNotNil(accueilController, @"Nib is nil");
    STAssertNotNil(accueilController.view, @"View is nil");
}

- (void)IBOutletNil:(AccueilController *)accueilController type:(NSString *)type {
    STAssertNil(accueilControllerIPhone.logo, @"MSSanté logo is %@", type);
    
    STAssertNil(accueilControllerIPhone.labelBienvenue, @"Label \"Bienvenue ...\" is %@", type);
    STAssertNil(accueilControllerIPhone.labelAcces, @"Label \"L'accès ...\" is %@", type);
    STAssertNil(accueilControllerIPhone.labelOperation, @"Label \"Cette opération ...\" is %@", type);
    STAssertNil(accueilControllerIPhone.labelPasCompte, @"Label \"Vous ne disposez pas ...\" is %@", type);
    
    STAssertNil(accueilControllerIPhone.boutonAjouter, @"Button \"Ajouter cet appareil ...\" is %@", type);
    STAssertNil(accueilControllerIPhone.boutonPasCompte, @"Button \"Vous ne disposez pas ...\" is %@", type);
}

- (void)IBOutletNotNil:(AccueilController *)accueilController type:(NSString *)type {
    STAssertNotNil(accueilController.logo, @"MSSanté logo is %@", type);
    
    STAssertNotNil(accueilController.labelBienvenue, @"Label \"Bienvenue ...\" is %@", type);
    STAssertNotNil(accueilController.labelAcces, @"Label \"L'accès ...\" is %@", type);
    STAssertNotNil(accueilController.labelOperation, @"Label \"Cette opération ...\" is %@", type);
    STAssertNotNil(accueilController.labelPasCompte, @"Label \"Vous ne disposez pas ...\" is %@", type);
    
    STAssertNotNil(accueilController.boutonAjouter, @"Button \"Ajouter cet appareil ...\" is %@", type);
    STAssertNotNil(accueilController.boutonPasCompte, @"Button \"Vous ne disposez pas ...\" is %@", type);
}

#pragma mark - View Binding
- (void)testViewBinding {
    [self nibAndViewNotNil:accueilControllerIPhone];
    [self nibAndViewNotNil:accueilControllerIPad];
    
    [self IBOutletNotNil:accueilControllerIPhone type:@"not binded"];
    [self IBOutletNotNil:accueilControllerIPad type:@"not binded"];
}

#pragma mark - View Unloading
- (void)testViewUnloading {
    [self nibAndViewNotNil:accueilControllerIPhone];
    [self nibAndViewNotNil:accueilControllerIPad];
    
    [self IBOutletNotNil:accueilControllerIPhone type:@"released"];
    [self IBOutletNotNil:accueilControllerIPad type:@"released"];
    
    [accueilControllerIPhone didReceiveMemoryWarning];
    [accueilControllerIPad didReceiveMemoryWarning];
    [self IBOutletNil:accueilControllerIPhone type:@"not released"];
    [self IBOutletNil:accueilControllerIPad type:@"not released"];
}

#pragma mark - View Reloading
- (void)testViewReloading {
    [self nibAndViewNotNil:accueilControllerIPhone];
    [self nibAndViewNotNil:accueilControllerIPad];

    [accueilControllerIPhone didReceiveMemoryWarning];
    [accueilControllerIPad didReceiveMemoryWarning];
    [self IBOutletNil:accueilControllerIPhone type:@"not released"];
    [self IBOutletNil:accueilControllerIPad type:@"not released"];
    
    [accueilControllerIPhone loadView];
    [accueilControllerIPad loadView];
    [self IBOutletNotNil:accueilControllerIPhone type:@"released"];
    [self IBOutletNotNil:accueilControllerIPad type:@"released"];
}

#pragma mark - View Label Text
- (void)testViewLabelTextIPhoneAndIPad {
    [self nibAndViewNotNil:accueilControllerIPhone];
    [self nibAndViewNotNil:accueilControllerIPad];
    
    NSData *checkImageDataOrigin = UIImagePNGRepresentation([UIImage imageNamed:@"Logo_app-MSS114px.png"]);
    NSData *checkImageDataFromNibIPhone = UIImagePNGRepresentation(accueilControllerIPhone.logo.image);
    NSData *checkImageDataFromNibIPad = UIImagePNGRepresentation(accueilControllerIPad.logo.image);
    STAssertTrue([checkImageDataFromNibIPhone isEqualToData:checkImageDataOrigin], @"Should be equal");
    STAssertTrue([checkImageDataFromNibIPad isEqualToData:checkImageDataOrigin], @"Should be equal");
    
    NSString *comparedText1 = @"Bienvenue sur l'application mobile MSSanté proposé par l’ASIP Santé et les Ordres professionnels.";
    STAssertTrue([accueilControllerIPhone.labelBienvenue.text isEqualToString:comparedText1], @"Should be equal");
    STAssertTrue([accueilControllerIPad.labelBienvenue.text isEqualToString:comparedText1], @"Should be equal");
    
    NSString *comparedText2 = @"L’accès à votre messagerie nécessite d’ajouter cet appareil mobile à la liste des appareils mobiles associés à votre compte.";
    STAssertTrue([accueilControllerIPhone.labelAcces.text isEqualToString:comparedText2], @"Should be equal");
    STAssertTrue([accueilControllerIPad.labelAcces.text isEqualToString:comparedText2], @"Should be equal");
    
    NSString *comparedText3 = @"Cette opération n’est à effectuer qu’une seule fois.";
    STAssertTrue([accueilControllerIPhone.labelOperation.text isEqualToString:comparedText3], @"Should be equal");
    STAssertTrue([accueilControllerIPad.labelOperation.text isEqualToString:comparedText3], @"Should be equal");
    
    NSString *comparedText4 = @"Vous ne disposez pas de compte MSSanté ?";
    STAssertTrue([accueilControllerIPhone.labelPasCompte.text isEqualToString:comparedText4], @"Should be equal");
    STAssertTrue([accueilControllerIPad.labelPasCompte.text isEqualToString:comparedText4], @"Should be equal");
}

@end
