//
//  SendResponse.h
//  MSSante
//
//  Created by Labinnovation on 26/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "Response.h"
#import "Message.h"

@interface SendMessageResponse : Response

@property(nonatomic, strong) Message* message;
@property(nonatomic, strong) NSDictionary *messageDictionary;

@end
