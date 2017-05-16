//
//  GestionError45.m
//  MSSante
//
//  Created by Labinnovation on 04/09/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "GestionError45.h"
#import "DAOFactory.h"
#import "Request.h"
#import "MessageDAO.h"
#import "UpdateMessagesInput.h"
#import "MoveMessagesInput.h"

@implementation GestionError45

@synthesize masterDelegate;
@synthesize destinationFolderId;

- (id)initWithListMsgId:(NSMutableArray*)_listMsgId
           andOperation:(NSString*)_operation
           withDelegate:(id)_delegate
                   type:(NSString*)_type {
    self = [super init];
    if (self){
        // Custom initialization
        masterDelegate = _delegate;
        requestDelegate = self;
        listMsgId = _listMsgId;
        op = _operation;
        type = _type;
    }
    return self;
}

- (void)execute {
    [self runRequestService:type andMethod:HTTP_POST];
}

- (void)runRequestService:(NSString*)_service andMethod:(NSString*)_method {
    DLog(@"listMsgId %@ & operation %@ in Gestion", listMsgId, op);
    id updateInput = nil;
    
    if ([S_ITEM_MOVE_MESSAGES isEqualToString:_service]) {
        updateInput = [[MoveMessagesInput alloc] init];
        if (destinationFolderId) {
            [updateInput setDestinationFolderId:destinationFolderId];
        }
    } else if ([S_ITEM_UPDATE_MESSAGES isEqualToString:_service]) {
        updateInput = [[UpdateMessagesInput alloc] init];
        [(UpdateMessagesInput*)updateInput setOperation:op];
    }
    
    if (updateInput != nil) {
        NSMutableArray *oneMessageId = [[NSMutableArray alloc] initWithObjects:[listMsgId objectAtIndex:0], nil];
        [updateInput setMessageIds:oneMessageId];
        
        Request *request = [[Request alloc] initWithService:_service
                                                     method:_method
                                                    headers:nil
                                                     params:[updateInput generate]];
        request.delegate = requestDelegate;
        [request execute];
    }
}

- (void)httpResponse:(id)_responseObject {
    DLog(@"Gestion Error 45 : httpResponse : %@", _responseObject);
    
    if([masterDelegate respondsToSelector:@selector(httpResponse:)]) {
        [masterDelegate httpResponse:_responseObject];
    }
    
    [listMsgId removeObjectAtIndex:0];
    
    if (listMsgId.count > 0) {
        [self runRequestService:type andMethod:HTTP_POST];
    }
}

- (void)httpError:(Error *)_error {
    DLog(@"Gestion Error 45 : httpError : %@", _error);
    
    if([masterDelegate respondsToSelector:@selector(httpError:)]) {
        [masterDelegate httpError:_error];
    }
    
    [listMsgId removeObjectAtIndex:0];
    
    if (listMsgId.count > 0) {
        [self runRequestService:type andMethod:HTTP_POST];
    }
}

@end
