//
//  NPEmail.m
//  MSSante
//
//  Created by Labinnovation on 27/11/2014.
//  Copyright (c) 2014 Capgemini. All rights reserved.
//

#import "NPEmail.h"
#import "EmailTool.h"

@implementation NPEmail

@synthesize idMail = _idMail;
@synthesize alias = _alias;
@synthesize mail = _mail;

- (id)initWithIdMail:(NSString*)anIdMail alias:(NSString*)anAlias mail:(NSString*)aMail {
    self = [super init];
    if (self) {
        _idMail = [anIdMail copy];
        _alias = [anAlias copy];
        _mail = [aMail copy];
    }
    return self;
}


//===========================================================
// + (id)objectWith:
//
//===========================================================
+ (id)objectWithIdMail:(NSString*)anIdMail alias:(NSString*)anAlias mail:(NSString*)aMail {
    id result = [[[self class] alloc] initWithIdMail:anIdMail alias:anAlias mail:aMail];
    
    return result;
}


- (BOOL)isValid:(NSError *)error {
    return [EmailTool isValidEmail:self.mail];
}

@end
