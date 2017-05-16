//
//  ShownFolder.h
//  MSSante
//
//  Created by Labinnovation on 25/10/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShownFolder : NSObject {
    NSNumber *folderId;
}

+ (ShownFolder *)sharedInstance;

@property(strong, nonatomic) NSNumber *folderId;

@end
