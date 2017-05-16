//
//  ShownFolder.m
//  MSSante
//
//  Created by Labinnovation on 25/10/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "ShownFolder.h"

@implementation ShownFolder
@synthesize folderId;
static ShownFolder *sharedInstance = nil;

+ (ShownFolder *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

@end
