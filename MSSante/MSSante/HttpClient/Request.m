//
//  Request.m
//  MSSante
//
//  Created by Ismail on 6/17/13.
//  Copyright (c) 2013 Work. All rights reserved.
//

#import "Request.h"
#import "Authentification.h"
#import "Modification.h"
#import "ModificationDAO.h"
#import "DAOFactory.h"
#import "MessageDAO.h"
#import "GestionError45.h"
#import "PasswordStore.h"
#import "UpdateMessagesInput.h"
#import "Error45.h"
#import "urls.h"

@implementation Request {
    Error45 *error45 ;
}

@synthesize method, initialMethod, responseClassName, url, service, responseString, responseData, statusMessage, request, httpClient, parameters, response,  operation, isAuthenticationRequest, httpBody, httpHeaders, initialParameters, isEnrolmentRequest, uiError, auth, authError, httpStatusCode, nextUrl, nsError, responseHeaders, responseObject, wrongResponseError, assertionConsumerServiceURL, authnRequest, isValidJson, jsonObject, mimeType, samlAssertion, sendError, sendResponse, wwwAuth, serviceNotAvailableError, connectionError, hasAttachments, attachmentFileName, downloadPath;
@synthesize requestQueue;
@synthesize tmpPassword;
@synthesize canceled;
@synthesize trashMessageIds;
@synthesize isModification;
@synthesize isError45Request;
@synthesize delegate;

- (id)initWithService:(NSString *)_service {
    return [self initWithService:_service method:nil params:nil];
}

- (id)initWithService:(NSString *)_service method:(NSString *)_method params:(NSMutableDictionary *)_parameters{
    return [self initWithService:_service method:_method headers:nil params:_parameters];
}

- (id)initWithService:(NSString *)_service method:(NSString *)_method headers:(NSMutableDictionary *)_headers params:(id)_parameters {
    self = [super init];
    fromAuthentificationRequest = NO;
    isError45Request = NO;
    isAuthenticationError = NO;
    isServiceInaccessible = NO;
    responseClassName = nil;
    url = SERVER_MSS;
    
    if(_service != nil) {
        service = _service;
        responseClassName = [[NSString alloc] initWithFormat:@"%@Response",[self capitalizeString:service]];
        [self generateUrl:service];
    }
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithString:url]];
    
    if(_method != nil) {
        method = _method;
    } else {
        method = HTTP_GET;
    }
    
    initialMethod = method;
    
    if(_parameters != nil) {
        parameters = _parameters;
    } else {
        parameters = [NSMutableDictionary dictionary];
    }
    
    httpClient = [[AFHTTPClient alloc] initWithBaseURL:URL];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    httpHeaders = _headers;
    
    auth = [Authentification sharedInstance];
    requestQueue = [RequestQueue sharedInstanceQueue];
    
    wrongResponseError = [[Error alloc] initWithErrorCode:2 httpStatusCode:httpStatusCode errorMsg:NSLocalizedString(@"ERREUR_WEB_SERVICE", @"Le Web Service n'a pas renvoyé la bonne information")];
    authError = [[Error alloc] initWithErrorCode:2 httpStatusCode:httpStatusCode errorMsg:NSLocalizedString(@"AUTHENTIFICATION_IMPOSSIBLE", @"Authentification impossible, veuillez réessayer")];
    serviceNotAvailableError = [[Error alloc] initWithErrorCode:ERROR_TO_DISPLAY_IN_CONTROLER httpStatusCode:0 errorMsg:NSLocalizedString(@"SERVICE_INDISPONIBLE", @"Service momentanément indisponible")];
    connectionError = [[Error alloc] initWithErrorCode:ERROR_TO_DISPLAY_IN_CONTROLER httpStatusCode:0 errorMsg:NSLocalizedString(@"CONNEXION_IMPOSSIBLE", @"Connexion impossible")];
    connectionError.serviceInaccessible = YES;
    
    if ([S_ITEM_UPDATE_MESSAGES isEqualToString:service]){
        NSMutableDictionary *updateDict = [parameters objectForKey:UPDATE_MESSAGES_INPUT];
        listMessageIdForModification = [updateDict objectForKey:MESSAGE_IDS];
    } else if ([S_ITEM_MOVE_MESSAGES isEqualToString:service]){
        NSMutableDictionary *moveDict = [parameters objectForKey:MOVE_MESSAGES_INPUT];
        listMessageIdForModification = [moveDict objectForKey:MESSAGE_IDS];
    } else if ([S_FOLDER_EMPTY isEqualToString:service]) {
        NSMutableDictionary *emptyFolderDict = [parameters objectForKey:EMPTY_FOLDER_INPUT];
        folderIdForModification = [emptyFolderDict objectForKey:FOLDER_ID];
    }
    

    
    return self;
}

