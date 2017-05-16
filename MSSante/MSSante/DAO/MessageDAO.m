//
//  MessageDAO.m
//  MSSante
//
//  Created by Labinnovation on 25/06/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "MessageDAO.h"
#import "DAOFactory.h"
#import "ModificationDAO.h"

@implementation MessageDAO

- (id)init {
    self = [super init];
    /* @WX - Amélioration Sonar
     * Décommenter le if pour l'initialisation
     */
    /*if (self) {
        // Custom initialization
    }*/
    [super setEntityName:@"Message"];
    return self;
}

- (NSMutableArray*)findMessagesByFolderId:(NSNumber*)folderId {
    CDSearchCriteria *criteria = [CDSearchCriteria criteriaWithEntityName:@"Folder"];
    [criteria addFilter:[CDFilter equals:FOLDER_ID value:folderId]];
    [criteria addOrder:[CDOrder descendingOrder:@"date"]];
    
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    if ([[self findAll:criteria] count] > 0 ) {
        messages = [[self findAll:criteria] mutableCopy];
    }
    
    return [self sortArrayByDate:messages];
}

- (NSMutableArray*)findAllMessagesUnread {
    CDSearchCriteria *criteria = [CDSearchCriteria criteria];
    
    /* @WX - Amélioration Sonar
     * [NSNumber numberWithInt:0] <=> @0
     */
    [criteria addFilter:[CDFilter equals:IS_READ value:@0]];
    [criteria addOrder:[CDOrder descendingOrder:@"date"]];
    
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    if ([[self findAll:criteria] count] > 0 ){
        messages = [[self findAll:criteria] mutableCopy];
    }
    
    return [self sortArrayByDate:messages];
}

- (NSMutableArray*)findAllMessagesFollowed {
    CDSearchCriteria *criteria = [CDSearchCriteria criteria];
    
    /* @WX - Amélioration Sonar
     * [NSNumber numberWithInt:1] <=> @1
     */
    [criteria addFilter:[CDFilter equals:IS_FAVOR value:@1]];
    [criteria addOrder:[CDOrder descendingOrder:@"date"]];
    
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    if ([[self findAll:criteria] count] > 0 ){
        messages = [[self findAll:criteria] mutableCopy];
    }
    
    return [self sortArrayByDate:messages];
}

- (Message*)findMessageByMessageId:(NSNumber*)messageId {
    CDSearchCriteria *criteria = [CDSearchCriteria criteria];
    [criteria addFilter:[CDFilter equals:MESSAGE_ID value:messageId]];
    
    NSMutableArray *msgs = [[self findAll:criteria] mutableCopy];
    if ([msgs count] > 0) {
        Message *msg = [msgs objectAtIndex:0];
        // [msgs removeAllObjects];
        return msg;
    }
    
    return nil;
}

+ (Message*)findMessageByMessageId:(NSNumber*)messageId {
    MessageDAO *messageDAO = (MessageDAO*)[[DAOFactory factory] newDAO:MessageDAO.class];
    return [messageDAO findMessageByMessageId:messageId];
}

+ (void)deleteMessageByMessageId:(NSNumber*)messageId {
    MessageDAO *messageDAO = (MessageDAO*)[[DAOFactory factory] newDAO:MessageDAO.class];
    Message *message = [messageDAO findMessageByMessageId:messageId];
    
    if (message) {
        [messageDAO deleteObject:message];
    }
}


+ (void)deleteMessageAndAllModificationsByMessageId:(NSNumber*)messageId {
    [ModificationDAO deleteModificationsMessageId:messageId forOperation:nil];
    [MessageDAO deleteMessageByMessageId:messageId];
}

