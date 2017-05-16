//
//  NSData+AES256.h
//  MSSante
//
//  Created by Labinnovation on 06/09/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

@interface NSData (AES256)
- (NSData *)AES256EncryptWithDataKey:(NSData *)key;
- (NSData *)AES256EncryptWithKey:(NSString *)key;
- (NSData *)AES256DecryptWithKey:(NSString *)key;
- (NSData *)AES256DecryptWithDataKey:(NSData *)key;
@end
