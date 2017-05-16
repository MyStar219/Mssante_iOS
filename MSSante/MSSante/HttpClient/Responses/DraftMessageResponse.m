//
//  DraftMessageResponse.m
//  MSSante
//
//  Created by Labinnovation on 16/09/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "DraftMessageResponse.h"

@implementation DraftMessageResponse

@synthesize message, messageDictionary, responseObject;

- (id)parseJSONObject {
    message = nil;
    messageDictionary = nil;
    if(!jsonError) {
        if ([[jsonObject objectForKey:DRAFT_MESSAGES_OUTPUT] isKindOfClass: [NSDictionary class]]) {
            if ([[jsonObject objectForKey:DRAFT_MESSAGES_OUTPUT] objectForKey:MESSAGE]) {
                messageDictionary = [[jsonObject objectForKey:DRAFT_MESSAGES_OUTPUT] objectForKey:MESSAGE];
                //                message = [self parseMessage:_messageDictionary];
                //                if (message && saveToDB) {
                //                    [self saveToDatabase];
                //
                //                }
            }
        }
    } else {
        DLog(@"Error parsing json : %@", jsonError);
    }
    responseObject = messageDictionary;
    return responseObject;
}

@end