- (NSString*)generateUrl:(NSString*)_service {
    url = nil;
    NSString *baseUrl = SERVER_MSS;
    
    if ([_service isEqualToString:S_ITEM_SEARCH_MESSAGES] ||
        [_service isEqualToString:S_ITEM_SEND_MESSAGE] ||
        [_service isEqualToString:S_ITEM_MOVE_MESSAGES] ||
        [_service isEqualToString:S_ITEM_DRAFT_MESSAGE] ||
        [_service isEqualToString:S_ITEM_UPDATE_MESSAGES] ||
        [_service isEqualToString:S_ITEM_FULL_TEXT_SEARCH_MESSAGES] ||
        [_service isEqualToString:S_ITEM_SYNC]) {
        baseUrl = [NSString stringWithFormat:@"%@%@",baseUrl,ITEM_SERVICE];
    } else if ([_service isEqualToString:S_ANNUAIRE_RECHERCHER] ||
               [_service isEqualToString:S_ANNUAIRE_LIST_EMAILS] ||
               [_service isEqualToString:S_ANNUAIRE_SEARCH_RECIPIENT ]) {
        baseUrl = [NSString stringWithFormat:@"%@%@",baseUrl,ANNUAIRE_SERVICE];
    } else if ([_service isEqualToString:S_ATTACHMENT_DOWNLOAD] ||
               [_service isEqualToString:S_ATTACHMENT_REMOVE] ||
               [_service isEqualToString:S_ATTACHMENT_UPLOAD]) {
        baseUrl = [NSString stringWithFormat:@"%@%@",baseUrl,ATTACHMENT_SERVICE];
    } else if ([_service isEqualToString:S_FOLDER_CREATE] ||
               [_service isEqualToString:S_FOLDER_DELETE] ||
               [_service isEqualToString:S_FOLDER_EMPTY]  ||
               [_service isEqualToString:S_FOLDER_LIST] ||
               [_service isEqualToString:S_FOLDER_MOVE] ||
               [_service isEqualToString:S_FOLDER_RENAME]||
               [_service isEqualToString:S_FOLDER_TRASH]) {
        baseUrl = [NSString stringWithFormat:@"%@%@",baseUrl,FOLDER_SERVICE];
    } else if ([_service isEqualToString:S_ENREGISTRER_CANAL] ) {
        baseUrl = SERVER_ENROLLEMENT;
        baseUrl = [NSString stringWithFormat:@"%@%@",baseUrl,ENROLEMENT_SERVICE];
    } else if ( [_service isEqualToString:S_MODIFIER_MDP]) {
        baseUrl = SERVER_ENROLLEMENT;
        baseUrl = [NSString stringWithFormat:@"%@%@",baseUrl,ADMINISTRATION_SERVICE];
    } else if ([_service isEqualToString:S_AUTHENTIFIER_OTP]) {
        baseUrl = SERVER_IDP;
        baseUrl = [NSString stringWithFormat:@"%@%@",baseUrl,SERVER_AUTH_IDP];
        _service = @"";
    } else if ([_service isEqualToString:S_CHANGE_NOTIF_STATE]) {
        baseUrl = SERVER_ENROLLEMENT;
        baseUrl = [NSString stringWithFormat:@"%@%@",baseUrl,NOTIFICATION_SERVICE];
    }
    
    url = [NSString stringWithFormat:@"%@%@",baseUrl,_service];
    return url;
}

- (void)execute {
    ConnectionLog(@"Request URL %@",url);
    ConnectionLog(@"Delegate %@",delegate);
    ConnectionLog(@"isModification %d",isModification);
    ConnectionLog(@"isError45Request %d",isError45Request);
    
    [[Authentification sharedInstance] setCanceled:NO];
    
    if([self isConnectedToInternet]) {
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;
        ConnectionLog(@"Setting Params Start");
        if([parameters isKindOfClass:[NSDictionary class]]) {
            [httpClient setParameterEncoding:AFJSONParameterEncoding];
            request = [httpClient requestWithMethod:method path:url parameters:parameters];
        } else if([parameters isKindOfClass:[NSString class]]) {
            request = [httpClient requestWithMethod:method path:url parameters:nil];
            [request setHTTPBody:[parameters dataUsingEncoding:NSUTF8StringEncoding]];
        } else {
            request = [httpClient requestWithMethod:method path:url parameters:nil];
        }
        
        ConnectionLog(@"Setting Params End");
        [request setValue:HTTP_HEADER_NUM_HOMOLOG_VALUE forHTTPHeaderField:HTTP_HEADER_NUM_HOMOLOGATION];
        
        if(httpHeaders != nil) {
            for (id key in httpHeaders) {
                id obj = [httpHeaders objectForKey:key];
                [request setValue:obj forHTTPHeaderField:key];
            }
        }
        [request setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
        if(!isAuthenticationRequest && !isEnrolmentRequest) {
            [request setValue:HTTP_HEADER_ACCEPT_PAOS_JSON forHTTPHeaderField:HTTP_HEADER_ACCEPT];
            [request setValue:HTTP_HEADER_PAOS_VALUE forHTTPHeaderField:HTTP_HEADER_PAOS];
        }
        
        __block id __self = self;
        
        
        
        
        [request setTimeoutInterval:TIMEOUT];
        operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        // Indicate that we want to validate "server trust" protection spaces.
        [operation setAuthenticationAgainstProtectionSpaceBlock:^BOOL(NSURLConnection *connection, NSURLProtectionSpace *protectionSpace) {
            return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
        }];
        
        // Handle the authentication challenge.
        [operation setAuthenticationChallengeBlock:^(NSURLConnection *connection, NSURLAuthenticationChallenge *challenge) {
            if ([__self shouldTrustProtectionSpace:challenge.protectionSpace]) {
                [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]
                     forAuthenticationChallenge:challenge];
            } else {
                [challenge.sender performDefaultHandlingForAuthenticationChallenge:challenge];
            }
        }];
        
        ConnectionLog(@"Request HTTP Headers %@", [request allHTTPHeaderFields]);
        if ([request.HTTPBody length] < 100000){
            ConnectionLog(@"Request HTTP Body %@", [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
        }

        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *_operation, id _response) {
            
            [__self handleRequestSuccess:_operation response:_response];
        } failure:^(AFHTTPRequestOperation *_operation, NSError *_error) {
            [__self handleRequestError:_operation error:_error];
        }];
        
        // Handle 302 Redirect
        [operation setRedirectResponseBlock:^NSURLRequest *(NSURLConnection *connection, NSURLRequest *_request, NSURLResponse *redirectResponse) {
            if (redirectResponse) {
                ConnectionLog(@"Redirection URL %@",[_request URL]);
                NSMutableURLRequest *redirectRequest = [connection.originalRequest mutableCopy];
                [redirectRequest setURL:[_request URL]];
                [redirectRequest setHTTPMethod:[__self initialMethod]];
                [redirectRequest setAllHTTPHeaderFields:[_request allHTTPHeaderFields]];
                
                if([[__self initialParameters] isKindOfClass:[NSDictionary class]]){
                    ConnectionLog(@"[__self initialParameters] %@", [__self initialParameters]);
                    NSError *_error;
                    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:[__self initialParameters] options:NSJSONWritingPrettyPrinted error:&_error];
                    [redirectRequest setHTTPBody:jsonData];
                    [redirectRequest setValue:APPLICATION_JSON forHTTPHeaderField:HTTP_CONTENT_TYPE];
                }
                
                ConnectionLog(@"[redirectRequest HTTPBody] %@", [redirectRequest HTTPBody]);
                ConnectionLog(@"redirectRequest HTTPHeaders %@", [redirectRequest allHTTPHeaderFields]);
                ConnectionLog(@"STEP#7 Finally calling the initial service");
                return redirectRequest;
            } else {
                return _request;
            }
        }];
        
        if (isAuthenticationRequest || fromAuthentificationRequest) {
            [operation start];
        } else {
            [requestQueue enqueue:self];
        }
        
    } else {
        isServiceInaccessible = YES;
        [self sendErrorToUI:connectionError];
    }
}

