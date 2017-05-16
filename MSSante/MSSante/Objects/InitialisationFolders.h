//
//  InitialisationFolders.h
//  MSSante
//
//  Created by Labinnovation on 02/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestFinishedDelegate.h"

@interface InitialisationFolders : NSObject <RequestFinishedDelegate> {
    NSMutableArray *listFolders;
    BOOL isRunning;
}
@property (assign, nonatomic) BOOL isRunning;
+(InitialisationFolders *) sharedInstance;
-(void)start;

@end
