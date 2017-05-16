//
//  NPMessage.m
//  MSSante
//
//  Created by Labinnovation on 27/11/2014.
//  Copyright (c) 2014 Capgemini. All rights reserved.
//

#import "NPMessage.h"
#import "NPEmail.h"
#import "AttachmentManager.h"
#import "Constant.h"
#define kMAX_SUBJECT_SIZE 50

@implementation NPMessage

@synthesize from;
@synthesize to;
@synthesize cc;
@synthesize cci;
@synthesize subject;
@synthesize body;
@synthesize isUrgent;
@synthesize replyType;
@synthesize date;
@synthesize messageId;
@synthesize messageTransferedId;
@synthesize folderId;
@synthesize isBodyLarger;
@synthesize isFavor;
@synthesize isRead;

- (id)initWithFrom:(NSMutableArray *)aFrom to:(NSMutableArray *)aTo cc:(NSMutableArray *)aCc cci:(NSMutableArray *)aCci subject:(NSString *)aSubject body:(NSString *)aBody isUrgent:(BOOL)flag replyType:(NSString *)aReplyType date:(NSDate *)aDate idMessage:(NSNumber *)aIdMessage messageTransferedId:(NSNumber *)aMessageTransferedId folderId:(NSNumber *)afolderId isBodyLarger:(NSNumber *)aisBodyLarger isFavor:(NSNumber *)aisFavor isRead:(NSNumber *)aisRead; {
    self = [super init];
    if (self) {
        from = [aFrom mutableCopy];
        to = [aTo mutableCopy];
        cc = [aCc mutableCopy];
        cci = [aCci mutableCopy];
        subject = [aSubject copy];
        body = [aBody copy];
        isUrgent = flag;
        replyType = [aReplyType copy];
        date = [aDate copy];
        messageId = [aIdMessage copy];
        messageTransferedId = [aMessageTransferedId copy];
        folderId = [afolderId copy];
        isBodyLarger = [aisBodyLarger copy];
        isFavor = [aisFavor copy];
        isRead = [aisRead copy];
    }
    return self;
}


//===========================================================
// + (id)objectWith:
//
//===========================================================
+ (id)objectWithFrom:(NSMutableArray *)aFrom to:(NSMutableArray *)aTo cc:(NSMutableArray *)aCc cci:(NSMutableArray *)aCci subject:(NSString *)aSubject body:(NSString *)aBody isUrgent:(BOOL)flag replyType:(NSString *)aReplyType date:(NSDate *)aDate idMessage:(NSNumber *)aIdMessage messageTransferedId:(NSNumber *)aMessageTransferedId folderId:(NSNumber *)afolderId isBodyLarger:(NSNumber *)aisBodyLarger isFavor:(NSNumber *)aisFavor isRead:(NSNumber *)aisRead;{
    id result = [[NPMessage  alloc] initWithFrom:aFrom to:aTo cc:aCc cci:aCci subject:aSubject body:aBody isUrgent:flag replyType:aReplyType date:aDate idMessage:aIdMessage messageTransferedId:aMessageTransferedId folderId:afolderId isBodyLarger:aisBodyLarger isFavor:aisFavor isRead:aisRead];
    
    return result;
}

- (id)copyWithZone:(NSZone *)zone{
    return [NPMessage objectWithFrom:from to:to cc:cc cci:cci subject:subject body:body isUrgent:isUrgent replyType:replyType date:date idMessage:messageId messageTransferedId: messageTransferedId folderId:folderId isBodyLarger:isBodyLarger isFavor:isFavor isRead:isRead];
}


- (BOOL)isBodyEmpty{
    return self.body == nil || [@"" isEqualToString:[self.body stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] ];
}

- (BOOL)isSubjectEmpty{
    return self.subject == nil || [@"" isEqualToString:[self.subject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] ];
}

- (BOOL)isTooBigAttachement {
    AttachmentManager * attachmentManager;
    [attachmentManager getAttachementsByIdMessage:self.messageId];
       NSData *bodyData = [self.body dataUsingEncoding:NSUTF8StringEncoding];
       long size = ceil(bodyData.length / 1024);
    if([attachmentManager getAttachementsCount] > 0){
        size+=[attachmentManager getTotalSize];
    }
       if (size > MAX_MESSAGE_SIZE) {
           return YES;
       }else{
           return NO;
       }
}

- (BOOL)isTooBigMessage {
    if(self.body.length>50000){
        return YES;
    }else {
        return NO;
    }
    
}

- (BOOL)hasInvalidRecipient{
    BOOL msgIsValid = YES;
    NSError *error = nil;
    //@TD - 
    for (NPEmail *npemail in self.to) {
        msgIsValid &= [npemail isValid:error];
    }
    for (NPEmail *npemail in self.cc) {
        msgIsValid &= [npemail isValid:error];
    }
    for (NPEmail *npemail in self.cci) {
        msgIsValid &= [npemail isValid:error];
    }
    return !msgIsValid;
}

- (void) deleteInvalidRecipient{
     NSError *error = nil;
    //@TD -
    for (NPEmail *npemail in self.to) {
        if(![npemail isValid:error]){
            [self.to removeObjectIdenticalTo:npemail];
        }
    }
    for (NPEmail *npemail in self.cc) {
        if(![npemail isValid:error]){
            [self.cc removeObjectIdenticalTo:npemail];
        }
    }
    for (NPEmail *npemail in self.cci) {
        if(![npemail isValid:error]){
            [self.cci removeObjectIdenticalTo:npemail];
        }
    }

    
}

