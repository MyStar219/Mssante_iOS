//
//  RequestTest.m
//  MSSante
//
//  Created by Labinnovation on 19/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "RequestTest.h"
#import "Request.h"
#import "AFHTTPRequestOperation.h"
#import "OCMock.h"

@implementation RequestTest {
    Request *request;
    NSString *service;
    NSMutableDictionary *params;
    NSMutableDictionary *headers;
    NSString *responseClassName;
    NSString *url;
    NSString *method;
    NSDictionary *tmpParams;
    NSDictionary *tmpHeaders;
    NSString *enregistrerCanalJson;
    NSString *listEmailsJson;
    NSString *searchJson;
    NSString *invalidJson;
    NSString *requestBody;
    NSDictionary *requestHeaders;
    NSString *acceptJsonPaosHeader;
    NSString *paosHeader;
    AFHTTPRequestOperation *operation;
    NSMutableDictionary *responseHeaders;
    int statusCode;
    id responseMock;
    id operationMock;
    int errorCode;
    id errorMock;
    NSString *nextUrl;
    NSString *wwwAuth;
    NSString *errorMsg;
    NSMutableDictionary* details;
    NSString *_errorMsg;
    NSNumber *_errorCode;
    NSString *appDomain;
    NSError *_error;
    NSString *MIMEType;
    id response;
    NSString *jSessionId;
    NSString *assertionConsumerServiceURL;
    NSString *authnRequest;
    
}

