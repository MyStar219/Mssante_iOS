//
//  MessageDAO.h
//  MSSante
//
//  Created by Labinnovation on 25/06/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "DAOBase.h"
#import "Message.h"
#import "Constant.h"
#import "CDCriteria.h"
#import "CDFilter.h"
#import "CDFilterFactory.h"
#import "CDFilterDisjunction.h"
#import "Email.h"
#import "CDFilterConjunction.h"
#import "CDOrder.h"

@interface MessageDAO : DAO

- (Message*)findMessageByMessageId:(NSNumber*)messageId;
+(Message*)findMessageByMessageId:(NSNumber*)messageId;
+(void)deleteMessageByMessageId:(NSNumber*)messageId;
+(void)deleteMessageAndAllModificationsByMessageId:(NSNumber*)messageId;
-(NSMutableArray*)findMessagesByFolderId:(NSNumber*)folderId;
-(NSMutableArray*)findAllMessagesUnread;
-(NSMutableArray*)findAllMessagesFollowed;
-(NSMutableArray*)searchMessages:(NSString*)query folderId:(NSNumber*)messageId;
-(void)cleanMessages:(NSNumber*)folderId;

@end
