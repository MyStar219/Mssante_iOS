//
//  Constant.h
//  MSSante
//
//  Created by labinnovation on 14/06/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#ifndef MSSante_Constant_h
#define MSSante_Constant_h

////Debug
//#define DISABLE_ENROLLEMENT             false
//#define DISABLE_RECUPERERBAL            false
//#define DISABLE_AUTHTENT                false
//#define DISABLE_PUSH                    false
//#define DISABLE_ENREGISTRER_CANAL       false

/* @WX - Anomalie liée au 18017
 * Un booléen pour savoir si l'utilisateur est connecté ou pas
 * (en ayant appuyé sur le bouton "Valider")
 */

#define IS_ABLE_TO_CONNECT              @"isAbleToConnect"

/* @WX - Anomalie 18086
 * Un booléen pour savoir si l'utilisateur est dans l'enrôlement ou pas
 */
#define IS_NOT_ENROLLEMENT              @"isNotEnrollement"

/* @WX - Fin des modifications */

//Display
#define WIDTH_BACK_MENU                 270
#define HEIGHT_HEADER_BACK_MENU         60
#define HEIGHT_FOOTER_BACK_MENU         50
#define kOFFSET_FOR_KEYBOARD            120.0
#define SLIDE_TIMING                    0.25

//Segue
#define MASTER_SEGUE                    @"segueToMaster"
#define DOSSIER_SEGUE                   @"segueToDossier"

//Regle de gestion
#define MIN_PASSWORD                    4
#define MAX_PASSWORD                    255
//User
#define AUTH_TOKEN                      @"AuthToken"
#define ASSERTION_SAML                  @"AssertionSAML"
#define OTP                             @"OTP"
#define USER_ID                         @"userId"

//Folder
#define FOLDER                          @"folder"
#define FOLDERS                         @"folders"
#define FOLDER_ID                       @"folderId"
#define FOLDER_NAME                     @"folderName"
#define FOLDER_NB_MESSAGES              @"folderNbMessages"
#define FOLDER_NB_UNREAD                @"folderNbUnread"
#define FOLDER_PARENT_ID                @"folderParentId"
#define NEW_FOLDER_NAME                 @"newFolderName"
#define DESTINATION_FOLDER_ID           @"destinationFolderId"
#define TOKEN                           @"token"
#define LIST_FOLDERS_OUTPUT             @"listFoldersOutput"
#define LIST_FOLDERS_INPUT              @"listFoldersInput"
#define SYNC_MESSAGES_OUTPUT            @"syncMessagesOutput"
#define SYNC_MESSAGES_INPUT             @"syncMessagesInput"
#define RENAME_FOLDER_OUTPUT            @"renameFolderOutput"
#define RENAME_FOLDER_INPUT             @"reameFolderInput"
#define EMPTY_FOLDER_OUTPUT             @"emptyFolderOutput"
#define EMPTY_FOLDER_INPUT              @"emptyFolderInput"
#define CREATE_FOLDER_OUTPUT            @"createFolderOutput"
#define CREATE_FOLDER_INPUT             @"createFolderInput"
#define TRASH_FOLDER_OUTPUT             @"trashFolderOutput"
#define TRASH_FOLDER_INPUT              @"trashFolderInput"
#define MOVE_FOLDER_OUTPUT              @"moveFolderOutput"
#define MOVE_FOLDER_INPUT               @"moveFolderInput"
#define DELETE_FOLDER_OUTPUT            @"deleteFolderOutput"
#define DELETE_FOLDER_INPUT             @"deleteFolderInput"

//Sync
#define DELETED_MESSAGE_ID             @"deletedMessageIds"
#define MODIFIED_MESSAGES               @"modifiedMessages"

