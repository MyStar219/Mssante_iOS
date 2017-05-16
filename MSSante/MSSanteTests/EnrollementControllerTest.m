//
//  EnrollementControllerTest.m
//  MSSante
//
//  Created by Labinnovation on 14/04/2015.
//  Copyright (c) 2015 Capgemini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SenTestingKit/SenTestingKit.h>
#import "EnrollementController.h"

@interface EnrollementControllerTest : SenTestCase

@property (strong, nonatomic) EnrollementController *enrollementControllerIPhone;
@property (strong, nonatomic) EnrollementController *enrollementControllerIPad;

@end

@implementation EnrollementControllerTest

@synthesize enrollementControllerIPhone;
@synthesize enrollementControllerIPad;

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    enrollementControllerIPhone = [[EnrollementController alloc] initWithNibName:@"EnrollementController_iPhone"
                                                                          bundle:nil];
    enrollementControllerIPad = [[EnrollementController alloc] initWithNibName:@"EnrollementController_iPad"
                                                                        bundle:nil];
    
    /* @WX - Important (from StackOverFlow - XIB Outlet Unit Testing)
     * To test IBOutlet from Nib, it needs to call
     * --> viewController.view
     * If it is not called, the test fails because the view is never fetched.
     */
    [enrollementControllerIPhone view];
    [enrollementControllerIPad view];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    enrollementControllerIPhone = nil;
    enrollementControllerIPad = nil;
    
    [super tearDown];
}

#pragma mark - Managing Test
- (void)nibAndViewNotNil:(EnrollementController *)enrollementController {
    STAssertNotNil(enrollementController, @"Nib is nil");
    STAssertNotNil(enrollementController.view, @"View is nil");
}

- (void)IBOutletNil:(EnrollementController *)enrollementController type:(NSString *)type {
    STAssertNil(enrollementController.barreProgression, @"Progress bar is %@", type);
    
    STAssertNil(enrollementController.labelEtape, @"Label \"Etape\" is %@", type);
    STAssertNil(enrollementController.labelDepuis, @"Label \"Depuis ...\" is %@", type);
    STAssertNil(enrollementController.labelConnectez, @"Label \"Connectez ...\" is %@", type);
    STAssertNil(enrollementController.labelEspace, @"Label \"Espace ...\" is %@", type);
    STAssertNil(enrollementController.labelCliquez, @"Label \"Cliquez ...\" is %@", type);
    
    STAssertNil(enrollementController.boutonContinuer, @"Button \"Continuer\" is %@", type);
}

- (void)IBOutletNotNil:(EnrollementController *)enrollementController type:(NSString *)type {
    STAssertNotNil(enrollementController.barreProgression, @"Progress bar is %@", type);
    
    STAssertNotNil(enrollementController.labelEtape, @"Label \"Etape\" is %@", type);
    STAssertNotNil(enrollementController.labelDepuis, @"Label \"Depuis ...\" is %@", type);
    STAssertNotNil(enrollementController.labelConnectez, @"Label \"Connectez ...\" is %@", type);
    STAssertNotNil(enrollementController.labelEspace, @"Label \"Espace ...\" is %@", type);
    STAssertNotNil(enrollementController.labelCliquez, @"Label \"Cliquez ...\" is %@", type);
    
    STAssertNotNil(enrollementController.boutonContinuer, @"Button \"Continuer\" is %@", type);
}

#pragma mark - View Binding
- (void)testViewBinding {
    [self nibAndViewNotNil:enrollementControllerIPhone];
    [self nibAndViewNotNil:enrollementControllerIPad];
    
    [self IBOutletNotNil:enrollementControllerIPhone type:@"not binded"];
    [self IBOutletNotNil:enrollementControllerIPad type:@"not binded"];
}

