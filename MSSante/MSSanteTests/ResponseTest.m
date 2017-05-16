//
//  ResponseTest.m
//  MSSante
//
//  Created by Labinnovation on 16/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "ResponseTest.h"
#import "Response.h"
#import "Email.h"
#import "Attachment.h"
#import "Message.h"
#import "DAOFactory.h"

@implementation ResponseTest {
    NSMutableSet *emailsSet;
    NSMutableArray *emailsArray;
    id emailOne;
    id emailTwo;
    id emailThree;
    
    NSMutableSet *attachmentsSet;
    NSMutableArray *attachmentsArray;
    id attachmentOne;
    id attachmentTwo;
    id attachmentThree;
    
    NSString *unreadFlag;
    NSString *urgentFlag;
    NSString *attachmentFlag;
    NSString *flaggedFlag;
    NSArray *flagsArrayWithOneFlag;
    NSArray *flagsArrayWithManyFlag;
    
    Message *msg;
    Response *res;
    
    NSNumberFormatter * numformatter;
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
    
    attachmentsArray = [[NSMutableArray alloc] initWithObjects:attachmentOne,attachmentTwo,attachmentThree, nil];
    
    // init flags
    unreadFlag = @"UNREAD";
    urgentFlag = @"URGENT";
    attachmentFlag = @"ATTACHEMENT";
    flaggedFlag = @"FLAGGED";
    
    flagsArrayWithOneFlag = [[NSArray alloc] initWithObjects:urgentFlag, nil];
    flagsArrayWithManyFlag = [[NSArray alloc] initWithObjects:unreadFlag,urgentFlag,attachmentFlag,flaggedFlag, nil];
    
    
    msg = [NSEntityDescription insertNewObjectForEntityForName: @"Message" inManagedObjectContext: [[DAOFactory factory] managedObjectContext]];
    
    res = [[Response alloc] init];
    
    numformatter = [[NSNumberFormatter alloc] init];
    [numformatter setNumberStyle:NSNumberFormatterDecimalStyle];
}

- (void)tearDown {
    // Tear-down code here.
    [super tearDown];
}

- (void)testResponseInitWithJsonObject {
    id jsonObject = nil;
    res = [[Response alloc] initWithJsonObject:jsonObject];
    STAssertNotNil(res, @"Impossible d'initialiser response");
    STAssertEqualObjects(nil, res.jsonObject, @"Impossible d'initialiser response");
    
    jsonObject = [NSMutableDictionary dictionary];
    res = [[Response alloc] initWithJsonObject:jsonObject];
    STAssertNotNil(res, @"Impossible d'initialiser response");
    STAssertEqualObjects(jsonObject, res.jsonObject, @"Impossible d'initialiser response");
}

- (void)testResponseInitWithJsonString {
    NSString *json;
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    NSMutableDictionary *childObject = [NSMutableDictionary dictionary];
    NSMutableDictionary *anotherChildObject = [NSMutableDictionary dictionary];
    
    json = [self jsonStringFromDictionary:jsonObject];
    res = [[Response alloc] initWithJsonString:json];
    STAssertNotNil(res, @"Impossible d'initialiser response avec nil jsonObject");
    STAssertEqualObjects(jsonObject, res.jsonObject, @"Impossible d'initialiser response");
    
    [jsonObject setValue:childObject forKey:@"child"];
    [jsonObject setValue:@"value10" forKey:@"param10"];
    [childObject setValue:anotherChildObject forKey:@"anotherChild"];
    [childObject setValue:@"value11" forKey:@"param11"];
    [anotherChildObject setValue:@"value1" forKey:@"param1"];
    [anotherChildObject setValue:@"value1" forKey:@"param1"];
    
    json = [self jsonStringFromDictionary:jsonObject];
    
    res = [[Response alloc] initWithJsonString:json];
    STAssertNotNil(res, @"Impossible d'initialiser response avec jsonObject vide");
    STAssertEqualObjects(jsonObject, res.jsonObject, @"Impossible d'initialiser response");
}

