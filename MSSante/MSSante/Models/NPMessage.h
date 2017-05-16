//
//  NPMessage.h
//  MSSante
//
//  Created by Labinnovation on 27/11/2014.
//  Copyright (c) 2014 Capgemini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NPMessage : NSObject <NSCopying>
@property (nonatomic, retain) NSMutableArray *from;
@property (nonatomic, retain) NSMutableArray *to;
@property (nonatomic, retain) NSMutableArray *cc;
@property (nonatomic, retain) NSMutableArray *cci;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, assign, getter=isUrgent) BOOL isUrgent;
@property (nonatomic, copy) NSString *replyType;
@property (nonatomic, copy) NSDate *date;
@property (nonatomic, copy) NSNumber *messageId;
@property (nonatomic, copy) NSNumber *messageTransferedId;
@property (nonatomic, copy) NSNumber *folderId;
@property (nonatomic, copy) NSNumber *isFavor;
@property (nonatomic, copy) NSNumber *isBodyLarger;
@property (nonatomic, copy) NSNumber *isRead;

- (id)initWithFrom:(NSMutableArray *)aFrom to:(NSMutableArray *)aTo cc:(NSMutableArray *)aCc cci:(NSMutableArray *)aCci subject:(NSString *)aSubject body:(NSString *)aBody isUrgent:(BOOL)flag replyType:(NSString *)aReplyType date:(NSDate *)aDate  idMessage:(NSNumber *)aIdMessage messageTransferedId:(NSNumber *)aMessageTransferedId folderId:(NSNumber *)afolderId isBodyLarger:(NSNumber *) aisBodyLarger isFavor:(NSNumber *)aisFavor isRead:(NSNumber *)aisRead;

+ (id)objectWithFrom:(NSMutableArray *)aFrom to:(NSMutableArray *)aTo cc:(NSMutableArray *)aCc cci:(NSMutableArray *)aCci subject:(NSString *)aSubject body:(NSString *)aBody isUrgent:(BOOL)flag replyType:(NSString *)aReplyType date:(NSDate *)aDate idMessage:(NSNumber *)aIdMessage messageTransferedId:(NSNumber *)aMessageTransferedId folderId:(NSNumber *)afolderId isBodyLarger:(NSNumber *)aisBodyLarger isRead:(NSNumber *)aisRead isFavor:(NSNumber *)aisFavor  isRead:(NSNumber *)aisRead;


- (BOOL)isValid:(NSError **)error;
- (BOOL)isValidForDraft:(NSError **)error;
- (NSString*)getMessageResponse;
@end
