//
//  Input.m
//  MSSante
//
//  Created by Labinnovation on 23/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "Input.h"

@implementation Input

@synthesize email, input;

- (id)init {
    self = [super init];
    email = [AccesToUserDefaults getUserInfoChoiceMail];
    input = [NSMutableDictionary dictionary];
    if ([email length] > 0) {
        [input setObject:email forKey:EMAIL];
    }
    return self;
}

@end