- (void)setUp {
    [super setUp];
    service = S_ANNUAIRE_LIST_EMAILS;
    url = [NSString stringWithFormat:@"%@%@%@",SERVER_MSS,ANNUAIRE_SERVICE,service];
    params = [NSMutableDictionary dictionary];
    headers = [NSMutableDictionary dictionary];
    method = nil;
    tmpParams = [NSDictionary dictionaryWithObjectsAndKeys:@"param1",@"key1",@"param2",@"key2", nil];
    tmpHeaders = [NSDictionary dictionaryWithObjectsAndKeys:@"header1",@"key1",@"header1",@"key2", nil];
    method = HTTP_POST;
    request = [[Request alloc] init];
    enregistrerCanalJson = @"{\"enregistrerCanalOutput\":{\"idCanal\":100007}}";
    listEmailsJson = @"{\"listEmailsOutput\":{\"emails\":[\"charles.henri@mssante.fr\",\"chenri@mssante.fr\",\"henri.charles@pro-mssante.fr\"]}}";
    searchJson = @"{\"searchOutput\": {\"messages\": [{\"body\": \"sqdqsd\",\"conversationId\": -266,\"date\": \"16/07/2013 09:09:17\",\"emails\": [{\"address\": \"jean.dupont@mssante.fr\",\"name\": \"Jean Dupont\",\"type\": \"FROM\"},{\"address\": \"jean.dupont@mssante.fr\",\"name\": \"jean dupont\",\"type\": \"TO\"},{\"address\": \"charles.henri@mssante.fr\",\"name\": \"charles henri\",\"type\": \"CC\"}],\"flags\": \"UNREAD\",\"folderId\": 2,\"messageId\": 266,\"size\": 1475,\"subject\": \"test avec cc\"},{\"body\": \"Je jure par Apollon\",\"conversationId\": 260,\"date\": \"10/07/2013 15:06:05\",\"emails\": [{\"address\": \"jean.dupont@mssante.fr\",\"name\": \"Jean Dupont\",\"type\": \"FROM\"},{\"address\": \"charles.henri@mssante.fr\",\"name\": \"charles henri\",\"type\": \"TO\"},{\"address\": \"henri.charles@pro-mssante.fr\",\"name\": \"henri charles\",\"type\": \"TO\"},{\"address\": \"chenri@mssante.fr\",\"type\": \"TO\"}],\"flags\": \"UNREAD\",\"folderId\": 2,\"messageId\": 265,\"size\": 3638,\"subject\": \"Serment d'Hippocrate\"},{\"body\": \"Je jure par Apollon\",\"conversationId\": 260,\"date\": \"10/07/2013 15:05:39\",\"emails\": [{\"address\": \"jean.dupont@mssante.fr\",\"name\": \"Jean Dupont\",\"type\": \"FROM\"},{\"address\": \"charles.henri@mssante.fr\",\"name\": \"charles henri\",\"type\": \"TO\"},{\"address\": \"henri.charles@pro-mssante.fr\",\"name\": \"henri charles\",\"type\": \"TO\"},{\"address\": \"chenri@mssante.fr\",\"type\": \"TO\"}],\"flags\": \"UNREAD\",\"folderId\": 2,\"messageId\": 264,\"size\": 3638,\"subject\": \"Serment d'Hippocrate\"},{\"body\": \"Je jure par Apollon, médecin, par Esculape, par Hygée et Panacée, par tous les dieux et toutes les déesses, les prenant à témoin que je remplirai, suivant mes forces et mes capacités, le serment et l'engagement suivants : je mettrai mon maître de médecine au même rang que les auteurs de mes jours, je partagerai avec lui mon avoir et, le cas échéant, je pourvoirai à ses besoins ; je tiendrai ses enfants pour des frères, et s'ils désirent apprendre la médecine, je la leur enseignerai sans salaire ni engagement. Je ferai part des préceptes, des leçons orales et du reste de l'enseignement à mes fils, à ceux de mon maître et aux disciples liés par engagement et un serment suivant la loi médicale, mais à nul autre.Je dirigerai le régime des malades à leur avantage, suivant mes forces et mon jugement, et je m'abstiendrai de tout mal et de toute injustice. Je ne remettrai à personne du poison, si on m'en demande, ni ne prendrai l'initiative d'une pareille suggestion; semblablement, je ne remettrai à aucune femme un pessaire abortif. Je passerai ma vie et j'exercerai mon art dans l'innocence et la pureté. Je ne pratiquerai pas l'opération de la taille, je la laisserai aux gens qui s'en occupent . Dans quelques maisons que je rentre, j'y entrerai pour l'utilité des malades, me préservant de tout méfait volontaire et corrupteur, et surtout de la séduction des femmes et des garçons, libres ou esclaves. Quoique je voie ou entende dans la société pendant l'exercice ou même hors de l'exercice de ma profession, je tairai ce qui n'a jamais besoin d'être divulgué, regardant la discrétion comme un devoir en pareil cas.Si je remplis ce serment sans l'enfreindre, qu'il me soit donné de jouir heureusement de la vie et de ma profession, hororé à jamais des hommes. Si je le viole et que je me parjure, puis-je avoir un sort contraire\",\"conversationId\": -263,\"date\": \"10/07/2013 12:46:22\",\"emails\": [{\"address\": \"jean.dupont@mssante.fr\",\"name\": \"Jean Dupont\",\"type\": \"FROM\"},{\"address\": \"charles.henri@mssante.fr\",\"name\": \"charles henri\",\"type\": \"TO\"}],\"flags\": [\"UNREAD\",\"URGENT\"],\"folderId\": 2,\"messageId\": 263,\"size\": 3693,\"subject\": \"Urgent\"},{\"body\": \"\",\"conversationId\": -262,\"date\": \"10/07/2013 12:45:24\",\"emails\": [{\"address\": \"jean.dupont@mssante.fr\",\"name\": \"Jean Dupont\",\"type\": \"FROM\"},{\"address\": \"charles.henri@mssante.fr\",\"name\": \"charles henri\",\"type\": \"TO\"}],\"flags\": [\"ATTACHEMENT\",\"UNREAD\"],\"folderId\": 2,\"messageId\": 262,\"size\": 22654,\"subject\": \"Voici le buste d'Hippocrate\"},{\"body\": \"Je jure par Apollon----- Mail original -----Envoyé: Mercredi 10 Juillet 2013 12:41:42Objet: Serment d'HippocrateJe jure par Apollon\",\"conversationId\": 260,\"date\": \"10/07/2013 12:42:17\",\"emails\": [{\"address\": \"jean.dupont@mssante.fr\",\"name\": \"Jean Dupont\",\"type\": \"FROM\"},{\"address\": \"charles.henri@mssante.fr\",\"name\": \"charles henri\",\"type\": \"TO\"},{\"address\": \"patrice.galou@mssante.fr\",\"name\": \"patrice galou\",\"type\": \"TO\"},{\"address\": \"chenri@mssante.fr\",\"type\": \"TO\"},{\"address\": \"henri.charles@pro-mssante.fr\",\"name\": \"henri charles\",\"type\": \"TO\"}],\"flags\": \"UNREAD\",\"folderId\": 2,\"messageId\": 261,\"size\": 8704,\"subject\": \"Re: Serment d'Hippocrate\"},{\"body\": \"Je jure par ApollonObjet: Serment d'HippocrateJe jure par Apollon\",\"conversationId\": 260,\"date\": \"10/07/2013 12:42:02\",\"emails\": [{\"address\": \"jean.dupont@mssante.fr\",\"name\": \"Jean Dupont\",\"type\": \"FROM\"},{\"address\": \"charles.henri@mssante.fr\",\"name\": \"charles henri\",\"type\": \"TO\"},{\"address\": \"patrice.galou@mssante.fr\",\"name\": \"patrice galou\",\"type\": \"TO\"},{\"address\": \"chenri@mssante.fr\",\"type\": \"TO\"},{\"address\": \"henri.charles@pro-mssante.fr\",\"name\": \"henri charles\",\"type\": \"TO\"}],\"folderId\": 2,\"messageId\": 259,\"size\": 6226,\"subject\": \"Re: Serment d'Hippocrate\"},{\"body\": \"Je jure par Apollon\",\"conversationId\": 260,\"date\": \"10/07/2013 12:41:49\",\"emails\": [{\"address\": \"jean.dupont@mssante.fr\",\"name\": \"Jean Dupont\",\"type\": \"FROM\"},{\"address\": \"charles.henri@mssante.fr\",\"name\": \"charles henri\",\"type\": \"TO\"},{\"address\": \"patrice.galou@mssante.fr\",\"name\": \"patrice galou\",\"type\": \"TO\"},{\"address\": \"chenri@mssante.fr\",\"type\": \"TO\"},{\"address\": \"henri.charles@pro-mssante.fr\",\"name\": \"henri charles\",\"type\": \"TO\"}],\"flags\": \"UNREAD\",\"folderId\": 2,\"messageId\": 258,\"size\": 3630,\"subject\": \"Serment d'Hippocrate\"},{\"body\": \"Je jure par Apollon\",\"conversationId\": -257,\"date\": \"10/07/2013 12:39:41\",\"emails\": [{\"address\": \"jean.dupont@mssante.fr\",\"name\": \"Jean Dupont\",\"type\": \"FROM\"},{\"address\": \"charles.henri@mssante.fr\",\"name\": \"charles henri\",\"type\": \"TO\"}],\"folderId\": 2,\"messageId\": 257,\"size\": 3647,\"subject\": \"Serment d'hippocrate\"}]}}";
    
    invalidJson = @"invalid json string";
    acceptJsonPaosHeader = @"";
    paosHeader = @"";
    
    details = [NSMutableDictionary dictionary];
    appDomain = [[NSBundle mainBundle] bundleIdentifier];
    responseHeaders = [NSMutableDictionary dictionary];
}

- (void)tearDown {
    // Tear-down code here.
    [super tearDown];
}

- (void)testInitWithService {
    request = [[Request alloc] initWithService:service];
    responseClassName = [NSString stringWithFormat:@"%@Response", [request capitalizeString:service]];
    STAssertNotNil(request, @"Impossible d'initialiser Request");
    STAssertEquals(service, request.service, @"Impossible d'initialiser service");
    STAssertEquals(HTTP_GET, request.method, @"Impossible d'initialiser method");
    STAssertEquals([params count], [request.parameters count], @"Impossible d'initialiser parameters");
    STAssertEquals([headers count], [request.httpHeaders count], @"Impossible d'initialiser parameters");
    STAssertEqualObjects(url, request.url, @"Impossible d'initialiser parameters");
    STAssertEqualObjects(responseClassName, request.responseClassName, @"Impossible d'initialiser responseClassName");
}

