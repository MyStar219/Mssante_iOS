//
//  ListFoldersInput.m
//  MSSante
//
//  Created by Labinnovation on 23/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "ListFoldersInput.h"

@implementation ListFoldersInput

@synthesize folderId;

- (NSDictionary*)generate {
    if (folderId != nil) {[input setObject:folderId forKey:FOLDER_ID];}
    return [NSDictionary dictionaryWithObject:input forKey:LIST_FOLDERS_INPUT];
}

@end