- (NSString*)jsonStringFromDictionary:(NSDictionary*)jsonObject {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (!error) {
        return jsonString;
    } else {
        return nil;
    }
}

- (void)testParseEmail {
    id emailObject = [NSMutableDictionary dictionary];
    
    Email *email = [res parseEmail:emailObject];
    STAssertNotNil(email, @"Impossible de parser un object vide Email");
    
    NSString *emailAddress = nil;
    [emailObject setValue:emailAddress forKey:E_ADDRESS];
    email = [res parseEmail:emailObject];
    STAssertEqualObjects(@"", email.address, @"Impossible de parser une Address null");
    
    //    emailAddress = @"";
    //    [emailObject setValue:emailAddress forKey:E_ADDRESS];
    //    email = [res parseEmail:emailObject];
    //    STAssertEqualObjects(emailAddress, email.address, @"Impossible de parser empty address");
    //
    emailAddress = @"test@mssante.fr";
    [emailObject setValue:emailAddress forKey:E_ADDRESS];
    email = [res parseEmail:emailObject];
    STAssertEqualObjects(emailAddress, email.address, @"Impossible de parser une Address de type string");
    
    NSString *name = nil;
    [emailObject setValue:name forKey:E_NAME];
    email = [res parseEmail:emailObject];
    STAssertEqualObjects(@"", email.name, @"Impossible de parser Name null");
    
    //    name = @"";
    //    [emailObject setValue:name forKey:E_NAME];
    //    email = [res parseEmail:emailObject];
    //    STAssertEqualObjects(name, email.name, @"Impossible de parser empty name");
    
    name = @"test";
    [emailObject setValue:name forKey:E_NAME];
    email = [res parseEmail:emailObject];
    STAssertEqualObjects(name, email.name, @"Impossible de parser Name");
    
    
    NSString *type = nil;
    [emailObject setValue:type forKey:E_TYPE];
    email = [res parseEmail:emailObject];
    STAssertEqualObjects(@"" , email.type, @"Impossible de parser Type");
    
    //    type = @"";
    //    [emailObject setValue:type forKey:E_TYPE];
    //    email = [res parseEmail:emailObject];
    //    STAssertEqualObjects(type, email.type, @"Impossible de parser empty type");
    
    type = E_FROM;
    [emailObject setValue:type forKey:E_TYPE];
    email = [res parseEmail:emailObject];
    STAssertEqualObjects(type, email.type, @"Impossible de parser type");
}


