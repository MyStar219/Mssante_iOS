//
//  StoreInput.h
//  MSSante
//
//  Created by Labinnovation on 26/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "Input.h"

@interface UpdateMessagesInput : Input

@property(nonatomic, strong) NSMutableArray *messageIds;
@property(nonatomic, strong) NSString *operation;
@property(nonatomic, strong) NSString *flag;

@end
