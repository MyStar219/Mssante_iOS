//
//  FullTextSearchMessagesResponse.h
//  MSSante
//
//  Created by Labinnovation on 06/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "Response.h"
#import "Message.h"

@interface FullTextSearchMessagesResponse : Response

@property(nonatomic, strong) NSMutableArray* messages;

@end
