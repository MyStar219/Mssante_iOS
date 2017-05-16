//
//  ListEmailsResponseTest.m
//  MSSante
//
//  Created by Labinnovation on 18/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "ListEmailsResponseTest.h"
#import "Constant.h"
#import "ListEmailsResponse.h"

@implementation ListEmailsResponseTest {
    NSMutableDictionary *listEmailsObj;
    NSMutableDictionary *listEmailsOutput;
    
    NSString *emailOne;
    NSString *emailTwo;
    NSString *emailThree;
    NSString *emailFour;
    NSArray *emailsArray;
    
    ListEmailsResponse *listEmailsResponse;
    
    NSArray *emails;
}

- (void)setUp {
    [super setUp];
    
    emailOne = @"test@mssanté.fr";
    emailTwo = @"test2@mssanté.fr";
    emailThree = @"test3@mssanté.fr";
    emailFour = @"test4@mssanté.fr";
    
    emailsArray = [[NSArray alloc] init];
    listEmailsObj = [NSMutableDictionary dictionary];
    listEmailsOutput = [NSMutableDictionary dictionary];
    
    
    
    listEmailsResponse = [[ListEmailsResponse alloc] initWithJsonObject:listEmailsObj];
}

- (void)tearDown {
    // Tear-down code here.
    [super tearDown];
}

- (void)testParseJSONObject {
    emails = [listEmailsResponse parseJSONObject];
    DLog(@"emails %@",emails);
    STAssertEquals((NSUInteger)0, [emails count], @"Impossible de parser null object");
    
    [listEmailsObj setValue:listEmailsOutput forKey:LIST_FOLDERS_OUTPUT];
    emails = [listEmailsResponse parseJSONObject];
    DLog(@"emails %@",emails);
    STAssertEquals((NSUInteger)0, [emails count], @"Impossible de parser null object");
    
    [listEmailsOutput setValue:nil forKey:EMAILS];
    emails = [listEmailsResponse parseJSONObject];
    DLog(@"emails %@",emails);
    STAssertEquals((NSUInteger)0, [emails count], @"Impossible de parser null object");
    
    [listEmailsOutput setValue:@"" forKey:EMAILS];
    emails = [listEmailsResponse parseJSONObject];
    DLog(@"emails %@",emails);
    STAssertEquals((NSUInteger)0, [emails count], @"Impossible de parser null object");
    
    [listEmailsOutput setValue:emailThree forKey:EMAILS];
    emails = [listEmailsResponse parseJSONObject];
    DLog(@"emails %@",emails);
    STAssertEquals((NSUInteger)1, [emails count], @"Impossible de parser un email");
    
    [listEmailsOutput setValue:emailsArray forKey:EMAILS];
    emails = [listEmailsResponse parseJSONObject];
    DLog(@"emails %@",emails);
    STAssertEquals([emailsArray count], [emails count], @"Impossible de parser une tableau d'emails vide");
    
    emailsArray = [[NSArray alloc] initWithObjects:emailOne,emailTwo,emailThree,emailFour, nil];
    [listEmailsOutput setValue:emailsArray forKey:EMAILS];
    emails = [listEmailsResponse parseJSONObject];
    DLog(@"emails %@",emails);
    STAssertEquals([emailsArray count], [emails count], @"Impossible de parser une tableau d'emails");
}

@end
