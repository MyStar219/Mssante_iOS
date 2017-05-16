//
//  FullTextSearchMessagesInput.m
//  MSSante
//
//  Created by Labinnovation on 06/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "FullTextSearchMessagesInput.h"

@implementation FullTextSearchMessagesInput

@synthesize searchString;

- (id)init {
    return [super init];
}

- (NSDictionary*)generate {
    if ([searchString length]>0) {[query setObject:searchString forKey:SEARCH_STRING];}
    if (html != nil) {[searchCriteria setObject:html forKey:HTML];}
    if (limit != nil) {[searchCriteria setObject:limit forKey:LIMIT];}
    if (offset != nil) {[searchCriteria setObject:offset forKey:OFFSET];}
    if ([after length] > 0) {[query setObject:after forKey:Q_AFTER];}
    if ([before length] > 0) {[query setObject:before forKey:Q_BEFORE];}
    if (folderId != nil) {[query setObject:folderId forKey:Q_FOLDER_ID];}
    if (includeSubfolders != nil) {[query setObject:includeSubfolders forKey:Q_INCLUDE_SUB_FOLDERS];}
    if ([query count] > 0) {[searchCriteria setObject:query forKey:QUERY];}
    return [NSDictionary dictionaryWithObject:input forKey:FULL_TEXT_SEARCH_MESSAGES_INPUT];
}

@end
