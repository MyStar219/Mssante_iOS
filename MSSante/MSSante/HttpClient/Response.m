//
//  Response.m
//  MSSante
//
//  Created by Work on 6/18/13.
//  Copyright (c) 2013 Ismail. All rights reserved.
//

#import "Response.h"
#import "DAOFactory.h"
#import "FolderDAO.h"
#import "MessageDAO.h"
#import "EmailDAO.h"


@implementation Response {
    NSNumberFormatter * numformatter;
}

@synthesize jsonObject, jsonError, responseObject, saveToDB;

- (id)initWithJsonString:(NSString *)_jsonString {
    self = [self init];
    NSError *error = nil;
    jsonError = error;
    NSData* jsonData = [_jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    BOOL isValidJson = [NSJSONSerialization isValidJSONObject:json];
    if (isValidJson) {
        jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    }
    return self;
}


- (id)initWithJsonObject:(id)_jsonObject {
    self = [self init];
    jsonObject = _jsonObject;
    
    return self;
}

- (id) init {
    self = [super init];
    numformatter = [[NSNumberFormatter alloc] init];
    [numformatter setNumberStyle:NSNumberFormatterDecimalStyle];
    saveToDB = YES;
    return self;
}

-(NSNumber*)getOldFolderInitialized:(NSMutableDictionary*)folders folderId:(NSNumber*)folderId {
    if ([folders objectForKey:folderId]) {
        return [folders objectForKey:folderId];
    }
    
    return [NSNumber numberWithBool:NO];
}

- (Folder*)parseFolder:(NSDictionary* )_folderDictionary level:(NSNumber*)_level oldFolders:(NSMutableDictionary*)oldFolders{
    
    NSArray *array = [NSArray arrayWithObjects:[NSNumber numberWithInteger:4],[NSNumber numberWithInteger:7],
                      [NSNumber numberWithInteger:10], [NSNumber numberWithInteger:13], [NSNumber numberWithInteger:14],
                      [NSNumber numberWithInteger:15], [NSNumber numberWithInteger:16], nil];
    
    Folder *tmpFolder = nil;
    
    if([_folderDictionary objectForKey:FOLDER_ID]){
        FolderDAO *folderDao = (FolderDAO*) [[DAOFactory factory] newDAO:FolderDAO.class];
        Folder* folder = [folderDao findFolderByFolderId:[_folderDictionary objectForKey:FOLDER_ID]];
        NSNumber *wasInitialized = [self getOldFolderInitialized:oldFolders folderId:[_folderDictionary objectForKey:FOLDER_ID]];
        
        if (folder) {
            [folderDao deleteObject:folder];
        }
        
        if ([array containsObject:[_folderDictionary objectForKey:FOLDER_ID]]) {
            return nil;
        }
        
        tmpFolder = [NSEntityDescription insertNewObjectForEntityForName: @"Folder" inManagedObjectContext: [[DAOFactory factory] managedObjectContext]];
        
        tmpFolder.initialized = wasInitialized;
        
        if (_level != nil) {
            tmpFolder.level = _level;
        }
        
        tmpFolder.folderId = [_folderDictionary objectForKey:FOLDER_ID];
        
        if([_folderDictionary objectForKey:FOLDER_NAME]) {
            tmpFolder.FolderName = [_folderDictionary objectForKey:FOLDER_NAME];
        }
        
        if([_folderDictionary objectForKey:FOLDER_NB_UNREAD]) {
            tmpFolder.folderNbUnread = [_folderDictionary objectForKey:FOLDER_NB_UNREAD];
        }
        
        if([_folderDictionary objectForKey:FOLDERS]) {
            tmpFolder.folders = [self parseFolders:[_folderDictionary objectForKey:FOLDERS] level:[NSNumber numberWithInt:([_level intValue]+1)] oldFolders:oldFolders];
        }
    }
    
    return tmpFolder;
}

- (NSMutableSet *)parseFolders:(id)folders level:(NSNumber*)_level oldFolders:(NSMutableDictionary*)oldFolders{

    NSMutableSet *Folders = [NSMutableSet set];
    if ([folders isKindOfClass:[NSArray class]] && [folders count] > 0) {
        for(int i = 0 ; i < [folders count]; i++) {
            if ([[folders objectAtIndex:i] isKindOfClass:[NSDictionary class]]) {
                [Folders addObject:[self parseFolder:[folders objectAtIndex:i] level:_level oldFolders:oldFolders]];
            }
        }
    } else if ([folders isKindOfClass:[NSDictionary class]]) {
        [Folders addObject:[self parseFolder:folders level:_level oldFolders:oldFolders]];
    }
    return Folders;
}



- (Email*)parseEmail:(id)_emailDictionary {
//    EmailDAO *emailDAO = (EmailDAO*) [[DAOFactory factory] newDAO:EmailDAO.class];
//    if([[_emailDictionary objectForKey:EMAIL] isKindOfClass:[NSString class]] && [[_emailDictionary objectForKey:E_TYPE] isKindOfClass:[NSString class]]) {
//        Email* email = [emailDAO findEmailByAddress:[_emailDictionary objectForKey:EMAIL] andType:[_emailDictionary objectForKey:E_TYPE]];
//        if (email) {
//            if ([email.name isEqualToString:@""] && [[_emailDictionary objectForKey:E_NAME] isKindOfClass:[NSString class]]){
//                email.name = [_emailDictionary objectForKey:E_NAME];
//            }
//            return email;
//        }
//    }
    
    Email *tmpEmail = [NSEntityDescription insertNewObjectForEntityForName: @"Email" inManagedObjectContext: [[DAOFactory factory] managedObjectContext]];
    
    if([[_emailDictionary objectForKey:EMAIL] isKindOfClass:[NSString class]]) {
        tmpEmail.address = [_emailDictionary objectForKey:EMAIL];
    } else {
        tmpEmail.address = @"";
    }
    
    if([[_emailDictionary objectForKey:E_NAME] isKindOfClass:[NSString class]]) {
        tmpEmail.name = [_emailDictionary objectForKey:E_NAME];
    } else {
        tmpEmail.name = @"";
    }
    
    if([[_emailDictionary objectForKey:E_TYPE] isKindOfClass:[NSString class]]) {
        tmpEmail.type = [_emailDictionary objectForKey:E_TYPE];
    } else {
        tmpEmail.type = @"";
    }
    
    tmpEmail.searchAttribute = [NSString stringWithFormat:@"%@ %@", tmpEmail.name, tmpEmail.address];
    
    return tmpEmail;
}


- (Attachment*)parseAttachment:(id)_attachmentDictionary {
    Attachment * tmpAttachment;
    tmpAttachment = [NSEntityDescription insertNewObjectForEntityForName: @"Attachment" inManagedObjectContext: [[DAOFactory factory] managedObjectContext]];
//    AttachmentDAO *attachDAO = (AttachmentDAO*) [[DAOFactory factory] newDAO:AttachmentDAO.class];
//    tmpAttachment = [attachDAO findAttachmentByFileName:[_attachmentDictionary objectForKey:A_FILENAME]];
//    if(!tmpAttachment) {
//        tmpAttachment = [NSEntityDescription insertNewObjectForEntityForName: @"Attachment" inManagedObjectContext: [[DAOFactory factory] managedObjectContext]];
//    }
    
    if([[_attachmentDictionary objectForKey:A_PART] isKindOfClass:[NSNumber class]]) {
        tmpAttachment.part = [_attachmentDictionary objectForKey:A_PART];
    } else if ([[_attachmentDictionary objectForKey:A_PART] isKindOfClass:[NSString class]]) {
        tmpAttachment.part = [numformatter numberFromString:[_attachmentDictionary objectForKey:A_PART]];
    } else {
        tmpAttachment.part= [NSNumber numberWithLong:0];
    }
    
    if([[_attachmentDictionary objectForKey:A_CONTENT_TYPE] isKindOfClass:[NSString class]]) {
        tmpAttachment.contentType = [_attachmentDictionary objectForKey:A_CONTENT_TYPE];
    } else {
        tmpAttachment.contentType= @"";
    }
    int size = 0;
    if([[_attachmentDictionary objectForKey:SIZE] isKindOfClass:[NSNumber class]]) {
        size = ceil((double)[(NSNumber*)[_attachmentDictionary objectForKey:SIZE] integerValue] /1024);
    } else if ([[_attachmentDictionary objectForKey:SIZE] isKindOfClass:[NSString class]]) {
        size = ceil((double)[[numformatter numberFromString:[_attachmentDictionary objectForKey:SIZE]] integerValue] /1024);
    }
    
    tmpAttachment.size = [NSNumber numberWithInt:size];
    
    if([[_attachmentDictionary objectForKey:A_FILENAME] isKindOfClass:[NSString class]]) {
        tmpAttachment.fileName = [_attachmentDictionary objectForKey:A_FILENAME];
        tmpAttachment.localFileName = @"";
    } else {
        tmpAttachment.fileName= @"";
        tmpAttachment.localFileName= @"";
    }
    
    //    if([_attachmentDictionary objectForKey:A_FILE_ID]) {
    //        tmpAttachment.fileID = [_attachmentDictionary objectForKey:A_FILE_ID];
    //    }
    
    return tmpAttachment;
}

- (void)deleteMessages:(id)_messageDictionary{
    NSMutableArray *listDeletedMessageId = [_messageDictionary mutableCopy];
    
//    DLog(@"listDeletedMessageId : %@", listDeletedMessageId);

    for (NSNumber* number in listDeletedMessageId) {
//        DLog(@"number : %@", number);
        MessageDAO *msgDAO = (MessageDAO*) [[DAOFactory factory] newDAO:MessageDAO.class];
        Message* msg = [msgDAO findMessageByMessageId:number];
        if (msg) {
            [msgDAO deleteObject:msg];
        }
    }
    
}

-(BOOL)messageIsDeleted:(id)_messageDictionary{
    if([_messageDictionary objectForKey:FLAGS]){
        id flags = [_messageDictionary objectForKey:FLAGS];
        if([flags isKindOfClass:[NSArray class]] && [flags count] > 0) {
            for(int i = 0 ; i < [flags count]; i++) {
                NSString *stringFlag = [flags objectAtIndex:i];
                if ([F_DELETED isEqualToString:stringFlag]) {
                    return YES;
                }
            }
        }
        else if([flags isKindOfClass:[NSString class]]) {
            if ([F_DELETED isEqualToString:flags]) {
                return YES;
            }
        }
    }
    return NO;
}

- (Message*)parseMessage:(id)_messageDictionary{
    Message *tmp = nil;
    
    if([_messageDictionary objectForKey:MESSAGE_ID]){
        MessageDAO *msgDAO = (MessageDAO*) [[DAOFactory factory] newDAO:MessageDAO.class];
        Message* msg = [msgDAO findMessageByMessageId:[_messageDictionary objectForKey:MESSAGE_ID]];
        if (msg) {
            DLog(@"parseMessage deleteObject");
            [msgDAO deleteObject:msg];
            [self saveToDatabase];
        }
        if ([self messageIsDeleted:_messageDictionary]){
            return nil;
        }
        
        tmp = [NSEntityDescription insertNewObjectForEntityForName: @"Message" inManagedObjectContext: [[DAOFactory factory] managedObjectContext]];
        if([[_messageDictionary objectForKey:MESSAGE_ID] isKindOfClass:[NSNumber class]]) {
            tmp.messageId = [_messageDictionary objectForKey:MESSAGE_ID];
        } else {
            tmp.messageId = [NSNumber numberWithLong:0];
        }
        
        if([[_messageDictionary objectForKey:CONVERSATION_ID] isKindOfClass:[NSNumber class]]) {
            tmp.conversationId = [_messageDictionary objectForKey:CONVERSATION_ID];
        } else {
            tmp.conversationId = [NSNumber numberWithLong:0];
        }
        
        if([[_messageDictionary objectForKey:DATE] isKindOfClass:[NSString class]]) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
            NSDate *dateFromString = [dateFormatter dateFromString:[_messageDictionary objectForKey:DATE]];
            tmp.date = dateFromString;
        } else {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
            NSDate *dateFromString = [dateFormatter dateFromString:[[_messageDictionary objectForKey:DATE]stringValue]];
            tmp.date = dateFromString;
        }
        
        if([[_messageDictionary objectForKey:SIZE] isKindOfClass:[NSNumber class]]) {
            tmp.size = [_messageDictionary objectForKey:SIZE];
        } else {
            tmp.size = [NSNumber numberWithLong:0];
        }
        
        if([_messageDictionary objectForKey:FLAGS]) {
            [self parseFlags:[_messageDictionary objectForKey:FLAGS] msgObject:tmp];
        }
        if([_messageDictionary objectForKey:PRIORITY]) {
            [tmp setIsUrgent:[NSNumber numberWithBool:[F_PRIORITY_HIGH isEqualToString:[_messageDictionary objectForKey:PRIORITY]]]];
        }
        
        if([[_messageDictionary objectForKey:FOLDER_ID] isKindOfClass:[NSNumber class]]) {
            tmp.folderId = [_messageDictionary objectForKey:FOLDER_ID];
        } else {
            tmp.folderId = 0;
        }
        
        if([[_messageDictionary objectForKey:SUBJECT] isKindOfClass:[NSString class]]) {
            NSString *subject = [_messageDictionary objectForKey:SUBJECT];
            if ([subject isEqual:@""]){
                tmp.subject = NSLocalizedString(@"SANS_OBJET", @"<Sans objet>");
            }
            else {
                tmp.subject = subject;
            }
        } else {
            tmp.subject = NSLocalizedString(@"SANS_OBJET", @"<Sans objet>");
        }
        
        if([[_messageDictionary objectForKey:FRAGMENT] isKindOfClass:[NSString class]]) {
            tmp.shortBody = [_messageDictionary objectForKey:FRAGMENT];
        } else {
            tmp.shortBody = @"";
        }
        
        if([[_messageDictionary objectForKey:BODY] isKindOfClass:[NSString class]]) {
            tmp.body = [_messageDictionary objectForKey:BODY];
        } else {
            tmp.body = @"";
        }
                
        if([[_messageDictionary objectForKey:IS_BODY_LARGER] isKindOfClass:[NSNumber class]]) {
            tmp.isBodyLarger = [_messageDictionary objectForKey:IS_BODY_LARGER];
        } else {
            tmp.isBodyLarger = [NSNumber numberWithBool:NO];
        }
        
        if([_messageDictionary objectForKey:E_ADDRESSES]) {
            tmp.emails = [self parseEmails:[_messageDictionary objectForKey:E_ADDRESSES] ];
        }
        
        if([_messageDictionary objectForKey:ATTACHMENTS]) {
            tmp.attachments = [self parseAttachments:[_messageDictionary objectForKey:ATTACHMENTS]];
            if (tmp.attachments.count > 0) {
                tmp.isAttachment = [NSNumber numberWithBool:YES];
            }
        }
    }
    
    return tmp;
}

