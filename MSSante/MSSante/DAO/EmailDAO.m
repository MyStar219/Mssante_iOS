//
//  EmailDAO.m
//  MSSante
//
//  Created by Labinnovation on 25/06/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "EmailDAO.h"
#import "Constant.h"
#import "CDFilter.h"

@implementation EmailDAO

- (id)init {
    self = [super init];
    /* @WX - Amélioration Sonar
     * Décommenter le if pour l'initialisation
     */
    /*if (self) {
        // Custom initialization
     }*/
    [super setEntityName:@"Email"];
    return self;
}

- (NSMutableArray*)findAllEmailsOnce {
    NSMutableArray *listEmails = [[self findAll] mutableCopy];
    NSMutableArray* uniqueAddress = [[NSMutableArray alloc] init];
    NSMutableArray* listUniqueEmails = [[NSMutableArray alloc] init];
    
    for(Email* email in listEmails) {
        if(![uniqueAddress containsObject:email.address]) {
            [listUniqueEmails addObject:email];
            [uniqueAddress addObject:email.address];
        }
    }
    
    return listUniqueEmails;
}

- (Email*)findEmailByAddress:(NSString*)adresse andType:(NSString*)type{
    CDSearchCriteria *criteria = [CDSearchCriteria criteria];
    [criteria addFilter:[CDFilter equals:E_ADDRESS value:adresse]];
    [criteria addFilter:[CDFilter equals:E_TYPE value:type]];
    
    NSMutableArray *listEmails = [[self findAll:criteria] mutableCopy];
    if ([listEmails count] > 0) {
        Email *email = [listEmails objectAtIndex:0];
        [listEmails removeAllObjects];
        return email;
    }
    
    return nil;
}

@end