//Message
#define MESSAGE                         @"message"
#define MESSAGES                        @"messages"
#define MESSAGE_ID                      @"messageId"
#define IS_READ                         @"isRead"
#define IS_FAVOR                        @"isFavor"
#define IS_URGENT                       @"isUrgent"
#define IS_ATTACHMENT                   @"isAttachment"
#define MESSAGE_TRANSFERED_ID           @"messageTransferedId"
#define CONVERSATION_ID                 @"conversationId"
#define FLAGS                           @"flags"
#define DATE                            @"date"
#define SIZE                            @"size"
#define EMAILS                          @"emails"
#define ADDRESSES                       @"addresses"
#define EMAIL                           @"email"
#define E_ADDRESS                       @"address"
#define E_EMAIL                         @"email"
#define E_ADDRESSES                     @"addresses"
#define E_NAME                          @"name"
#define E_TYPE                          @"type"
#define SUBJECT                         @"subject"
#define REPLY_TYPE                      @"replyType"
#define FORWARDED                       @"FORWARDED"
#define REPLIED                         @"REPLIED"
#define MSG_DETAIL                      @"MsgDetail"
#define FROM_ANNAUIRE                   @"FromAnnuaire"
#define CURRENT_NAV_CONTROLLER          @"CurrentNavigationController"
#define CURRENT_VIEW_CONTROLLER         @"CurrentViewController"
#define PRIORITY                        @"priority"
#define BODY                            @"body"
#define IS_BODY_LARGER                  @"isBodyLarger"
#define SHORT_BODY                      @"shortBody"
#define FRAGMENT                        @"fragment"
#define IS_HTML                         @"isHTML"
#define IS_ACCUSE                       @"isAccuse"
#define ATTACHMENTS                     @"attachments"
#define ID_ATTACHMENTS_REMOVE           @"idAttachmentsRemove"
#define ATTACHMENT                      @"attachment"
#define ATTACHMENT_ID                   @"attachmentId"
#define A_PART                          @"part"
#define A_CONTENT_TYPE                  @"contentType"
#define A_FILENAME                      @"fileName"
#define A_FILE_ID                       @"fileId"
#define A_FILE                          @"file"
#define SEND_MESSAGE_INPUT              @"sendMessageInput"
#define SEND_MESSAGE_OUTPUT             @"sendMessageOutput"
#define SEND_INPUT_GENERATE             @"sendInputGenerate"
#define ATTACHMENT_DATA                 @"attachmentData"
#define ATTACHMENT_BYTES                @"attachmentBytes"
#define DRAFT_MESSAGES_INPUT            @"draftMessageInput"
#define DRAFT_MESSAGES_OUTPUT           @"draftMessageOutput"
#define UPDATE_MESSAGES_INPUT           @"updateMessagesInput"
#define UPDATE_MESSAGES_OUTPUT          @"updateMessagesOutput"
#define MOVE_MESSAGES_INPUT             @"moveMessagesInput"
#define MOVE_MESSAGES_OUTPUT            @"moveMessagesOutput"
#define MESSAGE_IDS                     @"messageIds"
#define FLAG                            @"flag"

#define ATTACHMENTS_TEMP                @"attachmentsTemp"

#define DOWNLOAD_ATTACHMENT_INPUT       @"downloadAttachmentInput"
#define DOWNLOAD_ATTACHMENT_OUTPUT      @"downloadAttachmentOutput"

//Conversation
#define CONVERSATION                    @"conversation"
#define CONVERSATIONS                   @"conversations"
#define NUMBER_OF_MESSAGES              @"numberOfMessages"

//Modification
#define SEND                            @"Send"
#define UPDATE                          @"Update"
#define REPLY                           @"Reply"
#define FORWARD                         @"Forward"
#define DRAFT                           @"Draft"
#define MOVE                            @"Move"
#define DELETE                          @"Delete"
#define EMPTY                           @"Empty"


//Delegate detail-master
#define RESTORE_MESSAGE_DELEGATE        @"restoreMessageDelegate"
#define RELOAD_MESSAGE_DELEGATE         @"reloadMessageDelegate"
#define DELETE_MESSAGE_DELEGATE         @"deleteMessageDelegate"
#define MOVE_TO_FOLDER_DELEGATE         @"moveToFolderDelegate"
#define FOLLOW_DELEGATE                 @"followDelegate"
#define UNREAD_DELEGATE                 @"unreadDelegate"
#define TRASH_MESSAGE_DELEGATE          @"trashDelegate"