- (Professionel*)parseProfessionel:(id)_professionelDictionary{
    Professionel *tmp = [[Professionel alloc] init];
    
    if ([_professionelDictionary objectForKey:NOM]){
        tmp.nom = [_professionelDictionary objectForKey:NOM];
    }
    
    if ([_professionelDictionary objectForKey:PRENOM]){
        tmp.prenom = [_professionelDictionary objectForKey:PRENOM];
    }
    
    if ([_professionelDictionary objectForKey:PROFESSION]){
        tmp.profession = [_professionelDictionary objectForKey:PROFESSION];
    }
    
    if ([_professionelDictionary objectForKey:SPECIALITE]){
        tmp.specialite = [_professionelDictionary objectForKey:SPECIALITE];
    }
    
    if ([_professionelDictionary objectForKey:NUMERO_TEL]){
        tmp.numTel = [_professionelDictionary objectForKey:NUMERO_TEL];
    }
    
    if ([_professionelDictionary objectForKey:ADRESSES_MAIL]){
        tmp.listMails = [_professionelDictionary objectForKey:ADRESSES_MAIL];
    }
    
    if ([_professionelDictionary objectForKey:SITUATIONS_EXCERCICE]){
        tmp.listAdresse = [[_professionelDictionary objectForKey:SITUATIONS_EXCERCICE] mutableCopy];
    }

    return tmp;
}

