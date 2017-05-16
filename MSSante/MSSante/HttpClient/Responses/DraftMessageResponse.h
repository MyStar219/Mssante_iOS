//
//  DraftMessageResponse.h
//  MSSante
//
//  Created by Labinnovation on 16/09/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "Response.h"

@interface DraftMessageResponse : Response

@property(nonatomic, strong) Message* message;
@property(nonatomic, strong) NSDictionary *messageDictionary;

@end