- (BOOL)shouldTrustProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    // Load up the bundled certificate.
    //NSString *certPath = [[NSBundle mainBundle] pathForResource:@"cacert" ofType:@"der"];
    NSString *idEnv = [AccesToUserDefaults getUserInfoIdEnv];
    NSString *certPath = [[NSBundle mainBundle] pathForResource:@"cacert" ofType:@"der" inDirectory:idEnv];
    NSData *certData = [[NSData alloc] initWithContentsOfFile:certPath];
    CFDataRef certDataRef = CFDataCreate(NULL, [certData bytes], [certData length]);
    SecCertificateRef cert = SecCertificateCreateWithData(NULL, certDataRef);
    
    // Establish a chain of trust anchored on our bundled certificate.
    CFArrayRef certArrayRef = CFArrayCreate(NULL, (void *)&cert, 1, NULL);
    SecTrustRef serverTrust = protectionSpace.serverTrust;
    SecTrustSetAnchorCertificates(serverTrust, certArrayRef);
    
    // Verify that trust.
    SecTrustResultType trustResult;
    SecTrustEvaluate(serverTrust, &trustResult);
    
    // Did our custom trust chain evaluate successfully?
    return trustResult == kSecTrustResultUnspecified;
}

- (NSString *)applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

- (void)handleRequestError:(AFHTTPRequestOperation*)_operation error:(NSError*)_error {
    
    if (canceled) {
        return;
    }
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
    sendError = YES;
    httpStatusCode = [_operation.response statusCode];
    responseHeaders = [_operation.response allHeaderFields];
    mimeType = [_operation.response MIMEType];
    
    NSString *error404 = NSLocalizedString(@"ERREUR_404_DL_NEW_APPLI", @"Veuillez télécharger la dernière version de l'application");
    ConnectionLog(@"Error Status Code: %d",httpStatusCode);
    ConnectionLog(@"Error : %@",_error);
    ConnectionLog(@"Response Error Headers: %@", responseHeaders);
    ConnectionLog(@"Response Error frow request URL : %@", operation.request.description);
    
    if ([self catchSearchFolderErrorByFolderID:operation.request.HTTPBody] != nil){
        NSMutableDictionary *wrongFolderInitDict = [AccesToUserDefaults getUserInfoWrongFolderInitDictionary];
        if (!wrongFolderInitDict){
            wrongFolderInitDict = [[NSMutableDictionary alloc] init];
        }
        NSString *key = [NSString stringWithFormat:@"%@%@",FOLDER_ID,[self catchSearchFolderErrorByFolderID:operation.request.HTTPBody]];
        [wrongFolderInitDict setObject:[NSNumber numberWithBool:YES] forKey:key];
        [AccesToUserDefaults setUserInfoWrongFolderInitDictionary:wrongFolderInitDict];
    }
    
    switch (httpStatusCode) {
        default:
            uiError = serviceNotAvailableError;
            break;
        case 500:
            uiError = [[Error alloc] initWithParsingBody:_error httpStatus:httpStatusCode];
            break;
        case 404:
            uiError = [[Error alloc] initWithErrorCode:ERROR_TO_DISPLAY_IN_CONTROLER httpStatusCode:httpStatusCode errorMsg:error404];
            break;
        case 403:
            if (isAuthenticationRequest){
                NSString* xErrorCode = [responseHeaders objectForKey:X_ERROR_CODE];
                int errorCode = [[xErrorCode substringWithRange: NSMakeRange(0, [xErrorCode rangeOfString: @";"].location)] intValue];
                NSString *errorMessage = nil;
                if (errorCode == 22){
                    errorMessage = NSLocalizedString(@"COMPTE_BLOQUE", @"Compte bloqué");
                }
                else if (errorCode == 11 || errorCode == 15 || errorCode == 16){
                    errorMessage = NSLocalizedString(@"VEUILLEZ_VOUS_ENROLLER_DE_NOUVEAU", @"Veuillez vous enrôler de nouveau");
                    
                    /* @WX - Anomalie 18086
                     * Problème : A l'étape 1 d'enrôlement, on a un affichage d'erreur "Veuillez vous enrôler de nouveau"
                     * Solution : Mettre un booléen pour savoir si on est bien à cette étape
                     *
                     * (cf. MasterViewController -> syncError & ConnectionController -> login)
                     */
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:IS_NOT_ENROLLEMENT]) {
                        /* @WX - Anomalie 17999
                         * Problème : Suite au message d'erreur, l'application mobile se retrouve bloquer sur la boîte de réception
                         * Solution : Redirection de l'application vers la 1ère étape de l'enrôlement
                         */
                        [[NSNotificationCenter defaultCenter] postNotificationName:REENROLLEMENT_NOTIF object:nil];
                        
                        /* @WX - Anomalie 18086 
                         * L'utilisateur est dans l'enrôlement
                         */
                        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:IS_NOT_ENROLLEMENT];
                    }
                    /* @WX - Fin des modifications */
                }
                else if (errorCode == 44){
                    errorMessage = NSLocalizedString(@"CANAL_BLOQUE", @"Le canal associé à votre mobile est bloqué");
                }
                else if (errorCode == 2){
                    errorMessage = NSLocalizedString(@"SERVICE_INDISPONIBLE", @"Service momentanément indisponible");
                }
                else if (errorCode == 17){
                    errorMessage = NSLocalizedString(@"INFO_CONNEXION_INVALID", @"Les informations de connexion sont invalides");
                }
                else if (errorCode == 8){
                    errorMessage = NSLocalizedString(@"AUTHENTIFICATION_IMPOSSIBLE", @"Authentification impossible, veuillez réessayer");
                }
                uiError = [[Error alloc] initWithErrorCode:errorCode httpStatusCode:httpStatusCode errorMsg:errorMessage];
                ConnectionLog(@"uiError %@",uiError);
                ConnectionLog(@"errorCode : %d", errorCode);
                
                //Pour ne pas revenir a la vue précedente en cas de nouvel utilisateur
                BOOL firstAuthent = [AccesToUserDefaults getUserInfoChoiceMail] == nil ;
                [self authenticationError:firstAuthent];
            }
            else {
                uiError = [[Error alloc] initWithParsingBody:_error httpStatus:httpStatusCode];
                ConnectionLog(@"uiError.errorCode %d",uiError.errorCode);
                if ([uiError errorCode] == 42){
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[uiError title]
                                                                    message:NSLocalizedString(@"ADRESSE_MESSAGERIE_INVALIDE", @"Votre adresse de messagerie n'est pas reconnue, veuillez-vous réenrôller")
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                                          otherButtonTitles:nil];
                    [alert show];
                    uiError = nil;
                }
                else if (uiError.errorCode == 45){
                    if (isModification) {
                        uiError.errorCode = 4500;
                    }
                    
                    if (!isError45Request) {
                        error45 = [[Error45 alloc] initWithService:service andParams:parameters andDelegate:delegate];
                        error45.isModification = isModification;
                        [error45 execute];
                    } else {
                        ConnectionLog(@"error 45 for error45 request");
                        ConnectionLog(@"Delegate %@", delegate);
                    }
                    
                } 
            } 
            break;
        case 401:
            if(isAuthenticationRequest) {                nextUrl = nil;
                
                if([responseHeaders objectForKey:HTTP_HEADER_SET_COOKIE] && [responseHeaders objectForKey:HTTP_HEADER_WWW_AUTH]) {
                    wwwAuth = [responseHeaders objectForKey:HTTP_HEADER_WWW_AUTH];
                    nextUrl = [[NSString alloc] initWithFormat:@"%@%@",ID_PROVIDER_DOMAIN, [self regexFindMatch:wwwAuth pattern:@"OTP nextUrl=(.+)"]];
                    
                    if([nextUrl length] > 0) {
                        [auth setOtpSubmitURL:nextUrl];
                        sendError = NO;
                        [self sendResponseToUI:WAIT_FOR_OTP];
                    } else {
                        ConnectionLog(@"Can't Parse Cookies during authentication");
                        [auth reset];
                    }
                } else {
                    ConnectionLog(@"cookies and nextUrl don't exist");
                }
                
                if (sendError) {
                    [self authenticationError:NO];
                }

            } else {
                [auth reset];
                ConnectionLog(@"401 but not authnRequest");
            }
            uiError = authError;
            break;
        case 400:
            if (isAuthenticationRequest) {
                [self authenticationError:NO];
            }
            uiError = [[Error alloc] initWithParsingBody:_error httpStatus:httpStatusCode]; 
            break;
    }
    ConnectionLog(@"SendError %d",sendError);
    if(sendError) {
        ConnectionLog(@"Delegate %@", delegate);
        if (!isAuthenticationRequest || (httpStatusCode == 403)) {
            ConnectionLog(@"isAuthenticationRequest or httpStatusCode 403");
            [requestQueue execute];
        }
//        if (uiError.errorCode != 45) {
            ConnectionLog(@"send error to UI");
            [self sendErrorToUI:uiError];
//        }
        
    } else {
        ConnectionLog(@"isAuthenticationRequest %d",isAuthenticationRequest);
        ConnectionLog(@"httpStatusCode %d",httpStatusCode);
        ConnectionLog(@"service %@", service);
        ConnectionLog(@"RequestQueue %d", requestQueue.queue.count);
        if (requestQueue.queue.count > 0) {
            for (Request *r in requestQueue.queue) {
                ConnectionLog(@"r.service %@ r.url %@",r.service, r.url);
            }
        }
    }
}

