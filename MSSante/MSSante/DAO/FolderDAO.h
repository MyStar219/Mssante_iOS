//
//  FolderDAO.h
//  MSSante
//
//  Created by Labinnovation on 24/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "DAOBase.h"
#import "CDFilter.h"
#import "Constant.h"
#import "Folder.h"

@interface FolderDAO : DAO

- (Folder*)findFolderByFolderId:(NSNumber*)folderId;
- (NSMutableArray*)findFoldersByLevel:(NSNumber*)level;
+ (NSMutableDictionary*)deleteAllfolders;
+ (BOOL)folderExists:(NSNumber*)folderId;
+ (void)deleteDeletedFolders;

@end