- (void)testParseAttachment {
    
    id attachmentObj = [NSMutableDictionary dictionary];
    Attachment *attach = nil;
    attach = [res parseAttachment:attachmentObj];
    STAssertNotNil(attach, @"Impossible de parser objet attachment");
    
    NSNumber * part = [[NSNumber alloc] init];
    [attachmentObj setValue:part forKey:A_PART];
    attach = [res parseAttachment:attachmentObj];
    STAssertEquals(part, attach.part, @"Impossible de parser part (vide)");
    
    part = [NSNumber numberWithInt:1];
    [attachmentObj setValue:part forKey:A_PART];
    attach = [res parseAttachment:attachmentObj];
    STAssertEquals(part, attach.part, @"Impossible de parser part (int)");
    
    NSString *stringPart = @"1";
    [attachmentObj setValue:stringPart forKey:A_PART];
    attach = [res parseAttachment:attachmentObj];
    STAssertEquals([numformatter numberFromString:stringPart], attach.part, @"Impossible de parser number (string)");
    
    NSString *contentType = nil;
    [attachmentObj setValue:contentType forKey:A_CONTENT_TYPE];
    attach = [res parseAttachment:attachmentObj];
    STAssertEqualObjects(@"", attach.contentType, @"Impossible de parser contentType (null)");
    
    //    contentType = @"";
    //    [attachmentObj setValue:contentType forKey:A_CONTENT_TYPE];
    //    attach = [res parseAttachment:attachmentObj];
    //    STAssertEquals(contentType, attach.contentType, @"Impossible de parser empty content-type");
    
    contentType = @"test";
    [attachmentObj setValue:contentType forKey:A_CONTENT_TYPE];
    attach = [res parseAttachment:attachmentObj];
    STAssertEquals(contentType, attach.contentType, @"Impossible de parser contentType (string)");
    
    NSString *filename = nil;
    [attachmentObj setValue:filename forKey:A_FILENAME];
    attach = [res parseAttachment:attachmentObj];
    STAssertEquals(@"", attach.fileName, @"Impossible de parser filename (null)");
    
    //    filename = @"";
    //    [attachmentObj setValue:filename forKey:A_FILENAME];
    //    attach = [res parseAttachment:attachmentObj];
    //    STAssertEquals(filename, attach.fileName, @"Impossible de parser empty filename");
    
    filename = @"test";
    [attachmentObj setValue:filename forKey:A_FILENAME];
    attach = [res parseAttachment:attachmentObj];
    STAssertEquals(filename, attach.fileName, @"Impossible de parser filename (string)");
    
    
    NSNumber *size = [[NSNumber alloc] init];
    [attachmentObj setValue:size forKey:SIZE];
    attach = [res parseAttachment:attachmentObj];
    STAssertEquals(size, attach.size, @"Impossible de parser size (vide)");
    
    size = [NSNumber numberWithInt:12345];
    [attachmentObj setValue:size forKey:SIZE];
    attach = [res parseAttachment:attachmentObj];
    STAssertEquals([size intValue], [attach.size intValue], @"Impossible de parser size (int)");
    
    NSString *stringSize = @"12345";
    [attachmentObj setValue:stringSize forKey:SIZE];
    attach = [res parseAttachment:attachmentObj];
    STAssertEquals([[numformatter numberFromString:stringSize] intValue], [attach.size intValue], @"Impossible de parser size (string)");
}


