//
//  CreateInput.m
//  MSSante
//
//  Created by Labinnovation on 24/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "CreateInput.h"

@implementation CreateInput

@synthesize folderName, folderParentId;

- (NSDictionary*)generate {
    if (folderName != nil) {[input setObject:folderName forKey:FOLDER_NAME];}
    if (folderParentId != nil) {[input setObject:folderParentId forKey:FOLDER_PARENT_ID];}
    return [NSDictionary dictionaryWithObject:input forKey:CREATE_FOLDER_INPUT];
}

@end