- (void)testInitWithServiceAndMethodAndParams {
    request = [[Request alloc] initWithService:service method:method params:params];
    STAssertNotNil(request, @"Impossible d'initialiser Request");
    STAssertEquals(HTTP_POST, request.method, @"Impossible d'initialiser method");
    STAssertEquals([params count], [request.parameters count], @"Impossible d'initialiser parameters");
    
    [params setDictionary:tmpParams];
    request = [[Request alloc] initWithService:service method:method params:params];
    STAssertNotNil(request, @"Impossible d'initialiser Request");
    STAssertEquals([params count], [request.parameters count], @"Impossible d'initialiser parameters");
}

- (void)testInitWithServiceAndMethodAndHeadersAndParams {
    request = [[Request alloc] initWithService:service method:method headers:headers params:params];
    STAssertEquals(HTTP_POST, request.method, @"Impossible d'initialiser method");
    STAssertEquals([params count], [request.parameters count], @"Impossible d'initialiser parameters");
    STAssertEquals([headers count], [request.httpHeaders count], @"Impossible d'initialiser parameters");
    
    [params setDictionary:tmpParams];
    [headers setDictionary:tmpHeaders];
    request = [[Request alloc] initWithService:service method:method headers:headers params:params];
    STAssertEquals([params count], [request.parameters count], @"Impossible d'initialiser parameters");
    STAssertEquals([headers count], [request.httpHeaders count], @"Impossible d'initialiser parameters");
}

- (void)testGenerateUrl {
    
    // Item Service
    url = [NSString stringWithFormat:@"%@%@%@",SERVER_MSS,ITEM_SERVICE,S_ITEM_SEARCH_MESSAGES];
    NSString *generatedUrl = [request generateUrl:S_ITEM_SEARCH_MESSAGES];
    STAssertEqualObjects(url, generatedUrl, @"Impossible de generer url pour le service Search");
    
    url = [NSString stringWithFormat:@"%@%@%@",SERVER_MSS,ITEM_SERVICE,S_ITEM_SEND_MESSAGE];
    generatedUrl = [request generateUrl:S_ITEM_SEND_MESSAGE];
    STAssertEqualObjects(url, generatedUrl, @"Impossible de generer url pour le service Send");
    
    url = [NSString stringWithFormat:@"%@%@%@",SERVER_MSS,ITEM_SERVICE,S_ITEM_MOVE_MESSAGES];
    generatedUrl = [request generateUrl:S_ITEM_MOVE_MESSAGES];
    STAssertEqualObjects(url, generatedUrl, @"Impossible de generer url pour le service Copy");
    
    url = [NSString stringWithFormat:@"%@%@%@",SERVER_MSS,ITEM_SERVICE,S_ITEM_DRAFT_MESSAGE];
    generatedUrl = [request generateUrl:S_ITEM_DRAFT_MESSAGE];
    STAssertEqualObjects(url, generatedUrl, @"Impossible de generer url pour le service Draft");
    
    url = [NSString stringWithFormat:@"%@%@%@",SERVER_MSS,ITEM_SERVICE,S_ITEM_UPDATE_MESSAGES];
    generatedUrl = [request generateUrl:S_ITEM_UPDATE_MESSAGES];
    STAssertEqualObjects(url, generatedUrl, @"Impossible de generer url pour le service Store");
    
    // Annuaire Service
    url = [NSString stringWithFormat:@"%@%@%@",SERVER_MSS,ANNUAIRE_SERVICE,S_ANNUAIRE_RECHERCHER];
    generatedUrl = [request generateUrl:S_ANNUAIRE_RECHERCHER];
    STAssertEqualObjects(url, generatedUrl, @"Impossible de generer url pour le service Rechercher");
    
    url = [NSString stringWithFormat:@"%@%@%@",SERVER_MSS,ANNUAIRE_SERVICE,S_ANNUAIRE_LIST_EMAILS];
    generatedUrl = [request generateUrl:S_ANNUAIRE_LIST_EMAILS];
    STAssertEqualObjects(url, generatedUrl, @"Impossible de generer url pour le service listEmails");
    
    // Attachment Service
    url = [NSString stringWithFormat:@"%@%@%@",SERVER_MSS,ATTACHMENT_SERVICE,S_ATTACHMENT_DOWNLOAD];
    generatedUrl = [request generateUrl:S_ATTACHMENT_DOWNLOAD];
    STAssertEqualObjects(url, generatedUrl, @"Impossible de generer url pour le service Download");
    
    url = [NSString stringWithFormat:@"%@%@%@",SERVER_MSS,ATTACHMENT_SERVICE,S_ATTACHMENT_REMOVE];
    generatedUrl = [request generateUrl:S_ATTACHMENT_REMOVE];
    STAssertEqualObjects(url, generatedUrl, @"Impossible de generer url pour le service Remove");
    
    url = [NSString stringWithFormat:@"%@%@%@",SERVER_MSS,ATTACHMENT_SERVICE,S_ATTACHMENT_UPLOAD];
    generatedUrl = [request generateUrl:S_ATTACHMENT_UPLOAD];
    STAssertEqualObjects(url, generatedUrl, @"Impossible de generer url pour le service Upload");
    
    // Folder Service
    url = [NSString stringWithFormat:@"%@%@%@",SERVER_MSS,FOLDER_SERVICE,S_FOLDER_CREATE];
    generatedUrl = [request generateUrl:S_FOLDER_CREATE];
    STAssertEqualObjects(url, generatedUrl, @"Impossible de generer url pour le service Create");
    
    url = [NSString stringWithFormat:@"%@%@%@",SERVER_MSS,FOLDER_SERVICE,S_FOLDER_DELETE];
    generatedUrl = [request generateUrl:S_FOLDER_DELETE];
    STAssertEqualObjects(url, generatedUrl, @"Impossible de generer url pour le service Delete");
    
    url = [NSString stringWithFormat:@"%@%@%@",SERVER_MSS,FOLDER_SERVICE,S_FOLDER_EMPTY];
    generatedUrl = [request generateUrl:S_FOLDER_EMPTY];
    STAssertEqualObjects(url, generatedUrl, @"Impossible de generer url pour le service Empty");
    
    url = [NSString stringWithFormat:@"%@%@%@",SERVER_MSS,FOLDER_SERVICE,S_FOLDER_LIST];
    generatedUrl = [request generateUrl:S_FOLDER_LIST];
    STAssertEqualObjects(url, generatedUrl, @"Impossible de generer url pour le service List");
    
    url = [NSString stringWithFormat:@"%@%@%@",SERVER_MSS,FOLDER_SERVICE,S_FOLDER_MOVE];
    generatedUrl = [request generateUrl:S_FOLDER_MOVE];
    STAssertEqualObjects(url, generatedUrl, @"Impossible de generer url pour le service Move");
    
    url = [NSString stringWithFormat:@"%@%@%@",SERVER_MSS,FOLDER_SERVICE,S_FOLDER_RENAME];
    generatedUrl = [request generateUrl:S_FOLDER_RENAME];
    STAssertEqualObjects(url, generatedUrl, @"Impossible de generer url pour le service Rename");
    
    url = [NSString stringWithFormat:@"%@%@%@",SERVER_MSS,FOLDER_SERVICE,S_ITEM_SYNC];
    generatedUrl = [request generateUrl:S_ITEM_SYNC];
    STAssertEqualObjects(url, generatedUrl, @"Impossible de generer url pour le service Sync");
    
    url = [NSString stringWithFormat:@"%@%@%@",SERVER_MSS,FOLDER_SERVICE,S_FOLDER_TRASH];
    generatedUrl = [request generateUrl:S_FOLDER_TRASH];
    STAssertEqualObjects(url, generatedUrl, @"Impossible de generer url pour le service Trash");
    
    // Enrolment Service
    url = [NSString stringWithFormat:@"%@%@%@",SERVER_ENROLLEMENT,ENROLEMENT_SERVICE,S_ENREGISTRER_CANAL];
    generatedUrl = [request generateUrl:S_ENREGISTRER_CANAL];
    STAssertEqualObjects(url, generatedUrl, @"Impossible de generer url pour le service Enregistrer Canal");
    
    // Auth Service
    generatedUrl = [request generateUrl:S_AUTHENTIFIER_OTP];
    NSString * server_auth_ipd = [NSString stringWithFormat:@"%@%@",SERVER_ENROLLEMENT,SERVER_AUTH_IDP];
    STAssertEqualObjects(server_auth_ipd, generatedUrl, @"Impossible de generer url pour le service authentifier OTP");
    
    generatedUrl = [request generateUrl:@""];
    STAssertEqualObjects(SERVER_MSS, generatedUrl, @"Impossible de generer url pour un service vide");
}