//Notifications
#define SLIDE_BACK_MENU_NOTIF           @"SlideToBackMenu"
#define LOGIN_SUCCESSFUL_NOTIF          @"LoginSuccessful"
#define OPEN_PREFERENCES                @"OpenPreference"
#define OPEN_ANNUAIRE                   @"OpenAnnuaire"
#define REENROLLEMENT_NOTIF             @"ReEnrollement"
#define DECONNEXION_NOTIF               @"Deconnexion"
#define FIRST_CONNEXION                 @"FirstConnexion"
#define NOT_FIRST_CONNEXION             @"NotFirstConnexion"
#define HIDE_POPUP_NOTIF                @"HidePopup"
#define UPDATE_NOTIF                    @"updateNotif"
#define REPLY_NOTIF                     @"reply"
#define SHOW_NEW_MSG_VIEW_NOTIF         @"showNewMsg"
#define HIDE_NEW_MSG_VIEW_NOTIF         @"hideNewMsg"
#define SHOW_MOVE_MSG_VIEW_NOTIF        @"showMoveMsg"
#define HIDE_MOVE_MSG_VIEW_NOTIF        @"hideMoveMsg"
#define HIDE_IMAGE_VIEWER_NOTIF         @"hideImageViewer"
#define HIDE_KEYBOARD                   @"hideKeyboard"
#define MESSAGE_SENT_NOTIF              @"messageSent"
#define REFRESH_CURRENT_FOLDER_NOTIF    @"refreshCurrentFolder"
#define UPDATE_CURRENT_FOLDER_NOTIF     @"updateCurrentFolder"
#define FOLDER_INITIALIZATION_FINISHED_NOTIF    @"folderInitializationFinished"
#define VIEW_ATTACHMENT_FROM_NEW_MSG    @"viewAttachmentFromNewMsg"
#define DID_SAVE_DRAFT_NOTIF            @"didSaveDraft"
//Email Types
#define E_FROM                          @"FROM"
#define E_TO                            @"TO"
#define E_CC                            @"CC"
#define E_BCC                           @"BCC"

#define MESSAGE_SET_ID                  @"MessageSetID"
#define OPERATION                       @"operation"
#define LIST_EMAILS_OUTPUT              @"listEmailsOutput"
#define LIST_EMAILS_INPUT               @"listEmailsInput"

//Operations
#define O_DELETE                        @"DELETE"
#define O_READ                          @"READ"
#define O_UNREAD                        @"UNREAD"
#define O_FLAGGED                       @"FLAGGED"
#define O_UNFLAGGED                     @"UNFLAGGED"
#define O_SPAM                          @"SPAM"
#define O_UNSPAM                        @"UNSPAM"
#define O_TRASH                         @"TRASH"

//Flags
#define F_UNREAD                        @"UNREAD"
#define F_FLAGGED                       @"FLAGGED"
#define F_ATTACHMENT                    @"ATTACHMENT"
#define F_REPLIED                       @"REPLIED"
#define F_SENT_BY_ME                    @"SENT_BY_ME"
#define F_DELETED                       @"DELETED"
#define F_DRAFT                         @"DRAFT"
#define F_FORWARDED                     @"FORWARDED"
#define F_URGENT                        @"URGENT"
#define F_LOW_PRIORITY                  @"LOW_PRIORITY"
#define F_PRIORITY                      @"PRIORITY"
#define F_PRIORITY_HIGH                 @"HAUTE"

//Folder Name
#define RECEPTION_FOLDER_NAME           @"Reception"
#define CORBEILLE_FOLDER_NAME           @"Corbeille"
#define ENVOYES_FOLDER_NAME             @"Envoyes"
#define BROUILLON_FOLDER_NAME           @"Brouillon"

//IdFolder
#define NON_LUS_ID_FOLDER               9
#define SUIVIS_ID_FOLDER                1
#define BOITE_D_ENVOI_ID_FOLDER         8
#define RECEPTION_ID_FOLDER             2
#define CORBEILLE_ID_FOLDER             3
#define ENVOYES_ID_FOLDER               5
#define BROUILLON_ID_FOLDER             6
#define DOSSIER_ID_FOLDER               10