-(void)authenticationError:(BOOL)fromAuth {
    ConnectionLog(@"authenticationError");
    NSLog(@"authenticationError");
    if (!uiError) {
        uiError = serviceNotAvailableError;
    }
    
    isAuthenticationError = YES;
    isServiceInaccessible = YES;
    if (!fromAuth) {
        for (Request *queueRequest in requestQueue.queue) {
            [queueRequest sendErrorToUI:uiError];
        }
    }
    
    
    [requestQueue empty];
   // if (![PasswordStore plainPasswordIsSet]) {
    
    if (!fromAuth) {
        //#jnicco ajouter pour eviter un retour arriere intempestif lorsqu'on se réenrolle et qu'une erreur d'authent survient
        //TODO Verifez que cela ne compromet pas le systeme de retour automatique en cas de mauvaise authent en cours de sessions
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            //reset cookies
            [[NSNotificationCenter defaultCenter] postNotificationName:DECONNEXION_NOTIF object:nil];
        });
    }
   //}
}

//-(void)deleteModif:(NSMUtableArray*) listMsgId{
//    ModificationDAO *modificationDAO = (ModificationDAO*)[[DAOFactory factory] newDAO:ModificationDAO.class];
//    for (int i = 0; i < listMsgId.count; i++){
//        Modification *modificationDAO = [modificationDAO findModificationByMessageId:[listMsgId objectAtIndex:i]];
//        modificationDAO delete:<#(id)#>
//    }
//}

