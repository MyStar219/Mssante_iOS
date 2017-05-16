//
//  Tools.h
//  MSSante
//
//  Created by Labinnovation on 14/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonKeyDerivation.h>
#import <CommonCrypto/CommonHMAC.h>


@interface Tools : NSObject

+ (NSData *)base64DataFromString: (NSString *)string;
+ (NSData*)AES256EncryptWithKey:(NSString*)key data:(NSData*)data;
+ (NSData *)AES256DecryptWithKey:(NSString *)key data:(NSData*)data;
+ (NSArray*) arrayOfBytesFromData:(NSData*)data;
+ (NSString*)getAttachmentFilePath:(NSString*)filename;
+ (NSString*)getAttachmentTempFilePath:(NSString*)filename;
+ (void)deleteAttachmentFromTempFolder:(NSString*)fileName;
+ (NSString *)generateSalt:(NSUInteger)size;
+ (NSData*)PBKDF2:(NSString*)password withSalt:(NSString*)salt;
+ (NSString*)HMAC_SHA256:(NSString*)key password:(NSString*)password;
+ (void)copyAttachmentToTempFolder:(NSData*)attachmentData fileName:(NSString*)fileName;
@end
