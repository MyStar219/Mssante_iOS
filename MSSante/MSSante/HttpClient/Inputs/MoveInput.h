//
//  MoveInput.h
//  MSSante
//
//  Created by Labinnovation on 24/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "Input.h"

@interface MoveInput : Input {
    NSNumber *folderId;
    NSNumber *destinationFolderId;
}

@property(nonatomic, strong) NSNumber *folderId;
@property(nonatomic, strong) NSNumber *destinationFolderId;

@end
