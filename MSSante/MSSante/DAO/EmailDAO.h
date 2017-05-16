//
//  EmailDAO.h
//  MSSante
//
//  Created by Labinnovation on 25/06/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "DAOBase.h"
#import "Email.h"

@interface EmailDAO : DAO

- (Email*)findEmailByAddress:(NSString*)adresse andType:(NSString*)type;
- (NSMutableArray*)findAllEmailsOnce;

@end