- (BOOL)saveToDatabase {
    NSLog(@"SaveToDataBase in reponse");

    NSError *error;
    if (![[DAOFactory factory] save:&error]) {
        DLog(@"Failed to save to data store: %@", [error localizedDescription]);
        NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
        if(detailedErrors != nil && [detailedErrors count] > 0) {
            for(NSError* detailedError in detailedErrors) {
                DLog(@" DetailedError: %@", [detailedError userInfo]);
            }
        }
        else {
            DLog(@"  %@", [error userInfo]);
        }
        return NO;
    } else {
        DLog(@"Database Changes Saved");
        return YES;
    }
}

- (void)parseFlags:(id)flags msgObject:(Message*)tmpMsg {
    if([flags isKindOfClass:[NSArray class]] && [flags count] > 0) {
        for(int i = 0 ; i < [flags count]; i++) {
            NSString *stringFlag = [flags objectAtIndex:i];
            [self parseFlag:stringFlag msgObject:tmpMsg];
        }
    } else if([flags isKindOfClass:[NSString class]]) {
        [self parseFlag:flags msgObject:tmpMsg];
    }
}

- (NSMutableSet *)parseEmails:(id)emails {
    NSMutableSet *Emails = [NSMutableSet set];
    if ([emails isKindOfClass:[NSArray class]] && [emails count] > 0) {
        for(int i = 0 ; i < [emails count]; i++) {
            if ([[emails objectAtIndex:i] isKindOfClass:[NSDictionary class]]) {
                [Emails addObject:[self parseEmail:[emails objectAtIndex:i]]];
            }
        }
    } else if ([emails isKindOfClass:[NSDictionary class]]) {
        [Emails addObject:[self parseEmail:emails]];
    }
    return Emails;
}

