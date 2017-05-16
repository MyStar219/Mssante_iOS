//
//  NPAttachment.h
//  MSSante
//
//  Created by Labinnovation on 12/12/2014.
//  Copyright (c) 2014 Capgemini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NPAttachment : NSObject
@property (nonatomic, copy) NSString * contentType;
@property (nonatomic, copy) NSString * fileName;
@property (nonatomic, copy) NSString * localFileName;
@property (nonatomic, copy) NSNumber * part;
@property (nonatomic, copy) NSNumber * size;
@property (nonatomic, copy) NSString * datas;

- (id)initWithContentType:(NSString*)aContentType fileName:(NSString*)aFileName localFileName:(NSString*)aLocalFileName part:(NSNumber*)aPart size:(NSNumber*)aSize;

+ (id)objectWithContentType:(NSString*)aContentType fileName:(NSString*)aFileName localFileName:(NSString*)aLocalFileName part:(NSNumber*)aPart size:(NSNumber*)aSize;
@end
