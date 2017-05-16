//
//  AttachmentDAO.h
//  MSSante
//
//  Created by Labinnovation on 25/06/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "DAOBase.h"
#import "Attachment.h"

@interface AttachmentDAO : DAO

-(Attachment*)findAttachmentByFileName:(NSString*)fileName;
-(NSMutableArray*)findAttachmentByIdMessage:(NSNumber*)idMessage;
@end
