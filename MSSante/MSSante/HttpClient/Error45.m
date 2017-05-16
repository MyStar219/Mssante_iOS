//
//  Error45.m
//  MSSante
//
//  Created by Labinnovation on 28/10/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "Error45.h"
#import "Constant.h"
#import "MoveMessagesInput.h"
#import "UpdateMessagesInput.h"
#import "Request.h"
#import "MessageDAO.h"
#import "Modification.h"
#import "DAOFactory.h"

@implementation Error45

@synthesize delegate, service, parameters, isModification, messageIds, operation, destinationFolderId;

-(id)initWithService:(NSString*)_service andParams:(NSMutableDictionary*)_parameters andDelegate:(id)_delegate {
    self = [super init];
    if (self){
        service = _service;
        parameters = _parameters;
        delegate = _delegate;
        isModification = NO;
        messageIds = [NSMutableArray array];
    }
    return self;
}

- (void)execute {
    if ([S_ITEM_UPDATE_MESSAGES isEqualToString:service]) {
        if ([[parameters objectForKey:UPDATE_MESSAGES_INPUT] objectForKey:OPERATION] && [[parameters objectForKey:UPDATE_MESSAGES_INPUT] objectForKey:MESSAGE_IDS]) {
            operation = [[parameters objectForKey:UPDATE_MESSAGES_INPUT] objectForKey:OPERATION];
            messageIds = [[parameters objectForKey:UPDATE_MESSAGES_INPUT] objectForKey:MESSAGE_IDS];
            if (messageIds.count == 1) {
                DLog(@"Error45 : UPDATE_MSG : only one Message, Delete it and all it's modification %@",[messageIds objectAtIndex:0]);
                [MessageDAO deleteMessageAndAllModificationsByMessageId:[messageIds objectAtIndex:0]];
                [self saveDB];
            }
            else if (messageIds.count > 0) {
                DLog(@"Error45 : UPDATE_MSG : more than one message, execute update command for each Message");
                [self updateMessage:[messageIds objectAtIndex:0]];
            }
        }
    } else if ([S_ITEM_MOVE_MESSAGES isEqualToString:service]) {
        if ([[parameters objectForKey:MOVE_MESSAGES_INPUT] objectForKey:DESTINATION_FOLDER_ID] && [[parameters objectForKey:MOVE_MESSAGES_INPUT] objectForKey:MESSAGE_IDS]) {
            destinationFolderId = [[parameters objectForKey:MOVE_MESSAGES_INPUT] objectForKey:DESTINATION_FOLDER_ID];
            messageIds = [[parameters objectForKey:MOVE_MESSAGES_INPUT] objectForKey:MESSAGE_IDS];
            if (messageIds.count == 1) {
                DLog(@"Error45 : MOVE : only one Message, Delete it and all it's modification %@",[messageIds objectAtIndex:0]);
                [MessageDAO deleteMessageAndAllModificationsByMessageId:[messageIds objectAtIndex:0]];
                [self saveDB];
            }
            if (messageIds.count > 0) {
                DLog(@"Error45 : MOVE : more than one message, execute update command for each Message");
                [self moveMessage:[messageIds objectAtIndex:0]];
            }
        }
    }
}

-(void)moveMessage:(NSNumber*)messageId{
    MoveMessagesInput *input = [[MoveMessagesInput alloc] init];
    [input setDestinationFolderId:destinationFolderId];
    [input.messageIds addObject:messageId];
    [self runRequestWithService:S_ITEM_MOVE_MESSAGES params:[input generate]];
}

-(void)updateMessage:(NSNumber*)messageId{
    UpdateMessagesInput *input = [[UpdateMessagesInput alloc] init];
    [input setOperation:operation];
    [input.messageIds addObject:messageId];
    [self runRequestWithService:S_ITEM_UPDATE_MESSAGES params:[input generate]];
}

