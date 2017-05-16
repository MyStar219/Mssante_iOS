//
//  SyncResponse.h
//  MSSante
//
//  Created by Labinnovation on 25/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "Response.h"

@interface SyncMessagesResponse : Response

@property(nonatomic, strong) NSMutableDictionary* syncDictionary;
@property(nonatomic, strong) NSMutableArray* deletedMessagesIds;
@property(nonatomic, strong) NSMutableArray* createdMessages;
@property(nonatomic, strong) NSMutableArray* modifiedMessages;
@property(nonatomic, strong) NSNumber* token;

@end
