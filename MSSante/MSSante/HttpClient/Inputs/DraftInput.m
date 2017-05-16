//
//  DraftInput.m
//  MSSante
//
//  Created by Labinnovation on 26/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "DraftInput.h"

@implementation DraftInput

- (id)init {
    return [super init];
}

- (NSDictionary*)generate {
    if (messageId != nil) {[message setObject:messageId forKey:MESSAGE_ID];}
    if ([body length] > 0) {[message setObject:body forKey:BODY];}
    if ([subject length] > 0) {[message setObject:subject forKey:SUBJECT];}
    return [NSDictionary dictionaryWithObject:input forKey:SEND_MESSAGE_INPUT];
}

@end
