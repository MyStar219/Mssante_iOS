//
//  Persistence
//
//  Created by Ing. Jozef Bozek on 29.5.2009.
//
//	Copyright © 2009 Grapph. All Rights Reserved.
// 
//	Redistribution and use in source and binary forms, with or without 
//	modification, are permitted provided that the following conditions are met:
//
//	1. Redistributions of source code must retain the above copyright notice, this 
//	   list of conditions and the following disclaimer.
//
//	2. Redistributions in binary form must reproduce the above copyright notice, 
//	   this list of conditions and the following disclaimer in the documentation 
//	   and/or other materials provided with the distribution.
//
//	3. Neither the name of the author nor the names of its contributors may be used
//	   to endorse or promote products derived from this software without specific
//	   prior written permission.
//
//	THIS SOFTWARE IS PROVIDED BY GRAPPH "AS IS"
//	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//	DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
//	FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//	DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//	CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//	OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//	OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import <Foundation/Foundation.h>

#import <sqlite3.h>
@class DAO;
@class NSManagedObjectModel;
@class NSManagedObjectContext;
@class NSPersistentStoreCoordinator;
@protocol DAO;


@interface DAOFactory : NSObject {
	
	NSManagedObjectModel *managedObjectModel;
	NSManagedObjectContext *managedObjectContext;
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

+ (DAOFactory*)factory;
// setter for store type - defaul NSSQLiteStoreType
+ (void)setStorePath:(NSString*)storePath;
+ (void)setKey:(NSString*)key;
+ (void)setStoreType:(NSString*)storeType;
+ (NSString*)storePath;
+ (NSString*)storeType;
+ (void)deleteFactory;
- (BOOL)hasManageObjectContext;
- (void)deleteManagedObjectContext;

@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;

/** 
 * TODO - volitelne subcontexty pre novovytvarane DAO
 */
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, weak) NSUndoManager* undoManager;

- (NSString *)applicationDocumentsDirectory;

/**
 * Creates DAO object for given DAO type
 */
-(DAO*)newDAO:(Class)daoType;

/**
 * Creates runtime DAO object for given entity name.
 */
-(DAO*)newRuntimeDAO:(NSString*)entityName;

/**
 * Creates autoreleased runtime DAO object for given entity name.
 */
-(DAO*)createDAO:(NSString*)entityName;

// See NSManagedObjectContext
-(BOOL)save:(NSError**)error;
// See NSManagedObjectContext
-(BOOL)save;
// See NSManagedObjectContext
- (void)undo;
// See NSManagedObjectContext
- (void)redo;
// See NSManagedObjectContext
- (void)reset;
// See NSManagedObjectContext
- (void)rollback;
//A appeler pour clore le context
- (void)shutDown;
- (BOOL) resetDatabaseKey:(NSString*)dbKey;

- (NSManagedObjectContext *) resetManagedObjectContext;

@end
