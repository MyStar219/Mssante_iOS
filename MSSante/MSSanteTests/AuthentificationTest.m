//
//  AuthentificationTest.m
//  MSSante
//
//  Created by Labinnovation on 15/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "AuthentificationTest.h"
#import "AccesToUserDefaults.h"

@implementation AuthentificationTest {
    NSURL *otpSubmitURL;
    NSString *otp;
    NSString *idCanal;
    NSString *idNat;
    NSString *password;
    NSString *authRequest;
    NSString *jSessionId;
    NSString *idCanalHeader;
    NSString *idNatHeader;
    NSString *passwordHeader;
    NSString *userDefaultsSessionId;
    NSString *contentType;
    NSDictionary *headers;
    NSString *otpHeader;
    NSString *assertionConsumerServiceURL;
}

- (void)setUp {
    [super setUp];
    auth = [Authentification sharedInstance];
    otpSubmitURL = [NSURL URLWithString:SERVER_MSS];
    otp = @"OTP";
    idCanal = @"312654978";
    idNat = @"2313645987";
    password = @"aaaa";
    authRequest = @"AUTH_REQUEST";
    jSessionId = @"JSESSIONID";
    idCanalHeader = @"";
    idNatHeader = @"";
    passwordHeader = @"";
    contentType = @"";
    otpHeader = @"";
    assertionConsumerServiceURL = SERVER_MSS;
}

- (void)tearDown {
    
    [super tearDown];
}

- (void)testSharedInstance {
    STAssertNotNil(auth, @"Impossible d'initialiser auth");
}

- (void)testAuthDelegate {
    STAssertNil([Authentification authDelegate], @"Impossible d'initialiser authDelegate");

    id slf = nil;
    [auth setAuthDelegate:slf];
    STAssertNil([Authentification authDelegate], @"Impossible d'initialiser authDelegate");
    
    slf = self;
    
    [auth setAuthDelegate:slf];
    STAssertEqualObjects([Authentification authDelegate],slf, @"Impossible d'initialiser authDelegate");
    
}

- (void)testAuthentifierOtp {
    
    STAssertNil([auth authentifierOtp], @"mpossible d'initialiser Request");
    
    [AccesToUserDefaults setUserInfoIdNat:idNat];
    [auth setUserPassword:password];
    [AccesToUserDefaults setUserInfoIdCanal:idCanal];
    STAssertNotNil([auth authentifierOtp], @"Impossible d'initialiser Request: authentifierOtp");
    headers = [[[auth authentifierOtp] request] allHTTPHeaderFields];
    
    if([headers objectForKey:HTTP_HEADER_IDCANAL]) {
        idCanalHeader = [headers objectForKey:HTTP_HEADER_IDCANAL];
    }
    
    if([headers objectForKey:HTTP_HEADER_IDNAT]) {
        idNatHeader = [headers objectForKey:HTTP_HEADER_IDNAT];
    }
    
    if([headers objectForKey:HTTP_HEADER_PASSWORD]) {
        passwordHeader = [headers objectForKey:HTTP_HEADER_PASSWORD];
    }
    
    if([headers objectForKey:HTTP_CONTENT_TYPE]) {
        contentType = [headers objectForKey:HTTP_CONTENT_TYPE];
    }
    
    STAssertEqualObjects(idCanalHeader, idCanal, @"Impossible d'initialiser IDCANAL HEADER");
    STAssertEqualObjects(idNatHeader, idNat, @"Impossible d'initialiser IDNAT HEADER");
    STAssertEqualObjects(passwordHeader, password, @"Impossible d'initialiser PASSWORD HEADER");
    STAssertEqualObjects(contentType, TEXT_XML, @"Impossible d'initialiser PASSWORD HEADER");
    STAssertEqualObjects([[auth authentifierOtp] parameters], authRequest, @"Impossible d'initialiser parameters");
    STAssertEqualObjects([[auth authentifierOtp] delegate], auth, @"Impossible d'initialiser delegate");
    STAssertEqualObjects(jSessionId, userDefaultsSessionId, @"Impossible de stocker jSessionId dans UserDefaults");
    STAssertTrue([[auth authentifierOtp] isAuthenticationRequest], @"Impossible d'initialiser isAuthenticationRequest");
}


