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

#import <CoreData/CoreData.h>
#import "DAO.h"
#import "common_defines.h"
#import "DAOFactory.h"
#import "RuntimeDAO.h"
#import "EncryptedStore.h"

@implementation DAOFactory

@synthesize managedObjectModel;
@synthesize managedObjectContext;
@synthesize persistentStoreCoordinator;

static DAOFactory* factory;
static NSString* storePath;
static NSString* dbKey;
static NSString* storeType;

+(void)initialize {
	factory = [[DAOFactory alloc] init];
}

+ (void)setStorePath:(NSString*)path {
	if (storePath != path) {
		storePath = [path copy];
	}
}

+ (void)setKey:(NSString*)key {
	if (dbKey != key) {
		dbKey = [key copy];
	}
}

+ (NSString*)storePath {
	return storePath;
}

+ (void)setStoreType:(NSString*)aStoreType {
	if (storeType != aStoreType) {
		storeType = [aStoreType copy];
	}
}

+ (NSString*)storeType {
	return storeType;
}

+ (void)deleteFactory {
    if (factory) {
        NSLog(@"DAOFactory - deleteFactory");
        [factory deleteManagedObjectContext];
    }
}

- (void)deleteManagedObjectContext {
    if (persistentStoreCoordinator) {
        NSLog(@"DAOFactory - delete persistentStoreCoordinator");
        persistentStoreCoordinator = nil;
    }
    
    if (managedObjectContext) {
        NSLog(@"DAOFactory - delete managedObjectContext");
        managedObjectContext = nil;
    }
}

-init {
	if (factory) {
		return factory;
	}
	
	if (!(self=[super init])) {
		return nil;
	}
	
	return factory=self;  
}

+(DAOFactory*)factory {
 	return factory;
}

-(DAO*)newDAO:(Class)daoType {
	DAO *dao = [[daoType alloc] initWithContext:self.managedObjectContext];
	return dao;
}

-(DAO*)newRuntimeDAO:(NSString*)entityName {
	DAO *dao = [[RuntimeDAO alloc] initWithContextAndEntityName:self.managedObjectContext entityName:entityName];
	return dao;
}

-(DAO*)createDAO:(NSString*)entityName {
	DAO *dao = [[RuntimeDAO alloc] initWithContextAndEntityName:self.managedObjectContext entityName:entityName];
	return dao;
}

-(BOOL)save:(NSError**)error {
	BOOL result = [managedObjectContext save:error];
	return result;
}

-(BOOL)save {
	NSError* error = nil;
	BOOL result = [managedObjectContext save:&error];
	if (!result) {
		LOG_ERROR(error);
	}
	return result;
}

- (void)undo{
	[managedObjectContext undo];
}

- (void)redo{
	[managedObjectContext redo];
}

- (void)reset{
	[managedObjectContext reset];
}

- (void)rollback {
	[managedObjectContext rollback];
}

-(NSUndoManager*)undoManager {
	return [self managedObjectContext].undoManager;
}

-(void)setUndoManager:(NSUndoManager*)undoManager {
	self.managedObjectContext.undoManager = undoManager;
}


-(BOOL)hasManageObjectContext{
    if (managedObjectContext == nil){
        return NO;
    }
    return YES;
}

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSLog(@"DAOFactory - managedObjectContext - CREATE");
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
        
    }
    return managedObjectContext;
}

- (NSManagedObjectContext *) resetManagedObjectContext {
	[self deleteManagedObjectContext];
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    //    persistentStoreCoordinator = [EncryptedStore makeStore:[self managedObjectModel]:dbKey:storePath];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
        return managedObjectContext;
    } else {
        NSLog(@"DAOFactory - resetManagedObjectContext - Coordinator is nil");
    }
    return nil;
}


- (BOOL) resetDatabaseKey:(NSString*)newKey {
    
    static sqlite3 *database;
    NSString *path = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: storePath];
    
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        NSLog(@"DAOFactory - Database Successfully Opened");
        const char *oldKeyString = [dbKey UTF8String];
        const char *newKeyString = [newKey UTF8String];
        
        int setKeystatus = sqlite3_key(database, oldKeyString, strlen(oldKeyString));
        if (setKeystatus == SQLITE_OK) {
            NSLog(@"DAOFactory - Openning database using old key");
            int setNewKeyStatus = sqlite3_rekey(database, newKeyString, strlen(newKeyString));
            oldKeyString = NULL;
            newKeyString = NULL;
            if (setNewKeyStatus == SQLITE_OK) {
                [DAOFactory setKey:newKey];
                sqlite3_close(database);
                if (persistentStoreCoordinator) {
                    NSPersistentStore *oldStore = [persistentStoreCoordinator persistentStoreForURL:[NSURL fileURLWithPath:path]];
                    if (oldStore) {
                        NSError *error = nil;
                        [persistentStoreCoordinator removePersistentStore:oldStore error:&error];
                        if (error) {
                            NSLog(@"DAOFactory - Error Removing old Store %@",[error description]);
                            return NO;
                        }
                        
                        NSDictionary *options = @{EncryptedStorePassphraseKey : newKey,
                                                  NSMigratePersistentStoresAutomaticallyOption : @YES,
                                                  NSInferMappingModelAutomaticallyOption : @YES};

                        NSPersistentStore *newStore = [persistentStoreCoordinator addPersistentStoreWithType:EncryptedStoreType configuration:nil URL:[NSURL fileURLWithPath:path] options:options error:&error];
                        if (newStore) {
                            NSLog(@"DAOFactory - New Store Updated %@",newStore);
                            return YES;
                        } else {
                            NSLog(@"DAOFactory - Can't Update New Store %@",[error description]);
                        }
                    } else {
                        NSLog(@"DAOFactory - No Old Store");
                    }
                } else {
                    NSLog(@"DAOFactory - NO persistentStoreCoordinator");
                }
            } else {
                NSLog(@"DAOFactory - Can not set the new Key");
            }
        } else {
            NSLog(@"DAOFactory - Error openning old database using old key");
        }
    } else {
        NSLog(@"DAOFactory - Error in opening database :(");
        database = NULL;
    }
    
    NSLog(@"DAOFactory - ChangeDataBaseKeyFailed");
    
    return NO;
}
/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    if (dbKey && storePath) {
        NSLog(@"DAOFactory - init persistentStoreCoordinator");
        persistentStoreCoordinator = [EncryptedStore makeStore:[self managedObjectModel]:dbKey:storePath];
        if (persistentStoreCoordinator == nil) {
            NSLog(@"DAOFactory - persistentStoreCoordinator is NIL");
            return nil;
        }
        return persistentStoreCoordinator;
    } else {
        NSLog(@"DAOFactory - persistentStoreCoordinator - dbKey && storePath is NIL");
    }
    
	return nil;
}

#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

-(void)shutDown{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSError *error = nil;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            /*
                Replace this implementation with code to handle the error appropriately.
                
                abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
                */
            NSLog(@"DAOFactory - Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark -


@end
