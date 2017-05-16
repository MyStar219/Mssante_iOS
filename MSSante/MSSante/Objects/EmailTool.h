//
//  EmailTool.h
//  MSSante
//
//  Created by Labinnovation on 30/10/14.
//  Copyright (c) 2014 Capgemini. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Email.h"
#import "Attachment.h"
@interface EmailTool : NSObject

+(NSString*)dateToString:(NSDate*)_date;
+(NSString*)truncateSubject:(NSString*)subject;
+(NSString*)truncateBody:(NSString*)body;

+(NSString*)emailtoString:(Email*)email ;
+(NSString*)splitEmails:(NSMutableArray*)emails maxCharactersPerLine:(NSUInteger)maxChars label:(NSString*)label;
+(BOOL)isValidEmail:(NSString *)checkString;

+(BOOL)attachmentIsImage:(Attachment*)attachment;
+(BOOL)attachmentIsViewable:(Attachment*)attachment;
+(BOOL)attachmentIsSupported:(Attachment*)attachment;
@end

