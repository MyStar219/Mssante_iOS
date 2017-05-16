//
//  Tools.m
//  MSSante
//
//  Created by Labinnovation on 14/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "Tools.h"
#import "Constant.h"
#import "Base64.h"

@implementation Tools


+ (NSData *)base64DataFromString: (NSString *)string {
    unsigned long ixtext, lentext;
    unsigned char ch, inbuf[4], outbuf[3];
    short i, ixinbuf;
    Boolean flignore, flendtext = false;
    const unsigned char *tempcstring;
    NSMutableData *theData;
    
    if (string == nil){
        return [NSData data];
    }
    
    ixtext = 0;
    tempcstring = (const unsigned char *)[string UTF8String];
    lentext = [string length];
    theData = [NSMutableData dataWithCapacity: lentext];
    ixinbuf = 0;
    while (true) {
        if (ixtext >= lentext){
            break;
        }
        ch = tempcstring [ixtext++];
        
        flignore = false;
        
        if ((ch >= 'A') && (ch <= 'Z')){
            ch = ch - 'A';
        } else if ((ch >= 'a') && (ch <= 'z')) {
            ch = ch - 'a' + 26;
        } else if ((ch >= '0') && (ch <= '9')) {
            ch = ch - '0' + 52;
        } else if (ch == '+') {
            ch = 62;
        } else if (ch == '=') {
            flendtext = true;
        } else if (ch == '/') {
            ch = 63;
        } else {
            flignore = true;
        }
        
        if (!flignore) {
            short ctcharsinbuf = 3;
            Boolean flbreak = false;
            
            if (flendtext) {
                if (ixinbuf == 0) {
                    break;
                }
                
                if ((ixinbuf == 1) || (ixinbuf == 2)) {
                    ctcharsinbuf = 1;
                } else {
                    ctcharsinbuf = 2;
                }
                
                ixinbuf = 3;
                
                flbreak = true;
            }
            
            inbuf [ixinbuf++] = ch;
            
            if (ixinbuf == 4) {
                ixinbuf = 0;
                
                outbuf[0] = (inbuf[0] << 2) | ((inbuf[1] & 0x30) >> 4);
                outbuf[1] = ((inbuf[1] & 0x0F) << 4) | ((inbuf[2] & 0x3C) >> 2);
                outbuf[2] = ((inbuf[2] & 0x03) << 6) | (inbuf[3] & 0x3F);
                
                for (i = 0; i < ctcharsinbuf; i++) {
                    [theData appendBytes: &outbuf[i] length: 1];
                }
            }
            
            if (flbreak) {
                break;
            }
        }
    }
    
    return theData;
}

+ (NSData*)AES256EncryptWithKey:(NSString*)key data:(NSData*)data {
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
//	char keyPtr[kCCKeySizeAES256]; // room for terminator (unused)
//	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
//	
//	// fetch key data
//    
//    strncpy(keyPtr, [key cStringUsingEncoding:NSISOLatin1StringEncoding], kCCKeySizeAES256);
//    
////	[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
//	
//    DLog(@"keyPtr %s",[key cStringUsingEncoding:NSISOLatin1StringEncoding]);
//	NSUInteger dataLength = [data length];
	
	//See the doc: For block ciphers, the output size will always be less than or
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
//	size_t bufferSize = data.length + kCCBlockSizeAES128;
//	void *buffer = malloc(bufferSize);
	
    NSMutableData *cipherData = [NSMutableData dataWithLength:data.length + kCCBlockSizeAES128];
    
	size_t numBytesEncrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          [key cStringUsingEncoding:NSUTF8StringEncoding],
                                          kCCKeySizeAES256,
                                          NULL /* initialization vector (optional) */,
                                          [data bytes],
                                          [data length], /* input */
                                          cipherData.mutableBytes,
                                          cipherData.length, /* output */
                                          &numBytesEncrypted);
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return cipherData;
	}
    
//	free(buffer); //free the buffer;
	return nil;
}



