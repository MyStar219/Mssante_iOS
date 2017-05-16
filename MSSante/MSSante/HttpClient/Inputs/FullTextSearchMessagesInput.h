//
//  FullTextSearchMessagesInput.h
//  MSSante
//
//  Created by Labinnovation on 06/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "Input.h"
#import "SearchMessagesInput.h"

@interface FullTextSearchMessagesInput : SearchMessagesInput {
    NSString *searchString;
}

@property(nonatomic,strong)NSString *searchString;

@end
