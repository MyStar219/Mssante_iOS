//
//  ModificationDAO.m
//  MSSante
//
//  Created by Labinnovation on 26/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "ModificationDAO.h"
#import "Constant.h"
#import "CDFilter.h"
#import "DAOFactory.h"

@implementation ModificationDAO

-(id)init{
    if (self = [super init]) {
        
    }
    
    [super setEntityName:@"Modification"];
    
    return self;
}


-(NSMutableArray*)findModificationByMessageId:(NSNumber*)messageId {
    CDSearchCriteria *criteria = [CDSearchCriteria criteria];
    [criteria addFilter:[CDFilter equals:MESSAGE_ID value:messageId]];
    NSMutableArray *listModif = [[self findAll:criteria] mutableCopy];
    if ([listModif count] > 0) {
        return listModif;
    } else {
        return nil;
    }
}

+(NSMutableArray*)findModificationByMessageId:(NSNumber*)messageId {
    ModificationDAO *modifDAO = (ModificationDAO*)[[DAOFactory factory] newDAO:ModificationDAO.class];
    return [modifDAO findModificationByMessageId:messageId];
}


+(void)deleteModificationsMessageId:(NSNumber*)messageId forOperation:(NSString*)operation{
    
    DLog(@"messageId %@",messageId);
    ModificationDAO *modifDAO = (ModificationDAO*)[[DAOFactory factory] newDAO:ModificationDAO.class];
    
    NSMutableArray *modifications = [modifDAO findModificationByMessageId:messageId];
    
    if (modifications.count > 0) {
        for (Modification *modification in modifications) {
            if ([modification.operation isEqualToString:operation] || operation == nil) {
                DLog(@"deleting modification %@",modification.operation);
                [modifDAO deleteObject:modification];
            }
        }
    }
}

@end
