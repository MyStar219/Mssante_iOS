//
//  Attachment.h
//  MSSante
//
//  Created by Labinnovation on 03/10/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Message;

@interface Attachment : NSManagedObject

@property (nonatomic, retain) NSString * contentType;
@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSString * localFileName;
@property (nonatomic, retain) NSNumber * part;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) Message *message;

@end
