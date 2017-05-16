//
//  NPEmail.h
//  MSSante
//
//  Created by Labinnovation on 27/11/2014.
//  Copyright (c) 2014 Capgemini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NPEmail : NSObject
@property (nonatomic, copy) NSString *idMail;
@property (nonatomic, copy) NSString *alias;
@property (nonatomic, copy) NSString *mail;
- (id)initWithIdMail:(NSString*)anIdMail alias:(NSString*)anAlias mail:(NSString*)aMail;
+ (id)objectWithIdMail:(NSString*)anIdMail alias:(NSString*)anAlias mail:(NSString*)aMail;


- (BOOL)isValid:(NSError *)error;
@end