//Annuaire
#define NOM_PRENOM_ANNUAIRE             @"nomPrenomAnnuaire"
#define PROFESSION_ANNUAIRE             @"professionAnnuaire"
#define ADRESSE_ANNUAIRE                @"adresseAnnuaire"
#define SEARCH_RECIPIENT_OUTPUT         @"searchRecipientOutput"
#define SEARCH_RECIPIENT_INPUT          @"searchRecipientInput"
#define SEARCH_STRING                   @"searchString"
#define PROFESSIONELS                   @"professionnels"
#define PROFESSION                      @"profession"
#define SPECIALITE                      @"specialite"
#define NUMERO_TEL                      @"numeroTelephone"
#define ADRESSES_MAIL                    @"adressesMail"
#define SITUATIONS_EXCERCICE            @"situationsExercice"
#define NOM_STRUCTURE                   @"nomStructure"
#define ADRESSE                         @"adresse"
#define CODE_POSTAL                     @"codePostal"
#define COMMUNE                         @"commune"
#define NOM                             @"nom"
#define PRENOM                          @"prenom"

//Search Criteria
#define SEARCH_MESSAGES_OUTPUT          @"searchMessagesOutput"
#define SEARCH_MESSAGES_INPUT           @"searchMessagesInput"
#define FULL_TEXT_SEARCH_MESSAGES_OUTPUT    @"fullTextSearchMessagesOutput"
#define FULL_TEXT_SEARCH_MESSAGES_INPUT     @"fullTextSearchMessagesInput"
#define SEARCH_CRITERIA                 @"searchCriteria"
//#define SEARCH_STRING                   @"searchString"
#define OFFSET                          @"offset"
#define LIMIT                           @"limit"
#define HTML                            @"html"
#define SORT_BY                         @"sortBy"
#define QUERY                           @"query"
#define Q_CONTENT                       @"content"
#define Q_SUBJECT                       @"subject"
#define Q_TO                            @"to"
#define Q_FROM                          @"from"
#define Q_CC                            @"cc"
#define Q_BCC                           @"bcc"
#define Q_FOLDER_ID                     @"folderId"
#define Q_INCLUDE_SUB_FOLDERS           @"includeSubfolders"
#define Q_IS_SENT                       @"isSent"
#define Q_BEFORE                        @"before"
#define Q_AFTER                         @"after"
#define Q_IS                            @"is"
#define Q_FLAGGED                       @"flagged"
#define Q_UNFLAGGED                     @"UnFlagged"
#define Q_DELETED                       @"deleted"
#define Q_UNDELETED                     @"UnDeleted"
#define Q_DRAFT                         @"draft"
#define Q_UNDRAFT                       @"UnDraft"
#define Q_SEEN                          @"seen"
#define Q_UNSEEN                        @"UnSeen"
#define Q_ANSWERED                      @"answered"
#define Q_UNANSWERED                    @"UnAnswered"
#define Q_LARGER                        @"larger"
#define Q_SMALLER                       @"smaller"

//Sort By
#define SB_NONE                         @"NONE"
#define SB_DATE_ASC                     @"DATE_ASC"
#define SB_DATE_DESC                    @"DATE_DESC"
#define SB_SUBJET_ASC                   @"SUBJET_ASC"
#define SB_SUBJET_DESC                  @"SUBJET_DESC"
#define SB_NAME_ASC                     @"NAME_ASC"
#define SB_NAME_DESC                    @"NAME_DESC"
#define SB_RECIPENT_ASC                 @"RECIPENT_ASC"
#define SB_RECIPENT_DESC                @"RECIPENT_DESC"
#define SB_ATTACHMENT_ASC               @"ATTACHMENT_ASC"
#define SB_ATTACHMENT_DESC              @"ATTACHMENT_DESC"
#define SB_FLAG_ASC                     @"FLAG_ASC"
#define SB_FLAG_DESC                    @"FLAG_DESC"
#define SB_PRIORITY_ASC                 @"PRIORITY_ASC"
#define SB_PRIORITY_DESC                @"PRIORITY_DESC"

