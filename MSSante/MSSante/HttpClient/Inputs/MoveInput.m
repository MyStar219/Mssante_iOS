//
//  MoveInput.m
//  MSSante
//
//  Created by Labinnovation on 24/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "MoveInput.h"

@implementation MoveInput

@synthesize folderId, destinationFolderId;

- (NSDictionary*)generate {
    if (folderId != nil) {[input setObject:folderId forKey:FOLDER_ID];}
    if (destinationFolderId != nil) {[input setObject:destinationFolderId forKey:DESTINATION_FOLDER_ID];}
    return [NSDictionary dictionaryWithObject:input forKey:MOVE_FOLDER_INPUT];
}

@end
