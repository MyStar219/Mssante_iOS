//
//  SearchInput.h
//  MSSante
//
//  Created by Labinnovation on 23/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Input.h"

@interface SearchMessagesInput : Input {
    NSMutableDictionary *searchCriteria;
    NSNumber *html;
    NSNumber *limit;
    NSNumber *offset;
    NSString *sortBy;
    NSMutableDictionary *query;
    NSString *after;
    NSNumber *answered;
    NSString *before;
    NSString *cc;
    NSString *content;
    NSNumber *deleted;
    NSNumber *draft;
    NSNumber *flagged;
    NSNumber *folderId;
    NSString *from;
    NSNumber *includeSubfolders;
    NSNumber *isSent;
    NSNumber *larger;
    NSNumber *seen;
    NSNumber *smaller;
    NSString *subject;
    NSString *to;
}

@property(nonatomic, strong) NSMutableDictionary *searchCriteria;
@property(nonatomic, strong) NSNumber *html;
@property(nonatomic, strong) NSNumber *limit;
@property(nonatomic, strong) NSNumber *offset;
@property(nonatomic, strong) NSString *sortBy;
@property(nonatomic, strong) NSMutableDictionary *query;
@property(nonatomic, strong) NSString *after;
@property(nonatomic, strong) NSNumber *answered;
@property(nonatomic, strong) NSString *before;
@property(nonatomic, strong) NSString *cc;
@property(nonatomic, strong) NSString *content;
@property(nonatomic, strong) NSNumber *deleted;
@property(nonatomic, strong) NSNumber *draft;
@property(nonatomic, strong) NSNumber *flagged;
@property(nonatomic, strong) NSNumber *folderId;
@property(nonatomic, strong) NSString *from;
@property(nonatomic, strong) NSNumber *includeSubfolders;
@property(nonatomic, strong) NSNumber *isSent;
@property(nonatomic, strong) NSNumber *larger;
@property(nonatomic, strong) NSNumber *seen;
@property(nonatomic, strong) NSNumber *smaller;
@property(nonatomic, strong) NSString *subject;
@property(nonatomic, strong) NSString *to;

@end
