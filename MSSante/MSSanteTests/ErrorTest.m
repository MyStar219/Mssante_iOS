//
//  ErrorTest.m
//  MSSante
//
//  Created by Labinnovation on 18/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "ErrorTest.h"
#import "Error.h"

@implementation ErrorTest {
    Error *error;
    int errorCode;
    int httpStatusCode;
    NSString *errorMsg;
    NSString *errorTitle;
}

- (void)setUp {
    [super setUp];
    errorCode = 123;
    httpStatusCode = 501;
}

- (void)tearDown {
    // Tear-down code here.
    [super tearDown];
}

- (void)testInitError {
    errorMsg = nil;
    error = [[Error alloc] initWithErrorCode:errorCode httpStatusCode:httpStatusCode errorMsg:errorMsg];
    STAssertNotNil(error, @"Impossible d'initialiser error object");
    STAssertEqualObjects(errorMsg, error.errorMsg, @"Impossible d'initialiser errorMsg");
    STAssertEquals(errorCode, error.errorCode, @"Impossible d'initialiser errorCode");
    STAssertEquals(httpStatusCode, error.httpStatusCode, @"CImpossible d'initialiser httpStatusCode");
    
    errorMsg = @"";
    error = [[Error alloc] initWithErrorCode:errorCode httpStatusCode:httpStatusCode errorMsg:errorMsg];
    STAssertNotNil(error, @"Impossible d'initialiser error object");
    STAssertEqualObjects(errorMsg, error.errorMsg, @"Impossible d'initialiser errorMsg");
    
    errorMsg = @"Error Messqge";
    error = [[Error alloc] initWithErrorCode:errorCode httpStatusCode:httpStatusCode errorMsg:errorMsg];
    STAssertNotNil(error, @"Impossible d'initialiser error object");
    STAssertEqualObjects(errorMsg, error.errorMsg, @"Impossible d'initialiser errorMsg");
}

- (void)testInitErrorWithTitle {
    errorMsg = @"Error Messqge";
    errorTitle = nil;
    error = [[Error alloc] initWithErrorCode:errorCode httpStatusCode:httpStatusCode errorMsg:errorMsg title:errorTitle];
    STAssertNotNil(error, @"Impossible d'initialiser error object");
    STAssertEqualObjects(errorTitle, error.title, @"Impossible d'initialiser errorTitle");
    
    errorTitle = @"";
    error = [[Error alloc] initWithErrorCode:errorCode httpStatusCode:httpStatusCode errorMsg:errorMsg title:errorTitle];
    STAssertNotNil(error, @"Impossible d'initialiser error object");
    STAssertEqualObjects(errorTitle, error.title, @"Impossible d'initialiser errorTitle");
    
    errorTitle = @"Error Messqge";
    error = [[Error alloc] initWithErrorCode:errorCode httpStatusCode:httpStatusCode errorMsg:errorMsg title:errorTitle];
    STAssertNotNil(error, @"CImpossible d'initialiser error object");
    STAssertEqualObjects(errorTitle, error.title, @"Impossible d'initialiser errorTitle");
}

@end