#pragma mark - View Unloading
- (void)testViewUnloading {
    [self nibAndViewNotNil:enrollementControllerIPhone];
    [self nibAndViewNotNil:enrollementControllerIPad];
    
    [self IBOutletNotNil:enrollementControllerIPhone type:@"released"];
    [self IBOutletNotNil:enrollementControllerIPad type:@"released"];
    
    [enrollementControllerIPhone didReceiveMemoryWarning];
    [enrollementControllerIPad didReceiveMemoryWarning];
    [self IBOutletNil:enrollementControllerIPhone type:@"not released"];
    [self IBOutletNil:enrollementControllerIPad type:@"not released"];
}

#pragma mark - View Reloading
- (void)testViewReloading {
    [self nibAndViewNotNil:enrollementControllerIPhone];
    [self nibAndViewNotNil:enrollementControllerIPad];
    
    [enrollementControllerIPhone didReceiveMemoryWarning];
    [enrollementControllerIPad didReceiveMemoryWarning];
    [self IBOutletNil:enrollementControllerIPhone type:@"not released"];
    [self IBOutletNil:enrollementControllerIPad type:@"not released"];
    
    [enrollementControllerIPhone loadView];
    [enrollementControllerIPad loadView];
    [self IBOutletNotNil:enrollementControllerIPhone type:@"released"];
    [self IBOutletNotNil:enrollementControllerIPad type:@"released"];
}

#pragma mark - View Label Text
- (void)testViewLabelText {
    [self nibAndViewNotNil:enrollementControllerIPhone];
    [self nibAndViewNotNil:enrollementControllerIPad];
    
    NSData *checkImageDataOrigin = UIImagePNGRepresentation([UIImage imageNamed:@"barre_progression1.png"]);
    NSData *checkImageDataFromNibIPhone = UIImagePNGRepresentation(enrollementControllerIPhone.barreProgression.image);
    NSData *checkImageDataFromNibIPad = UIImagePNGRepresentation(enrollementControllerIPad.barreProgression.image);
    STAssertTrue([checkImageDataFromNibIPhone isEqualToData:checkImageDataOrigin], @"Should be equal");
    STAssertTrue([checkImageDataFromNibIPad isEqualToData:checkImageDataOrigin], @"Should be equal");
    
    NSString *comparedText1 = @"Etape 1/3";
    STAssertTrue([enrollementControllerIPhone.labelEtape.text isEqualToString:comparedText1], @"Should be equal");
    STAssertTrue([enrollementControllerIPad.labelEtape.text isEqualToString:comparedText1], @"Should be equal");
    
    NSString *comparedText2 = @"Depuis votre ordinateur :";
    STAssertTrue([enrollementControllerIPhone.labelDepuis.text isEqualToString:comparedText2], @"Should be equal");
    STAssertTrue([enrollementControllerIPad.labelDepuis.text isEqualToString:comparedText2], @"Should be equal");
    
    NSString *comparedText3 = @"1. Connectez-vous à votre compte MSSanté,";
    STAssertTrue([enrollementControllerIPhone.labelConnectez.text isEqualToString:comparedText3], @"Should be equal");
    STAssertTrue([enrollementControllerIPad.labelConnectez.text isEqualToString:comparedText3], @"Should be equal");
    
    NSString *comparedText4 = @"2. Dans l’espace « Gérer mes appareils mobiles », sélectionnez la rubrique « Les appareils mobiles associés à mon compte »,";
    STAssertTrue([enrollementControllerIPhone.labelEspace.text isEqualToString:comparedText4], @"Should be equal");
    STAssertTrue([enrollementControllerIPad.labelEspace.text isEqualToString:comparedText4], @"Should be equal");
    
    NSString *comparedText5 = @"3. Cliquez sur le bouton « Ajouter un appareil mobile ».";
    STAssertTrue([enrollementControllerIPhone.labelCliquez.text isEqualToString:comparedText5], @"Should be equal");
    STAssertTrue([enrollementControllerIPad.labelCliquez.text isEqualToString:comparedText5], @"Should be equal");
}

@end
