//
//  MoveMessagesInput.m
//  MSSante
//
//  Created by Labinnovation on 08/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "MoveMessagesInput.h"

@implementation MoveMessagesInput

@synthesize destinationFolderId, messageIds;

- (id)init {
    self = [super init];
    messageIds = [NSMutableArray array];
    [input setObject:messageIds forKey:MESSAGE_IDS];
    return self;
}

- (NSDictionary*)generate {
    if ([messageIds count] > 0) {[input setObject:messageIds forKey:MESSAGE_IDS];}
    if (destinationFolderId) {[input setObject:destinationFolderId forKey:DESTINATION_FOLDER_ID];}
    return [NSDictionary dictionaryWithObject:input forKey:MOVE_MESSAGES_INPUT];
}

@end
