//
//  RenameInput.m
//  MSSante
//
//  Created by Labinnovation on 24/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "RenameInput.h"

@implementation RenameInput

@synthesize folderId, folderName;

- (NSDictionary*)generate {
    if (folderId != nil) {[input setObject:folderId forKey:FOLDER_ID];}
    if (folderName != nil) {[input setObject:folderName forKey:NEW_FOLDER_NAME];}
    return [NSDictionary dictionaryWithObject:input forKey:RENAME_FOLDER_INPUT];
}

@end
