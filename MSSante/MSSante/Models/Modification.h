//
//  Modification.h
//  MSSante
//
//  Created by Labinnovation on 03/10/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Modification : NSManagedObject

@property (nonatomic, retain) id argument;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * messageId;
@property (nonatomic, retain) NSString * operation;

@end
