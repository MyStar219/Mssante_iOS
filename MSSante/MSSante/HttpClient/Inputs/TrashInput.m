//
//  TrashInput.m
//  MSSante
//
//  Created by Labinnovation on 24/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "TrashInput.h"

@implementation TrashInput

@synthesize folderId;

- (NSDictionary*)generate {
    if (folderId != nil) {[input setObject:folderId forKey:FOLDER_ID];}
    return [NSDictionary dictionaryWithObject:input forKey:TRASH_FOLDER_INPUT];
}

@end
