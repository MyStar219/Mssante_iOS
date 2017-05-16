//
//  CopyInput.m
//  MSSante
//
//  Created by Labinnovation on 26/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "CopyInput.h"

@implementation CopyInput

@synthesize idMessageSet, destinationFolderId;

- (id)init {
    self = [super init];
    idMessageSet = [NSMutableArray array];
    [input setObject:idMessageSet forKey:MESSAGE_IDS];
    return self;
}

- (NSDictionary*)generate {
    if (destinationFolderId != nil) {[input setObject:destinationFolderId forKey:DESTINATION_FOLDER_ID];}
    return [NSDictionary dictionaryWithObject:input forKey:MOVE_MESSAGES_INPUT];
}


@end
