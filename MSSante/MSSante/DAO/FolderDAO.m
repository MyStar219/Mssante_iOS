//
//  FolderDAO.m
//  MSSante
//
//  Created by Labinnovation on 24/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "FolderDAO.h"
#import "DAOFactory.h"

@implementation FolderDAO

- (id)init {
    self = [super init];
    /* @WX - Amélioration Sonar
     * Décommenter le if pour l'initialisation
     */
    /*if (self) {
        // Custom initialization
     }*/
    [super setEntityName:@"Folder"];
    return self;
}

- (Folder*)findFolderByFolderId:(NSNumber*)folderId {
    if (folderId.intValue > 0) {
        CDSearchCriteria *criteria = [CDSearchCriteria criteria];
        [criteria addFilter:[CDFilter equals:FOLDER_ID value:folderId]];
        
        NSMutableArray *folders = [[self findAll:criteria] mutableCopy];
        if ([folders count] > 0) {
            Folder *folder = [folders objectAtIndex:0];
            [folders removeAllObjects];
            return folder;
        }
    }
    return nil;
}

- (NSMutableArray*)findFoldersByLevel:(NSNumber*)level {
    CDSearchCriteria *criteria = [CDSearchCriteria criteria];
    [criteria addFilter:[CDFilter equals:@"level" value:level]];
    NSMutableArray *folders = [[self findAll:criteria] mutableCopy];
    return folders;
}

+ (NSMutableDictionary*)deleteAllfolders {
    FolderDAO *folderDao = (FolderDAO*) [[DAOFactory factory] newDAO:FolderDAO.class];
    NSMutableArray *folders = [[folderDao findAll] mutableCopy];
    NSMutableDictionary *oldFolders = [NSMutableDictionary dictionary];
    if (folders.count > 0) {
        for (Folder *folder in folders) {
            if (folder.folderId.intValue > 0 && folder.folderName.length > 0) {
                [oldFolders setObject:folder.initialized forKey:folder.folderId];
                [folderDao deleteObject:folder];
            }
        }
    }
    return oldFolders;
}

+ (void)deleteDeletedFolders {
    FolderDAO *folderDao = (FolderDAO*) [[DAOFactory factory] newDAO:FolderDAO.class];
    
    /* @WX - Amélioration Sonar
     * [NSNumber numberWithInt:0] <=> @0
     */
    NSMutableArray *folders = [folderDao findFoldersByLevel:@0];
    if (folders.count > 0) {
        for (Folder *folder in folders) {
            /* @WX - Amélioration Sonar
             * [NSNumber numberWithBool:YES] <=> @YES
             */
            if ([folder.deleted isEqualToNumber:@YES]) {
                [folderDao deleteObject:folder];
            }
        }
    }
}

+ (BOOL)folderExists:(NSNumber*)folderId {
    FolderDAO *folderDao = (FolderDAO*) [[DAOFactory factory] newDAO:FolderDAO.class];
    return [[folderDao findFolderByFolderId:folderId] isKindOfClass:[Folder class]];
}

@end