-(void)handleError45 {
    
//    __strong Error45 *error45 = [[Error45 alloc] initWithService:service andParams:parameters andDelegate:delegate];
//    error45.isModification = isModification;
//    [error45 execute];
    
//    NSMutableDictionary *messageInput;
//    NSString *op;
//    if ([service isEqualToString:S_ITEM_UPDATE_MESSAGES]) {
//        if ([parameters objectForKey:UPDATE_MESSAGES_INPUT]) {
//            messageInput = [parameters objectForKey:UPDATE_MESSAGES_INPUT];
//        }
//        if ([messageInput objectForKey:OPERATION]) {
//            op = [messageInput objectForKey:OPERATION];
//        }
//    }
//    
//    else if ([service isEqualToString:S_ITEM_MOVE_MESSAGES]) {
//        if ([parameters objectForKey:MOVE_MESSAGES_INPUT]) {
//            messageInput = [parameters objectForKey:MOVE_MESSAGES_INPUT];
//        }
//        op = MOVE;
//    }
//    
//    ConnectionLog(@"messageInput %@", messageInput);
//    if ([messageInput objectForKey:MESSAGE_IDS] && [[messageInput objectForKey:MESSAGE_IDS] isKindOfClass:[NSArray class]]){
//        listMessageIdForError45 = [[messageInput objectForKey:MESSAGE_IDS] mutableCopy];
//        
//        ConnectionLog(@"listMsgIds : %@", listMessageIdForError45);
//        ConnectionLog(@"ope : %@", op);
//        if (listMessageIdForError45.count > 1){
//            ConnectionLog(@"call methode 45");
//            GestionError45 *gestionError45 = [[GestionError45 alloc] initWithListMsgId:listMessageIdForError45 andOperation:op withDelegate:delegate type:service];
//            if ([service isEqualToString:S_ITEM_MOVE_MESSAGES]) {
//                [gestionError45 setDestinationFolderId: [messageInput objectForKey:DESTINATION_FOLDER_ID ]];
//            }
//            [gestionError45 execute];
//        }
//        else if (listMessageIdForError45.count == 1){
//            ConnectionLog(@"error 45 for just msgId : %@", listMessageIdForError45);
//            MessageDAO *messageDAO = (MessageDAO*)[[DAOFactory factory] newDAO:MessageDAO.class];
//            Message* msg = [messageDAO findMessageByMessageId:[listMessageIdForError45 objectAtIndex:0]];
//            if (msg != nil){
//                [messageDAO deleteObject:msg];
//                [self saveDB];
//            }
//        }
//    }
}