#define URL_SEPARATOR                   @"/"

#define SERVER_AUTH_IDP                 @"openam/SSOSoap/metaAlias/asip/idp"

#define ANNUAIRE_SERVICE                @"mss-msg-services/services/Annuaire/rest/v1/"
#define CANAL_SERVICE                   @"mss-msg-services/services/Canal/rest/v1/"
#define NOTIFICATION_SERVICE            @"mss-auth-services/services/Notification/rest/v1/"
#define ATTACHMENT_SERVICE              @"mss-msg-services/services/Attachment/rest/v1/"
#define ENROLEMENT_SERVICE              @"mss-auth-services/services/Enrolement/rest/v1/"
//#define ADMINISTRATION_SERVICE          @"mss-auth-services/services/Enrolement/rest/v1/"
#define ADMINISTRATION_SERVICE          @"mss-auth-services/services/Administration/rest/v1/"
#define FOLDER_SERVICE                  @"mss-msg-services/services/Folder/rest/v1/"
#define ITEM_SERVICE                    @"mss-msg-services/services/Item/rest/v1/"


//#define ANNUAIRE_SERVICE                @"mss-msg-services-no-secure/services/Annuaire/rest/v1/"
//#define ATTACHMENT_SERVICE              @"mss-msg-services-no-secure/services/Attachment/rest/v1/"
//#define ENROLEMENT_SERVICE              @"mss-auth-services/services/Enrolement/rest/v1/"
//#define FOLDER_SERVICE                  @"mss-msg-services-no-secure/services/Folder/rest/v1/"
//#define ITEM_SERVICE                    @"mss-msg-services-no-secure/services/Item/rest/v1/"

// services
    // folder
#define S_FOLDER_LIST                   @"listFolders"
#define S_FOLDER_CREATE                 @"createFolder"
#define S_FOLDER_DELETE                 @"deleteFolder"
#define S_FOLDER_EMPTY                  @"emptyFolder"
#define S_FOLDER_TRASH                  @"trashFolder"
#define S_FOLDER_RENAME                 @"renameFolder"
#define S_FOLDER_MOVE                   @"moveFolder"

    // item
#define S_ITEM_UPDATE_MESSAGES          @"updateMessages"
#define S_ITEM_DRAFT_MESSAGE            @"draftMessage"
#define S_ITEM_MOVE_MESSAGES            @"moveMessages"
#define S_ITEM_SEND_MESSAGE             @"sendMessage"
#define S_ITEM_SEARCH_MESSAGES          @"searchMessages"
#define S_ITEM_FULL_TEXT_SEARCH_MESSAGES @"fullTextSearchMessages"
#define S_ITEM_SYNC                     @"syncMessages"

    //  attachment
#define S_ATTACHMENT_UPLOAD             @"upload"
#define S_ATTACHMENT_REMOVE             @"remove"
#define S_ATTACHMENT_DOWNLOAD           @"downloadAttachment"

    //  enrolment
#define S_ENREGISTRER_CANAL             @"enregistrerCanal"

    //Modifier Mot de passe
#define S_MODIFIER_MDP                  @"modifierMotDePasse"

//change notification state 
#define S_CHANGE_NOTIF_STATE            @"changeNotificationState"

    // authentification
#define S_AUTHENTIFIER_OTP              @"authentifierOtp"
#define S_VALIDER_OTP                   @"validerOtp"

    // annuaire
#define S_ANNUAIRE_LIST_EMAILS          @"listEmails"
#define S_ANNUAIRE_RECHERCHER           @"rechercher"
#define S_ANNUAIRE_SEARCH_RECIPIENT     @"searchRecipient"

// http
#define HTTP_GET                        @"GET"
#define HTTP_POST                       @"POST"
#define HTTP_PUT                        @"PUT"
#define HTTP_DELETE                     @"DELETE"
#define HTTP_OK                         204

