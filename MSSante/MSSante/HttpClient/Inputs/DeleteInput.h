//
//  DeleteInput.h
//  MSSante
//
//  Created by Labinnovation on 24/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "Input.h"

@interface DeleteInput : Input {
    NSNumber *folderId;
}

@property(nonatomic, strong) NSNumber *folderId;

@end