-(void)saveForModification{
    
    if ((![self isConnectedToInternet] || (uiError != nil && uiError.errorCode != 45)) && !isModification){
        
        ConnectionLog(@"listMessageIdForModification %@",listMessageIdForModification);
        
        if ([service isEqualToString:S_ITEM_UPDATE_MESSAGES]){
            NSString *updateOperation = nil;
            if ([[parameters objectForKey:UPDATE_MESSAGES_INPUT] objectForKey:OPERATION]) {
                updateOperation = [[parameters objectForKey:UPDATE_MESSAGES_INPUT] objectForKey:OPERATION];
            }
            
            // pour les messages à supprimer
            if ([updateOperation isEqualToString:O_DELETE]) {
                // si erreur technique 1, relancer DELETE pour chaque message
                if ([uiError.errorType isEqualToString:ERROR_TYPE_TECHNIQUE] && listMessageIdForModification.count > 1 && uiError.errorCode == 1) {
                    for (NSNumber *messageId in listMessageIdForModification) {
                        UpdateMessagesInput* updateInput = [[UpdateMessagesInput alloc] init];
                        [updateInput.messageIds addObject:messageId];
                        [updateInput setOperation:O_DELETE];
                        [self saveModificationInDatabase:messageId operation:DELETE params:[updateInput generate]];
                    }
                }
                // si service inacessible, on garde l'action
                else if (isServiceInaccessible || isAuthenticationError) {
                    [self saveModificationInDatabase:nil operation:DELETE params:parameters];
                }
            } else {
                // si service inacessible, on garde l'action
                if (isServiceInaccessible || isAuthenticationError) {
                    [self saveModificationInDatabase:nil operation:UPDATE params:parameters];
                }
                else if (listMessageIdForModification.count > 0) {
                    for (NSNumber *messageId in listMessageIdForModification){
                        Modification* modif = [NSEntityDescription insertNewObjectForEntityForName: @"Modification" inManagedObjectContext: [[DAOFactory factory] managedObjectContext]];
                        NSMutableDictionary *newParams = [parameters mutableCopy];
                        if ([[newParams objectForKey:UPDATE_MESSAGES_INPUT] objectForKey:MESSAGE_IDS] ) {
                            NSMutableArray *messageIds = [[newParams objectForKey:UPDATE_MESSAGES_INPUT] objectForKey:MESSAGE_IDS];
                            for (NSNumber *msgId in messageIds) {
                                if (![messageId isEqualToNumber:msgId]) {
                                    [messageIds removeObject:msgId];
                                }
                            }
                        }
                        modif.messageId = messageId;
                        modif.operation = UPDATE;
                        modif.argument = newParams;
                        modif.date = [NSDate date];
                        [self saveDB];
                    }
                }
            }
        }
        else if ([service isEqualToString:S_ITEM_MOVE_MESSAGES]){
            if (isServiceInaccessible || isAuthenticationError) {
                [self saveModificationInDatabase:nil operation:MOVE params:parameters];
            }
            else if (listMessageIdForModification.count > 0) {
                for (NSNumber *messageId in listMessageIdForModification){
                    Modification* modif = [NSEntityDescription insertNewObjectForEntityForName: @"Modification" inManagedObjectContext: [[DAOFactory factory] managedObjectContext]];
                    NSMutableDictionary *newParams = [parameters mutableCopy];
                    if ([[newParams objectForKey:MOVE_MESSAGES_INPUT] objectForKey:MESSAGE_IDS] ) {
                        NSMutableArray *messageIds = [[newParams objectForKey:MOVE_MESSAGES_INPUT] objectForKey:MESSAGE_IDS];
                        for (NSNumber *msgId in messageIds) {
                            if (![messageId isEqualToNumber:msgId]) {
                                [messageIds removeObject:msgId];
                            }
                        }
                    }
                    modif.messageId = messageId;
                    modif.operation = MOVE;
                    modif.argument = newParams;
                    modif.date = [NSDate date];
                    [self saveDB];
                }
            }
        }
        else if ([service isEqualToString:S_FOLDER_EMPTY]){
            if (trashMessageIds.count > 0) {
                UpdateMessagesInput* updateInput = [[UpdateMessagesInput alloc] init];
                [updateInput setMessageIds:trashMessageIds];
                [updateInput setOperation:O_DELETE];
                Modification* modif = [NSEntityDescription insertNewObjectForEntityForName: @"Modification" inManagedObjectContext: [[DAOFactory factory] managedObjectContext]];
                modif.messageId = nil;
                modif.operation = DELETE;
                modif.argument = [updateInput generate];
                modif.date = [NSDate date];
                [self saveDB];
            }
        }
    }
}


-(void)saveModificationInDatabase:(NSNumber*)messageId operation:(NSString*)op params:(id)argument {
    Modification* modif = [NSEntityDescription insertNewObjectForEntityForName: @"Modification" inManagedObjectContext: [[DAOFactory factory] managedObjectContext]];
    modif.messageId = messageId;
    modif.operation = op;
    modif.argument = argument;
    modif.date = [NSDate date];
    [self saveDB];
}


-(NSString*)catchSearchFolderErrorByFolderID: (NSData*)_httpBody{
    NSString* folderId = [[[[(NSDictionary*)[self parseJsonData:_httpBody] objectForKey:SEARCH_MESSAGES_INPUT] objectForKey:SEARCH_CRITERIA] objectForKey:QUERY] objectForKey:FOLDER_ID];
    return folderId;
}

