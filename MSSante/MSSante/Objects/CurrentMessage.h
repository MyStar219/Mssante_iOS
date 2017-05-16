//
//  CurrentMessage.h
//  MSSante
//
//  Created by Labinnovation on 30/10/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"

@interface CurrentMessage : NSObject

+ (CurrentMessage *)sharedInstance;

@property(strong, nonatomic) Message *message;

@end
