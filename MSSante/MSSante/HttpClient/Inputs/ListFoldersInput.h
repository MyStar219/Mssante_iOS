//
//  ListFoldersInput.h
//  MSSante
//
//  Created by Labinnovation on 23/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "Input.h"

@interface ListFoldersInput : Input {
    NSNumber *folderId;
}

@property(nonatomic, strong) NSNumber *folderId;

@end