#define APPLICATION_JSON                @"application/json"
#define TEXT_XML                        @"text/xml"
#define APPLICATION_VND_PAOS_XML        @"application/vnd.paos+xml"
#define TEXT_HTML                       @"text/html"

#define HTTP_HEADER_SET_COOKIE          @"Set-Cookie"
#define HTTP_HEADER_WWW_AUTH            @"WWW-Authenticate"
#define HTTP_LOCATION                   @"Location"
#define HTTP_CONTENT_TYPE               @"Content-Type"
#define HTTP_HEADER_ACCEPT              @"Accept"
#define HTTP_HEADER_PAOS                @"PAOS"
#define HTTP_HEADER_PAOS_VALUE          @"ver='urn:liberty:paos:2003-08'; 'urn:oasis:names:tc:SAML:2.0:profiles:SSO:ecp'"
#define HTTP_HEADER_NUM_HOMOLOGATION    @"NUMHOMOLOGATION"
#define HTTP_HEADER_NUM_HOMOLOG_VALUE   @"APPMOBILE"
#define HTTP_HEADER_ACCEPT_PAOS_JSON    @"application/json, application/vnd.paos+xml"
#define HTTP_HEADER_ACCEPT_PAOS         @"application/vnd.paos+xml"
#define HTTP_HEADER_IDNAT               @"IDNAT"
#define HTTP_HEADER_PASSWORD            @"PASSWORD"
#define HTTP_HEADER_IDCANAL             @"IDCANAL"



//Erreur
#define RECOVERY_SUGGESTION             @"NSLocalizedRecoverySuggestion"
#define X_ERROR_CODE                    @"X-ErrorCode"
#define ERROR                           @"error"
#define ERROR_CODE                      @"code"
#define ERROR_TYPE                      @"type"
#define ERROR_TYPE_TECHNIQUE            @"TECHNIQUE"
#define ERROR_TYPE_FONCTIONNELLE        @"FONCTIONNELLE"
#define ERROR_MSG                       @"message"
#define ERROR_AUTHN_REQUEST             @"AuthnRequest"
#define ERROR_0                         @"Request timeout"
#define ERROR_1                         @"Pas de connexion internet"
#define ERROR_2                         @"Le service est temporairement indisponible, merci de réessayer ultérieurement"
#define ERROR_3                         @"Votre application doit être mise à jour"
#define ERROR_5                         @"Application invalide"
#define ERROR_23                        @"Le mail est non renseigné"
#define ERROR_24                        @"Le mail est invalide"
#define ERROR_25                        @"L’Assertion SAML est invalide"
#define ERROR_26                        @"Le cookie de session est invalide"
#define ERROR_27                        @"Jeton d’authentification vide, Assertion SAML ou Cookie de session est nécessaire"

#define ERROR_CODE_CONNEXION            222
#define ERROR_TO_DISPLAY_IN_CONTROLER   35

#define ERROR_PUSH_TIMEOUT              1000
#define TIMEOUT                         30.0
#define TIMEOUT_OTP_FIRST               60.0
#define TIMEOUT_OTP                     240.0
#define TIMEOUT_LOGOUT_15MIN            15
#define TIMEOUT_LOGOUT_4H               4
//#define LOGIN_BLOCK_TIME                30 (en secondes)


#define QR_CODE                         @"code"
#define QR_NOM                          @"nom"
#define QR_PRENOM                       @"prenom"
#define QR_IDNAT                        @"idNat"
#define QR_IDENV                        @"idEnv"
#define ID_PUSH                         @"idPush"
#define ID_PUSH_ENROLEMENT              @"idPushEnrolement"
#define PUSH_ID                         @"pushId"
#define ID_MOBILE                       @"idMobile"
#define OS                              @"os"
#define IOS                             @"iOS"
#define CODE_APPAREILLEMENT             @"codeAppareillement"
#define IPLANETDIRECTORYPRO             @"iPlanetDirectoryPro"
#define ASSERTION_CUSTOMER_SERVICE_URL  @"assertionConsumerServiceURL"
#define ID_CANAL                        @"idCanal"
#define SYNC_TOKEN                      @"syncToken"
#define LOGIN_COUNTER                   @"loginCounter"
#define LOGIN_TIMESTAMP                 @"loginTimestamp"
#define WRONG_FOLDER_INIT_DICT          @"wrongFolderInitDict"
#define ANCIEN_MDP                      @"ancienMotDePasse"
#define NOUVEAU_MDP                     @"nouveauMotDePasse"
#define LAST_SYNC_DATE                  @"lastSyncDate"
#define EMAIL_NOTIFICATION_STATUS       @"emailNotificationStatus"
#define EMAIL_NOTIFICATION_STATUS_INIT  @"emailNotificationStatusInit"
#define LAST_ACTIVITY_TIME              @"lastActivityTime"

