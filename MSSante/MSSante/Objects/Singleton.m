//
//  Singleton.m
//  MSSante
//
//  Created by Labinnovation on 13/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "Singleton.h"

@implementation Singleton
@synthesize activityNetwork;

static Singleton *instance = nil;

//Get UserDefaults
+(Singleton*)getInstance{
    if (!instance){
        instance = [[Singleton allocWithZone:NULL] init];
    }
    return instance;
}

-(void)incrementActivityNetwork{
    activityNetwork++;
}
-(void)decrementActivityNetwork{
    activityNetwork--;
}
@end
