//
//  CheckAndLaunchModification.m
//  MSSante
//
//  Created by Labinnovation on 26/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "SyncAndLaunchModification.h"
#import "Modification.h"
#import "DAOFactory.h"
#import "Request.h"
#import "MessageDAO.h"
#import "SendMessageInput.h"
#import "UpdateMessagesInput.h"
#import "SendMessageResponse.h"
#import "AttachmentDAO.h"
#import "SyncInput.h"
#import "SyncMessagesResponse.h"
#import "AccesToUserDefaults.h"
#import "FolderDAO.h"
#import "ListFoldersInput.h"
#import "ListFoldersResponse.h"
#import "PasswordStore.h"
#import "DraftMessageResponse.h"
#import "EmptyInput.h"
#import "Error45.h"

@implementation SyncAndLaunchModification {
    BOOL launchListFolder;
    NSNumber *initialFolderId ;
}

@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        DLog(@"SyncAndLaunchModification init");
        requestDelegate = self;
        listFolderId = [[NSMutableArray alloc] init];
        modifDAO = (ModificationDAO*)[[DAOFactory factory] newDAO:ModificationDAO.class];
        [listFolderId addObject:[NSNumber numberWithInt:1]];
        listModif = [self sortArrayByDate:[[modifDAO findAll] mutableCopy]];
    }
    return self;
}

-(void)syncOnlyFolderId:(NSNumber*)folderId{
    [listFolderId removeAllObjects];
    [listFolderId addObject:folderId];
    initialFolderId = folderId;
    launchListFolder = YES;
}

-(void)initFolderId:(NSNumber*)folderId{
    [listFolderId removeAllObjects];
    [listFolderId addObject:folderId];
    initialFolderId = folderId;
    launchListFolder = NO;
}

-(void)execute{
    DLog(@"SyncAndLaunchModification execute");
    [self runSyncRequest];

}

-(void)runSyncRequest{
    DLog(@"SyncAndLaunchModification runSyncRequest");
    
    if (launchListFolder) {
        DLog(@"callListFolderRequest");
        [self callListFolderRequest];
    } else {
        DLog(@"callSyncRequest");
        [self callSyncRequest];
    }
    
        
}

-(void)callSyncRequest {
    SyncInput* syncInput = [[SyncInput alloc] init];
    if (listFolderId.count > 0) {
        DLog(@"listFolderId %d", [[listFolderId objectAtIndex:0] intValue]);
        if (listFolderId.count > 0){
            [syncInput setFolderId:[listFolderId objectAtIndex:0]];
        }
    }
    [syncInput setToken:[AccesToUserDefaults getUserInfoSyncToken]];
    Request *request = [[Request alloc] initWithService:S_ITEM_SYNC method:HTTP_POST headers:nil params:[syncInput generate]];
    request.delegate = requestDelegate;
    [request execute];
}

-(void)callListFolderRequest {
    ListFoldersInput *listInput = [[ListFoldersInput alloc] init];
    Request *request = [[Request alloc] initWithService:S_FOLDER_LIST method:HTTP_POST headers:nil params:[listInput generate]];
    request.delegate = requestDelegate;
    [request execute];
}

