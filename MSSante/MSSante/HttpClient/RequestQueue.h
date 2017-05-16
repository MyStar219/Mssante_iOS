//
//  RequestQueue.h
//  MSSante
//
//  Created by Labinnovation on 02/09/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Request.h"

@class  Request;
@interface RequestQueue : NSObject {
    NSMutableArray *queue;
}

@property (nonatomic, strong) NSMutableArray *queue;

+ (RequestQueue*)sharedInstanceQueue;

- (void)enqueue: (Request*)item;
- (Request*)dequeue;
- (Request*)peek;
- (void)execute;
- (void)empty;
- (BOOL)hasSyncRequest;
- (BOOL)isEmpty;

@end
