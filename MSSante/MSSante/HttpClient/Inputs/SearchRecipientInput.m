//
//  SearchRecipientInput.m
//  MSSante
//
//  Created by Labinnovation on 28/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "SearchRecipientInput.h"

@implementation SearchRecipientInput

@synthesize searchString;

- (id)init {
    self = [super init];
    return self;
}


- (NSDictionary*)generate {
    [input removeObjectForKey:EMAIL];
    if (searchString) {[input setObject:searchString forKey:SEARCH_STRING];}
    return [NSDictionary dictionaryWithObject:input forKey:SEARCH_RECIPIENT_INPUT];
}

@end
