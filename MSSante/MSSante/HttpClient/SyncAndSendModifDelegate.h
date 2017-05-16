//
//  SendMessageDelegate.h
//  MSSante
//
//  Created by Labinnovation on 12/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Error.h"

@protocol SyncAndSendModifDelegate <NSObject>

-(void)syncSucces:(id)responseObject;
-(void)syncError:(id)responseObject;
-(void)messageSent:(id)responseObject;

@end
