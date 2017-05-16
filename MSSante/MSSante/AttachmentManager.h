//
//  AttachementManager.h
//  MSSante
//
//  Created by Labinnovation on 09/12/2014.
//  Copyright (c) 2014 Capgemini. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NouveauMessageViewController2;
@interface AttachmentManager : NSObject


+ (NSMutableArray*) getAttachementsByIdMessage:(NSNumber*)idMessage;

- (instancetype) initWithMaster:(NouveauMessageViewController2 *)theMaster;
- (void) addAttachmentFromPickingMediaWithInfo : (NSDictionary *)info;

- (NSArray*) getAttachements;

- (NSMutableArray*) getAttachementsByIdMessage:(NSNumber*)idMessage;
- (NSInteger) getAttachementsCount;
- (NSInteger) getTotalSize;
- (void) setAttachements:(NSMutableArray*)attachements;
- (void) removeAttachment :(NSString*)fileName;
@end
