//
//  SearchResponseTest.m
//  MSSante
//
//  Created by Labinnovation on 17/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "SearchResponseTest.h"
#import "Response.h"
#import "SearchMessagesResponse.h"
#import "Email.h"
#import "Attachment.h"
#import "Message.h"
#import "DAOFactory.h"

@implementation SearchResponseTest {
    NSMutableSet *emailsSet;
    NSMutableArray *emailsArray;
    
    NSMutableDictionary *emailOne;
    NSMutableDictionary *emailTwo;
    NSMutableDictionary *emailThree;
    
    NSMutableSet *attachmentsSet;
    NSArray *attachmentsArray;
    
    NSMutableDictionary *attachmentOne;
    NSMutableDictionary *attachmentTwo;
    NSMutableDictionary *attachmentThree;
    
    NSString *unreadFlag;
    NSString *urgentFlag;
    NSString *attachmentFlag;
    NSString *flaggedFlag;
    NSArray *flagsArrayWithOneFlag;
    NSArray *flagsArrayWithManyFlags;
    
    SearchMessagesResponse *searchResponse;
    
    NSArray *messagesArray;
    NSArray *messages;
    
    NSMutableDictionary *searchObj;
    NSMutableDictionary *messageOne;
    NSMutableDictionary *messageTwo;
    NSMutableDictionary *messageThree;
    NSDictionary *searchOutputEmpty;
    NSDictionary *searchOutputOneMessage;
    NSDictionary *searchOutputManyMessages;
    
    
}

- (void)setUp {
    [super setUp];
    
    
    // init emails
    emailsSet = nil;
    
    emailOne = [NSMutableDictionary dictionary];
    emailTwo = [NSMutableDictionary dictionary];
    emailThree  = [NSMutableDictionary dictionary];
    
    [emailOne setValue:@"ismail@mssante.fr" forKey:E_ADDRESS];
    [emailOne setValue:@"Ismail ALMETWALLY" forKey:E_NAME];
    [emailOne setValue:E_FROM forKey:E_TYPE];
    
    [emailTwo setValue:@"chenri@mssante.fr" forKey:E_ADDRESS];
    [emailTwo setValue:@"Henri" forKey:E_NAME];
    [emailTwo setValue:E_TO forKey:E_TYPE];
    
    [emailThree setValue:@"charles.henri@mssante.fr" forKey:E_ADDRESS];
    [emailThree setValue:@"Charles Henri" forKey:E_NAME];
    [emailThree setValue:E_CC forKey:E_TYPE];
    
    emailsArray = [[NSMutableArray alloc] initWithObjects:emailOne,emailTwo,emailThree, nil];
    
    // init attachments
    attachmentsSet = nil;
    
    attachmentOne = [NSMutableDictionary dictionary];
    attachmentTwo = [NSMutableDictionary dictionary];
    attachmentThree  = [NSMutableDictionary dictionary];
    
    [attachmentOne setValue:[NSNumber numberWithInt:1] forKey:A_PART];
    [attachmentOne setValue:@"application/pdf" forKey:A_CONTENT_TYPE];
    [attachmentOne setValue:@"text.pdf" forKey:A_FILENAME];
    [attachmentOne setValue:[NSNumber numberWithInt:1234] forKey:SIZE];
    
    [attachmentTwo setValue:[NSNumber numberWithInt:2] forKey:A_PART];
    [attachmentTwo setValue:@"application/pdf" forKey:A_CONTENT_TYPE];
    [attachmentTwo setValue:@"text.pdf" forKey:A_FILENAME];
    [attachmentTwo setValue:[NSNumber numberWithInt:1234] forKey:SIZE];
    
    [attachmentThree setValue:[NSNumber numberWithInt:3] forKey:A_PART];
    [attachmentThree setValue:@"application/pdf" forKey:A_CONTENT_TYPE];
    [attachmentThree setValue:@"text.pdf" forKey:A_FILENAME];
    [attachmentThree setValue:[NSNumber numberWithInt:1234] forKey:SIZE];
    
    attachmentsArray = [[NSArray alloc] initWithObjects:attachmentOne,attachmentTwo,attachmentThree, nil];
    
    // init flags
    unreadFlag = @"UNREAD";
    urgentFlag = @"URGENT";
    attachmentFlag = @"ATTACHEMENT";
    flaggedFlag = @"FLAGGED";
    
    flagsArrayWithOneFlag = [[NSArray alloc] initWithObjects:urgentFlag, nil];
    flagsArrayWithManyFlags = [[NSArray alloc] initWithObjects:unreadFlag,urgentFlag,attachmentFlag,flaggedFlag, nil];

    // init messages
    messageOne = [NSMutableDictionary dictionary];
    messageTwo = [NSMutableDictionary dictionary];
    messageThree = [NSMutableDictionary dictionary];
    
    [messageOne setValue:[NSNumber numberWithInt:111] forKey:MESSAGE_ID];
    [messageOne setValue:[NSNumber numberWithInt:222] forKey:CONVERSATION_ID];
    [messageOne setValue:[NSNumber numberWithInt:333] forKey:FOLDER_ID];
    [messageOne setValue:@"17072013" forKey:DATE];
    [messageOne setValue:[NSNumber numberWithInt:1784758] forKey:SIZE];
    [messageOne setValue:flagsArrayWithManyFlags forKey:FLAGS];
    [messageOne setValue:@"Message One Subject" forKey:SUBJECT];
    [messageOne setValue:@"Message One Body" forKey:BODY];
    [messageOne setValue:emailsArray forKey:EMAILS];
    [messageOne setValue:attachmentsArray forKey:ATTACHMENTS];
    
    [messageTwo setValue:[NSNumber numberWithInt:222] forKey:MESSAGE_ID];
    [messageTwo setValue:[NSNumber numberWithInt:333] forKey:CONVERSATION_ID];
    [messageTwo setValue:[NSNumber numberWithInt:444] forKey:FOLDER_ID];
    [messageTwo setValue:@"17072013" forKey:DATE];
    [messageTwo setValue:[NSNumber numberWithInt:1784758] forKey:SIZE];
    [messageTwo setValue:unreadFlag forKey:FLAGS];
    [messageTwo setValue:@"Message Two Subject" forKey:SUBJECT];
    [messageTwo setValue:@"Message Two Body" forKey:BODY];
    [messageTwo setValue:emailsArray forKey:EMAILS];
    
    [messageThree setValue:[NSNumber numberWithInt:333] forKey:MESSAGE_ID];
    [messageThree setValue:[NSNumber numberWithInt:444] forKey:CONVERSATION_ID];
    [messageThree setValue:[NSNumber numberWithInt:555] forKey:FOLDER_ID];
    [messageThree setValue:@"17072013" forKey:DATE];
    [messageThree setValue:[NSNumber numberWithInt:1784758] forKey:SIZE];
    [messageThree setValue:@"Message Three Subject" forKey:SUBJECT];
    [messageThree setValue:@"Message Three Body" forKey:BODY];
    [messageThree setValue:emailOne forKey:EMAILS];
    [messageThree setValue:attachmentThree forKey:ATTACHMENTS];
    
    messagesArray = [[NSArray alloc] initWithObjects:messageOne,messageTwo,messageThree, nil];
    
    searchObj = [NSMutableDictionary dictionary];
    searchOutputEmpty = [NSDictionary dictionary];
    searchOutputOneMessage = [[NSDictionary alloc] initWithObjectsAndKeys:messageThree, MESSAGES, nil];
    searchOutputManyMessages = [[NSDictionary alloc] initWithObjectsAndKeys:messagesArray, MESSAGES, nil];
}