+ (NSData *)AES256DecryptWithKey:(NSString *)key data:(NSData*)data {
	NSMutableData *cipherData = [NSMutableData dataWithLength:data.length + kCCBlockSizeAES128];
    
	size_t numBytesEncrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          [key cStringUsingEncoding:NSUTF8StringEncoding],
                                          kCCKeySizeAES256,
                                          NULL /* initialization vector (optional) */,
                                          [data bytes],
                                          [data length], /* input */
                                          cipherData.mutableBytes,
                                          cipherData.length, /* output */
                                          &numBytesEncrypted);
    DLog(@"cryptStatus %d",cryptStatus);
    
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return cipherData;
	}
    
    //	free(buffer); //free the buffer;
	return nil;
}

+ (NSArray*) arrayOfBytesFromData:(NSData*)data {
    unsigned char *bytes =(unsigned char*)[data bytes];
    if (data.length > 0) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:data.length];
        for (NSUInteger i = 0; i < data.length; i++) {
            [array addObject:[NSNumber numberWithUnsignedChar:bytes[i]]];
        }
        
        return [NSArray arrayWithArray:array];
    }
    return nil;
}

+ (NSString*)getAttachmentFilePath:(NSString*)filename {
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *attachmentsDir = [documentsPath stringByAppendingPathComponent:ATTACHMENTS];
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:attachmentsDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:attachmentsDir withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    }
    return [attachmentsDir stringByAppendingPathComponent:filename];
}

+ (NSString*)getAttachmentTempFilePath:(NSString*)filename {
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *attachmentsDir = [[documentsPath stringByAppendingPathComponent:ATTACHMENTS] stringByAppendingPathComponent:ATTACHMENTS_TEMP];
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:attachmentsDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:attachmentsDir withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    }
    return [attachmentsDir stringByAppendingPathComponent:filename];
}

+ (void)copyAttachmentToTempFolder:(NSData*)attachmentData fileName:(NSString*)fileName{
    NSString *filePath = [Tools getAttachmentTempFilePath:fileName];
    [attachmentData writeToFile:filePath atomically:YES];
}

+ (void)deleteAttachmentFromTempFolder:(NSString*)fileName {
    NSString *filePath = [Tools getAttachmentTempFilePath:fileName];
    if (filePath) {
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
        if (fileExists) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError *error;
            BOOL success = [fileManager removeItemAtPath:filePath error:&error];
            if (!success) DLog(@"Error Deleting Attachment: %@", [error localizedDescription]);
        }
    }
}

+ (NSString*)generateSalt:(NSUInteger)size {
    NSMutableData* data = [NSMutableData dataWithLength:size];
    int status = SecRandomCopyBytes(kSecRandomDefault, size, [data mutableBytes]);
    if (status == -1) {
        DLog(@"Error using randomization services: %s", strerror(errno));
        return nil;
    }
    return [data base64EncodedString];
}

+ (NSData*)PBKDF2:(NSString*)password withSalt:(NSString*)salt {
    
    NSData *saltData = [salt base64DecodedData];
//    const uint32_t oneSecond = 1000;
//    int rounds = CCCalibratePBKDF(kCCPBKDF2, password.length, salt.length, kCCPRFHmacAlgSHA256, kCCKeySizeAES256, oneSecond);
    int rounds = 20000;
//    DLog(@"NumberOfRounds %d",rounds);
    NSMutableData* key = [NSMutableData dataWithLength:kCCKeySizeAES256];
    int keyDerivationResult = CCKeyDerivationPBKDF(kCCPBKDF2,
                                                   [password UTF8String],
                                                   [password lengthOfBytesUsingEncoding: NSUTF8StringEncoding],
                                                   [saltData bytes],
                                                   [saltData length],
                                                   kCCPRFHmacAlgSHA256,
                                                   rounds,
                                                   [key mutableBytes],
                                                   kCCKeySizeAES256);
    if (keyDerivationResult == kCCParamError) {
        //you shouldn't get here with the parameters as above
        DLog(@"Error generating key derivation");
        return nil;
    }
    return key;
}

+ (NSString*)HMAC_SHA256:(NSString*)key password:(NSString*)password {
    NSMutableData* hmac = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    NSData *keyData = [key base64DecodedData];
    CCHmac(kCCHmacAlgSHA256,
           [keyData bytes],
           kCCKeySizeAES128,
           [password UTF8String],
           [password lengthOfBytesUsingEncoding: NSUTF8StringEncoding],
           [hmac mutableBytes]);
    
    return [hmac base64EncodedString];
}

@end
