//
//  SyncResponse.m
//  MSSante
//
//  Created by Labinnovation on 25/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "SyncMessagesResponse.h"
#import "AccesToUserDefaults.h"

@implementation SyncMessagesResponse

@synthesize syncDictionary, responseObject;

- (id)parseJSONObject {
    syncDictionary = [[NSMutableDictionary alloc] init];
    
    if(!jsonError) {
        if ([[jsonObject objectForKey:SYNC_MESSAGES_OUTPUT] isKindOfClass: [NSDictionary class]]) {
            if ([[jsonObject objectForKey:SYNC_MESSAGES_OUTPUT] objectForKey:TOKEN]) {
                syncDictionary = [jsonObject objectForKey:SYNC_MESSAGES_OUTPUT];
                DLog(@"syncDictionary : %@", syncDictionary);
                if ([syncDictionary objectForKey:TOKEN]){
                    [AccesToUserDefaults setUserInfoSyncToken:[syncDictionary objectForKey:TOKEN]];
                }
                if ([syncDictionary objectForKey:DELETED_MESSAGE_ID]){
                    [self deleteMessages:[syncDictionary objectForKey:DELETED_MESSAGE_ID]];
                }
                if ([syncDictionary objectForKey:MODIFIED_MESSAGES]){
                    self.createdMessages = [[NSMutableArray alloc] init];
                    NSMutableArray *listDictMessages = [syncDictionary objectForKey:MODIFIED_MESSAGES];
                    if (listDictMessages.count > 0){
                        for (NSMutableDictionary* dictMessage in listDictMessages){
                            Message* message = [self parseMessage:dictMessage];
                            if (saveToDB) {
                                DLog(@"saveToDB");
                                [self saveToDatabase];
                            }
                            if(message != nil){
                                [self.createdMessages addObject:message];
                            }
                        }
                    }
                }
            }
        }
    } else {
        DLog(@"Error parsing json : %@", jsonError);
    }
    responseObject = syncDictionary;
    return responseObject;
}

@end
