//
//  NPConverter.m
//  MSSante
//
//  Created by Labinnovation on 27/11/2014.
//  Copyright (c) 2014 Capgemini. All rights reserved.
//

#import "NPConverter.h"

#import "Email.h"
#import "NPEmail.h"

#import "NPMessage.h"
#import "Message.h"

#import "Attachment.h"
#import "NPAttachment.h"

#import "AccesToUserDefaults.h"
#import "Constant.h"

#define kTO @"TO"
#define kFROM @"FROM"
#define kCC @"CC"
#define kCCI @"CCI"

@implementation NPConverter

+(NPEmail *)convertEmail:(Email *)persistantEmail{
    NPEmail * nonPersistantEmail = [[NPEmail alloc] init];
    [nonPersistantEmail setMail: persistantEmail.address];
    [nonPersistantEmail setAlias: persistantEmail.name];
    [nonPersistantEmail setIdMail: [persistantEmail.objectID description]];
    return nonPersistantEmail;
}

+(NPMessage *)convertMessage:(Message *) message{
    NPMessage *nonPersistantMessage = [[NPMessage alloc]init];
    
    [nonPersistantMessage setFrom:[NSMutableArray array]];
    [nonPersistantMessage setTo:[NSMutableArray array]];
    [nonPersistantMessage setCc:[NSMutableArray array]];
    [nonPersistantMessage setCci:[NSMutableArray array]];
  //  NSString *myEmail = [AccesToUserDefaults getUserInfoChoiceMail];
    for (Email *email in message.emails) {
        NPEmail *convertedEmail = [NPConverter convertEmail:email];
    //    if (![myEmail isEqualToString:convertedEmail.mail]) {
            if ([email.type isEqualToString:kTO]) {
                [nonPersistantMessage.to addObject:convertedEmail];
            }
            else if ([email.type isEqualToString:kCC]) {
                [nonPersistantMessage.cc addObject:convertedEmail];
            }

            else if ([email.type isEqualToString:kFROM]) {
                [nonPersistantMessage.from addObject:convertedEmail];
            }
        //@TD le champs type d'un email en CCI != KCCI
        //            else if ([email.type isEqualToString:kCCI]) {
        //                [nonPersistantMessage.cci addObject:convertedEmail];
        //            }
            else {
                [nonPersistantMessage.cci addObject:convertedEmail];
            }
     //   }
    }
    NSString * subject = message.subject;
    if (message.subject == nil || [NSLocalizedString(@"SANS_OBJET", @"<Sans objet>") isEqualToString:message.subject]) {
        subject = @"";
    }

    [nonPersistantMessage setSubject:subject];
    [nonPersistantMessage setBody:message.body];
    [nonPersistantMessage setMessageId:message.messageId];
    //@TD
      [nonPersistantMessage setIsUrgent:[message.isUrgent boolValue] ];
    [nonPersistantMessage setIsRead:[NSNumber numberWithBool:[message.isRead boolValue]]];
    [nonPersistantMessage setIsFavor:[NSNumber numberWithBool:[message.isFavor boolValue]]];
    [nonPersistantMessage setIsBodyLarger:[NSNumber numberWithBool:[message.isBodyLarger boolValue]]];
    [nonPersistantMessage setFolderId:[NSNumber numberWithInt:[message.folderId intValue]]];
    [nonPersistantMessage setDate:message.date];

 
    return nonPersistantMessage;
}


+(NPMessage *)switchToRespondMessage:(NPMessage *)message{
    NPMessage *nonPersistantMessage = [message copy];
    NSString *myEmailString = [AccesToUserDefaults getUserInfoChoiceMail];
    NPEmail *myEmail = [[NPEmail alloc] initWithIdMail:nil alias:nil mail:myEmailString];
    [nonPersistantMessage setTo:[NSMutableArray array]];
    [nonPersistantMessage setCc:[NSMutableArray array]];
    [nonPersistantMessage setCci:[NSMutableArray array]];
    [nonPersistantMessage setFrom:[NSMutableArray arrayWithObject: myEmail]];
    for (NPEmail *email in message.from) {
        //if (![myEmail isEqualToString:email.mail]){
            [nonPersistantMessage.to addObject:email];
       // }
    }
    [nonPersistantMessage setReplyType:REPLIED];
    [nonPersistantMessage setSubject:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"RE", @"Re:"),message.subject]];
    [nonPersistantMessage setBody:[NSString stringWithFormat: @"%@ %@",[message getMessageResponse],message.body]];
    return nonPersistantMessage;
}


+(NPMessage *)switchToRespondToAllMessage:(NPMessage *)message{
    NPMessage *nonPersistantMessage = [message copy];
    NSString *myEmailString = [AccesToUserDefaults getUserInfoChoiceMail];
    NPEmail *myEmail = [[NPEmail alloc] initWithIdMail:nil alias:nil mail:myEmailString];
    [nonPersistantMessage setTo:[NSMutableArray array]];
    [nonPersistantMessage setCc:[NSMutableArray array]];
    [nonPersistantMessage setCci:[NSMutableArray array]];
    [nonPersistantMessage setFrom:[NSMutableArray arrayWithObject: myEmail]];
    for (NPEmail *email in message.from) {
        if (![myEmail.mail isEqualToString:email.mail]){
            [nonPersistantMessage.to addObject:email];
        }
    }
    for (NPEmail *email in message.to) {
        if (![myEmail.mail isEqualToString:email.mail]){
            [nonPersistantMessage.to addObject:email];
        }
    }
    for (NPEmail *email in message.cc) {
        if (![myEmail.mail isEqualToString:email.mail]){
            [nonPersistantMessage.cc addObject:email];
        }
    }
    [nonPersistantMessage setReplyType:REPLIED];
    [nonPersistantMessage setSubject:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"RE", @"Re:"),message.subject]];
    [nonPersistantMessage setBody:[NSString stringWithFormat: @"%@ %@",[message getMessageResponse],message.body]];
    return nonPersistantMessage;
}

+(NPMessage *)switchToTransferMessage:(NPMessage *)message{
    NPMessage *nonPersistantMessage = [message copy];
    NSString *myEmailString = [AccesToUserDefaults getUserInfoChoiceMail];
    NPEmail *myEmail = [[NPEmail alloc] initWithIdMail:nil alias:nil mail:myEmailString];
    [nonPersistantMessage setTo:[NSMutableArray array]];
    [nonPersistantMessage setCc:[NSMutableArray array]];
    [nonPersistantMessage setCci:[NSMutableArray array]];
    [nonPersistantMessage setFrom:[NSMutableArray arrayWithObject: myEmail]];
  
    [nonPersistantMessage setSubject:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"TR", @"Tr:"),message.subject]];
    [nonPersistantMessage setBody:[NSString stringWithFormat: @"%@ %@",[message getMessageResponse],message.body]];
    [nonPersistantMessage setReplyType:FORWARDED];
    return nonPersistantMessage;
}



+(NPAttachment *)convertAttachment:(Attachment *)attachment{
    return [[NPAttachment alloc] initWithContentType:attachment.contentType
                                            fileName:attachment.fileName
                                       localFileName:attachment.localFileName
                                                part:attachment.part
                                                size:attachment.size];
}

@end
