//
//  EnrollementTest.m
//  MSSante
//
//  Created by Labinnovation on 16/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "EnrollementTest.h"
#import "Constant.h"
#import "OCMock.h"

@implementation EnrollementTest


- (void)setUp
{
    [super setUp];
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testReadQrCode
{
    controllerEnrolB = [[EnrollementBController alloc] init];
    STAssertNotNil(controllerEnrolB, @"Impossible d'initialiser controllerEnrolB");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:USER];
    
    NSString *jsonString = @"{\"code\" : \"1234567890\","
                            "\"nom\" : \"Nicco\","
                            "\"prenom\" : \"Julien\","
                            "\"idNat\" : \"1\"}";
    NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    [controllerEnrolB readQrCode:jsonObject];
    
    
    if (error){
        STFail(@"Erreur lecture QRCode : %@", error);
    }
       
    STAssertNotNil([defaults objectForKey:USER], @"User initialisé dans NSUserDefaults");
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo = [[defaults objectForKey:USER] mutableCopy];
    
    STAssertNotNil([userInfo objectForKey:QR_CODE], @"Code null dans QR code");
    STAssertNotNil([userInfo objectForKey:QR_IDNAT], @"Id Nat null dans QR code");
    STAssertNotNil([userInfo objectForKey:QR_NOM], @"Nom null dans QR code");
    STAssertNotNil([userInfo objectForKey:QR_PRENOM], @"Prenom null dans QR code");
}


- (void)testComparePassword
{
    
    controllerEnrolC = [[EnrollementCController alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:USER];
    
    NSString* mdp = @"Julien";
    NSString* confirmation = @"Julien";
    
//    [controllerEnrolC comparePassword:mdp withConfirmPassword:confirmation];
//    
//    STAssertNotNil([defaults objectForKey:USER], @"User not setted on NSUserDefaults");
//    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
//    userInfo = [[defaults objectForKey:USER] mutableCopy];
//    
//    STAssertNotNil([userInfo objectForKey:PASSWORD], @"Password null in QR code");
    
}

@end
