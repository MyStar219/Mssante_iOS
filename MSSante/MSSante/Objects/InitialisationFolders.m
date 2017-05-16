//
//  InitialisationFolders.m
//  MSSante
//
//  Created by Labinnovation on 02/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "InitialisationFolders.h"
#import "FolderDAO.h"
#import "SearchMessagesInput.h"
#import "Request.h"
#import "DAOFactory.h"
#import "SearchMessagesResponse.h"
#import "SyncInput.h"
#import "SyncMessagesResponse.h"

@implementation InitialisationFolders
@synthesize isRunning;
static InitialisationFolders *sharedInstance = nil;

+(InitialisationFolders *) sharedInstance{
    if (sharedInstance == nil){
        sharedInstance = [[InitialisationFolders alloc] init];
    }
    return sharedInstance;
}

-(void)start{
    FolderDAO *folderDAO = (FolderDAO*)[[DAOFactory factory] newDAO:FolderDAO.class];
    
    listFolders = [[folderDAO findAll] mutableCopy];
    
    __block __typeof__(self) blockSelf = self ;
    dispatch_queue_t initSearchMessage = dispatch_queue_create("Init Dossier With Search",NULL);
    if (listFolders.count > 0) {
        isRunning = YES;
        for (Folder *folder in listFolders) {
            if (![folder.folderId isEqualToNumber:[NSNumber numberWithInt:RECEPTION_ID_FOLDER ]]){
                dispatch_async(initSearchMessage, ^{
                    SearchMessagesInput* input = [[SearchMessagesInput alloc] init];
                    [input setFolderId:folder.folderId];
                    [input setLimit:[NSNumber numberWithInt:50]];
                    Request *request = [[Request alloc] initWithService:S_ITEM_SEARCH_MESSAGES method:HTTP_POST headers:nil params:[input generate]];
                    request.delegate = blockSelf;
                    [request execute];
                });
            }
        }
    } 
    
    
    dispatch_async(initSearchMessage, ^{
        DLog(@"LoginProcess : InitFolders : calling Sync");
        SyncInput* syncInput = [[SyncInput alloc] init];
        Request *request = [[Request alloc] initWithService:S_ITEM_SYNC method:HTTP_POST headers:nil params:[syncInput generate]];
        request.delegate = self;
        [request execute];
    });
    
    
}

-(void)httpError:(Error *)_error{
    if (_error != nil){
    }    
}

-(void)httpResponse:(id)_responseObject{
    if ([_responseObject isKindOfClass:[SearchMessagesResponse class]]) {
//        DLog(@"SearchMessagesResponse _responseObject %@",[(SearchMessagesResponse*)_responseObject messages]);
        if (listFolders.count > 0) {
            Folder *folder = [listFolders objectAtIndex:0];
            
            DLog(@"MasterFolder %d %@ %d",folder.folderId.intValue, folder.folderName, folder.initialized.intValue);
            if (!folder.initialized || [folder.initialized isEqualToNumber:[NSNumber numberWithBool:NO]]) {
                [folder setInitialized:[NSNumber numberWithBool:YES]];
                [(SearchMessagesResponse*)_responseObject saveToDatabase];
            }
            [listFolders removeObjectAtIndex:0];
        }
//        SearchMessagesResponse *response = _responseObject;
//        DLog(@"response Object %d",response.messages.count);
//        DLog(@"response Object %@",response.messages);
        
    } else if ([_responseObject isKindOfClass:[SyncMessagesResponse class]]) {
        SyncMessagesResponse* syncMessagesResponse = _responseObject;
        [AccesToUserDefaults setUserInfoSyncToken:[syncMessagesResponse.syncDictionary objectForKey:TOKEN]];
    }
    //@TD anomaile BAL VIDE
    DLog(@"Listfolders.count %d", listFolders.count);
    if (listFolders.count == 1) {
        isRunning = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:FOLDER_INITIALIZATION_FINISHED_NOTIF object:nil];
    }
}

@end
