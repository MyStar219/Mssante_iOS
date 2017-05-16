//
//  NoAccountControllerTest.m
//  MSSante
//
//  Created by Labinnovation on 13/04/2015.
//  Copyright (c) 2015 Capgemini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SenTestingKit/SenTestingKit.h>
#import "NoAccountController.h"

@interface NoAccountControllerTest : SenTestCase

@property (strong, nonatomic) NoAccountController *noAccountControllerIPhone;
@property (strong, nonatomic) NoAccountController *noAccountControllerIPad;

@end

@implementation NoAccountControllerTest

@synthesize noAccountControllerIPhone;
@synthesize noAccountControllerIPad;

#pragma mark - Initialization
- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    noAccountControllerIPhone = [[NoAccountController alloc] initWithNibName:@"NoAccountController_iPhone"
                                                                      bundle:nil];
    noAccountControllerIPad = [[NoAccountController alloc] initWithNibName:@"NoAccountController_iPad"
                                                                    bundle:nil];
    
    /* @WX - Important (from StackOverFlow - XIB Outlet Unit Testing)
     * To test IBOutlet from Nib, it needs to call
     * --> viewController.view
     * If it is not called, the test fails because the view is never fetched.
     */
    [noAccountControllerIPhone view];
    [noAccountControllerIPad view];
}

#pragma mark - Clean Up
- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    noAccountControllerIPhone = nil;
    noAccountControllerIPad = nil;
    
    [super tearDown];
}

#pragma mark - Managing Test
- (void)nibAndViewNotNil:(NoAccountController *)noAccountController {
    STAssertNotNil(noAccountController, @"Nib is nil");
    STAssertNotNil(noAccountController.view, @"View is nil");
}

- (void)IBOutletNil:(NoAccountController *)noAccountController type:(NSString *)type {
    STAssertNil(noAccountController.labelRdv, @"Label \"Rendez-vous ...\" is %@", type);
    STAssertNil(noAccountController.labelActivation, @"Label \"L'activation d'un ...\" is %@", type);
    STAssertNil(noAccountController.labelProfessionnel, @"Label \"- un professionnel ...\" is %@", type);
    STAssertNil(noAccountController.labelTitulaire, @"Label \"- titulaire d'une CPS,\" is %@", type);
    STAssertNil(noAccountController.labelEquipe, @"Label \"- équipé d'un lecteur ...\" is %@", type);
}

- (void)IBOutletNotNil:(NoAccountController *)noAccountController type:(NSString *)type {
    STAssertNotNil(noAccountController.labelRdv, @"Label \"Rendez-vous ...\" is %@", type);
    STAssertNotNil(noAccountController.labelActivation, @"Label \"L'activation d'un ...\" is %@", type);
    STAssertNotNil(noAccountController.labelProfessionnel, @"Label \"- un professionnel ...\" is %@", type);
    STAssertNotNil(noAccountController.labelTitulaire, @"Label \"- titulaire d'une CPS,\" is %@", type);
    STAssertNotNil(noAccountController.labelEquipe, @"Label \"- équipé d'un lecteur ...\" is %@", type);
}

#pragma mark - View Binding
- (void)testViewBinding {
    [self nibAndViewNotNil:noAccountControllerIPhone];
    [self nibAndViewNotNil:noAccountControllerIPad];
    
    [self IBOutletNotNil:noAccountControllerIPhone type:@"not binded"];
    [self IBOutletNotNil:noAccountControllerIPad type:@"not binded"];
}

#pragma mark - View Unloading
- (void)testViewUnloading {
    [self nibAndViewNotNil:noAccountControllerIPhone];
    [self nibAndViewNotNil:noAccountControllerIPad];
    
    [self IBOutletNotNil:noAccountControllerIPhone type:@"not released"];
    [self IBOutletNotNil:noAccountControllerIPad type:@"not released"];
    
    [noAccountControllerIPhone didReceiveMemoryWarning];
    [noAccountControllerIPad didReceiveMemoryWarning];
    [self IBOutletNil:noAccountControllerIPhone type:@"released"];
    [self IBOutletNil:noAccountControllerIPad type:@"released"];
}

#pragma mark - View Reloading
- (void)testViewReloading {
    [self nibAndViewNotNil:noAccountControllerIPhone];
    [self nibAndViewNotNil:noAccountControllerIPad];
    
    [noAccountControllerIPhone didReceiveMemoryWarning];
    [noAccountControllerIPad didReceiveMemoryWarning];
    [self IBOutletNil:noAccountControllerIPhone type:@"released"];
    [self IBOutletNil:noAccountControllerIPad type:@"released"];
    
    [noAccountControllerIPhone loadView];
    [noAccountControllerIPad loadView];
    [self IBOutletNotNil:noAccountControllerIPhone type:@"not released"];
    [self IBOutletNotNil:noAccountControllerIPad type:@"not released"];
}

#pragma mark - View Label Text
- (void)testViewLabelText {
    [self nibAndViewNotNil:noAccountControllerIPhone];
    [self nibAndViewNotNil:noAccountControllerIPad];
    
    NSString *comparedText1 = @"Rendez-vous sur le site mssante.fr pour activer votre compte de messagerie sécurisée MSSanté depuis votre poste de travail.";
    STAssertTrue([noAccountControllerIPhone.labelRdv.text isEqualToString:comparedText1], @"Should be equal");
    STAssertTrue([noAccountControllerIPad.labelRdv.text isEqualToString:comparedText1], @"Should be equal");
    
    NSString *comparedText2 = @"L'activation d'un compte MSSanté nécessite d'être :";
    STAssertTrue([noAccountControllerIPhone.labelActivation.text isEqualToString:comparedText2], @"Should be equal");
    STAssertTrue([noAccountControllerIPad.labelActivation.text isEqualToString:comparedText2], @"Should be equal");
    
    NSString *comparedText3 = @"- un professionnel de santé,";
    STAssertTrue([noAccountControllerIPhone.labelProfessionnel.text isEqualToString:comparedText3], @"Should be equal");
    STAssertTrue([noAccountControllerIPad.labelProfessionnel.text isEqualToString:comparedText3], @"Should be equal");
    
    NSString *comparedText4 = @"- titulaire d'une CPS,";
    STAssertTrue([noAccountControllerIPhone.labelTitulaire.text isEqualToString:comparedText4], @"Should be equal");
    STAssertTrue([noAccountControllerIPad.labelTitulaire.text isEqualToString:comparedText4], @"Should be equal");
    
    NSString *comparedText5 = @"- équipé d'un lecteur de carte.";
    STAssertTrue([noAccountControllerIPhone.labelEquipe.text isEqualToString:comparedText5], @"Should be equal");
    STAssertTrue([noAccountControllerIPad.labelEquipe.text isEqualToString:comparedText5], @"Should be equal");
}

@end
