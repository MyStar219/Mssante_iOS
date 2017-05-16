//
//  DownloadAttachmentInput.h
//  MSSante
//
//  Created by Labinnovation on 13/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "Input.h"

@interface DownloadAttachmentInput : Input

@property(nonatomic, strong) NSNumber *messageId;
@property(nonatomic, strong) NSNumber *part;

@end