- (NSMutableArray*)searchMessages:(NSString*)query folderId:(NSNumber*)folderId {
    NSString *trimmedReplacement = [self cleanString:query];
    // DLog(@"trimmedReplacement %@",trimmedReplacement);
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    CDSearchCriteria *criteria = [CDSearchCriteria criteria];
    [criteria addOrder:[CDOrder descendingOrder:@"date"]];
    NSMutableArray *orPredicates = [NSMutableArray array];
    [criteria setDistinct:YES];
    CDFilterConjunction *conjunction = [CDFilterFactory conjuction];
    
    if ([folderId intValue] == 1) {
        [conjunction add:[CDFilterFactory equals:@"isFavor" value:[NSNumber numberWithBool:TRUE]]];
    } else if ([folderId intValue] == 9) {
        [conjunction add:[CDFilterFactory equals:@"isRead" value:[NSNumber numberWithBool:FALSE]]];
    } else {
        [conjunction add:[CDFilterFactory equals:FOLDER_ID value:folderId]];
    }
    
    [orPredicates addObject:[conjunction createPredicate]];
    
    CDFilterConjunction *conjuct= [CDFilterFactory conjuction];
    [conjuct add:[CDFilterFactory contains:SUBJECT value:trimmedReplacement caseSensitive:NO]];
    [orPredicates addObject:[conjuct createPredicate]];
    
    
    NSPredicate* compoudPredicate;
    
    if ([orPredicates count] > 1) {
        compoudPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:orPredicates];
    } else {
        compoudPredicate = [orPredicates objectAtIndex:0];
    }
    [criteria setPredicate:compoudPredicate];
    
     if ([[self findAll:criteria] count] > 0 ){
        messages = [[self findAll:criteria] mutableCopy];
    }
    
    [self searchMail:trimmedReplacement inFolderId:folderId addToArray:messages];
    NSMutableArray *noDuplicates = [[[NSSet setWithArray: messages] allObjects] mutableCopy];
    
    return [self sortArrayByDate:noDuplicates];
}

- (void)addMessageFromArray:(NSMutableArray*)tmpArray toAnother:(NSMutableArray*)arrayReturn {
    if ([tmpArray count] > 0 ){
        for (Message *message in tmpArray) {
            [arrayReturn addObject:message];
        }
    }
}

- (void)searchMail:(NSString *)query
        inFolderId:(NSNumber *)folderId
        addToArray:(NSMutableArray*)messages {
    CDSearchCriteria *criteria = [CDSearchCriteria criteria];
    [criteria addOrder:[CDOrder descendingOrder:@"date"]];
    [criteria setDistinct:YES];
    
    NSPredicate* compoudPredicate = [NSPredicate predicateWithFormat:@"emails.searchAttribute CONTAINS %@", query];
    [criteria setPredicate:compoudPredicate];
    NSMutableArray* returnArray = [[self findAll:criteria] mutableCopy];
    NSMutableArray* tmpArray = [[NSMutableArray alloc] init];
    for (Message *message in returnArray) {
        if ([message.folderId intValue] == [folderId intValue]){
            [tmpArray addObject:message];
        }
    }
    
    [self addMessageFromArray:tmpArray toAnother:messages];
}

- (NSMutableArray*)searchMessages2:(NSString*)query folderId:(NSNumber*)folderId {
    // NSLog(@"query : %@", query);
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SUBQUERY(emails, $x, $x.name CONTAINS %@ OR $x.address CONTAINS %@).@count > 0", query, query];
    NSLog(@"predicate : %@", predicate);
    
    [request setPredicate:predicate];
    NSLog(@"request : %@", request);
    NSError *error;
    NSLog(@"result : %@", [[[DAOFactory factory] managedObjectContext] executeFetchRequest:request
                                                                                     error:&error]);
    NSLog(@"error : %@", error);
    
    return [NSMutableArray array];
}

- (void)cleanMessages:(NSNumber*)folderId {
    DLog(@"FolderId %d",folderId.intValue);
    // DLog(@"SyncAndLaunchModification ");
    NSMutableArray *Messages = [self findMessagesByFolderId:folderId];
    DLog(@"Messages.count %d", Messages.count);
    if (Messages.count > SEARCH_MESSAGES_LIMIT) {
        for (int i = SEARCH_MESSAGES_LIMIT; i < Messages.count; i++) {
            Message *msg = [Messages objectAtIndex:i];
            [self deleteObject:msg];
        }
    }
}

- (NSString*)cleanString:(NSString*)string {
    NSMutableCharacterSet *allowedChars = [[NSCharacterSet alphanumericCharacterSet] mutableCopy];
    [allowedChars addCharactersInString:@"àáâãäåòóôõöøèéêëçìíîïùúûüÿñ"];
    NSCharacterSet *charactersToRemove = [allowedChars invertedSet];
    NSString *trimmedReplacement =[[string componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@" "];
    return trimmedReplacement;
}

- (NSMutableArray*)sortArrayByDate:(NSMutableArray*)array {
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSArray *sortedArray = [NSArray arrayWithObject: descriptor];
    [array sortUsingDescriptors:sortedArray];
    return  array;
}

@end
