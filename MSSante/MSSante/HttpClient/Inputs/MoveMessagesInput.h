//
//  MoveMessagesInput.h
//  MSSante
//
//  Created by Labinnovation on 08/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "Input.h"

@interface MoveMessagesInput : Input
@property(nonatomic, strong) NSMutableArray *messageIds;
@property(nonatomic, strong) NSNumber *destinationFolderId;
@end
