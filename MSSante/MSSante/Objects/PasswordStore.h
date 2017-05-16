//
//  Password.h
//  MSSante
//
//  Created by Labinnovation on 23/09/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PasswordStore : NSObject {
    BOOL firstConnection;
}

@property(nonatomic, assign) BOOL firstConnection;

+(PasswordStore*)getInstance;
+(PasswordStore*)getInstanceWithPlainPassword:(NSString *)plainPassword;
+(PasswordStore*)getInstanceWithPlainPasswordForEnrollment:(NSString *)plainPassword;

+(BOOL)verifyPassword:(NSString*)tmpPassword;
-(NSString*)getPlainPassword;
-(void)setPlainPasswordValue:(NSString*)plainPassword;
-(void)changePassword:(NSString*)newPassword;
-(NSString*)getDbEncryptionKey;
-(NSString*)getPlainDbEncryptionKey;
+(void)resetKeyChain;
+(void)deletePlainPassword;
+(BOOL)plainPasswordIsSet;
+(void)resetPasswords;
+(NSString *)getSaltB;
-(NSString*)generateDbEncryptionKey;
@end
