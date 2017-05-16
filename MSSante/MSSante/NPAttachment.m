//
//  NPAttachment.m
//  MSSante
//
//  Created by Labinnovation on 12/12/2014.
//  Copyright (c) 2014 Capgemini. All rights reserved.
//

#import "NPAttachment.h"

@implementation NPAttachment
@synthesize contentType;
@synthesize fileName;
@synthesize localFileName;
@synthesize part;
@synthesize size;
@synthesize datas;

- (id)initWithContentType:(NSString*)aContentType fileName:(NSString*)aFileName localFileName:(NSString*)aLocalFileName part:(NSNumber*)aPart size:(NSNumber*)aSize
{
    self = [super init];
    if (self) {
        contentType = [aContentType copy];
        fileName = [aFileName copy];
        localFileName = [aLocalFileName copy];
        part = [aPart copy];
        size = [aSize copy];
    }
    return self;
}


//===========================================================
// + (id)objectWith:
//
//===========================================================
+ (id)objectWithContentType:(NSString*)aContentType fileName:(NSString*)aFileName localFileName:(NSString*)aLocalFileName part:(NSNumber*)aPart size:(NSNumber*)aSize
{
    id result = [[[self class] alloc] initWithContentType:aContentType fileName:aFileName localFileName:aLocalFileName part:aPart size:aSize];
    
    return result;
}


@end
