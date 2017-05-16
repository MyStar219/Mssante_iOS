//
//  GestionError45.h
//  MSSante
//
//  Created by Labinnovation on 04/09/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestFinishedDelegate.h"
#import "Message.h"

@interface GestionError45 : NSObject <RequestFinishedDelegate>{
    NSMutableArray *listModif;
    NSString* op;
    id requestDelegate;
    id requestDelegateForMaster;
    Message *msgToModify;
    NSMutableArray *listMsgId;
    __weak id <RequestFinishedDelegate>masterDelegate;
    NSString *type;
    NSNumber *destinationFolderId;
}

@property (nonatomic, weak) id<RequestFinishedDelegate>masterDelegate;
@property (nonatomic, strong) NSNumber *destinationFolderId;

- (id)initWithListMsgId:(NSMutableArray*)_listMsgId andOperation:(NSString*)_operation withDelegate:(id)_delegate type:(NSString*)_type;
- (void)execute;

@end