- (void)capitalizeString {
    NSString *str = @"searchResponse";
    NSString *capStr = [request capitalizeString:str];
    STAssertEqualObjects(@"SearchResponse", capStr, @"Strings don't match");
    
    str = @"";
    capStr = [request capitalizeString:str];
    STAssertEqualObjects(@"", capStr, @"Strings don't match");
    
    str = nil;
    capStr = [request capitalizeString:str];
    STAssertEqualObjects(@"", capStr, @"Strings don't match");
}

- (void)testRegexReplaceMatch {
    NSString *authRequest = @"<soap11:Header><paos:Request xmlns:paos=\"urn:liberty:paos:2003-08\" responseConsumerURL=\"http://ns393081.ovh.net:8080/mss-msg-services/saml/SSO/alias/defaultAlias\" service=\"urn:oasis:names:tc:SAML:2.0:profiles:SSO:ecp\" soap11:actor=\"http://schemas.xmlsoap.org/soap/actor/next\" soap11:mustUnderstand=\"1\"/><ecp:Request xmlns:ecp=\"urn:oasis:names:tc:SAML:2.0:profiles:SSO:ecp\" IsPassive=\"false\" soap11:actor=\"http://schemas.xmlsoap.org/soap/actor/next\" soap11:mustUnderstand=\"1\"><saml2:Issuer xmlns:saml2=\"urn:oasis:names:tc:SAML:2.0:assertion\">http://ns393081.ovh.net:8080/mss-msg-services</saml2:Issuer><saml2p:IDPList xmlns:saml2p=\"urn:oasis:names:tc:SAML:2.0:protocol\"><saml2p:IDPEntry ProviderID=\"http://ns393081.ovh.net:8080/openam\"/></saml2p:IDPList></ecp:Request></soap11:Header><soap11:Body></soap11:Body>";
    NSString *result = [request regexReplaceMatch:authRequest pattern:@"<soap11:Header>.*</soap11:Header>" replacement:@"<soap11:Header></soap11:Header>"];
    STAssertEqualObjects(@"<soap11:Header></soap11:Header><soap11:Body></soap11:Body>", result, @"Impossible de vider Soap:Header");
    
    result = [request regexReplaceMatch:nil pattern:nil replacement:nil];
    STAssertEqualObjects(nil, result, @"Impossible de executer regexFindMatch sur un string vide");
    
    result = [request regexReplaceMatch:@"" pattern:@"" replacement:@""];
    STAssertEqualObjects(nil, result, @"Impossible de executer regexFindMatch sur un string vide");
}