#define USER                            @"user"
#define ENROLLEMENT                     @"enrollement"
#define PASSWORD                        @"password"

#define MOT_DE_PASSE                    @"motDePasse"
#define CODE_SERVICE                    @"codeService"
#define ENREGISTRER_CANAL_INPUT         @"enregistrerCanalInput"
#define ENREGIST_CANAL_OUTPUT           @"enregistrerCanalOutput"
#define MODIFIER_MDP_INPUT              @"modifierMotDePasseInput"
#define CHANGE_NOTIF_STATE_INPUT        @"changeNotificationStateInput"
#define CHOICE_MAIL                     @"choice_mail"

#define MSSANTE                         @"mssante"



#define WAIT_FOR_OTP                    @"WaitForOTP"

#define MASTER_FOLDER_ID                @"masterFolderId"
#define CURRENT_FOLDER_ID               @"currentFolderId"
#define SELECTED_MESSAGE                @"selectedMessages"

#define HEIGHT_PORTRAIT_TABLEVIEW       922
#define HEIGHT_LANDSCAPE_TABLEVIEW      664
#define WIDTH_PORTRAIT_TABLEVIEW        732
#define WIDTH_LANDSCAPE_TABLEVIEW       990
#define POPUP_NAV_BAR_HEIGHT            44
#define SEARCH_MESSAGES_LIMIT           50
#define SEARCH_MESSAGES_OFFSET          50

#define TO                              @"A :"
#define CC                              @"Cc :"
#define CI                              @"Cci :"
#define CC_CCI                          @"Cc/Cci :"
#define PIECES_JOINTES                  @"Pièces jointes :"


#define kCellA 0
#define kCellCC 1
#define kCellCCI 2

#define LOAD_MORE_MESSAGES              1
#define SEARCH_MORE_MESSAGES            2


#define IMAGE_JPEG                      @"image/jpeg"
#define IMAGE_PNG                       @"image/png"
#define IMAGE_GIF                       @"image/gif"
#define IMAGE_TIFF                      @"image/tiff"
#define APPLICATION_PDF                 @"application/pdf"
#define TEXT_PLAIN                      @"text/plain"
#define TEXT_CSV                        @"text/csv"
#define APPLICATION_RTF                 @"application/rtf"

#define AES_KEY                         @"abcdefghijklmnopqrstuvwxyz123456"

#define PLAIN_PASSWORD                  @"plainPassword"
#define DERIVED_PASSWORD                @"derivedPassword"
#define SALTED_PASSWORD                 @"saltedPassword"
#define SALT                            @"salt"
#define SALT_A                          @"saltA"
#define SALT_A_ONE                      @"saltAOne"
#define SALT_A_TWO                      @"saltATwo"
#define SALT_A_THREE                    @"saltAThree"
#define SALT_B                          @"saltB"
#define SALT_B_ONE                      @"saltBOne"
#define SALT_B_TWO                      @"saltBTwo"
#define SALT_B_THREE                    @"saltBThree"
#define ENCRYPTION_KEY                  @"dbEncryptionKey"
#define IS_FIRST_CONNEXION              @"isFirstConnexion"
#define NUMBER_VERSION                  @"numberVersion"


#define kOtherCellSubject 0
#define kOtherCellAttachments 1
#define kOtherCellAttachmentsTableView 2
#define kOtherCellBody 3
#define kOtherCellCount 4

#define MAX_MESSAGE_SIZE                8192
#endif
