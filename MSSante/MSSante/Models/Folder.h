//
//  Folder.h
//  MSSante
//
//  Created by Labinnovation on 10/10/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Folder;

@interface Folder : NSManagedObject

@property (nonatomic, retain) NSNumber * folderId;
@property (nonatomic, retain) NSString * folderName;
@property (nonatomic, retain) NSNumber * folderNbUnread;
@property (nonatomic, retain) NSNumber * level;
@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) NSNumber * initialized;
@property (nonatomic, retain) NSSet *folders;
@property (nonatomic, retain) Folder *parentFolder;
@end

@interface Folder (CoreDataGeneratedAccessors)

- (void)addFoldersObject:(Folder *)value;
- (void)removeFoldersObject:(Folder *)value;
- (void)addFolders:(NSSet *)values;
- (void)removeFolders:(NSSet *)values;

@end
