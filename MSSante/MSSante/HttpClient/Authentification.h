//
//  Authentification.h
//  MSSante
//
//  Created by Ismail on 6/27/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthenticationDelegate.h"
#import "RequestFinishedDelegate.h"
#import "Request.h"

@class Request;
@interface Authentification : NSObject <RequestFinishedDelegate> {
    NSTimer *pushTimer;
    NSString *otpSubmitURL;
    NSString *assertionConsumerServiceURL;
    NSString *assertionSAML;
    NSMutableDictionary *headers;
    NSMutableDictionary *userInfo;
    NSMutableDictionary *authInfo;
    Request *authentifierOtp;
    Request *validerOtp;
    double validerOtpTimer;
    Error *error;
    NSString *userPassword;
    BOOL canceled;
}

@property (nonatomic, strong) NSTimer *pushTimer;
@property (nonatomic, strong) NSString *otpSubmitURL;
@property (nonatomic, strong) NSString *assertionConsumerServiceURL;
@property (nonatomic, strong) NSString *assertionSAML;
@property (nonatomic, strong) NSMutableDictionary *headers;
@property (nonatomic, strong) NSMutableDictionary *userInfo;
@property (nonatomic, strong) NSMutableDictionary *authInfo;
@property (nonatomic, strong) Request *authentifierOtp;
@property (nonatomic, strong) Request *validerOtp;
@property (nonatomic, assign) double validerOtpTimer;
@property (nonatomic, strong) Error *error;
@property (nonatomic, strong) NSString *userPassword;
@property (nonatomic, assign) BOOL canceled;
@property (nonatomic, assign) double timeout;

+ (Authentification*)sharedInstance;
+ (id<AuthenticationDelegate>)authDelegate;
- (void)setAuthDelegate:(id<AuthenticationDelegate>)value;

- (void)authentifierOtp:(NSString*)_authnRequest authServer:(BOOL)isAuthServer;
- (void)validerOtp:(NSString*)_otp;
- (void)authenticationError:(id)sender;
- (void)reset;
- (void)resetTimer;

@end
