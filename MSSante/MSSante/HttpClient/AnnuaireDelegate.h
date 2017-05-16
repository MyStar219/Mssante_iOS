//
//  AnnuaireDelegate.h
//  MSSante
//
//  Created by Labinnovation on 29/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Email.h"

@protocol AnnuaireDelegate <NSObject>

-(void)addMailToNouveauMessage:(Email*)email;
@end
