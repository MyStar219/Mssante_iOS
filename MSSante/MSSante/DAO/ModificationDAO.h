//
//  ModificationDAO.h
//  MSSante
//
//  Created by Labinnovation on 26/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "DAOBase.h"
#import "Modification.h"

@interface ModificationDAO : DAO

-(NSMutableArray*)findModificationByMessageId:(NSNumber*)messageId;
+(NSMutableArray*)findModificationByMessageId:(NSNumber*)messageId;
+(void)deleteModificationsMessageId:(NSNumber*)messageId forOperation:(NSString*)operation;

@end
