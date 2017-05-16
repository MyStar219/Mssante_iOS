//
//  RenameInput.h
//  MSSante
//
//  Created by Labinnovation on 24/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "Input.h"

@interface RenameInput : Input {
    NSNumber *folderId;
    NSString *folderName;
}

@property(nonatomic, strong) NSNumber *folderId;
@property(nonatomic, strong) NSString *folderName;

@end
