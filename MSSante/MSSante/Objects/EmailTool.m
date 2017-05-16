//
//  EmailTool.m
//  MSSante
//
//  Created by Labinnovation on 30/10/14.
//  Copyright (c) 2014 Capgemini. All rights reserved.
//

#import "EmailTool.h"
#import "Email.h"
#import "Attachment.h"
#import "Constant.h"
@implementation EmailTool

#pragma mark - Generic string tools
+(NSString*)dateToString:(NSDate*)_date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy\nHH:mm"];
    NSString *strDate = [dateFormatter stringFromDate:_date];
    return [strDate stringByReplacingOccurrencesOfString:@":" withString:@"h"];
}
#define kSubjectLength 50
#define kSubjectSubstringLength 46
#define kSubstitutionString @"%@..."

+(NSString*)truncateSubject:(NSString*)subject{
    if([subject length]>kSubjectLength){
        return [NSString stringWithFormat:kSubstitutionString,[subject substringToIndex:kSubjectSubstringLength]];
    }
    return subject;
}

#define kBodyLength 50000
#define kBodySubstringLength 49999
+(NSString*)truncateBody:(NSString*)body{
    if([body length]>kBodyLength){
        return [body substringToIndex:kBodySubstringLength];
    }
    return body;
}


#pragma mark - Email string tools
+(NSString*)emailtoString:(Email*)email {
    if ([email.address length] > 0) {
        NSLog(@"email : %@",email.address);
        return email.address;
    } else {
        NSLog(@"email : %@",email.name);
        return email.name;
    }
}

+(NSString*)splitEmails:(NSMutableArray*)emails maxCharactersPerLine:(NSUInteger)maxChars label:(NSString*)label{
    NSMutableString *result = [NSMutableString stringWithFormat:@""];
    NSUInteger defaultMaxChars = maxChars;
    for (NSUInteger i = 0; i < emails.count; i++) {
        NSString *email = [emails objectAtIndex:i];
        if (i == 0) {
            defaultMaxChars -= label.length + 2;
        } else {
            defaultMaxChars = maxChars;
        }
        
        if (email.length < defaultMaxChars) {
            [result appendString:email];
        } else {
            NSUInteger splits = (email.length / defaultMaxChars) + 2;
            for (NSUInteger j = 1 ; j < splits; j++) {
                NSUInteger lastIndex = (j - 1) * defaultMaxChars;
                NSUInteger remaining = email.length - lastIndex;
                NSRange range = NSMakeRange(MAX(lastIndex, 0), MIN(defaultMaxChars, remaining) );
                [result appendString: [email substringWithRange:range]];
                
                if (j*defaultMaxChars < email.length && j < splits -1) {
                    [result appendString: @"\n"];
                }
            }
        }
        
        if (i < (emails.count - 1)) {
            [result appendString:@"\n"];
        }
    }
    
    return result;
}



#define regEmailOWASP @"^[a-zA-Z0-9+&*-]+(?:\\.[a-zA-Z0-9_+&*-]+)*@(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,7}$"

+(BOOL)isValidEmail:(NSString *)checkString {
    if (checkString==nil || checkString.length >= 256) {
        return NO;
    } else {
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regEmailOWASP];
        BOOL emailTestResult = [emailTest evaluateWithObject:checkString];
        return emailTestResult;
    }
}


#pragma mark - Attachment Tools
+(BOOL)attachmentIsImage:(Attachment*)attachment {
    NSString *contentType = attachment.contentType;
    return  [contentType isEqual:IMAGE_JPEG]    ||
            [contentType isEqual:IMAGE_PNG]     ||
            [contentType isEqual:IMAGE_GIF]     ||
            [contentType isEqual:IMAGE_TIFF];
}

+(BOOL)attachmentIsViewable:(Attachment*)attachment {
    NSString *contentType = attachment.contentType;
    return  [contentType isEqualToString:APPLICATION_PDF]   ||
            [contentType isEqualToString:TEXT_HTML]         ||
            [contentType isEqualToString:TEXT_PLAIN]        ||
            [contentType isEqualToString:TEXT_CSV]          ||
            [contentType isEqualToString:APPLICATION_RTF];
}

+(BOOL)attachmentIsSupported:(Attachment*)attachment {
    return [self attachmentIsViewable:attachment] || [self attachmentIsImage:attachment];
}

@end
