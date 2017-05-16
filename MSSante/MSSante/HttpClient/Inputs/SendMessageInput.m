//
//  SendInput.m
//  MSSante
//
//  Created by Labinnovation on 26/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "SendMessageInput.h"
#import "Attachment.h"
#import "EmailTool.h"
#import "NPEmail.h"
#import "TITokenTableViewController.h"
#import "NPAttachment.h"
@implementation SendMessageInput

@synthesize attachments, body, conversationId, emails, subject, message, idAttachmentsRemove, isAccuse, isHTML, messageId, messageTransferedId, priority, replyType;

- (id)init {
    self = [super init];
    //    message = [NSMutableDictionary dictionary];
    //    emails = [NSMutableArray array];
    //    attachments = [NSMutableArray array];
    //    idAttachmentsRemove = [NSMutableArray array];
    //    [message setObject:emails forKey:ADDRESSES];
    //    [message setObject:attachments forKey:ATTACHMENTS];
    ////    [message setObject:idAttachmentsRemove forKey:ID_ATTACHMENTS_REMOVE];
    //    [input setObject:message forKey:MESSAGE];
    [self reset];
    return self;
}

-(void)reset {
    message = [NSMutableDictionary dictionary];
    emails = [NSMutableArray array];
    idAttachmentsRemove = [NSMutableArray array];
    [message setObject:emails forKey:ADDRESSES];
    if (!attachments) {
        attachments = [NSMutableArray array];
    }
    [message setObject:attachments forKey:ATTACHMENTS];
    [input setObject:message forKey:MESSAGE];
}

- (NSDictionary*)generate {
    DLog(@"sendInput generate Start");
    if (messageId != nil) {[message setObject:messageId forKey:MESSAGE_ID];}
    if (messageTransferedId != nil) {[message setObject:messageTransferedId forKey:MESSAGE_TRANSFERED_ID];}
    if (conversationId != nil) {[message setObject:conversationId forKey:CONVERSATION_ID];}
    if ([body length] > 0) {[message setObject:body forKey:BODY];}
    if ([subject length] > 0) {[message setObject:subject forKey:SUBJECT];}
    if ([replyType length] > 0) {[message setObject:replyType forKey:REPLY_TYPE];}
    if ([priority length] > 0) {[message setObject:priority forKey:PRIORITY];}
    if (isHTML != nil) {[message setObject:isHTML forKey:IS_HTML];}
    if (isAccuse != nil) {[message setObject:isAccuse forKey:IS_ACCUSE];}
    //@TD
    if (attachments.count > 0) {
        for (NSMutableDictionary* attachment in attachments) {
            if ([attachment objectForKey:A_FILE]) {
                [attachment removeObjectForKey:A_PART];
                [attachment removeObjectForKey:MESSAGE_ID];
            }
            else if([messageId intValue]> 0){
                [attachment setObject:messageId forKey:MESSAGE_ID];
            }else if (messageTransferedId != nil)
            {
                [attachment setObject:messageTransferedId forKey:MESSAGE_ID];
            }
        }
    }
    
    return [NSDictionary dictionaryWithObject:input forKey:SEND_MESSAGE_INPUT];
}

-(NSDictionary*)generateDraftInput {
    DLog(@"messageId %@",messageId);
    if (messageId.intValue > 0) {DLog(@"messageId %@",messageId); [message setObject:messageId forKey:MESSAGE_ID];}
    if ([body length] > 0) {[message setObject:body forKey:BODY];}
    if ([subject length] > 0) {[message setObject:subject forKey:SUBJECT];}
    if (messageTransferedId != nil) {[message setObject:messageTransferedId forKey:MESSAGE_TRANSFERED_ID];}
    if (conversationId != nil) {[message setObject:conversationId forKey:CONVERSATION_ID];}
    if (isHTML != nil) {[message setObject:isHTML forKey:IS_HTML];}
    if (isAccuse != nil) {[message setObject:isAccuse forKey:IS_ACCUSE];}
    //@TD
    if (attachments.count > 0) {
        for (NSMutableDictionary* attachment in attachments) {
           if ([attachment objectForKey:A_FILE]) {
                [attachment removeObjectForKey:A_PART];
                [attachment removeObjectForKey:MESSAGE_ID]; 
            }
            else if([messageId intValue]> 0){
                [attachment setObject:messageId forKey:MESSAGE_ID];
            }
            else if (messageTransferedId != nil)
            {
                [attachment setObject:messageTransferedId forKey:MESSAGE_ID];
            }
        }
    }
    
    if ([priority length] > 0) {[message setObject:priority forKey:PRIORITY];}
    if ([replyType length] > 0) {[message setObject:replyType forKey:REPLY_TYPE];}
    
    return [NSDictionary dictionaryWithObject:input forKey:DRAFT_MESSAGES_INPUT];
}