- (BOOL)hasRecipient{
    bool hasRecipient=NO;
    
    if([self.to count]>0||[self.cc count]>0||[self.cci count]>0){
        hasRecipient=YES;
    }
    return hasRecipient;
}

- (BOOL)isValid:(NSError **)error{
    if (error == NULL){
        return NO;
    }
    if(![self hasRecipient]){
        *error = [NSError errorWithDomain:@"Fonctionnal"
                                    code:3
                                userInfo:@{
                                           NSLocalizedDescriptionKey : NSLocalizedString(
                                                                                         @"RENSEIGNER_UN_DESTINATAIRE",
                                                                                         @"Veuillez renseigner un destinataire"
                                                                                         )}];
    }
    else if([self hasInvalidRecipient]){
        *error = [NSError errorWithDomain:@"Fonctionnal"
                                    code:2
                                userInfo:@{
                                           NSLocalizedDescriptionKey : NSLocalizedString(
                                                                                         @"FORMAT_DESTINATAIRES_INVALIDE" ,
                                                                                         @"Le format des destinataires est invalide"
                                                                                         )}];
    }
    else if ([self.subject length] > kMAX_SUBJECT_SIZE){
        *error = [NSError errorWithDomain:@"Fonctionnal"
                                    code:2
                                userInfo:@{
                                           NSLocalizedDescriptionKey : NSLocalizedString(
                                                                                         @"OBJET_MESSAGE_SUPERIEUR_50",
                                                                                         @"L'objet ne doit pas dépasser 50 caractères"
                                                                                         )}];
    }
    else if ([self isTooBigAttachement]){
        *error = [NSError errorWithDomain:@"Fonctionnal"
                                    code:2
                                userInfo:@{
                                           NSLocalizedDescriptionKey : NSLocalizedString(
                                                                                         @"MESSAGE_ATTACHMENTS_TROP_VOLUMINEUX",
                                                                                         @"Le message est trop volumineux (supérieur à..."
                                                                                         )}];
    }
    else if ([self isTooBigMessage]){
        *error = [NSError errorWithDomain:@"Fonctionnal"
                                    code:2
                                userInfo:@{
                                           NSLocalizedDescriptionKey : NSLocalizedString(
                                                                                         @"MESSAGE_TROP_VOLUMINEUX",
                                                                                         @"Le contenu du message est trop volumineux"
                                                                                         )}];
    }
    
    else if([self isBodyEmpty] && [self isSubjectEmpty]){
        *error = [NSError errorWithDomain:@"Fonctionnal"
                                     code:1
                                 userInfo:@{
                                            NSLocalizedDescriptionKey : NSLocalizedString(
                                                                                          @"MESSAGE_CONFIRMATION_PAS_DE_CORPS_NI_OBJET" ,
                                                                                          @"Etes vous sûr de vouloir envoyer le message sans objet ni contenu ?"
                                                                                          )}];
    }
    return *error == nil;
}

- (BOOL)isValidForDraft:(NSError **)error{
    if (error == NULL){
        return NO;
    }
 if ([self.subject length] > kMAX_SUBJECT_SIZE){
     self.subject = [NSString stringWithFormat:@"%@...",[self.subject substringToIndex:46]];
     //@TD Truncate object
//        *error = [NSError errorWithDomain:@"Fonctionnal"
//                                     code:2
//                                 userInfo:@{
//                                            NSLocalizedDescriptionKey : NSLocalizedString(
//                                                                                          @"OBJET_MESSAGE_SUPERIEUR_50",
//                                                                                          @"L'objet ne doit pas dépasser 50 caractères"
//                                                                                          )}];
    }
    else if ([self isTooBigAttachement]){
        *error = [NSError errorWithDomain:@"Fonctionnal"
                                     code:2
                                 userInfo:@{
                                            NSLocalizedDescriptionKey : NSLocalizedString(
                                                                                          @"MESSAGE_ATTACHMENTS_TROP_VOLUMINEUX",
                                                                                          @"Le message est trop volumineux (supérieur à..."
                                                                                          )}];
    }
    else if ([self isTooBigMessage]){
        *error = [NSError errorWithDomain:@"Fonctionnal"
                                     code:2
                                 userInfo:@{
                                            NSLocalizedDescriptionKey : NSLocalizedString(
                                                                                          @"MESSAGE_TROP_VOLUMINEUX",
                                                                                          @"Le contenu du message est trop volumineux"
                                                                                          )}];
    }
    [self deleteInvalidRecipient];
    return *error == nil;
}

//TODO: Move to Utils
-(NSString*)dateToStringWithoutSeconds:(NSDate*)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    return strDate;
}

-(NSString*)getMessageResponse{
    NSMutableString* tempDate = [[self dateToStringWithoutSeconds:date] mutableCopy];
    [tempDate insertString:@" à" atIndex:10];
    NSString *emailFromString = @"";
    NSString *alias = @"";
    for (NPEmail* iEmail in [self from] ) {
        emailFromString = iEmail.mail;
        alias = iEmail.alias;
    }
    
    return [NSString stringWithFormat:@"\n\nLe %@, %@ <%@> a écrit :\n\n",tempDate, alias, emailFromString];
}
@end
