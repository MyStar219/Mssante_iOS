//
//  Response.h
//  MSSante
//
//  Created by Ismail on 6/18/13.
//  Copyright (c) 2013 Work. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constant.h"
//#import "Folder.h"

#import "Message.h"
#import "Email.h"
#import "Attachment.h"
#import "Folder.h"
#import "Error.h"
#import "Professionel.h"
#import "AttachmentDAO.h"

@interface Response : NSObject {
    id jsonObject;
    NSError *jsonError;
    BOOL saveToDB;
}

@property(nonatomic, strong) id responseObject;
@property(nonatomic, strong) id jsonObject;
@property(nonatomic, strong) NSError* jsonError;
@property(nonatomic, assign) BOOL saveToDB;


- (id)initWithJsonString:(NSString *)_jsonString;

- (id)initWithJsonObject:(id)_jsonObject;

- (Folder*)parseFolder:(NSDictionary* )_folderDictionary level:(NSNumber*)_level oldFolders:(NSMutableDictionary*)oldFolders;

//- (NSMutableSet *)parseFolders:(id)folders level:(NSNumber*)_level;

- (Email*)parseEmail:(id)_emailDictionary;

- (Attachment*)parseAttachment:(id)_attachmentDictionary ;

- (Message*)parseMessage:(id)_messageDictionary;

- (Professionel*)parseProfessionel:(id)_professionelDictionary;

- (BOOL)saveToDatabase;

- (void)parseFlags:(id)flags msgObject:(Message*)tmpMsg;

- (NSMutableSet *)parseEmails:(id)emails;

- (NSMutableSet*)parseAttachments:(id)attachments;

- (void)parseFlag:(NSString*)stringFlag msgObject:(Message*)tmpMsg;

- (id)parseJSONObject;

- (void)deleteMessages:(id)_messageDictionary;

@end