-(void)generateSendInputWithTokenFieldTo:(NSArray*)tokenFieldTo
                            TokenFieldCc:(NSArray*)tokenFieldCc
                            TokenFieldCi:(NSArray*)tokenFieldCi
                                 Subject:(NSString*)_subject
                                    Body:(NSString*)_body
                               Important:(BOOL)isImportant
                                     MsgId:(NSNumber*)msgId{
    DLog(@"generateSendInput Start");
  
    [self reset];
    //ajout des adresses emails dans le Input
    [self addEmails:tokenFieldTo type:E_TO];
    [self addEmails:tokenFieldCc type:E_CC];
    [self addEmails:tokenFieldCi type:E_BCC];
    
    
    NSString *name = [NSString stringWithFormat:@"%@ %@", [AccesToUserDefaults getUserInfoPrenom], [AccesToUserDefaults getUserInfoNom]];
    [self addEmail:[AccesToUserDefaults getUserInfoChoiceMail] name:name type:E_FROM];
    if(msgId){
    if (msgId.intValue > 0 && ![FORWARDED  isEqualToString:self.replyType] && ![REPLIED isEqualToString:self.replyType]) {
        [self setMessageId:messageId];
    } else {
        [self setMessageId:[NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]*-1]];
    }
    }
       if ([_subject length] > 0) {
        [self setSubject:_subject];
    }
    
    if ([_body length] > 0) {
        [self setBody:_body];
    }
    
    if (isImportant) {
        [self setPriority:F_PRIORITY_HIGH];
    }
    //@TD
    if (attachments.count > 0) {
        for (NSMutableDictionary* attachment in attachments) {
            if ([attachment objectForKey:A_FILE]) {
                [attachment removeObjectForKey:A_PART];
                [attachment removeObjectForKey:MESSAGE_ID];
            }
            else if([messageId intValue]> 0){
                [attachment setObject:messageId forKey:MESSAGE_ID];
            }else if (self.messageTransferedId != nil)
            {
                [attachment setObject:messageTransferedId forKey:MESSAGE_ID];
            }
        }
    }
    DLog(@"generateSendInput End");
}

-(BOOL)isEmptyInput{
    return ![self countValidEmails]>1 && subject.length == 0 && body.length == 0 && attachments.count == 0;
}

#pragma mark - Email
/**
 * array of TITOKEN ?? why ?
 */
-(void)addEmails:(NSArray *)emailsToAdd type:(NSString*)type {
    if ([emailsToAdd count] > 0){
        for (id theToken in emailsToAdd) {
            if ([theToken respondsToSelector:@selector(representedObject)]) {
                TIToken* token = (TIToken*)theToken;
                if ([token.representedObject isKindOfClass:[Email class]]) {
                    Email* tmpEmail = (Email*)token.representedObject;
                    [self addEmail:tmpEmail.address name:tmpEmail.name type:type];
                    // Why ?
                    //[emailAddresses addObject:email.address];
                } else if ([token.representedObject isKindOfClass:[NPEmail class]]) {
                    NPEmail* tmpEmail = (NPEmail*)token.representedObject;
                    [self addEmail:tmpEmail.mail   name:tmpEmail.alias type:type];
                    // Why ?
                    //[emailAddresses addObject:email.address];
                }
                else {
                    [self addEmail:token.title name:nil type:type];
                    //Why ?
                    //[emailAddresses addObject:token.title];
                }
            }
            else if ([theToken isKindOfClass:[NPEmail class]]){
                NPEmail* tmpEmail = (NPEmail*)theToken;
                [self addEmail:tmpEmail.mail   name:tmpEmail.alias type:type];
            }
        }
    }
}


- (void)addEmail:(NSString*)address name:(NSString*)name type:(NSString*)type {
    NSMutableDictionary *emailDict = [NSMutableDictionary dictionary];
    if (address) {[emailDict setValue:address forKey:EMAIL];}
    if (name) {[emailDict setValue:name forKey:E_NAME];}
    if (type) {[emailDict setValue:type forKey:E_TYPE];}
    [emails addObject:emailDict];
}


- (int)countValidEmails{
    int count = 0;
    for (NSDictionary *_email in emails) {
        if ([EmailTool isValidEmail:[_email objectForKey:E_EMAIL]]) {
            count++;
        }
    }
    return count;
}