-(void)runRequestForModification:(Modification*) modification{

    if ([DELETE isEqualToString:modification.operation] || modification.messageId == nil) {
        if ([MOVE isEqualToString:modification.operation]) {
            [self checkMoveRequestBeforeMove:modification];
        } else if ([UPDATE isEqualToString:modification.operation] || [DELETE isEqualToString:modification.operation ]) {
            [self executeUpdateOrMoveMessage:S_ITEM_UPDATE_MESSAGES argumet:modification.argument];
        }
    } else {
        MessageDAO *msgDAO = (MessageDAO*)[[DAOFactory factory] newDAO:MessageDAO.class];
        msgToModify = [msgDAO findMessageByMessageId:modification.messageId];
        
        DLog(@"runRequestForModification messageId : %@ operation : %@", modification.messageId , modification.operation);
        
        if (msgToModify != nil) {
            DLog(@"runRequestForModification : msgToModify exists");
            if ([SEND isEqualToString:modification.operation] || [DRAFT isEqualToString:modification.operation]){
                [self executeSendOrDraftRequest:modification.argument operation:modification.operation];
            }
            else if ([UPDATE isEqualToString:modification.operation]){
                [self executeUpdateOrMoveMessage:S_ITEM_UPDATE_MESSAGES argumet:modification.argument];
            }
            else if ([MOVE isEqualToString:modification.operation]){
                [self checkMoveRequestBeforeMove:modification];
            }
        }
        else {
            DLog(@"runRequestForModification : msgToModify doesn't exists");
            [self skipModification:modification];
        }
    }
    
}

-(void)checkMoveRequestBeforeMove:(Modification*) modification {
    DLog(@"checkMoveRequestBeforeMove");
    NSMutableDictionary* moveInput = modification.argument;
    NSArray *messageIds = [[moveInput objectForKey:MOVE_MESSAGES_INPUT] objectForKey:MESSAGE_IDS];
    DLog(@"Message Ids %@",messageIds);
    if ([[moveInput objectForKey:MOVE_MESSAGES_INPUT] objectForKey:DESTINATION_FOLDER_ID]) {
        NSNumber *destrinationFolderId = [[moveInput objectForKey:MOVE_MESSAGES_INPUT] objectForKey:DESTINATION_FOLDER_ID];
        
        DLog(@"destinationFolderId %d",destrinationFolderId.intValue);
        FolderDAO *folderDAO = (FolderDAO*) [[DAOFactory factory] newDAO:FolderDAO.class];
        if ([folderDAO findFolderByFolderId:destrinationFolderId]) {
            DLog(@"Moving Message %@ to Folder %@",modification.messageId, destrinationFolderId);
            [self executeUpdateOrMoveMessage:S_ITEM_MOVE_MESSAGES argumet:modification.argument];
        } else {
            for (NSNumber *messageId in messageIds) {
                DLog(@"messageId %@",messageId);
                NSMutableArray *messageModifications = [ModificationDAO findModificationByMessageId:messageId];
                DLog(@"messageModifications %@",messageModifications);
                DLog(@"messageModifications count %d",messageModifications.count);
                if (messageModifications.count <= 1) {
                    DLog(@"DestinationFolder Doesn't exist and last action, delete Message %@",messageId);
                    UpdateMessagesInput *updateInput = [[UpdateMessagesInput alloc] init];
                    [updateInput.messageIds addObject:messageId];
                    [updateInput setOperation:O_DELETE];
                    [self executeUpdateOrMoveMessage:S_ITEM_UPDATE_MESSAGES argumet:[[updateInput generate] mutableCopy]];
                }
            }
            
            DLog(@"DestinationFolder Doesn't exist, will not move message");
            [self skipModification:modification];
        }
    }
}

-(void)skipModification:(Modification*)modification {
    DLog(@"skipModification for %d", modification.messageId.intValue);
    [modifDAO deleteObject:modification];
    [self saveDB];
    [listModif removeObjectAtIndex:0];
    listModif = [self sortArrayByDate:[[modifDAO findAll] mutableCopy]];
    if (listModif.count > 0){
        [self runRequestForModification:[listModif objectAtIndex:0]];
    } 
}

-(void)executeUpdateOrMoveMessage:(NSString*)service argumet:(NSMutableDictionary*)argument {
    Request *request = [[Request alloc] initWithService:service method:HTTP_POST headers:nil params:argument];
    request.delegate = requestDelegate;
    request.isModification = YES;
    [request execute];
}