- (void)tearDown {
    // Tear-down code here. 
    [super tearDown];
}

- (void)testParseJSONObject {
    
    [searchObj setValue:nil forKey:SEARCH_MESSAGES_OUTPUT];
    searchResponse = [[SearchMessagesResponse alloc] initWithJsonObject:searchObj];
    searchResponse.saveToDB=NO;
    messages = [searchResponse parseJSONObject];
    STAssertEquals((NSUInteger)0, [messages count], @"Impossible de parser null searchOutput");
    
    [searchObj setValue:searchOutputEmpty forKey:SEARCH_MESSAGES_OUTPUT];
    searchResponse = [[SearchMessagesResponse alloc] initWithJsonObject:searchObj];
    searchResponse.saveToDB=NO;
    messages = [searchResponse parseJSONObject];
    STAssertEquals((NSUInteger)0, [messages count], @"Impossible de parser vide searchOutput");
    
    
    [searchObj setValue:searchOutputOneMessage forKey:SEARCH_MESSAGES_OUTPUT];
    searchResponse = [[SearchMessagesResponse alloc] initWithJsonObject:searchObj];
    searchResponse.saveToDB=NO;
    messages = [searchResponse parseJSONObject];
    STAssertEquals((NSUInteger)1, [messages count], @"Impossible de parser searchOutput qui contient un seul messqge message");
    
    
    [searchObj setValue:searchOutputManyMessages forKey:SEARCH_MESSAGES_OUTPUT];
    searchResponse = [[SearchMessagesResponse alloc] initWithJsonObject:searchObj];
    searchResponse.saveToDB=NO;
    messages = [searchResponse parseJSONObject];
    STAssertEquals([messagesArray count], [messages count], @"Impossible de parser searchOutput qui contient plusiers messages");
}
@end
