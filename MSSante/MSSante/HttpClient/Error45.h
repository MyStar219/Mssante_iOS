//
//  Error45.h
//  MSSante
//
//  Created by Labinnovation on 28/10/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestFinishedDelegate.h"
#import "Message.h"

@interface Error45 : NSObject <RequestFinishedDelegate> {
    id requestDelegate;
}
@property (nonatomic, strong) NSString *service;
@property (nonatomic, strong) NSMutableDictionary *parameters;
@property (nonatomic, weak) id<RequestFinishedDelegate>delegate;
@property (nonatomic, assign) BOOL isModification;
@property (nonatomic, strong) NSMutableArray *messageIds;
@property (nonatomic, strong) NSString *operation;
@property (nonatomic, strong) NSNumber *destinationFolderId;

-(id)initWithService:(NSString*)_service andParams:(NSMutableDictionary*)_parameters andDelegate:(id)_delegate;
-(void)execute;
@end
