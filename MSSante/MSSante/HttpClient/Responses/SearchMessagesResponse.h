//
//  SearchAndFetchResponse.h
//  MSSante
//
//  Created by Ismail on 6/25/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "Response.h"
#import "Message.h"

@interface SearchMessagesResponse : Response

@property(nonatomic, strong) NSMutableArray* messages;

@end
