//
//  RequestQueue.m
//  MSSante
//
//  Created by Labinnovation on 02/09/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "RequestQueue.h"
#import "Authentification.h"

@implementation RequestQueue

@synthesize queue;

static RequestQueue *sharedInstance = nil;

+ (RequestQueue *)sharedInstanceQueue {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
        sharedInstance.queue = [NSMutableArray array];
    }
    return sharedInstance;
}

- (void)enqueue:(Request*)item {
    DLog(@"RequestQueue : enqueue");
    
    BOOL duplicate = NO;
    BOOL sync = [S_ITEM_SYNC isEqualToString:item.service];
    BOOL listFolder = [S_FOLDER_LIST isEqualToString:item.service];
    BOOL isSyncOrListFolder = sync || listFolder;
    
    if ([self peek] && [[[self peek] service] isEqualToString:item.service] && isSyncOrListFolder) {
        duplicate = YES;
        DLog(@"RequestQueue : Duplicate %@ request", item.service);
    }
    
    if (!duplicate) {
        DLog(@"RequestQueue : Adding Request to Queue");
        [queue addObject:item];
        
        DLog(@"RequestQueue : Queue size %d",queue.count);
        
        if ([queue count] == 1) {
            DLog(@"RequestQueue : Execting Request because it's the only one in the queue %@",item);
            [[item operation] start];
        }
    }
}

- (Request*)dequeue {
    Request *item = nil;
    if ([queue count] != 0) {
        item = [queue objectAtIndex:0];
        [queue removeObjectAtIndex:0];
    }
    return item;
}

- (Request*)peek {
    Request *item = nil;
    if ([queue count] > 0) {
        item = [queue objectAtIndex:0];
    }
    return item;
}

- (void)execute {
    if (queue.count > 0) {
        Request *toRemove = [self dequeue];
        DLog(@"Removing old request from queue %@",toRemove);
        /*for (Request *request in queue) {
            DLog(@"request %@, \n service : %@  \n, url : %@", request, request.service, request.url);
            DLog(@"request %@, \n params: %@\ndelegate : %@", request, request.parameters, request.delegate);
        }*/
        DLog(@"Queue size %d",queue.count);
        Request* request = [self peek];
        if ([request isKindOfClass:[Request class]]) {
            DLog(@"Exectuing new Request %@",request);
            [[request operation] start];
        }
    }
}

- (void)empty {
    if (queue.count > 0) {
        Request* current = [self peek];
        [[current operation] cancel];
        [current setCanceled:YES];
        [[Authentification sharedInstance] setCanceled:YES];
        DLog(@"RequestQueue Cancel Operation for Request %@",current);
        [queue removeAllObjects];
    }
}

- (BOOL)hasSyncRequest {
    if (queue.count > 0) {
        for (Request *r in queue) {
            if ([S_ITEM_SYNC isEqualToString:r.service]) {
                return  YES;
            }
        }
    }
    return NO;
}

- (BOOL)isEmpty {
    return queue.count == 0;
}

@end
