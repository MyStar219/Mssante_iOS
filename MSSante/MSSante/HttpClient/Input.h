//
//  Input.h
//  MSSante
//
//  Created by Labinnovation on 23/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccesToUserDefaults.h"
#import "Constant.h"
@interface Input : NSObject {
    NSMutableDictionary *input;
    NSString *email;
}

@property(nonatomic,strong) NSMutableDictionary *input;
@property(nonatomic,strong) NSString *email;

- (id)init;
- (NSDictionary*)generate;

@end
