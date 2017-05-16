//
//  AttachmentDAO.m
//  MSSante
//
//  Created by Labinnovation on 25/06/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "AttachmentDAO.h"
#import "CDFilter.h"
#import "Constant.h"

@implementation AttachmentDAO
-(id)init{
    if (self = [super init]) {
        
    }
    
    [super setEntityName:@"Attachment"];
    
    return self;
}

-(Attachment*)findAttachmentByFileName:(NSString*)fileName {
    CDSearchCriteria *criteria = [CDSearchCriteria criteria];
    [criteria addFilter:[CDFilter equals:@"fileName" value:fileName]];
    NSMutableArray *listAttach = [[self findAll:criteria] mutableCopy];
    if ([listAttach count] > 0) {
        Attachment *attach = [listAttach objectAtIndex:0];
        [listAttach removeAllObjects];
        return attach;
    } else {
        return nil;
    }
}

-(NSMutableArray*)findAttachmentByIdMessage:(NSNumber*)idMessage {
    CDSearchCriteria *criteria = [CDSearchCriteria criteria];
    [criteria addFilter:[CDFilter equals:[NSString stringWithFormat:@"%@.%@",@"message",MESSAGE_ID] value:idMessage]];
    NSMutableArray *listAttach = [[self findAll:criteria] mutableCopy];
    if ([listAttach count] > 0) {
        return listAttach;
    } else {
        return nil;
    }
}
@end