- (void)handleRequestSuccess:(AFHTTPRequestOperation*)_operation response:(id)_response{
    if (canceled) {
        return;
    }
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
    httpStatusCode = 0;
    responseObject = nil;
    sendError = NO;
    sendResponse = YES;
    httpStatusCode = [_operation.response statusCode];
    NSLog(@"httpStatusCode %d",httpStatusCode);
    
    ConnectionLog(@"delegate %@",delegate);
    ConnectionLog(@"isError45 %d",isError45Request);
    // check if response body is not null
    if(_response != nil && httpStatusCode != HTTP_OK) {
        
        
        if ([_response isKindOfClass:[NSString class]]) {
            responseString = _response;
        } else if([_response isKindOfClass:[NSData class]]) {
            responseString = [[NSString alloc] initWithData:_response encoding:NSUTF8StringEncoding];
        } else {
            responseString = [_operation responseString];
        }
        
        mimeType = [_operation.response MIMEType];
        responseHeaders = [_operation.response allHeaderFields];
        ConnectionLog(@"Response MIMEType: %@" ,mimeType);
        ConnectionLog(@"Response Headers: %@", responseHeaders);
        if (responseString.length < 5000) {
            ConnectionLog(@"Response String: %@",responseString);
        }
        
        
        // check if the response content-type is application/json
        if([APPLICATION_JSON isEqualToString:mimeType]) {
            ConnectionLog(@"APPLICATION/JSON");
            if([self parseJsonData:_response] != nil && service != nil) {
                ConnectionLog(@"PARSING DATA %@",service);
                if (tmpPassword.length > 0) {
                    ConnectionLog(@"Request : HandleSuccess");
                   
                    
                    PasswordStore *passwordInstance = [PasswordStore getInstanceWithPlainPassword:tmpPassword];
  
                    NSString *key = [passwordInstance getPlainDbEncryptionKey];
                    ConnectionLog(@"Request - HandleSuccess - setKey : %@", key);
                    [DAOFactory setKey:key];
                    DAOFactory *factory = [DAOFactory factory];
                    ConnectionLog(@"factory %@",factory);
                    if (factory.managedObjectContext == nil) {
                        ConnectionLog(@"Request : HandleSuccess : creating managedObjectContext");
                        if ([factory resetManagedObjectContext] != nil) {
                            [factory.managedObjectContext setRetainsRegisteredObjects:YES];
                            ConnectionLog(@"[factory managedObjectContext] %@",factory.managedObjectContext );
                        } else {
                            
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                            message:NSLocalizedString(@"PROBLEME_BD", @"Problème d'initialisation de base de données")
                                                                           delegate:nil
                                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                                                  otherButtonTitles:nil];
                            [alert show];
                            ConnectionLog(@"Request : HandleSuccess : probleme creating managedObjectContext");
                            
                            [PasswordStore resetPasswords];
                             NSLog(@"PasswordStore resetPasswords");
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName:DECONNEXION_NOTIF object:ENROLLEMENT];
                            
                            return;
                        }
                        
                    }
                    tmpPassword = nil;
                }
                responseObject = [self getResponseObjectFromJsonObject:jsonObject];
            } else {
                uiError = wrongResponseError;
                ConnectionLog(@"ERROR %@",service);
            }
        }
        
        // if response content-type is text/xml (AuthnRequest or SAMLAssertion)
        else if([TEXT_XML isEqualToString:mimeType] || [APPLICATION_VND_PAOS_XML isEqualToString:mimeType]) {
            if(!isAuthenticationRequest && !isEnrolmentRequest) {
                if([responseHeaders isKindOfClass:[NSDictionary class]]) {
                        assertionConsumerServiceURL = [self regexFindMatch:responseString pattern:@"AssertionConsumerServiceURL=\"([^\"]+)(\")"];
                        authnRequest = [self regexReplaceMatch:responseString pattern:@"<soap11:Header>.*</soap11:Header>" replacement:@"<soap11:Header></soap11:Header>"];
                        
                        [auth setAssertionConsumerServiceURL:assertionConsumerServiceURL];
                        [auth setAuthDelegate:self];
                        BOOL isAuth = NO;
                        if ([S_CHANGE_NOTIF_STATE isEqualToString:service] || [S_MODIFIER_MDP isEqualToString:service]) {
                            isAuth = YES;
                        }
                    //#ANO 16503
                        [auth authentifierOtp:authnRequest authServer:isAuth];
                        sendError = NO;
                } else {
                    uiError = wrongResponseError;
                }
                sendResponse = NO;
            } else if(isAuthenticationRequest){
                responseObject = responseString;
            } else {
                uiError = wrongResponseError;
            }
        }
        // if response content-type is text/html
        else if([TEXT_HTML isEqualToString:mimeType]) {
            if (isAuthenticationRequest) {
                uiError = authError;
                [self authenticationError:NO];
            } else {
                uiError = wrongResponseError;
            }
        } else {
            uiError = wrongResponseError;
        }
    }
    else if (httpStatusCode == HTTP_OK) {
        ConnectionLog(@"Response Object %@",service);
        responseObject = service;
    }
    
    //    else {
    //        // No Response Body
    //        sendError = NO;
    //    }
    
    if (uiError) {
        sendError = YES;
    }
    
    if (isAuthenticationRequest) {
        ConnectionLog(@"isAuthenticationRequest");
    }
    
    ConnectionLog(@"Delegate %@", delegate);
    if ((sendError || sendResponse) && !isAuthenticationRequest) {
        [requestQueue execute];
    }
    
    ConnectionLog(@"sendResponse %d",sendResponse);
    if (sendError) {
        [self sendErrorToUI:uiError];
    } else if (sendResponse) {
        [self sendResponseToUI:responseObject];
    }
    
}

- (id)parseJsonString:(NSString*)_jsonString {
    return [self parseJsonData:[_jsonString dataUsingEncoding:NSUTF8StringEncoding]];
}

- (id)parseJsonData:(NSData*)_jsonData {
    id result = nil;
    if (_jsonData != nil) {
        NSError* jsonError = nil;
        jsonObject = [NSJSONSerialization JSONObjectWithData:_jsonData options:NSJSONReadingMutableContainers error:&jsonError];
        isValidJson = [NSJSONSerialization isValidJSONObject:jsonObject];
        if(isValidJson) {
            result = jsonObject;
        }
    }
    return result;
}

- (NSString*)capitalizeString:(NSString*)_str {
    NSString *cappedString = _str;
    if([_str length] > 0) {
        NSString *firstCapChar = [[_str substringToIndex:1] capitalizedString];
        cappedString = [_str stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:firstCapChar];
    }
    return cappedString;
}

