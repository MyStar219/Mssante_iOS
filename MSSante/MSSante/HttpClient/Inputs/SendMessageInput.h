//
//  SendInput.h
//  MSSante
//
//  Created by Labinnovation on 26/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "Input.h"

@interface SendMessageInput : Input {
    NSMutableDictionary *message;
    NSNumber *messageId;
    NSNumber *messageTransferedId;
    NSNumber *conversationId;
    NSMutableArray *emails;
    NSString *subject;
    NSString *body;
    NSString *replyType;
    NSString *priority;
    NSNumber *isHTML;
    NSNumber *isAccuse;
    NSMutableArray *attachments;
    NSMutableArray *idAttachmentsRemove;
}

@property(nonatomic, strong) NSMutableDictionary *message;
@property(nonatomic, strong) NSNumber *messageId;
@property(nonatomic, strong) NSNumber *messageTransferedId;
@property(nonatomic, strong) NSNumber *conversationId;
@property(nonatomic, strong) NSMutableArray *emails;
@property(nonatomic, strong) NSString *subject;
@property(nonatomic, strong) NSString *body;
@property(nonatomic, strong) NSString *replyType;
@property(nonatomic, strong) NSString *priority;
@property(nonatomic, strong) NSNumber *isHTML;
@property(nonatomic, strong) NSNumber *isAccuse;
@property(nonatomic, strong) NSMutableArray *attachments;
@property(nonatomic, strong) NSMutableArray *idAttachmentsRemove;

-(void)addEmail:(NSString*)address name:(NSString*)name type:(NSString*)type;
-(void)addAttachment:(NSNumber*)part contentType:(NSString*)contentType size:(NSNumber*)size fileName:(NSString*)fileName file:(NSData*)file attachmentMsgId:(NSNumber*)attachmentMsgId;
-(void)addAttachments:(NSArray *)aAttachments;
-(NSDictionary*)generateDraftInput;
-(void)removeAttachment:(NSString*)fileName;
-(void)reset;
-(BOOL) hasErrors:(NSError **)errors;
-(void)generateSendInputWithTokenFieldTo:(NSArray*)tokenFieldTo
                            TokenFieldCc:(NSArray*)tokenFieldCc
                            TokenFieldCi:(NSArray*)tokenFieldCi
                                 Subject:(NSString*)_subject
                                    Body:(NSString*)_body
                               Important:(BOOL)isImportant
                                   MsgId:(NSNumber*)msgId;
@end