- (void)testParseJsonString {
    id result = [request parseJsonString:nil];
    STAssertNil(result, @"Impossible de parser un string nil");
    
    result = [request parseJsonString:@""];
    STAssertNil(result, @"Impossible de parser un string vide");
    
    result = [request parseJsonString:invalidJson];
    STAssertNil(result, @"Impossible de parser un string vide");
    
    result = [request parseJsonString:searchJson];
    STAssertNotNil(result, @"Impossible de parser un json string");
    
    result = [request parseJsonString:listEmailsJson];
    STAssertNotNil(result, @"Impossible de parser un json string");
    
    result = [request parseJsonString:enregistrerCanalJson];
    STAssertNotNil(result, @"Impossible de parser un json string");
}

- (void)testGetResponseObjectFromJsonObject {
    id obj = nil;
    id result = [request getResponseObjectFromJsonObject:obj];
    DLog(@"result %@",result);
    STAssertNil(result, @"Impossible de parser un string nil");
    
    request = [[Request alloc] initWithService:S_ENREGISTRER_CANAL];
    obj = [request parseJsonString:enregistrerCanalJson];
    [request setService:S_ENREGISTRER_CANAL];
    result = [request getResponseObjectFromJsonObject:obj];
    STAssertNotNil(result, @"Impossible de parser enregistrerCanalJson");
    DLog(@"result %@",result);
    
    request = [[Request alloc] initWithService:S_ANNUAIRE_LIST_EMAILS];
    obj = [request parseJsonString:listEmailsJson];
    [request setService:S_ANNUAIRE_LIST_EMAILS];
    result = [request getResponseObjectFromJsonObject:obj];
    STAssertNotNil(result, @"Impossible de parser listEmailsJson");
    DLog(@"result %@",result);
    
    request = [[Request alloc] initWithService:S_ITEM_SEARCH_MESSAGES];
    obj = [request parseJsonString:searchJson];
    [request setService:S_ITEM_SEARCH_MESSAGES];
    result = [request getResponseObjectFromJsonObject:obj];
    STAssertNotNil(result, @"Impossible de parser listEmailsJson");
    DLog(@"result %@",result);
}

- (void)testExecute {
    request = [[Request alloc] initWithService:S_ANNUAIRE_LIST_EMAILS];
    [request execute];
    
    requestBody = [[NSString alloc] initWithData:[[request request] HTTPBody] encoding:NSUTF8StringEncoding];
    
    requestHeaders = [[request request] allHTTPHeaderFields];
    
    if ([requestHeaders objectForKey:HTTP_HEADER_ACCEPT]) {
        acceptJsonPaosHeader = [requestHeaders objectForKey:HTTP_HEADER_ACCEPT];
    }
    
    if ([requestHeaders objectForKey:HTTP_HEADER_PAOS]) {
        paosHeader = [requestHeaders objectForKey:HTTP_HEADER_PAOS];
    }
    
    STAssertEqualObjects(requestBody, @"", @"Impossible d'initialiser parameters");
    STAssertEqualObjects(acceptJsonPaosHeader, HTTP_HEADER_ACCEPT_PAOS_JSON, @"Impossible d'initialiser Accept Header");
    STAssertEqualObjects(paosHeader, HTTP_HEADER_PAOS_VALUE, @"Impossible d'initialiser PAOS Header");
    STAssertEquals([[request request] timeoutInterval], TIMEOUT, @"Impossible d'initialiser timeout");
    
    headers = [NSMutableDictionary dictionary];
    [headers setValue:@"CUSTOM" forKey:@"CUSTOM_HEADER"];
    params = [NSMutableDictionary dictionary];
    [params setValue:@"VALUE" forKey:@"ONE"];
    [params setValue:@"VALUE2" forKey:@"TWO"];
    request = [[Request alloc] initWithService:S_ANNUAIRE_LIST_EMAILS method:HTTP_POST headers:headers params:params];
    [request execute];

    requestBody = [[NSString alloc] initWithData:[[request request] HTTPBody] encoding:NSUTF8StringEncoding];
    requestHeaders = [[request request] allHTTPHeaderFields];
    
    NSString *customHeader = [requestHeaders objectForKey:@"CUSTOM_HEADER"];
    if ([requestHeaders objectForKey:@"CUSTOM_HEADER"]) {
        customHeader = [requestHeaders objectForKey:@"CUSTOM_HEADER"];
    }
    
    NSError *error;
    NSData *requestJsonBody = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    STAssertEqualObjects([[request request] HTTPBody], requestJsonBody, @"Impossible d'initialiser parameters");
    STAssertEqualObjects(customHeader, @"CUSTOM" , @"Impossible d'initialiser CUSTOM_HEADER");
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

- (void)testHandleRequestError {
    request = [[Request alloc] initWithService:S_ANNUAIRE_LIST_EMAILS method:HTTP_POST headers:nil params:nil];

    // Valider httpStatusCode != 400 ou 401  
    statusCode = 0;
    operationMock = [OCMockObject mockForClass:[AFHTTPRequestOperation class]];
    responseMock = [OCMockObject mockForClass:[NSHTTPURLResponse class]];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(statusCode)] statusCode];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(responseHeaders)] allHeaderFields];
    [[[operationMock stub] andReturnValue:OCMOCK_VALUE(responseMock)] response];
    _error = [NSError errorWithDomain:appDomain code:0 userInfo:details];
    [request handleRequestError:operationMock error:_error];
    STAssertEqualObjects([request uiError] , [request serviceNotAvailableError], @"Impossible d'initialiser error");
    STAssertTrue([request sendError], @"SendError devrait être True");
    
    
    // Valider httpStatusCode 401
    statusCode = 401;
    errorCode = 401;
    nextUrl = @"NEXT_URL";
    wwwAuth = [NSString stringWithFormat:@"OTP nextUrl=%@", nextUrl];
    
    [responseHeaders setValue:wwwAuth forKey:HTTP_HEADER_WWW_AUTH];
    
    operationMock = [OCMockObject mockForClass:[AFHTTPRequestOperation class]];
    responseMock = [OCMockObject mockForClass:[NSHTTPURLResponse class]];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(statusCode)] statusCode];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(responseHeaders)] allHeaderFields];
    [[[operationMock stub] andReturnValue:OCMOCK_VALUE(responseMock)] response];
    [request setIsAuthenticationRequest:YES];
    _error = [NSError errorWithDomain:appDomain code:0 userInfo:details];
    [request handleRequestError:operationMock error:_error];
    nextUrl = [NSString stringWithFormat:@"%@%@",ID_PROVIDER_DOMAIN, nextUrl];
    
    STAssertEqualObjects([request wwwAuth], wwwAuth , @"Impossible de parser www-auth header");
    STAssertEqualObjects([request nextUrl], nextUrl, @"Impossible de parser nextUrl");
    STAssertEqualObjects([request uiError] , [request authError], @"Impossible d'initialiser error");
    STAssertFalse([request sendError], @"SendError devrait être False");
    
    
    // Valider httpStatusCode 400
    statusCode = 400;
    errorCode = 400;
    
    operationMock = [OCMockObject mockForClass:[AFHTTPRequestOperation class]];
    responseMock = [OCMockObject mockForClass:[NSHTTPURLResponse class]];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(statusCode)] statusCode];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(responseHeaders)] allHeaderFields];
    [[[operationMock stub] andReturnValue:OCMOCK_VALUE(responseMock)] response];
    [request setIsAuthenticationRequest:NO];
    _error = [NSError errorWithDomain:appDomain code:0 userInfo:details];
    
    [request handleRequestError:operationMock error:_error];
    
    STAssertTrue([request sendError], @"SendError devrait être False");
    STAssertEqualObjects([request uiError] , [request qrError], @"Impossible d'initialiser error");
}