-(void)executeSendOrDraftRequest:(NSMutableDictionary*)requestBody operation:(NSString*)operation { 
    NSString *inputKey = SEND_MESSAGE_INPUT;
    NSString *service = S_ITEM_SEND_MESSAGE;
    BOOL isDraft = NO;
    if ([operation isEqualToString:DRAFT]) {
        inputKey = DRAFT_MESSAGES_INPUT;
        service = S_ITEM_DRAFT_MESSAGE;
        isDraft = YES;
    }
    
    NSMutableDictionary *inputGenerate = [self addMessageAttachmentsBinaryContents:requestBody inputKey:inputKey];
    
    NSMutableDictionary *modifyInput = [inputGenerate objectForKey:inputKey];
    NSMutableDictionary *messageInput = [modifyInput objectForKey:MESSAGE];
    
    if ([messageInput objectForKey:DATE]) {
        [messageInput removeObjectForKey:DATE];
    }
    
    if ([messageInput objectForKey:FOLDER_ID]) {
        [messageInput removeObjectForKey:FOLDER_ID];
    }
    
    if (isDraft) {
        if ([messageInput objectForKey:MESSAGE_ID] && [[messageInput objectForKey:MESSAGE_ID] intValue] < 0) {
            [messageInput removeObjectForKey:MESSAGE_ID];
        }
    } else {
        if ([messageInput objectForKey:MESSAGE_ID]) {
            [messageInput removeObjectForKey:MESSAGE_ID];
        }
    }
    
    if ([messageInput objectForKey:SIZE]) {
        [messageInput removeObjectForKey:SIZE];
    }
    
    if (![self isConnectedToInternet]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"CONNEXION_IMPOSSIBLE", @"Connexion impossible")
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Continuer", nil];
        [alert show];
        return;
    }
    
    Request *request = [[Request alloc] initWithService:service method:HTTP_POST headers:nil params:inputGenerate];
    request.delegate = requestDelegate;
    request.isModification = YES;
    [request execute];
}


//TODO Needs Refactoring
-(NSMutableDictionary*)addMessageAttachmentsBinaryContents:(NSMutableDictionary*)sendInput inputKey:(NSString*)inputKey{
    if ([[sendInput objectForKey:inputKey] objectForKey:MESSAGE]) {
        NSMutableDictionary *tmpMsg = [[sendInput objectForKey:inputKey] objectForKey:MESSAGE];
        if ([[tmpMsg objectForKey:ATTACHMENTS] isKindOfClass:[NSArray class]] && [[tmpMsg objectForKey:ATTACHMENTS] count] > 0 ) {
            for (NSMutableDictionary *attachment in [tmpMsg objectForKey:ATTACHMENTS]) {
                if (![attachment objectForKey:A_FILE] && ![attachment objectForKey:A_PART] && [[attachment objectForKey:A_FILENAME] isKindOfClass:[NSString class]]) {
                    NSString *filename = [attachment objectForKey:A_FILENAME];
                    NSString *filePath = [Tools getAttachmentFilePath:filename];
                    NSURL *url = [NSURL fileURLWithPath:filePath];
                    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
                    NSData *content;
                    if (fileExists) {
                        content = [[NSData dataWithContentsOfURL:url] AES256DecryptWithKey:[[PasswordStore getInstance] getDbEncryptionKey]];
                        NSArray* bytes = [Tools arrayOfBytesFromData:content];
                        if (bytes) {
                            [attachment setObject:bytes forKey:A_FILE];
                        } else  if (![attachment objectForKey:A_PART]) {
                                [[tmpMsg objectForKey:ATTACHMENTS] removeObject:attachment];
                        }
                    } 
                } else {
                    if (![attachment objectForKey:A_FILE] && ![attachment objectForKey:A_FILENAME] && ![attachment objectForKey:A_PART]) {
                        [[tmpMsg objectForKey:ATTACHMENTS] removeObject:attachment];
                    }
                
                }
            }
        }
    }
    return sendInput;
}