- (void)testValiderOtp {
    otpSubmitURL = [NSURL URLWithString:SERVER_MSS];
    otp = @"OTP";
    
    [auth setOtpSubmitURL:SERVER_MSS];
    [auth validerOtp:otp];
    STAssertNotNil([auth validerOtp], @"Impossible d'initialiser Request");
    
    headers = [[[auth validerOtp] request] allHTTPHeaderFields];
    
    
    if([headers objectForKey:OTP]) {
        otpHeader = [headers objectForKey:OTP];
    }
    
    if([headers objectForKey:HTTP_CONTENT_TYPE]) {
        contentType = [headers objectForKey:HTTP_CONTENT_TYPE];
    }
    
    STAssertEqualObjects(otpHeader, otp, @"Impossible d'initialiser OTP HEADER");
    STAssertEqualObjects(contentType, TEXT_XML, @"Impossible d'initialiser CONTENT-TYPE HEADER");
    STAssertEqualObjects([[auth validerOtp] parameters], [NSMutableDictionary dictionary],@"Impossible d'initialiser parameters");
    STAssertEqualObjects([[auth validerOtp] delegate], auth, @"Impossible d'initialiser delegate");
    STAssertTrue([[auth validerOtp] isAuthenticationRequest], @"Impossible d'initialiser isAuthenticationRequest");
    STAssertEqualObjects([[[auth validerOtp] request] URL], otpSubmitURL, @"Impossible d'initialiser otpSubmitURL");
}

- (void)testReset {
    [auth setOtpSubmitURL:SERVER_MSS];
    [auth reset];
    STAssertNil([auth otpSubmitURL], @"Impossible de réinitialiser otpSubmitURL");
    STAssertNil([auth pushTimer], @"Impossible de réinitialiser pushTimer");
}

- (void)testHttpResponse {
    id response = WAIT_FOR_OTP;
    [auth reset];
    [auth httpResponse:response];
    STAssertNotNil([auth pushTimer], @"Impossible de réinitialiser pushTimer");
    
    response = @"SAML_ASSERTION";
    [auth setAssertionConsumerServiceURL:assertionConsumerServiceURL];
    [auth httpResponse:response];
    
    NSDictionary *authInfo = [auth authInfo];
    
    NSString *authInfoJsessionID = @"";
    NSString *authInfoAssertionConsumerServiceURL = @"";
    NSString *authInfoSamlAssertion = @"";
    
    if([authInfo objectForKey:ASSERTION_CUSTOMER_SERVICE_URL]) {
        authInfoAssertionConsumerServiceURL = [authInfo objectForKey:ASSERTION_CUSTOMER_SERVICE_URL];
    }
    
    if([authInfo objectForKey:ASSERTION_CUSTOMER_SERVICE_URL]) {
        authInfoSamlAssertion = [authInfo objectForKey:ASSERTION_SAML];
    }
    
    STAssertEqualObjects(authInfoJsessionID, jSessionId, @"Impossible d'initialiser jSessionId");
    STAssertEqualObjects(authInfoAssertionConsumerServiceURL, assertionConsumerServiceURL, @"Impossible d'initialiser assertionConsumerServiceURL");
    STAssertEqualObjects(authInfoSamlAssertion, response, @"Impossible d'initialiser SAML Assertion");
}

- (void) testAuthenticationError {
    Error *error = [[Error alloc] initWithErrorCode:1000 httpStatusCode:0 errorMsg:NSLocalizedString(@"AUTHENTIFICATION_IMPOSSIBLE", "Authentification impossible, veuillez réessayer")];
    [auth authenticationError:self];
    STAssertEquals([error errorCode], [[auth error] errorCode], @"Impossible d'initialiser error");
    STAssertEqualObjects([error errorMsg], [[auth error] errorMsg], @"Impossible d'initialiser error");
}

@end