-(void)runRequestWithService:(NSString*)s params:(NSDictionary*)params {
    Request *request = [[Request alloc] initWithService:s method:HTTP_POST headers:nil params:params];
    request.delegate = self;
    request.isError45Request = YES;
    request.isModification = isModification;
    DLog(@"request.delegate %@", request.delegate);
    [request execute];
}

-(void)httpResponse:(id)_responseObject {
    DLog(@"Error45 httpResponse :  ");
    BOOL respondToCaller = [self runNextRequest];
    if (respondToCaller && [delegate respondsToSelector:@selector(httpResponse:)]){
        DLog(@"No More Messages to Update : Respond to Caller");
        [delegate httpResponse:_responseObject];
    }
}

-(void)httpError:(Error *)_error {
    DLog(@"Error45 HttpError :  ");
    if (_error.errorCode == 45) {
        if (messageIds.count > 0) {
            //delete msg and all it's modifications
            DLog(@"Error45 HttpError : error 45 %@, service %@", [messageIds objectAtIndex:0], service);
            [MessageDAO deleteMessageAndAllModificationsByMessageId:[messageIds objectAtIndex:0]];
            [self saveDB];
        }
    } else if (_error.serviceInaccessible) {
        //save modification
        NSDictionary *modificationInput = nil;
        NSString *modificationOperation = nil;
        NSNumber *messageId = [messageIds objectAtIndex:0];
        if (messageIds.count > 0) {
            if ([S_ITEM_MOVE_MESSAGES isEqualToString:service ]) {
                MoveMessagesInput *input = [[MoveMessagesInput alloc] init];
                [input setDestinationFolderId:destinationFolderId];
                [input.messageIds addObject:messageId];
                modificationInput = [input generate];
                modificationOperation = MOVE;
            } else if([S_ITEM_UPDATE_MESSAGES isEqualToString:service]) {
                UpdateMessagesInput *input = [[UpdateMessagesInput alloc] init];
                [input setOperation:operation];
                [input.messageIds addObject:messageId];
                modificationInput = [input generate];
                modificationOperation = UPDATE;
            }
            if (modificationInput && modificationOperation) {
                [self saveModificationInDatabase:messageId operation:modificationOperation params:modificationInput];
            }
        }
    } else {
        DLog(@"Error45 HttpError : unhandled case error.code %d",_error.errorCode);
    }
    
    BOOL respondToCaller = [self runNextRequest];

    if (respondToCaller && [delegate respondsToSelector:@selector(httpError:)]){
        if (isModification) {
            _error.errorCode = 4500;
        }
        [delegate httpError:_error];
    }
}

- (BOOL)runNextRequest {
    DLog(@"Error45 : runNextRequest");
    BOOL respondToCaller = YES;
    if (messageIds.count > 0) {
        DLog(@"Error45 : runNextRequest : delete last message");
        [messageIds removeObjectAtIndex:0];
        if (messageIds.count > 0) {
            DLog(@"Error45 : runNextRequest : More Messages to update");
            respondToCaller = NO;
            if ([S_ITEM_MOVE_MESSAGES isEqualToString:service]) {
                [self moveMessage:[messageIds objectAtIndex:0]];
            } else if([S_ITEM_UPDATE_MESSAGES isEqualToString:service]) {
                [self updateMessage:[messageIds objectAtIndex:0]];
            } else {
                respondToCaller = YES;
            }
        }
    }
    
    DLog(@"respondToCaller %d",respondToCaller);
    
    return respondToCaller;
}

-(void)saveModificationInDatabase:(NSNumber*)messageId operation:(NSString*)op params:(id)argument {
    Modification* modif = [NSEntityDescription insertNewObjectForEntityForName: @"Modification" inManagedObjectContext: [[DAOFactory factory] managedObjectContext]];
    modif.messageId = messageId;
    modif.operation = op;
    modif.argument = argument;
    modif.date = [NSDate date];
    [self saveDB];
}

-(void)saveDB{
    NSError *error;
    if (![[DAOFactory factory] save:&error]) {
        DLog(@"error save %@", [error userInfo]);
    }
}
@end
