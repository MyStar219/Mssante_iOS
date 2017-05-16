//
//  NPConverter.h
//  MSSante
//
//  Created by Labinnovation on 27/11/2014.
//  Copyright (c) 2014 Capgemini. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NPEmail;
@class Email;
@class NPMessage;
@class Message;
@class Attachment;
@class NPAttachment;

@interface NPConverter : NSObject
+(NPEmail *)convertEmail:(Email *)persistantEmail;

+(NPMessage *)convertMessage:(Message *) message;
+(NPMessage *)switchToRespondMessage:(NPMessage *)message;
+(NPMessage *)switchToRespondToAllMessage:(NPMessage *)message;
+(NPMessage *)switchToTransferMessage:(NPMessage *)message;

+(NPAttachment *)convertAttachment:(Attachment *)attachment;

@end