-(void)httpResponse:(id)_responseObject{
    
    if ([_responseObject isKindOfClass:[ListFoldersResponse class]]) {
        [self callSyncRequest];
    }
    
    else if ([_responseObject isKindOfClass:[SyncMessagesResponse class]]){
        SyncMessagesResponse* syncMessagesResponse = _responseObject;
        
        NSDate *dateNow = [NSDate date];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd/MM/yyyy HH:mm"];
        
        [AccesToUserDefaults setUserInfoLastSyncDate:[formatter stringFromDate:dateNow]];
        DLog(@"SyncDelegate %@", delegate);
        
        if (listFolderId.count > 0) {
            MessageDAO *messageDAO = (MessageDAO*)[[DAOFactory factory] newDAO:MessageDAO.class];
            [messageDAO cleanMessages:[listFolderId objectAtIndex:0]];
        }
        
        
        if([delegate respondsToSelector:@selector(syncSucces:)]){
            DLog(@"syncSucces");
            [delegate syncSucces:syncMessagesResponse.syncDictionary];
        }

        if (listFolderId.count > 0) {
            [listFolderId removeObjectAtIndex:0];
        }
        
        if (listFolderId.count > 0){
            SyncInput* syncInput = [[SyncInput alloc] init];
            [syncInput setFolderId:[listFolderId objectAtIndex:0]];
            [syncInput setToken:[AccesToUserDefaults getUserInfoSyncToken]];
            Request *request = [[Request alloc] initWithService:S_ITEM_SYNC method:HTTP_POST headers:nil params:[syncInput generate]];
            request.delegate = requestDelegate;
            [request execute];
        }
        else {
            [self saveDB];
            listModif = [self sortArrayByDate:[[modifDAO findAll] mutableCopy]];
            
            DLog(@"listModif %@",listModif );
            if (listModif.count > 0){
                [self runRequestForModification:[listModif objectAtIndex:0]];
            }
        }
    }
    
    else {
        if (listModif.count > 0) {
            
            Modification *modification = [listModif objectAtIndex:0];
            
            if ([_responseObject isKindOfClass:[SendMessageResponse class]]) {
                SendMessageResponse *sendMessageResponse = (SendMessageResponse*)_responseObject;
                
                [msgToModify setMessageId:[sendMessageResponse.messageDictionary objectForKey:MESSAGE_ID]];
                [msgToModify setDate:[self dateFromString:[sendMessageResponse.messageDictionary objectForKey:DATE]]];
                [msgToModify setSize:[sendMessageResponse.messageDictionary objectForKey:SIZE]];
                [msgToModify setFolderId:[NSNumber numberWithInt:ENVOYES_ID_FOLDER]];
                
                if ([sendMessageResponse.messageDictionary objectForKey:ATTACHMENTS] ) {
                    [msgToModify setAttachments:[sendMessageResponse parseAttachments:[sendMessageResponse.messageDictionary objectForKey:ATTACHMENTS]]];
                }
                
                DLog(@"SyncAndLaunchModification httpResponse : %@", _responseObject);
                
                if([delegate respondsToSelector:@selector(messageSent:)]){
                    [delegate messageSent:msgToModify];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:MESSAGE_SENT_NOTIF object:nil];
            } else if ([_responseObject isKindOfClass:[DraftMessageResponse class]]) {
                DraftMessageResponse *draftMessagesResponse = (DraftMessageResponse*)_responseObject;
                if (modification.messageId) {
                    
                    Message *localDraft = [MessageDAO findMessageByMessageId:modification.messageId];

                    if ([draftMessagesResponse.messageDictionary objectForKey:MESSAGE_ID]) {
                        [localDraft setMessageId:[draftMessagesResponse.messageDictionary objectForKey:MESSAGE_ID]];
                    }
                    
                    if ([draftMessagesResponse.messageDictionary objectForKey:DATE]) {
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
                        NSDate *dateFromString = [dateFormatter dateFromString:[draftMessagesResponse.messageDictionary objectForKey:DATE]];
                        localDraft.date = dateFromString;
                    }
                    
                    if ([draftMessagesResponse.messageDictionary objectForKey:SIZE]) {
                        [localDraft setSize:[draftMessagesResponse.messageDictionary objectForKey:SIZE]];
                    }
                    
                    
                    if ([draftMessagesResponse.messageDictionary objectForKey:ATTACHMENTS] ) {
                        [localDraft setAttachments:[draftMessagesResponse parseAttachments:[draftMessagesResponse.messageDictionary objectForKey:ATTACHMENTS]]];
                    }
//                    [MessageDAO deleteMessageByMessageId:modification.messageId];
                    [self saveDB];
                }
                

            
            }
            else if ([_responseObject isKindOfClass:[NSString class]] && [_responseObject isEqual:S_ITEM_UPDATE_MESSAGES]) {
//                DLog(@"SyncAndLaunchModification httpResponse : updateMessages SUR ! ");
                //        Modification *modification = [listModif objectAtIndex:0];
            }
            
            
            [modifDAO deleteObject:modification];
            [self saveDB];
            
            [listModif removeObjectAtIndex:0];
            
            [self runTheRemainingModifications];
        } else {
//            if([delegate respondsToSelector:@selector(syncSucces:)]){
//                DLog(@"syncSucces");
//                [delegate syncSucces:nil];
//            }
        }
        
    }
    
}

