//
//  CreateInput.h
//  MSSante
//
//  Created by Labinnovation on 24/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "Input.h"

@interface CreateInput : Input {
    NSNumber *folderParentId;
    NSString *folderName;
}

@property(nonatomic, strong) NSNumber *folderParentId;
@property(nonatomic, strong) NSString *folderName;

@end