- (void)testHandleRequestSuccess {
    request = [[Request alloc] initWithService:S_ITEM_SEARCH_MESSAGES method:HTTP_POST headers:nil params:nil];
    

    statusCode = 200;
    // Response = nil
    response = nil;
    operationMock = [OCMockObject mockForClass:[AFHTTPRequestOperation class]];
    responseMock = [OCMockObject mockForClass:[NSHTTPURLResponse class]];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(statusCode)] statusCode];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(responseHeaders)] allHeaderFields];
    [[[operationMock stub] andReturnValue:OCMOCK_VALUE(responseMock)] response];
    [request handleRequestSuccess:operationMock response:response];
    STAssertNil([request responseObject], @"Impossible d'initialiser responseObject");
    STAssertFalse([request sendError], @"SendError devrait être False");
    STAssertTrue([request sendResponse], @"SendError devrait être True");
    
    
    // MIMEType = application/json 
    MIMEType = APPLICATION_JSON;
    response = [searchJson dataUsingEncoding:NSUTF8StringEncoding];
    operationMock = [OCMockObject mockForClass:[AFHTTPRequestOperation class]];
    responseMock = [OCMockObject mockForClass:[NSHTTPURLResponse class]];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(statusCode)] statusCode];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(responseHeaders)] allHeaderFields];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(MIMEType)] MIMEType];
    [[[operationMock stub] andReturnValue:OCMOCK_VALUE(responseMock)] response];
    [request handleRequestSuccess:operationMock response:response];
    STAssertNotNil([request responseObject], @"Impossible d'initialiser responseObject");
    STAssertFalse([request sendError], @"SendError devrait être False");
    STAssertTrue([request sendResponse], @"SendError devrait être True");
    
    
    // MIMEType = application/json avec invalide json
    MIMEType = APPLICATION_JSON;
    response = [invalidJson dataUsingEncoding:NSUTF8StringEncoding];
    operationMock = [OCMockObject mockForClass:[AFHTTPRequestOperation class]];
    responseMock = [OCMockObject mockForClass:[NSHTTPURLResponse class]];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(statusCode)] statusCode];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(responseHeaders)] allHeaderFields];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(MIMEType)] MIMEType];
    [[[operationMock stub] andReturnValue:OCMOCK_VALUE(responseMock)] response];
    [request handleRequestSuccess:operationMock response:response];
    STAssertNil([request responseObject], @"Impossible d'initialiser responseObject");
    STAssertEqualObjects([request uiError] , [request wrongResponseError], @"Impossible d'initialiser uiError");
    STAssertTrue([request sendError], @"SendError devrait être True");
    
    
    // MIMEType = text/xml AuthenticationRequest 
    MIMEType = TEXT_XML;
    response = [@"SAML_ASSERTION" dataUsingEncoding:NSUTF8StringEncoding];
    [request setIsAuthenticationRequest:YES];
    operationMock = [OCMockObject mockForClass:[AFHTTPRequestOperation class]];
    responseMock = [OCMockObject mockForClass:[NSHTTPURLResponse class]];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(statusCode)] statusCode];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(responseHeaders)] allHeaderFields];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(MIMEType)] MIMEType];
    [[[operationMock stub] andReturnValue:OCMOCK_VALUE(responseMock)] response];
    [request handleRequestSuccess:operationMock response:response];
    STAssertNotNil([request responseObject], @"Impossible d'initialiser responseObject");
    STAssertEqualObjects([request responseObject] , @"SAML_ASSERTION", @"Impossible d'initialiser responseObject");
    STAssertTrue([request sendResponse], @"sendResponse devrait être True");
    
    
    // MIMEType = text/xml EnrolmentRequest
    MIMEType = TEXT_XML;
    response = [@"SAML_ASSERTION" dataUsingEncoding:NSUTF8StringEncoding];
    [request setIsAuthenticationRequest:NO];
    [request setIsEnrolmentRequest:YES];
    operationMock = [OCMockObject mockForClass:[AFHTTPRequestOperation class]];
    responseMock = [OCMockObject mockForClass:[NSHTTPURLResponse class]];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(statusCode)] statusCode];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(responseHeaders)] allHeaderFields];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(MIMEType)] MIMEType];
    [[[operationMock stub] andReturnValue:OCMOCK_VALUE(responseMock)] response];
    [request handleRequestSuccess:operationMock response:response];
    STAssertNil([request responseObject], @"Impossible d'initialiser responseObject");
    STAssertEqualObjects([request uiError] , [request wrongResponseError], @"Impossible d'initialiser uiError");
    STAssertTrue([request sendError], @"SendError devrait être True");
    
    
    // MIMEType = text/xml services messagerie
    MIMEType = TEXT_XML;
    //authRequest
    response = [@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><soap11:Envelope xmlns:soap11=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap11:Header><paos:Request xmlns:paos=\"urn:liberty:paos:2003-08\" responseConsumerURL=\"http://ns393081.ovh.net:8080/mss-msg-services/saml/SSO/alias/defaultAlias\" service=\"urn:oasis:names:tc:SAML:2.0:profiles:SSO:ecp\" soap11:actor=\"http://schemas.xmlsoap.org/soap/actor/next\" soap11:mustUnderstand=\"1\"/><ecp:Request xmlns:ecp=\"urn:oasis:names:tc:SAML:2.0:profiles:SSO:ecp\" IsPassive=\"false\" soap11:actor=\"http://schemas.xmlsoap.org/soap/actor/next\" soap11:mustUnderstand=\"1\"><saml2:Issuer xmlns:saml2=\"urn:oasis:names:tc:SAML:2.0:assertion\">http://ns393081.ovh.net:8080/mss-msg-services</saml2:Issuer><saml2p:IDPList xmlns:saml2p=\"urn:oasis:names:tc:SAML:2.0:protocol\"><saml2p:IDPEntry ProviderID=\"http://ns393081.ovh.net:8080/openam\"/></saml2p:IDPList></ecp:Request></soap11:Header><soap11:Body><saml2p:AuthnRequest xmlns:saml2p=\"urn:oasis:names:tc:SAML:2.0:protocol\" AssertionConsumerServiceURL=\"http://ns393081.ovh.net:8080/mss-msg-services/saml/SSO/alias/defaultAlias\" ForceAuthn=\"false\" ID=\"a1aga81040gdb716ea31a860je06h\" IsPassive=\"false\" IssueInstant=\"2013-07-23T08:47:52.170Z\" ProtocolBinding=\"urn:oasis:names:tc:SAML:2.0:bindings:PAOS\" Version=\"2.0\">" dataUsingEncoding:NSUTF8StringEncoding];
    
    authnRequest = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><soap11:Envelope xmlns:soap11=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap11:Header></soap11:Header><soap11:Body><saml2p:AuthnRequest xmlns:saml2p=\"urn:oasis:names:tc:SAML:2.0:protocol\" AssertionConsumerServiceURL=\"http://ns393081.ovh.net:8080/mss-msg-services/saml/SSO/alias/defaultAlias\" ForceAuthn=\"false\" ID=\"a1aga81040gdb716ea31a860je06h\" IsPassive=\"false\" IssueInstant=\"2013-07-23T08:47:52.170Z\" ProtocolBinding=\"urn:oasis:names:tc:SAML:2.0:bindings:PAOS\" Version=\"2.0\">";
    
    jSessionId = @"50F8848279B431E36B0F4314578F80F4";
    assertionConsumerServiceURL = @"http://ns393081.ovh.net:8080/mss-msg-services/saml/SSO/alias/defaultAlias";
    
    [request setIsEnrolmentRequest:NO];
    [request setIsAuthenticationRequest:NO];
    operationMock = [OCMockObject mockForClass:[AFHTTPRequestOperation class]];
    responseMock = [OCMockObject mockForClass:[NSHTTPURLResponse class]];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(statusCode)] statusCode];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(responseHeaders)] allHeaderFields];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(MIMEType)] MIMEType];
    [[[operationMock stub] andReturnValue:OCMOCK_VALUE(responseMock)] response];
    [request handleRequestSuccess:operationMock response:response];
    
    STAssertEqualObjects([request assertionConsumerServiceURL], assertionConsumerServiceURL , @"Impossible de parser assertionConsumerServiceURL");
    STAssertEqualObjects([request authnRequest], authnRequest , @"Impossible de parser authnRequest");
    STAssertEqualObjects([[request auth] assertionConsumerServiceURL], assertionConsumerServiceURL , @"Impossible d'initialiser assertionConsumerServiceURL dans auth");
    STAssertEqualObjects([Authentification authDelegate], request , @"Impossible d'initialiser authDelegate dans auth");
    STAssertFalse([request sendResponse], @"SendError devrait être False");
    
    
    // MIMEType = text/htm AuthenticationRequest
    MIMEType = TEXT_HTML;
    response = [@"HTML HERE" dataUsingEncoding:NSUTF8StringEncoding];
    [request setIsAuthenticationRequest:YES];
    [request setIsEnrolmentRequest:NO];
    operationMock = [OCMockObject mockForClass:[AFHTTPRequestOperation class]];
    responseMock = [OCMockObject mockForClass:[NSHTTPURLResponse class]];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(statusCode)] statusCode];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(responseHeaders)] allHeaderFields];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(MIMEType)] MIMEType];
    [[[operationMock stub] andReturnValue:OCMOCK_VALUE(responseMock)] response];
    [request handleRequestSuccess:operationMock response:response];
    STAssertNil([request responseObject], @"Impossible d'initialiser responseObject");
    STAssertEqualObjects([request uiError] , [request authError], @"Impossible d'initialiser uiError");
    STAssertTrue([request sendError], @"SendError devrait être True");
    
    
    // MIMEType = text/htm AuthenticationRequest
    MIMEType = TEXT_HTML;
    response = [@"HTML HERE" dataUsingEncoding:NSUTF8StringEncoding];
    [request setIsAuthenticationRequest:NO];
    [request setIsEnrolmentRequest:NO];
    operationMock = [OCMockObject mockForClass:[AFHTTPRequestOperation class]];
    responseMock = [OCMockObject mockForClass:[NSHTTPURLResponse class]];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(statusCode)] statusCode];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(responseHeaders)] allHeaderFields];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(MIMEType)] MIMEType];
    [[[operationMock stub] andReturnValue:OCMOCK_VALUE(responseMock)] response];
    [request handleRequestSuccess:operationMock response:response];
    STAssertNil([request responseObject], @"Impossible d'initialiser responseObject");
    STAssertEqualObjects([request uiError] , [request wrongResponseError], @"Impossible d'initialiser uiError");
    STAssertTrue([request sendError], @"SendError devrait être True");
    
    
    
    MIMEType = @"ANYTHING";
    response = [@"HTML HERE" dataUsingEncoding:NSUTF8StringEncoding];
    [request setIsAuthenticationRequest:NO];
    [request setIsEnrolmentRequest:NO];
    operationMock = [OCMockObject mockForClass:[AFHTTPRequestOperation class]];
    responseMock = [OCMockObject mockForClass:[NSHTTPURLResponse class]];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(statusCode)] statusCode];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(responseHeaders)] allHeaderFields];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(MIMEType)] MIMEType];
    [[[operationMock stub] andReturnValue:OCMOCK_VALUE(responseMock)] response];
    [request handleRequestSuccess:operationMock response:response];
    STAssertNil([request responseObject], @"Impossible d'initialiser responseObject");
    STAssertEqualObjects([request uiError] , [request wrongResponseError], @"Impossible d'initialiser uiError");
    STAssertTrue([request sendError], @"SendError devrait être True");
    
}


