//
//  SendResponse.m
//  MSSante
//
//  Created by Labinnovation on 26/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "SendMessageResponse.h"

@implementation SendMessageResponse

@synthesize message, messageDictionary, responseObject;

- (id)parseJSONObject {
    message = nil;
    messageDictionary = nil;
    if(!jsonError) {
        if ([[jsonObject objectForKey:SEND_MESSAGE_OUTPUT] isKindOfClass: [NSDictionary class]]) {
            if ([[jsonObject objectForKey:SEND_MESSAGE_OUTPUT] objectForKey:MESSAGE]) {
                messageDictionary = [[jsonObject objectForKey:SEND_MESSAGE_OUTPUT] objectForKey:MESSAGE];
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
