//
//  SyncInput.m
//  MSSante
//
//  Created by Labinnovation on 24/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "SyncInput.h"

@implementation SyncInput

@synthesize folderId, token;

- (NSDictionary*)generate {
//    if (folderId != nil) {[input setObject:folderId forKey:FOLDER_ID];}
    if (token != nil) {[input setObject:token forKey:TOKEN];}
    return [NSDictionary dictionaryWithObject:input forKey:SYNC_MESSAGES_INPUT];
}

@end
