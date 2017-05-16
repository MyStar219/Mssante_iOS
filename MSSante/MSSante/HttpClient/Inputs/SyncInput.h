//
//  SyncInput.h
//  MSSante
//
//  Created by Labinnovation on 24/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "Input.h"

@interface SyncInput : Input {
    NSNumber *folderId;
    NSNumber *token;
}

@property(nonatomic, strong) NSNumber *folderId;
@property(nonatomic, strong) NSNumber *token;

@end