#pragma mark - Attachment

- (void)addAttachment:(NSNumber*)part contentType:(NSString*)contentType size:(NSNumber*)size fileName:(NSString*)fileName file:(NSData*)file attachmentMsgId:(NSNumber*)attachmentMsgId {
    NSMutableDictionary *attachment = [NSMutableDictionary dictionary];
    if (part) {[attachment setValue:part forKey:A_PART];}
    if (contentType.length > 0) {[attachment setValue:contentType forKey:A_CONTENT_TYPE];}
    if (size) {[attachment setValue:size forKey:SIZE];}
    if (fileName.length > 0) {[attachment setValue:fileName forKey:A_FILENAME];}
    if (file) {[attachment setValue:file forKey:A_FILE];}
    if ([attachmentMsgId intValue] > 0){[attachment setValue:attachmentMsgId forKey:MESSAGE_ID];}
    [attachments addObject:attachment];
}
- (void)addAttachment:(NSNumber*)part contentType:(NSString*)contentType size:(NSNumber*)size fileName:(NSString*)fileName attachmentMsgId:(NSNumber*)attachmentMsgId {
    NSMutableDictionary *attachment = [NSMutableDictionary dictionary];
    if (part) {[attachment setValue:part forKey:A_PART];}
    if (contentType.length > 0) {[attachment setValue:contentType forKey:A_CONTENT_TYPE];}
    if (size) {[attachment setValue:size forKey:SIZE];}
    if (fileName.length > 0) {[attachment setValue:fileName forKey:A_FILENAME];}
    if ([attachmentMsgId intValue] > 0){[attachment setValue:attachmentMsgId forKey:MESSAGE_ID];}
    [attachments addObject:attachment];
}


-(void)addAttachments:(NSArray *)aAttachments{
    DLog(@"SendMessageInput addAttachments");
    for (NPAttachment *attachment in aAttachments) {
        if(attachment.datas !=nil){
            [self addAttachment:attachment.part
                    contentType:attachment.contentType
                           size:attachment.size
                       fileName:attachment.fileName
                           file:attachment.datas
                attachmentMsgId:messageId];
        }else {
            [self addAttachment:attachment.part
                    contentType:attachment.contentType
                           size:attachment.size
                       fileName:attachment.fileName
                attachmentMsgId:messageId];
        }
    }
}



-(void)removeAttachment:(NSString*)fileName {
    if (fileName.length > 0) {
        for (NSMutableDictionary *attachment in attachments) {
            if ([[attachment objectForKey:A_FILENAME] isEqualToString:fileName]) {
                [attachments removeObject:attachment];
                break;
            }
        }
    }
}

- (void)addIdAttachmentRemove:(NSString*)fileId {
    if ([fileId length] > 0) {[idAttachmentsRemove addObject:fileId];}
}



-(long)sizeInput {
    NSData *bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
    long size = ceil(bodyData.length / 1024);
    if (attachments.count > 0) {
        for (Attachment *attachment in attachments) {
            DLog(@"attachment size %d",attachment.size.intValue);
            size += attachment.size.intValue;
        }
    }
    return size;
}

-(BOOL)isHugeAttachments{
    return [self sizeInput]>MAX_MESSAGE_SIZE ;
}

#pragma mark - Error Handling

-(BOOL) hasErrors:(NSError **)errors{
    BOOL error = NO;
    if ([self isEmptyInput]){
        *errors = [[NSError alloc] initWithDomain:@"TECHNICAL"
                                             code:0
                                         userInfo:@{ NSLocalizedDescriptionKey: @"Empty " } ];
        error = YES;
    }
    else if (![self countValidEmails]>1) {
        *errors = [[NSError alloc] initWithDomain:@"TECHNICAL"
                                             code:-1
                                         userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"FORMAT_DESTINATAIRES_INVALIDE" , @"Le format des destinataires est invalide") } ];
        error = YES;
    } else if (self.body.length > 50000) {
        *errors = [[NSError alloc] initWithDomain:@"TECHNICAL"
                                             code:-1
                                         userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"MESSAGE_TROP_VOLUMINEUX", @"Le contenu du message est trop volumineux") } ];
        error = YES;
    } else if ([self isHugeAttachments]) {
        *errors = [[NSError alloc] initWithDomain:@"TECHNICAL"
                                             code:-1
                                         userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"MESSAGE_ATTACHMENTS_TROP_VOLUMINEUX", @"Le message est trop volumineux (supérieur à 10Mo)") } ];
        error = YES;
    }
    return error;
}

@end