- (NSString*)regexFindMatch:(NSString*)_string pattern:(NSString*)_pattern {
    NSError  *regexError  = nil;
    NSString *result = @"";
    if ([_string length] > 0 && [_pattern length] > 0) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:_pattern options:NSRegularExpressionCaseInsensitive error:&regexError];
        if(!regexError) {
            NSTextCheckingResult *textCheckingResult = [regex firstMatchInString:_string options:0 range:NSMakeRange(0, _string.length)];
            NSRange matchRange = [textCheckingResult rangeAtIndex:1];
            result = [_string substringWithRange:matchRange];
        }
    }
    return result;
}

- (NSString*)regexReplaceMatch:(NSString*)_string pattern:(NSString*)_pattern replacement:(NSString*)_replacement {
    NSMutableString *result = nil;
    if ([_string length] > 0 && [_pattern length] > 0 && [_replacement length] > 0) {
        result = [[NSMutableString alloc] initWithString:_string];
        NSError *regexError = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:_pattern options:NSRegularExpressionCaseInsensitive error:&regexError];
        if(!regexError) {
            [regex replaceMatchesInString:result options:0 range:NSMakeRange(0, [result length]) withTemplate:_replacement];
        }
    }
    return result;
}

- (id)getResponseObjectFromJsonData:(NSData*)_data {
    responseObject = nil;
    if(responseClassName != nil && NSClassFromString(responseClassName)) {
        NSString *_responseString = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
        id responseClass = [[NSClassFromString(responseClassName) alloc] initWithJsonString:_responseString];
        if(responseClass != nil) {
            responseObject = [responseClass parseJSONObject];
        }
    }
    return responseObject;
}

- (id)getResponseObjectFromJsonObject:(id)_jsonObject {
    responseObject = nil;
    if(responseClassName != nil && NSClassFromString(responseClassName)) {
        id responseClass = [[NSClassFromString(responseClassName) alloc] initWithJsonObject:_jsonObject];
        if(responseClass != nil) {
            [responseClass parseJSONObject];
            responseObject = responseClass;
        }
    }
    return responseObject;
}

- (BOOL)isConnectedToInternet {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        ConnectionLog(@"NO INTERNET");
        return NO;
    } else {
        return YES;
    }
}

- (void)sendErrorToUI:(Error*)_error {
    
    [self saveForModification];
    
    [_error setService:service];
    [_error setParams:parameters];
    if ([delegate isKindOfClass:[Error45 class]]) {
        ConnectionLog(@"Error 45 delegate");
    } else {
        ConnectionLog(@"delegate : %@", delegate);
    }
    
    if([delegate respondsToSelector:@selector(httpError:)]){
        [delegate httpError:_error];
    }
}

- (void)sendResponseToUI:(id)_response {
    ConnectionLog(@"delegate : %@", delegate);
    if([delegate respondsToSelector:@selector(httpResponse:)]){
        [delegate httpResponse:_response];
    }
}

- (void)authResponse:(id)_authInfo {
    sendError = YES;
    if([_authInfo isKindOfClass:[NSDictionary class]] && [_authInfo objectForKey:ASSERTION_CUSTOMER_SERVICE_URL] != nil && [_authInfo objectForKey:ASSERTION_SAML] != nil) {
        ConnectionLog(@"STEP#5 Handle ValiderOtp");
        httpHeaders = [NSMutableDictionary dictionary];
        [httpHeaders setObject:HTTP_HEADER_ACCEPT_PAOS forKey:HTTP_CONTENT_TYPE];
        
        samlAssertion = [_authInfo objectForKey:ASSERTION_SAML];
        samlAssertion = [self regexReplaceMatch:samlAssertion pattern:@"<soap-env:Header>.*</soap-env:Header>" replacement:@"<soap-env:Header></soap-env:Header>"];
        
        initialParameters = parameters;
        parameters = samlAssertion;
        
        assertionConsumerServiceURL = [_authInfo objectForKey:ASSERTION_CUSTOMER_SERVICE_URL];
        
        ConnectionLog(@"STEP#6 Calling service: %@ Again",service);
        
        [self setUrl:assertionConsumerServiceURL];
        [self setMethod:HTTP_POST];
        [requestQueue dequeue];
        fromAuthentificationRequest = YES;
        [self execute];
        sendError = NO;
        //@TD 16670
        /* @WX - Anomalie liée au 18017
         * Problème survenu : Pendant l'écriture d'un nouveau message (ou lecture d'un message),
         * l'utilisateur désire se déconnecter sans changer de page (ou de vue). L'aplication se déconnecte bien
         * mais elle se reconnecte automatiquement sans que l'utilisateur ait besoin de mettre son mot de passe.
         *
         * Solution apportée : Mettre un booléen permettant de savoir si l'utilisateur s'est connecté ou pas
         * [[NSUserDefaults standardUserDefaults] boolForKey:@"isAbleToConnect"]
         */
        if([AccesToUserDefaults getUserInfoChoiceMail] != nil && [AccesToUserDefaults getUserInfoSyncToken] !=nil
           && [[NSUserDefaults standardUserDefaults] boolForKey:IS_ABLE_TO_CONNECT]){
            [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_SUCCESSFUL_NOTIF object:nil];
        }
        
    }
    
    if(sendError) {
        [self sendErrorToUI:authError];
    }
}

- (void) authError:(id)_error {
    [self authenticationError:YES];
    [self sendErrorToUI:_error];
}

-(void)saveDB{
    NSError *error;
    if (![[DAOFactory factory] save:&error]) {
        ConnectionLog(@"error save %@", [error userInfo]);
    }
}

@end
