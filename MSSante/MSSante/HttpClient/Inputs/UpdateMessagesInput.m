//
//  StoreInput.m
//  MSSante
//
//  Created by Labinnovation on 26/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "UpdateMessagesInput.h"

@implementation UpdateMessagesInput

@synthesize flag, messageIds, operation;

- (id)init {
    self = [super init];
    messageIds = [NSMutableArray array];
    [input setObject:messageIds forKey:MESSAGE_IDS];
    return self;
}

- (NSDictionary*)generate {
    
    if ([messageIds count] > 0) {[input setObject:messageIds forKey:MESSAGE_IDS];}
    if ([flag length] > 0) {[input setObject:flag forKey:FLAG];}
    if ([operation length] > 0) {[input setObject:operation forKey:OPERATION];}
    return [NSDictionary dictionaryWithObject:input forKey:UPDATE_MESSAGES_INPUT];
}

@end
