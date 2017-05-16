//
//  CheckAndLaunchModification.h
//  MSSante
//
//  Created by Labinnovation on 26/08/13.
//  Copyright (c) 2013 ;;. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestFinishedDelegate.h"
#import "ModificationDAO.h"
#import "Message.h"
#import "SyncAndSendModifDelegate.h"
#import "Tools.h"
#import "NSData+AES256.h"
#import "Folder.h"

@interface SyncAndLaunchModification : NSObject <RequestFinishedDelegate>{
    NSMutableArray *listModif;
    ModificationDAO *modifDAO;
    id requestDelegate;
    Message *msgToModify;
    Folder *folderToModify;
    __weak id <SyncAndSendModifDelegate>delegate;
    NSMutableArray *listFolderId;
}


@property (nonatomic, weak) id<SyncAndSendModifDelegate>delegate;

-(void)execute;
-(void)syncOnlyFolderId:(NSNumber*)folderId;
-(void)initFolderId:(NSNumber*)folderId;

@end
