//
//  CurrentMessage.m
//  MSSante
//
//  Created by Labinnovation on 30/10/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "CurrentMessage.h"

@implementation CurrentMessage
@synthesize message;
static CurrentMessage *sharedInstance = nil;

+ (CurrentMessage *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}
@end
