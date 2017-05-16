//
//  Error.m
//  MSSante
//
//  Created by Ismail on 6/20/13.
//  Copyright (c) 2013 Work. All rights reserved.
//

#import "Error.h"
#import "Constant.h"

@implementation Error

@synthesize errorCode, httpStatusCode, errorMsg, title;
@synthesize service, params, errorType;
@synthesize serviceInaccessible;
- (id)initWithErrorCode:(int)_errorCode httpStatusCode:(int)_httpStatusCode errorMsg:(NSString*)_errorMsg {
    return [self initWithErrorCode:_errorCode httpStatusCode:_httpStatusCode errorMsg:_errorMsg title:NSLocalizedString(@"ERREUR", @"Erreur")];
}

- (id)initWithErrorCode:(int)_errorCode httpStatusCode:(int)_httpStatusCode errorMsg:(NSString*)_errorMsg title:(NSString *)_title {
    self = [super init];
    errorCode = _errorCode;
    httpStatusCode = _httpStatusCode;
    errorMsg = _errorMsg;
    title = _title;
    return self;
}


- (id)initWithParsingBody:(NSError*)_body httpStatus:(int)_httpStatus{
    self = [super init];
   BOOL isJSONValid = [self parseJsonData:[_body userInfo]];
    if (!isJSONValid){
        errorMsg = NSLocalizedString(@"ERREUR_WS", @"Service momentanément indisponible");
        errorCode = 0;
    }
    httpStatusCode = _httpStatus;
    title = NSLocalizedString(@"ERREUR", @"Erreur");
    return self;
}

- (BOOL)parseJsonData:(NSDictionary*)_jsonDict {
    BOOL isValidJSON = FALSE;
    if (_jsonDict != nil){
        NSString *recoveryString = [_jsonDict objectForKey:RECOVERY_SUGGESTION];
        NSData *jsonData = [recoveryString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        if (jsonData != nil) {
            NSDictionary *recoveryDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
            if (recoveryDict != nil){
                NSMutableDictionary* errorDict = [recoveryDict objectForKey:ERROR];
                if (errorDict != nil){
                    errorMsg = [errorDict objectForKey:MESSAGE];
                    errorType = [errorDict objectForKey:ERROR_TYPE];
                    errorCode = [[errorDict objectForKey:ERROR_CODE] intValue];
                    isValidJSON = TRUE;
                }
            }
        }
        
    }
    return isValidJSON;
}

@end
