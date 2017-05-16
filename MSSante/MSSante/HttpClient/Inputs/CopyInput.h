//
//  CopyInput.h
//  MSSante
//
//  Created by Labinnovation on 26/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "Input.h"

@interface CopyInput : Input

@property(nonatomic, strong) NSMutableArray *idMessageSet;
@property(nonatomic, strong) NSNumber *destinationFolderId;

@end
