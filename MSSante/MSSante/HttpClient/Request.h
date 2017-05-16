//
//  Request.h
//  MSSante
//
//  Created by Ismail on 6/17/13.
//  Copyright (c) 2013 Work. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constant.h"
#import "AFHTTPClient.h"
#import "RequestFinishedDelegate.h"
#import "AFHTTPRequestOperation.h"
#import "Error.h"
#import "Response.h"
#import "AuthenticationDelegate.h"
#import "Reachability.h"
#import "Authentification.h"
#import "AccesToUserDefaults.h"
#import "RequestQueue.h"

// file UIApplication+NetworkActivity.h
@interface UIApplication (NetworkActivity)
- (void)showNetworkActivityIndicator;
- (void)hideNetworkActivityIndicator;
@end

@class RequestQueue;
@class Authentification;
@interface Request : NSObject <AuthenticationDelegate, UIAlertViewDelegate> {
    NSString *service;
    NSString *responseClassName;
    NSString *assertionConsumerServiceURL;
    NSString *authnRequest;
    NSString *samlAssertion;
    NSString *wwwAuth;
    NSString *method;
    NSString *initialMethod;
    NSString *url;
    NSString *httpBody;
    NSString *statusMessage;
    NSString *responseString;
    NSString *nextUrl;
    NSString *mimeType;
    NSString *attachmentFileName;
    NSString *downloadPath;
    NSMutableDictionary *httpHeaders;
    NSMutableURLRequest *request;
    NSURLResponse *response;
    NSDictionary *responseHeaders;
    NSData *responseData;
    int httpStatusCode;
    BOOL isValidJson;
    BOOL sendError;
    BOOL sendResponse;
    BOOL isAuthenticationRequest;
    BOOL isAuthenticationError;
    BOOL isServiceInaccessible;
    BOOL fromAuthentificationRequest;
    BOOL isEnrolmentRequest;
    BOOL hasAttachments;
    id parameters;
    id initialParameters;
    id jsonObject;
    id responseObject;
    Authentification *auth;
    AFHTTPClient *httpClient;
    Error *uiError;
    Error *wrongResponseError;
    Error *authError;
    Error *serviceNotAvailableError;
    Error *connectionError;
    NSMutableArray *listMessageIdForModification;
    NSNumber *folderIdForModification;
    NSMutableArray *listMessageIdForError45;
    RequestQueue *requestQueue;
    NSString *tmpPassword;
    BOOL canceled;
    
    NSMutableArray *trashMessageIds;
}

@property (nonatomic, strong) NSString *service;
@property (nonatomic, strong) NSString *responseClassName;
@property (nonatomic, strong) NSString *nextUrl;
@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic, strong) NSString *assertionConsumerServiceURL;
@property (nonatomic, strong) NSString *authnRequest;
@property (nonatomic, strong) NSString *samlAssertion;
@property (nonatomic, strong) NSString *wwwAuth;
@property (nonatomic, strong) NSString *method;
@property (nonatomic, strong) NSString *initialMethod;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *httpBody;
@property (nonatomic, strong) NSString *responseString;
@property (nonatomic, strong) NSString *statusMessage;
@property (nonatomic, strong) NSString *attachmentFileName;
@property (nonatomic, strong) NSString *downloadPath;
@property (nonatomic, strong) NSMutableDictionary *httpHeaders;
@property (nonatomic, strong) NSDictionary *responseHeaders;
@property (nonatomic, strong) NSMutableURLRequest *request;
@property (nonatomic, strong) NSData *responseData;
@property (nonatomic, strong) NSError *nsError;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, assign) int httpStatusCode;
@property (nonatomic, assign) BOOL sendError;
@property (nonatomic, assign) BOOL sendResponse;
@property (nonatomic, assign) BOOL isValidJson;
@property (nonatomic, assign) BOOL isAuthenticationRequest;
@property (nonatomic, assign) BOOL isEnrolmentRequest;
@property (nonatomic, assign) BOOL hasAttachments;
@property (nonatomic, strong) id jsonObject;
@property (nonatomic, strong) id responseObject;
@property (nonatomic, strong) id parameters;
@property (nonatomic, strong) id initialParameters;
@property (nonatomic, weak) id<RequestFinishedDelegate>delegate;
@property (nonatomic, strong) AFHTTPClient *httpClient;
@property (nonatomic, strong) AFHTTPRequestOperation *operation;
@property (nonatomic, strong) Error *uiError;
@property (nonatomic, strong) Error *wrongResponseError;
@property (nonatomic, strong) Error *authError;
@property (nonatomic, strong) Error *serviceNotAvailableError;
@property (nonatomic, strong) Error *connectionError;
@property (nonatomic, strong) Error *qrError;
@property (nonatomic, strong) Authentification *auth;
@property (nonatomic, strong) RequestQueue *requestQueue;
@property (nonatomic, strong) NSString *tmpPassword;
@property (nonatomic, assign) BOOL canceled;
@property (nonatomic, assign) BOOL isModification;
@property (nonatomic, assign) BOOL isError45Request;
@property (nonatomic, strong) NSMutableArray *trashMessageIds;

- (id)initWithService:(NSString *)_service;
- (id)initWithService:(NSString *)_service method:(NSString *)_method params:(NSMutableDictionary *)_parameters;
- (id)initWithService:(NSString *)_service method:(NSString *)_method headers:(NSMutableDictionary *)_headers params:(id)_parameters;

- (NSString*)generateUrl:(NSString*)_service;
- (void)execute;
- (void)handleRequestError:(AFHTTPRequestOperation*)_operation error:(NSError*)_error;
- (void)handleRequestSuccess:(AFHTTPRequestOperation*)_operation response:(id) _response;

- (id)parseJsonString:(NSString*)_jsonString;
- (id)parseJsonData:(NSData*)_jsonData;

- (NSString*)capitalizeString:(NSString*)_str;
- (NSString*)regexFindMatch:(NSString*)_string pattern:(NSString*)_pattern;
- (NSString*)regexReplaceMatch:(NSString*)_string pattern:(NSString*)_pattern replacement:(NSString*)_replacement;

- (id)getResponseObjectFromJsonData:(NSData*)_data;
- (id)getResponseObjectFromJsonObject:(id)_jsonObject;

- (BOOL)isConnectedToInternet;

- (void)sendErrorToUI:(Error*)_error;
- (void)sendResponseToUI:(id)_response;

@end
