//
//  FullTextSearchMessagesResponse.m
//  MSSante
//
//  Created by Labinnovation on 06/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "FullTextSearchMessagesResponse.h"

@implementation FullTextSearchMessagesResponse

@synthesize messages, responseObject;

- (id)parseJSONObject {
    messages = [NSMutableArray array];
    if(!jsonError) {
        if ([[jsonObject objectForKey:FULL_TEXT_SEARCH_MESSAGES_OUTPUT] isKindOfClass: [NSDictionary class]]) {
            id searchOutput = [jsonObject objectForKey:FULL_TEXT_SEARCH_MESSAGES_OUTPUT];
            if([[searchOutput objectForKey:MESSAGES] isKindOfClass:[NSArray class]] && [[searchOutput objectForKey:MESSAGES] count] > 0) {
                NSArray *_messages = [searchOutput objectForKey:MESSAGES];
                for(int i = 0 ; i < [_messages count]; i++) {
                    if([[_messages objectAtIndex:i] isKindOfClass: [NSDictionary class]]) {
                        NSDictionary *__messageDictionary = [_messages objectAtIndex:i];
                        Message *tmpMessage = [self parseMessage:__messageDictionary];                        
                        if (tmpMessage != nil){
                            [messages addObject:tmpMessage];
                        }
                    }
                }
            } else if ([[searchOutput objectForKey:MESSAGES] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *__messageDictionary = [searchOutput objectForKey:MESSAGES];
                Message *tmpMessage = [self parseMessage:__messageDictionary];
                if (saveToDB) {
                    [self saveToDatabase];
                }
                if (tmpMessage != nil){
                    [messages addObject:tmpMessage];                    
                }
            }
        } else {
            //Pas de message : searchOutput est un string : {searchOutput:""}
        }
    } else {
        DLog(@"Error parsing json : %@", jsonError);
    }
    responseObject = messages;
    return responseObject;
}

@end