- (void)testAuthResponse {
    request = [[Request alloc] initWithService:S_ITEM_SEARCH_MESSAGES method:HTTP_POST headers:nil params:nil];
    [request authResponse:nil];
    STAssertTrue([request sendError], @"SendError devrait être True");
    jSessionId = @"50F8848279B431E36B0F4314578F80F4";
    assertionConsumerServiceURL = @"http://ns393081.ovh.net:8080/mss-msg-services/saml/SSO/alias/defaultAlias";
    NSString *assertionSAML = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><soap11:Envelope xmlns:soap11=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap-env:Header><paos:Request xmlns:paos=\"urn:liberty:paos:2003-08\" responseConsumerURL=\"http://ns393081.ovh.net:8080/mss-msg-services/saml/SSO/alias/defaultAlias\" service=\"urn:oasis:names:tc:SAML:2.0:profiles:SSO:ecp\" soap11:actor=\"http://schemas.xmlsoap.org/soap/actor/next\" soap11:mustUnderstand=\"1\"/><ecp:Request xmlns:ecp=\"urn:oasis:names:tc:SAML:2.0:profiles:SSO:ecp\" IsPassive=\"false\" soap11:actor=\"http://schemas.xmlsoap.org/soap/actor/next\" soap11:mustUnderstand=\"1\"><saml2:Issuer xmlns:saml2=\"urn:oasis:names:tc:SAML:2.0:assertion\">http://ns393081.ovh.net:8080/mss-msg-services</saml2:Issuer><saml2p:IDPList xmlns:saml2p=\"urn:oasis:names:tc:SAML:2.0:protocol\"><saml2p:IDPEntry ProviderID=\"http://ns393081.ovh.net:8080/openam\"/></saml2p:IDPList></ecp:Request></soap-env:Header><soap11:Body><saml2p:AuthnRequest xmlns:saml2p=\"urn:oasis:names:tc:SAML:2.0:protocol\" AssertionConsumerServiceURL=\"http://ns393081.ovh.net:8080/mss-msg-services/saml/SSO/alias/defaultAlias\" ForceAuthn=\"false\" ID=\"a1aga81040gdb716ea31a860je06h\" IsPassive=\"false\" IssueInstant=\"2013-07-23T08:47:52.170Z\" ProtocolBinding=\"urn:oasis:names:tc:SAML:2.0:bindings:PAOS\" Version=\"2.0\">";
    
    NSString *cleanSaml = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><soap11:Envelope xmlns:soap11=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap-env:Header></soap-env:Header><soap11:Body><saml2p:AuthnRequest xmlns:saml2p=\"urn:oasis:names:tc:SAML:2.0:protocol\" AssertionConsumerServiceURL=\"http://ns393081.ovh.net:8080/mss-msg-services/saml/SSO/alias/defaultAlias\" ForceAuthn=\"false\" ID=\"a1aga81040gdb716ea31a860je06h\" IsPassive=\"false\" IssueInstant=\"2013-07-23T08:47:52.170Z\" ProtocolBinding=\"urn:oasis:names:tc:SAML:2.0:bindings:PAOS\" Version=\"2.0\">";
    
    NSMutableDictionary *authInfo = [NSMutableDictionary dictionary];
    [authInfo setObject:assertionSAML forKey:ASSERTION_SAML];
    [authInfo setObject:assertionConsumerServiceURL forKey:ASSERTION_CUSTOMER_SERVICE_URL];
    
    [request authResponse:authInfo];
    
    
    STAssertEqualObjects([request samlAssertion] , cleanSaml, @"Impossible d'initialiser samlAssertion");
    STAssertEqualObjects([request url] , assertionConsumerServiceURL, @"Impossible d'initialiser assertionConsumerServiceURL");
    STAssertEqualObjects([request parameters] , cleanSaml, @"Impossible d'initialiser parameters");
    STAssertFalse([request sendError], @"SendError devrait être False");
    
    requestHeaders = [[request request] allHTTPHeaderFields];
    
    NSString *contentTypeHeader =@"";
    if ([requestHeaders objectForKey:HTTP_CONTENT_TYPE]) {
        contentTypeHeader = [requestHeaders objectForKey:HTTP_CONTENT_TYPE];
    }
    
    STAssertEqualObjects(contentTypeHeader, HTTP_HEADER_ACCEPT_PAOS, @"Impossible d'initialiser ContentType Header");
    
}

@end
