//
//  SearchInput.m
//  MSSante
//
//  Created by Labinnovation on 23/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "SearchMessagesInput.h"

@implementation SearchMessagesInput

@synthesize after, answered, before, cc, content, deleted, draft, flagged, folderId, from;
@synthesize html, includeSubfolders, isSent, larger, limit, offset, query;
@synthesize searchCriteria, seen, smaller, sortBy, subject, to;

- (id)init {
    self = [super init];
    searchCriteria = [NSMutableDictionary dictionary];
    query = [NSMutableDictionary dictionary];
    [input setObject:searchCriteria forKey:SEARCH_CRITERIA];
    return self;
}

- (NSDictionary*)generate {
    if (html != nil) {[searchCriteria setObject:html forKey:HTML];}
    if (limit != nil) {[searchCriteria setObject:limit forKey:LIMIT];}
    if (offset != nil) {[searchCriteria setObject:offset forKey:OFFSET];}
    if (sortBy != nil) {[searchCriteria setObject:sortBy forKey:SORT_BY];}
    if ([after length] > 0) {[query setObject:after forKey:Q_AFTER];}
    if (answered != nil) {[query setObject:answered forKey:Q_ANSWERED];}
    if ([before length] > 0) {[query setObject:before forKey:Q_BEFORE];}
    if ([cc length] > 0) {[query setObject:cc forKey:Q_CC];}
    if ([content length] > 0) {[query setObject:content forKey:Q_CONTENT];}
    if (deleted != nil) {[query setObject:deleted forKey:Q_DELETED];}
    if (draft != nil) {[query setObject:draft forKey:Q_DRAFT];}
    if (flagged != nil) {[query setObject:flagged forKey:Q_FLAGGED];}
    if (folderId != nil) {[query setObject:folderId forKey:Q_FOLDER_ID];}
    if ([from length] > 0) {[query setObject:from forKey:Q_FROM];}
    if (includeSubfolders != nil) {[query setObject:includeSubfolders forKey:Q_INCLUDE_SUB_FOLDERS];}
    if (isSent != nil) {[query setObject:isSent forKey:Q_IS_SENT];}
    if (larger != nil) {[query setObject:larger forKey:Q_LARGER];}
    if (seen != nil) {[query setObject:seen forKey:Q_SEEN];}
    if (smaller != nil) {[query setObject:smaller forKey:Q_SMALLER];}
    if ([subject length] > 0) {[query setObject:subject forKey:Q_SUBJECT];}
    if ([to length] > 0) {[query setObject:to forKey:Q_TO];}
    if ([query count] > 0) {[searchCriteria setObject:query forKey:QUERY];}
    return [NSDictionary dictionaryWithObject:input forKey:SEARCH_MESSAGES_INPUT];
}

@end
