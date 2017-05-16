//
//  Authentification.m
//  MSSante
//
//  Created by Ismail on 6/27/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "Authentification.h"
#import "AccesToUserDefaults.h"
#import "PasswordStore.h"


@implementation Authentification

@synthesize pushTimer, otpSubmitURL, assertionConsumerServiceURL, authentifierOtp, headers, validerOtp, userInfo, assertionSAML, authInfo, validerOtpTimer, error, userPassword;
@synthesize canceled;
@synthesize timeout;

static id <AuthenticationDelegate>authDelegate;

+ (id)authDelegate { return authDelegate; }
- (void)setAuthDelegate:(id)value; { authDelegate = value; }

static Authentification *sharedInstance = nil;

+ (Authentification *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

- (void)authentifierOtp:(NSString*)_authnRequest authServer:(BOOL)isAuthServer{
    headers = [NSMutableDictionary dictionary];
    userInfo = [NSMutableDictionary dictionary];
    
    if([AccesToUserDefaults getUserInfo]) {
        DLog(@"setting jSessionId in user defaults");
        userInfo = [AccesToUserDefaults getUserInfo];
    }
    
  

    DLog(@"[userInfo objectForKey:QR_IDNAT] %@",[userInfo objectForKey:QR_IDNAT]);
    DLog(@"[userInfo objectForKey:ID_CANAL] %@",[userInfo objectForKey:ID_CANAL]);
    if ([userInfo objectForKey:QR_IDNAT] && userPassword && [userInfo objectForKey:ID_CANAL]) {
        [headers setObject:[userInfo objectForKey:QR_IDNAT] forKey:HTTP_HEADER_IDNAT];
        [headers setObject:userPassword forKey:HTTP_HEADER_PASSWORD];
        [headers setObject:[userInfo objectForKey:ID_CANAL] forKey:HTTP_HEADER_IDCANAL];
        [headers setObject:TEXT_XML forKey:HTTP_CONTENT_TYPE];
        
        authentifierOtp = [[Request alloc] initWithService:S_AUTHENTIFIER_OTP method:HTTP_POST headers:headers params:_authnRequest];
        [authentifierOtp setIsAuthenticationRequest:YES];
        [authentifierOtp setDelegate:self];
        
        DLog(@"STEP#1 Execute Authentifier OTP");
        
        [authentifierOtp execute];

    } else {
        DLog(@"User info are invalid!");
        [self authenticationError:self];
    }
}

- (void)validerOtp:(NSString*)_otp {
    if (canceled) {
        return;
    }
    //wait until cookies are set
    double wait = 0.0001;
    
    validerOtpTimer = 0.0;
    
    if (timeout == 0.0) {
        timeout = TIMEOUT_OTP;
    }
    
    DLog(@"validerOtp timeout %f",timeout);
    
    while (otpSubmitURL == nil && validerOtpTimer < timeout) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:wait]];
        validerOtpTimer += wait;
    }
    
    if(validerOtpTimer < timeout && [otpSubmitURL length] > 0 && [_otp length] > 0){
        DLog(@"STEP#3 Executing Valider OTP");
        headers = [NSMutableDictionary dictionary];
        
        [headers setObject:_otp forKey:OTP];
        [headers setObject:TEXT_XML forKey:HTTP_CONTENT_TYPE];
        
        DLog(@"header OTP : %@", headers);
        validerOtp = [[Request alloc] initWithService:S_VALIDER_OTP method:HTTP_POST headers:headers params:nil];
        [validerOtp setUrl:otpSubmitURL];
        [validerOtp setDelegate:self];
        [validerOtp setIsAuthenticationRequest:YES];
        [validerOtp execute];
    } else {
        DLog(@"Cookies are invalid!");
        [self authenticationError:self];
    }
}

- (void)authenticationError:(id)sender {
    DLog(@"Push Timeout");
    error = [[Error alloc] initWithErrorCode:ERROR_TO_DISPLAY_IN_CONTROLER httpStatusCode:0 errorMsg:NSLocalizedString(@"AUTHENTIFICATION_IMPOSSIBLE", "Authentification impossible, veuillez réessayer")];

    if([authDelegate respondsToSelector:@selector(authError:)]) {
        DLog(@"Sending AuthError to Request");
        [authDelegate authError:error];
    }
    [self reset];
}

- (void)httpResponse:(id)_responseObject {
    if (canceled) {
        return;
    }
    if([_responseObject isKindOfClass:[NSString class]]) {
        if([WAIT_FOR_OTP isEqualToString:_responseObject]) {
            timeout = TIMEOUT_OTP;
            if ([AccesToUserDefaults getUserInfoChoiceMail] == nil) {
                timeout = TIMEOUT_OTP_FIRST;
            }
            
            DLog(@"httpResponse timeout %f",timeout);
            pushTimer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(authenticationError:) userInfo:nil repeats:NO];
            DLog(@"STEP#2 WAITING FOR OTP - Timer Started");
        } else {
            DLog(@"STEP#4 PARSING SAML ASSERTION");
            authInfo = [NSMutableDictionary dictionary];
            assertionSAML = _responseObject;
            if([assertionSAML length] > 0 && [assertionConsumerServiceURL length] > 0) {
                [authInfo setObject:assertionSAML forKey:ASSERTION_SAML];
                [authInfo setObject:assertionConsumerServiceURL forKey:ASSERTION_CUSTOMER_SERVICE_URL];
                
                if([authDelegate respondsToSelector:@selector(authResponse:)]) {
                    [authDelegate authResponse:authInfo];
                }
                
                [self reset];
            } else {
                [self authenticationError:self];
            }
        }
    }
}

- (void)reset {
    [self resetTimer];
    otpSubmitURL = nil;
}

- (void)resetTimer {
    [pushTimer invalidate];
    pushTimer = nil;
}

- (void)httpError:(Error*)_error {
    DLog(@"Auth Request Error");
    if([authDelegate respondsToSelector:@selector(authError:)]) {
        [authDelegate authError:_error];
    }
    
    [self reset];
}

@end
