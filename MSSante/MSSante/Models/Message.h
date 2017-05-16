//
//  Message.h
//  MSSante
//
//  Created by Labinnovation on 03/10/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Attachment, Email;

@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSNumber * conversationId;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * folderId;
@property (nonatomic, retain) NSNumber * isAttachment;
@property (nonatomic, retain) NSNumber * isBodyLarger;
@property (nonatomic, retain) NSNumber * isFavor;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSNumber * isUrgent;
@property (nonatomic, retain) NSNumber * messageId;
@property (nonatomic, retain) NSString * shortBody;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) NSSet *attachments;
@property (nonatomic, retain) NSSet *emails;
@end

@interface Message (CoreDataGeneratedAccessors)

- (void)addAttachmentsObject:(Attachment *)value;
- (void)removeAttachmentsObject:(Attachment *)value;
- (void)addAttachments:(NSSet *)values;
- (void)removeAttachments:(NSSet *)values;

- (void)addEmailsObject:(Email *)value;
- (void)removeEmailsObject:(Email *)value;
- (void)addEmails:(NSSet *)values;
- (void)removeEmails:(NSSet *)values;

@end