-(void)runTheRemainingModifications {
    listModif = [self sortArrayByDate:[[modifDAO findAll] mutableCopy]];
    if (listModif.count > 0){
        [self runRequestForModification:[listModif objectAtIndex:0]];
    }
    else {
        [self runSyncRequest];
        [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_NOTIF object:nil];
    }
}

-(Modification *)deleteTheLastModification {
    Modification *modification = [listModif objectAtIndex:0];
    [modifDAO deleteObject:modification];
    [self saveDB];
    [listModif removeObjectAtIndex:0];
    return modification;
}

-(void)saveModificationInDatabase:(NSNumber*)messageId operation:(NSString*)op params:(id)argument {
    Modification* modif = [NSEntityDescription insertNewObjectForEntityForName: @"Modification" inManagedObjectContext: [[DAOFactory factory] managedObjectContext]];
    modif.messageId = messageId;
    modif.operation = op;
    modif.argument = argument;
    modif.date = [NSDate date];
    [self saveDB];
}

-(void)httpError:(Error *)_error {
    
    if ([S_ITEM_UPDATE_MESSAGES isEqualToString:_error.service]) {
        if(listModif.count > 0){
            Modification *modification = [listModif objectAtIndex:0];
            NSArray *messageIds = [[modification.argument objectForKey:UPDATE_MESSAGES_INPUT] objectForKey:MESSAGE_IDS];
            NSString *updateOp = [[modification.argument objectForKey:UPDATE_MESSAGES_INPUT] objectForKey:OPERATION];
            if([DELETE isEqualToString:modification.operation]) {
                if ([ERROR_TYPE_TECHNIQUE isEqualToString:_error.errorType] && messageIds.count > 1 && _error.errorCode == 1) {
                    for (NSNumber *messageId in messageIds) {
                        UpdateMessagesInput* updateInput = [[UpdateMessagesInput alloc] init];
                        [updateInput.messageIds addObject:messageId];
                        [updateInput setOperation:O_DELETE];
                        [self saveModificationInDatabase:messageId operation:DELETE params:[updateInput generate]];
                    }
                    [self deleteTheLastModification];
                } else if (_error.serviceInaccessible){
                    modification.date = [NSDate date];
                    [self saveDB];
                } else {
                    [self deleteTheLastModification];
                }
            } else if ([UPDATE isEqualToString:modification.operation]) {
                if ([O_UNREAD isEqualToString:updateOp]) {
                    if (_error.errorCode == 4500) {
                        [self deleteTheLastModification];
                    }
                    else if (_error.errorCode == 45) {
                        DLog(@"Sync : HTTP ERROR : Error 45 UNREAD");
                        Error45 *error45 = [[Error45 alloc] initWithService:S_ITEM_UPDATE_MESSAGES andParams:modification.argument andDelegate:self];
                        error45.isModification = YES;
                        [error45 execute];
                        [self deleteTheLastModification];
                    } else if (_error.serviceInaccessible){
                        modification.date = [NSDate date];
                    } else {
                        Modification *lastModification = [self deleteTheLastModification];
                        if (lastModification.messageId) {
                            Message *msg = [MessageDAO findMessageByMessageId:lastModification.messageId];
                            if (msg) {
                                [msg setIsRead:[NSNumber numberWithBool:YES]];
                            }
                        }
                    }
                    [self saveDB];
                }
                else if ([O_READ isEqualToString:updateOp]) {
                    if (_error.errorCode == 4500) {
                        [self deleteTheLastModification];
                    }
                    else if (_error.errorCode == 45) {
                        DLog(@"Sync : HTTP ERROR : Error 45 READ");
                        
                        DLog(@"Modification Argument %@", modification.argument);
                        Error45 *error45 = [[Error45 alloc] initWithService:S_ITEM_UPDATE_MESSAGES andParams:modification.argument andDelegate:self];
                        error45.isModification = YES;
                        [error45 execute];
                        [self deleteTheLastModification];
                    } else if (_error.serviceInaccessible){
                        modification.date = [NSDate date];
                    } else {
                        Modification *lastModification = [self deleteTheLastModification];
                        if (lastModification.messageId) {
                            Message *msg = [MessageDAO findMessageByMessageId:lastModification.messageId];
                            if (msg) {
                                [msg setIsRead:[NSNumber numberWithBool:NO]];
                            }
                        }
                    }
                    [self saveDB];
                }
                
                else if ([O_FLAGGED isEqualToString:updateOp]) {
                    if (_error.errorCode == 4500) {
                        [self deleteTheLastModification];
                    }
                    else if (_error.errorCode == 45) {
                        DLog(@"Sync : HTTP ERROR : Error 45 FLAG");
                        DLog(@"Modification Argument %@", modification.argument);
                        Error45 *error45 = [[Error45 alloc] initWithService:S_ITEM_UPDATE_MESSAGES andParams:modification.argument andDelegate:self];
                        error45.isModification = YES;
                        [error45 execute];
                        [self deleteTheLastModification];
                    } else if (_error.serviceInaccessible){
                        modification.date = [NSDate date];
                    } else {
                        Modification *lastModification = [self deleteTheLastModification];
                        if (lastModification.messageId) {
                            Message *msg = [MessageDAO findMessageByMessageId:lastModification.messageId];
                            if (msg) {
                                [msg setIsFavor:[NSNumber numberWithBool:NO]];
                            }
                        }
                    }
                    [self saveDB];
                }
                
                else if ([O_UNFLAGGED isEqualToString:updateOp]) {
                    if (_error.errorCode == 4500) {
                        [self deleteTheLastModification];
                    }
                    else if (_error.errorCode == 45) {
                        DLog(@"Sync : HTTP ERROR : Error 45 UNFLAG");
                        Error45 *error45 = [[Error45 alloc] initWithService:S_ITEM_UPDATE_MESSAGES andParams:modification.argument andDelegate:self];
                        error45.isModification = YES;
                        [error45 execute];
                        [self deleteTheLastModification];
                    } else if (_error.serviceInaccessible){
                        modification.date = [NSDate date];
                    } else {
                        Modification *lastModification = [self deleteTheLastModification];
                        if (lastModification.messageId) {
                            Message *msg = [MessageDAO findMessageByMessageId:lastModification.messageId];
                            if (msg) {
                                [msg setIsFavor:[NSNumber numberWithBool:YES]];
                            }
                        }
                    }
                    [self saveDB];
                }
                
                else if ([O_TRASH isEqualToString:updateOp]) {
                    if (_error.errorCode == 4500) {
                        [self deleteTheLastModification];
                    }
                    else if (_error.errorCode == 45) {
                        DLog(@"Sync : HTTP ERROR : Error 45 TRASH");
                        DLog(@"Modification Argument %@", modification.argument);
                        Error45 *error45 = [[Error45 alloc] initWithService:S_ITEM_UPDATE_MESSAGES andParams:modification.argument andDelegate:self];
                        error45.isModification = YES;
                        [error45 execute];
                        [self deleteTheLastModification];
                    } else if (_error.serviceInaccessible){
                        modification.date = [NSDate date];
                    } else {
                        [self deleteTheLastModification];
                    }
                    [self saveDB];
                }
            }
        } 
    }
    //pour les messages à envoyer 
    else if ([S_ITEM_SEND_MESSAGE isEqualToString:_error.service]) {
        if ((_error.errorCode == 1 || _error.errorCode == 28 || _error.errorCode == 36 || _error.errorCode ==42) && listModif.count > 0) {
            DLog(@"Modification Error : Send %d",_error.errorCode);
            [self deleteTheLastModification];
            DLog(@"Delete Modification");
        } else if(listModif.count > 0){
            Modification *modification = [listModif objectAtIndex:0];
            [modification setDate:[NSDate date]];
            [self saveDB];
        }
    }
    //pour les messages à envoyer 
    else if ([S_ITEM_DRAFT_MESSAGE isEqualToString:_error.service]) {
        if ((_error.errorCode == 1 || _error.errorCode == 28 || _error.errorCode == 36 || _error.errorCode == 39 || _error.errorCode == 42 || _error.errorCode == 45) && listModif.count > 0) {
            DLog(@"Modification Error : Draft %d",_error.errorCode);
            [self deleteTheLastModification];
            DLog(@"Delete Modification");
        } else if(listModif.count > 0){
            Modification *modification = [listModif objectAtIndex:0];
            [modification setDate:[NSDate date]];
            [self saveDB];
        }
    }
    else if ([S_ITEM_MOVE_MESSAGES isEqualToString:_error.service]) {
        if(listModif.count>0){
        Modification *modification = [listModif objectAtIndex:0];
        if(_error.errorCode == 41 && listModif.count > 0){
            DLog(@"Sync : HTTP ERROR : Error 41 MOVE");
            [self deleteTheLastModification];
        } else if (_error.errorCode == 45) {
            Error45 *error45 = [[Error45 alloc] initWithService:S_ITEM_MOVE_MESSAGES andParams:modification.argument andDelegate:self];
            error45.isModification = YES;
            [error45 execute];
            [self deleteTheLastModification];
        } else if (_error.serviceInaccessible){
            modification.date = [NSDate date];
        } else {
            [self deleteTheLastModification];
        }
        
        [self saveDB];
        }
    }
    if (![S_FOLDER_LIST isEqualToString:_error.service] && ![S_ITEM_SYNC isEqualToString:_error.service]) {
        [self runTheRemainingModifications];
    }
    
    

    if((listModif.count == 0 || _error.errorCode == 44) && [delegate respondsToSelector:@selector(syncError:)]){
        [delegate syncError:_error];
    }

    
    DLog(@"SyncAndLaunchModification httpError : %@", _error);
}

-(void)saveDB{
    NSError *error;
    if (![[DAOFactory factory] save:&error]) {
        DLog(@"error save %@", [error userInfo]);
    }
}
- (BOOL)isConnectedToInternet {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        DLog(@"NO INTERNET");
        return NO;
    } else {
        return YES;
    }
}

-(NSDate*)dateFromString:(NSString*)stringDate{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    NSDate *dateFromString = [dateFormatter dateFromString:stringDate];
    return dateFromString;
}

- (NSMutableArray*)sortArrayByDate:(NSMutableArray*)array {
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    NSArray *sortedArray = [NSArray arrayWithObject: descriptor];
    [array sortUsingDescriptors:sortedArray];
    return  array;
}

@end