- (void)testParseMessage {
    id messageObj = nil;
    msg = [res parseMessage:messageObj];
    STAssertNil(msg, @"Impossible de parser objet message (vide)");
    
    messageObj = [NSMutableDictionary dictionary];

    //Testing MessageId
    NSNumber * msgId = [[NSNumber alloc] init];
    [messageObj setValue:msgId forKey:MESSAGE_ID];
    msg = [res parseMessage:messageObj];
    STAssertEquals(msgId, msg.messageId, @"Impossible de parser messageId");
    
    msgId = [NSNumber numberWithInt:123];
    [messageObj setValue:msgId forKey:MESSAGE_ID];
    msg = [res parseMessage:messageObj];
    STAssertEquals([msgId intValue], [msg.messageId intValue], @"Impossible de parser MessageId");
    
    //Testing ConversationId
    NSNumber * convId = [[NSNumber alloc] init];
    [messageObj setValue:convId forKey:CONVERSATION_ID];
    msg = [res parseMessage:messageObj];
    STAssertEquals(convId, msg.conversationId, @"Impossible de parser ConversationId");
    
    convId = [NSNumber numberWithInt:1];
    [messageObj setValue:convId forKey:CONVERSATION_ID];
    msg = [res parseMessage:messageObj];
    STAssertEquals(convId, msg.conversationId, @"Impossible de parser ConversationId");
    
    //Testing FolderId
    NSNumber * folderId = [[NSNumber alloc] init];
    [messageObj setValue:folderId forKey:FOLDER_ID];
    msg = [res parseMessage:messageObj];
    STAssertEquals(folderId, msg.folderId, @"Impossible de parser FolderId");
    
    folderId = [NSNumber numberWithInt:1];
    [messageObj setValue:folderId forKey:FOLDER_ID];
    msg = [res parseMessage:messageObj];
    STAssertEquals(folderId, msg.folderId, @"Impossible de parser FolderId");
    
    //Testing Size
    NSNumber * size = [[NSNumber alloc] init];
    [messageObj setValue:size forKey:SIZE];
    msg = [res parseMessage:messageObj];
    STAssertEquals(size, msg.size, @"Impossible de parser size");
    
    size = [NSNumber numberWithInt:5355];
    [messageObj setValue:size forKey:SIZE];
    msg = [res parseMessage:messageObj];
    STAssertEquals([size intValue], [msg.size intValue], @"Impossible de parser size");
    
    //Testing Date
    NSNumber * date = [[NSNumber alloc] init];
    [messageObj setValue:date forKey:DATE];
    msg = [res parseMessage:messageObj];
    STAssertEquals(date, msg.date, @"Impossible de parser date");
    
    date = [NSNumber numberWithInt:5358785];
    [messageObj setValue:date forKey:DATE];
    msg = [res parseMessage:messageObj];
    STAssertEquals([date intValue], [msg.date intValue], @"Impossible de parser date");
    
    NSString *strDate = @"213457";
    [messageObj setValue:strDate forKey:DATE];
    msg = [res parseMessage:messageObj];
    STAssertEquals(strDate, msg.date, @"Impossible de parser date");
    
    //Testing Subject
    NSString *subject = nil;
    [messageObj setValue:subject forKey:SUBJECT];
    msg = [res parseMessage:messageObj];
    STAssertEquals(@"", msg.subject, @"Impossible de parser subject");
    
    //    subject = @"";
    //    [messageObj setValue:subject forKey:SUBJECT];
    //    msg = [res parseMessage:messageObj];
    //    STAssertEquals(subject, msg.subject, @"Impossible de parser subject");
    
    subject = @"Test Subject";
    [messageObj setValue:subject forKey:SUBJECT];
    msg = [res parseMessage:messageObj];
    STAssertEquals(subject, msg.subject, @"Impossible de parser subject");
    
    //Testing Body
    NSString *body = nil;
    [messageObj setValue:body forKey:BODY];
    msg = [res parseMessage:messageObj];
    STAssertEquals(@"", msg.body, @"Impossible de parser body");
    
    //    body = @"";
    //    [messageObj setValue:body forKey:BODY];
    //    msg = [res parseMessage:messageObj];
    //    STAssertEquals(body, msg.body, @"Impossible de parser body");
    
    body = @"Test Body";
    [messageObj setValue:body forKey:BODY];
    msg = [res parseMessage:messageObj];
    STAssertEquals(body, msg.body, @"Impossible de parser body");
    
    //Testing Emails
    NSMutableArray *emails = [NSMutableArray array];
    [messageObj setValue:emails forKey:EMAILS];
    msg = [res parseMessage:messageObj];
    STAssertEquals([emails count], [msg.emails count], @"Impossible de parser emails");
    
    [messageObj setValue:emailOne forKey:EMAILS];
    msg = [res parseMessage:messageObj];
    STAssertEquals((NSUInteger)1, [msg.emails count], @"Impossible de parser emails");
    
    [messageObj setValue:emailsArray forKey:EMAILS];
    msg = [res parseMessage:messageObj];
    STAssertEquals([emailsArray count], [msg.emails count], @"Impossible de parser emails");
    
    
    //Testing Attachments
    NSMutableArray *attachments = [NSMutableArray array];
    [messageObj setValue:attachments forKey:ATTACHMENTS];
    msg = [res parseMessage:messageObj];
    STAssertEquals([attachments count], [msg.attachments count], @"Impossible de parser attachments");
    
    [messageObj setValue:attachmentOne forKey:ATTACHMENTS];
    msg = [res parseMessage:messageObj];
    STAssertEquals((NSUInteger)1, [msg.attachments count], @"Impossible de parser attachments");
    
    [messageObj setValue:attachmentsArray forKey:ATTACHMENTS];
    msg = [res parseMessage:messageObj];
    STAssertEquals([attachmentsArray count], [msg.attachments count], @"Impossible de parser attachments");
}

