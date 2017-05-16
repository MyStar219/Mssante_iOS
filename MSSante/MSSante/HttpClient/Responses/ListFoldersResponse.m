//
//  ListFoldersResponse.m
//  MSSante
//
//  Created by Labinnovation on 23/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "ListFoldersResponse.h"
#import "DAOFactory.h"
#import "Folder.h"
#import "FolderDAO.h"

@implementation ListFoldersResponse

@synthesize folders, responseObject;


- (id)parseJSONObject {
    folders = [NSMutableArray array];
    if(!jsonError) {
        if ([[jsonObject objectForKey:LIST_FOLDERS_OUTPUT] isKindOfClass: [NSDictionary class]]) {
            id listFoldersOutput = [jsonObject objectForKey:LIST_FOLDERS_OUTPUT];
            NSMutableDictionary *oldFolders = [FolderDAO deleteAllfolders];
            if([[listFoldersOutput objectForKey:FOLDERS] isKindOfClass:[NSArray class]] && [[listFoldersOutput objectForKey:FOLDERS] count] > 0) {
                
                [self saveToDatabase];
                
                NSArray *_folders = [listFoldersOutput objectForKey:FOLDERS];
                for(int i = 0 ; i < [_folders count]; i++) {
                    if([[_folders objectAtIndex:i] isKindOfClass: [NSDictionary class]]) {
                        NSDictionary *__folderDictionary = [_folders objectAtIndex:i];
                        Folder *tmpFolder = [self parseFolder:__folderDictionary level:[NSNumber numberWithInt:0] oldFolders:oldFolders];
                        if (tmpFolder && saveToDB) {
                            
                            [self saveToDatabase];
                            [folders addObject:tmpFolder];
                        }
                        
                    }
                }
                
            } else if ([[listFoldersOutput objectForKey:FOLDERS] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *__folderDictionary = [listFoldersOutput objectForKey:FOLDERS];
                Folder *tmpFolder = [self parseFolder:__folderDictionary level:[NSNumber numberWithInt:0] oldFolders:oldFolders];
                if (tmpFolder && saveToDB) {
                    [self saveToDatabase];
                    [folders addObject:tmpFolder];
                }
                
            }
        } else {
            //Pas de folders : listFoldersOutput est un string : {listFoldersOutput:""}
        }
    } else {
        DLog(@"Error parsing json : %@", jsonError);
    }
    responseObject = folders;
    return responseObject;
}

@end
