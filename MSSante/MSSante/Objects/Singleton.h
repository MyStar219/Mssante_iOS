//
//  Singleton.h
//  MSSante
//
//  Created by Labinnovation on 13/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Singleton : NSObject{
    int activityNetwork;
}

@property (nonatomic)int activityNetwork;
+ (Singleton*)getInstance;
-(void)incrementActivityNetwork;
-(void)decrementActivityNetwork;
@end