- (void)testParseFlag {
    msg = [NSEntityDescription insertNewObjectForEntityForName: @"Message" inManagedObjectContext: [[DAOFactory factory] managedObjectContext]];
    
    [res parseFlag:unreadFlag msgObject:msg];
    STAssertFalse([msg.isRead boolValue], @"Impossible d'initialiser read flag");
    
    [res parseFlag:urgentFlag msgObject:msg];
    STAssertTrue([msg.isUrgent boolValue], @"Impossible d'initialiser urgent flag");
    
    [res parseFlag:attachmentFlag msgObject:msg];
    STAssertTrue([msg.isAttachment boolValue], @"Impossible d'initialiser attachment flag");
    
    [res parseFlag:flaggedFlag msgObject:msg];
    STAssertTrue([msg.isFavor boolValue], @"Impossible d'initialiser flagged flag");
}

- (void)testParseFlags {
    msg = [NSEntityDescription insertNewObjectForEntityForName: @"Message" inManagedObjectContext: [[DAOFactory factory] managedObjectContext]];
    
    [res parseFlags:unreadFlag msgObject:msg];
    STAssertFalse([msg.isRead boolValue], @"Impossible de parser un flag (string)");
    
    [res parseFlags:flagsArrayWithOneFlag msgObject:msg];
    STAssertTrue([msg.isUrgent boolValue], @"Impossible de parser une tableau qui contient un seul flag");
    
    [res parseFlags:flagsArrayWithManyFlag msgObject:msg];
    STAssertTrue(([msg.isAttachment boolValue] && [msg.isFavor boolValue] && [msg.isUrgent boolValue] && ![msg.isRead boolValue]) , @"Failed to parse array of flags");
}

- (void)testParseEmails {
    emailsSet = [res parseEmails:emailsArray];
    STAssertEquals([emailsArray count], [emailsSet count], @"Impossible de parser une tableau d'emails");
    
    emailsSet = [res parseEmails:emailOne];
    STAssertEquals((NSUInteger)1, [emailsSet count], @"Impossible de parser un seul email");
    
    emailsSet = [res parseEmails:nil];
    STAssertEquals((NSUInteger)0, [emailsSet count], @"Impossible de parser objet nil");
}

- (void)testParseAttachments {
    attachmentsSet = [res parseAttachments:attachmentsArray];
    STAssertEquals([attachmentsArray count], [attachmentsSet count], @"Impossible de parser une tableau d'attachments");
    
    attachmentsSet = [res parseAttachments:attachmentThree];
    STAssertEquals((NSUInteger)1, [attachmentsSet count], @"Impossible de parser un attachment");
    
    attachmentsSet = [res parseAttachments:nil];
    STAssertEquals((NSUInteger)0, [attachmentsSet count], @"Impossible de parser objet nil");
}


- (void)testParseError {
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    NSString *errorMsg = NSLocalizedString(@"AUTHENTIFICATION_IMPOSSIBLE", "Authentification impossible, veuillez réessayer");
    NSNumber *errorCode = [NSNumber numberWithInt:ERROR_PUSH_TIMEOUT];
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    
    NSError *_error = [NSError errorWithDomain:appDomain code:1000 userInfo:details];
    Error *error = [Response parseError:_error httpStatusCode:0];
    STAssertNotNil(error, @"Could not initialize error");
    STAssertEqualObjects(NSLocalizedString(@"ERREUR", "Erreur"), error.errorMsg, @"Impossible de parser errorMessage");
    STAssertEquals(0, error.errorCode, @"Impossible de parser error code");

        
    NSMutableDictionary* errorObject = [NSMutableDictionary dictionary];
    [errorObject setValue:errorMsg forKey:ERROR_MSG];
    [errorObject setValue:errorCode forKey:ERROR_CODE];
    NSString *jsonString = [self jsonStringFromDictionary:errorObject];
    [details setValue:jsonString forKey:NSLocalizedRecoverySuggestionErrorKey];
    
    _error = [NSError errorWithDomain:appDomain code:1000 userInfo:details];
    error = [Response parseError:_error httpStatusCode:0];
    STAssertNotNil(error, @"Could not initialize error");
    STAssertEqualObjects(errorMsg, error.errorMsg, @"Impossible de parser errorMessage");
    STAssertEquals([errorCode intValue], error.errorCode, @"Impossible de parser errorCode");
}


@end
