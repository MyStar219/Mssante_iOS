//
//  Error.h
//  MSSante
//
//  Created by Ismail on 6/20/13.
//  Copyright (c) 2013 Work. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Error : NSObject {
    int httpStatusCode;
    int errorCode;
    NSString* errorMsg;
    NSString* title;
    NSString *service;
    NSString *errorType;
    id params;
}

@property(nonatomic, strong) NSString* errorMsg;
@property(nonatomic, assign) int errorCode;
@property(nonatomic, assign) int httpStatusCode;
@property(nonatomic, strong) NSString* title;
@property(nonatomic, strong) NSString* service;
@property(nonatomic, strong) NSString* errorType;
@property(nonatomic, strong) id params;
@property(nonatomic, assign) BOOL serviceInaccessible;

- (id)initWithErrorCode:(int)_errorCode httpStatusCode:(int)_httpStatusCode errorMsg:(NSString*)_errorMsg;
- (id)initWithErrorCode:(int)_errorCode httpStatusCode:(int)_httpStatusCode errorMsg:(NSString*)_errorMsg title:(NSString*)_title;
- (id)initWithParsingBody:(NSError*)_body httpStatus:(int)_httpStatus;

@end