- (NSMutableSet*)parseAttachments:(id)attachments {
    NSMutableSet *Attachments = [NSMutableSet set];
    if([attachments isKindOfClass:[NSArray class]] && [attachments count] > 0) {
        for(int i = 0 ; i < [attachments count]; i++) {
            if([[attachments objectAtIndex:i] isKindOfClass:[NSDictionary class]]) {
                [Attachments addObject:[self parseAttachment:[attachments objectAtIndex:i]]];
            }
        }
    } else if([attachments isKindOfClass:[NSDictionary class]]) {
        [Attachments addObject:[self parseAttachment:attachments]];
    }
    return Attachments;
}

- (void)parseFlag:(NSString*)stringFlag msgObject:(Message*)tmpMsg {
    if ([F_URGENT isEqualToString:stringFlag]) {
        tmpMsg.isUrgent = [NSNumber numberWithBool:TRUE];
    } else if ([F_UNREAD isEqualToString:stringFlag]) {
        tmpMsg.isRead = [NSNumber numberWithBool:FALSE];
    } else if ([F_ATTACHMENT isEqualToString:stringFlag]) {
        tmpMsg.isAttachment = [NSNumber numberWithBool:TRUE];
    } else if ([F_FLAGGED isEqualToString:stringFlag]) {
        tmpMsg.isFavor = [NSNumber numberWithBool:TRUE];
    }
}

- (id)parseJSONObject {
    return jsonObject;
}

@end
