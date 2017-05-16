//
// Created by Labinnovation on 04/11/14.
// Copyright (c) 2014 Capgemini. All rights reserved.
//

#import "NouveauMessageViewController2.h"
#import "NouveauMessageDrawer.h"
#import "NPEmail.h"
#import "NPConverter.h"
#import "NPAttachment.h"
#import "UpdateMessagesInput.h"
#import "AttachmentManager.h"
#import "AnnuaireViewController.h"
#import "MoveMessagesInput.h"
#import "Modification.h"
#import "ModificationDAO.h"
#import "ELCUIApplication.h"

#define kOtherCellBodyHeight 340
#define kCellHeight 42

@interface NouveauMessageViewController2 ()

@property (nonatomic, retain) PieceJointeMenu *pjMenu;
@property (nonatomic, retain) UIButton *pjButton;
@property (nonatomic, retain) UIButton *urgentButton;
@property (nonatomic) bool isSending;
//Titres des champs de textes
@property (nonatomic, retain) NSArray *_tokenFieldTitles;
// taille de ???
@property (nonatomic, assign) CGFloat _oldHeight;
//point de la tgableview le plus haut
@property (nonatomic, assign) CGPoint _point;

//Champs A:,CC:,CCi:
@property (nonatomic, retain) TITokenField *tokenFieldTo;
@property (nonatomic, retain) TITokenField *tokenFieldCc;
@property (nonatomic, retain) TITokenField *tokenFieldCci;
@property (nonatomic, retain) TITokenField *setFirstResponder;
//Champs Subject
@property (nonatomic, retain) IBOutlet UITextField *textFieldSubject;

//Objet Message
@property (nonatomic, retain) NPMessage *message;


//Flags
@property (assign) BOOL isManipulatingADraft;

// Flags use for avoid dismiss during background execution (draft for example)
@property (assign) BOOL isPreventingDismiss;

@property (nonatomic, retain) UIResponder* lastTextInput;


// action sheet view for Draft saving
@property (nonatomic, retain) UIActionSheet *sheet;

//Gestion des PJ
@property (nonatomic, retain) AttachmentManager *attachmentManager;

-(void)hideView:(BOOL)isError;
-(void)processToSend:(id)sender;
// Passe le message en urgent / pas urgent
-(void)setUrgent;
-(void)setStateUrgent;

@end


@implementation NouveauMessageViewController2

@synthesize popoverControllerCamera;

@synthesize spinnerView,attachmentsView;
@synthesize pjButton;
@synthesize urgentButton;
@synthesize attachmentsCountLabel;
@synthesize addingAttachmentSpinner;
@synthesize toggleAttachments;
@synthesize textFieldSubject;
@synthesize _tokenFieldTitles;
@synthesize pjMenu;
@synthesize _oldHeight;
@synthesize lastTextInput;
@synthesize isManipulatingADraft;
@synthesize tokenFieldTo,tokenFieldCc,tokenFieldCci;
@synthesize isPreventingDismiss;
@synthesize sheet;
@synthesize attachmentManager;
@synthesize setFirstResponder;
@synthesize tokenField;
@synthesize isSending;

#pragma mark - lifecycle
- (id)init {
    self = [super init];
    if (self) {
        _tokenFieldTitles = @[TO, CC_CCI, CI];
        _oldHeight = kOtherCellBodyHeight;
        
        self.tokenDataSource = self;
        self.delegate = self;
        self.message = [[NPMessage alloc] init];
        self.message.isUrgent = NO;
        self.attachmentManager = [[AttachmentManager alloc] initWithMaster:self];
    }
    
    return self;
}

- (void)setMustCCIBeVisible:(BOOL)aHideCiField{
    self.hideCiField = !hideCiField;
}

- (BOOL)mustCCIBeVisible{
    return !hideCiField;
}

- (void)viewDidLoad {
    DLog(@"NouveauMessageViewController viewDidLoad");
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveDraft:)
                                                 name:@"saveDraft"
                                               object:nil];
    
    
    [super viewDidLoad];
    [self setMustCCIBeVisible:YES];
    [self setHideCiField:YES];
    [self setupAttachmentsView];
    
    NouveauMessageDrawer * drawer = [[NouveauMessageDrawer alloc] initWithMaster:self];
    
    [self setTextFieldSubject:[drawer createTextFieldSubject]];
    [self setPjButton:[drawer createPjButton]];
    [self setUrgentButton:[drawer createUrgentButton]];
    [self setPjMenu:[drawer createPjMenu]];
    [self setSpinnerView:[drawer createSpinnerView]];
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:spinnerView];
    
    [self createMessageView];
    
    [self.navigationItem setLeftBarButtonItem: [drawer createLeftButton]];
    [self.navigationController.navigationBar setTintColor: [UIColor colorWithWhite:0.9 alpha:1]];
    [self.navigationItem setTitleView: [drawer createTitleLabel]];
    [self.navigationItem setRightBarButtonItem:[drawer createSendButton]];
    
    
    [self setup];
    
    // Initialisation des textfields pour A: CC: CCI:
    if ([_tokenFields objectAtIndex:kCellA]) {
        tokenFieldTo = [_tokenFields objectAtIndex:kCellA];
    }
    
    if ([_tokenFields objectAtIndex:kCellCC]) {
        tokenFieldCc = [_tokenFields objectAtIndex:kCellCC];
    }
    
    if ([_tokenFields objectAtIndex:kCellCCI]) {
        tokenFieldCci = [_tokenFields objectAtIndex:kCellCCI];
    }
    
    // Génération pieces jointes
    if (self.message != nil && self.message.messageId!= nil){
        [self.attachmentManager getAttachementsByIdMessage:self.message.messageId];
    }
    [self loadMessageInformation];
    isSending=NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self countCellVisible];
    [self orientationChanged:nil];
}

#pragma mark - Setup
- (UITextView *)createMessageView {
    if (!self.messageView) {
        CGRect frame = CGRectMake(0, 0, widthView, heightView - numberOfShownCells * kCellHeight);
        UITextView *_messageView = [[UITextView alloc] initWithFrame:frame];
        [_messageView setScrollEnabled:NO];
        [_messageView setAutoresizingMask:UIViewAutoresizingNone];
        [_messageView setDelegate:self];
        [_messageView setFont:[UIFont systemFontOfSize:15]];
        [_messageView setAutocapitalizationType: UITextAutocapitalizationTypeSentences];
        
        _messageView.delegate = self;
        self.messageView = _messageView;
    } else {
        self.messageView.frame = CGRectMake(0, 0, widthView, heightView - numberOfShownCells * kCellHeight);
    }
    return messageView;
}

- (void)setupAttachmentsView {
    if (!attachmentsView) {
        attachmentsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthView, kCellHeight)];
        
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectZero];
        [label setTextColor:[UIColor colorWithWhite:0.5 alpha:1]];
        [label setText:PIECES_JOINTES];
        [label setFont:[UIFont systemFontOfSize:15]];
        [label sizeToFit];
        
        [attachmentsView addSubview:label];
        CGRect labelFrame = label.frame;
        labelFrame.origin = CGPointMake(10, 11);
        [label setFrame:labelFrame];
        
        CGRect attachmentsCountLabelFrame = CGRectMake(labelFrame.size.width + 20, 11, 100, 20);
        attachmentsCountLabel = [[UILabel alloc] initWithFrame:attachmentsCountLabelFrame];
        [attachmentsCountLabel setFont:[UIFont systemFontOfSize:14]];
        //#TD
        [attachmentsCountLabel setText:[NSString stringWithFormat:@"%lu",(unsigned long)[self numberOfAttachmentsRows]]];
        [attachmentsView addSubview:attachmentsCountLabel];
        
        addingAttachmentSpinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(labelFrame.size.width + 20, 11, 20, 20)];
        [addingAttachmentSpinner stopAnimating];
        [addingAttachmentSpinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [addingAttachmentSpinner setHidesWhenStopped:YES];
        [addingAttachmentSpinner setBackgroundColor:[UIColor whiteColor]];
        [attachmentsView addSubview:addingAttachmentSpinner];
        
        toggleAttachments = [[UIButton alloc] initWithFrame:CGRectMake( attachmentsView.frame.size.width -37, 7, 34, 22)];
        [toggleAttachments setImage:[UIImage imageNamed:@"fleche_haut_gris"] forState:UIControlStateNormal];
        [toggleAttachments addTarget:self action:@selector(toggleAttachmentsTable)  forControlEvents:UIControlEventTouchUpInside];
        [attachmentsView addSubview:toggleAttachments];
        
        CGFloat tokenFieldBottom = CGRectGetMaxY(label.frame);
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, tokenFieldBottom+11, attachmentsView.frame.size.width, 1)];
        [separator setBackgroundColor:[UIColor colorWithWhite:0.7 alpha:0.5]];
        [attachmentsView addSubview:separator];
    }
}

- (void)loadMessageInformation{
    if (self.message != nil) {
        
        for (NPEmail * email in self.message.to) {
            [tokenFieldTo addTokenWithTitle:(email.alias != nil ? email.mail: email.alias) representedObject:email];
        }
        //@TD ajout des champs cc et cci
        for (NPEmail * email in self.message.cc) {
            [tokenFieldCc addTokenWithTitle:(email.alias != nil ? email.mail: email.alias) representedObject:email];
        }
        for (NPEmail * email in self.message.cci) {
            [tokenFieldCci addTokenWithTitle:(email.alias != nil ? email.mail: email.alias) representedObject:email];
        }
        self.textFieldSubject.text = self.message.subject;
        self.messageView.text = self.message.body;
        
        //@TD Met a jour l'icone sans changer le bool
        [self setStateUrgent];
        //@TD Met à jour les pj
        if([self mustAttachementBeVisible]>0){
            [self.tableView reloadData];
            [attachmentsTable setHidden:NO];
            [toggleAttachments setImage:[UIImage imageNamed:@"fleche_haut_gris"] forState:UIControlStateNormal];
            // [self.attachmentsTable reloadData];
            //[attachmentsTable setHidden:NO];
            [self updateattachmentsViewFrame];
            [self countCellVisible];
            [self.tableView reloadData];
        }
    }
}

- (void)updateWithMessage:(NPMessage *)message{
    self.isManipulatingADraft = YES;
    self.message = message;
}
- (void)updateWithAttachments:(NSMutableArray *)attachments{
    self.isManipulatingADraft = YES;
    NSMutableArray * npAttachments =[[NSMutableArray alloc]init];
    for (Attachment *attachment in attachments){
        [npAttachments addObject:[NPConverter convertAttachment:attachment]];
    }
    [self.attachmentManager setAttachements:npAttachments];
}

-(void)addMailToNouveauMessage:(Email*)mail{
    NPEmail * npEmail = [[NPEmail alloc ] init];
    npEmail = [NPConverter convertEmail:mail];
    
    if ([@"tokenFieldTo" isEqualToString:tokenField]){
        
        [tokenFieldTo addTokenWithTitle:(npEmail.alias != nil ? npEmail.mail: npEmail.alias) representedObject:npEmail];
        [[self.message to] addObject:npEmail];
    }
    else if ([@"tokenFieldCc" isEqualToString:tokenField]){
        [tokenFieldCc addTokenWithTitle:(npEmail.alias != nil ? npEmail.mail: npEmail.alias) representedObject:npEmail];
        [[self.message cc] addObject:npEmail];
    }
    else if ([@"tokenFieldCci" isEqualToString:tokenField]){
        [tokenFieldCci addTokenWithTitle:(npEmail.alias != nil ? npEmail.mail: npEmail.alias) representedObject:npEmail];
        [[self.message cci] addObject:npEmail];
    }
    [self initFirstResponder];
    
}

#pragma mark - NouveauMessageProtocol
- (IBAction)cancelButtonPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:HIDE_POPUP_NOTIF object:self];
    [spinnerView setHidden:YES];
    
    if ([self needToSaveDraft]) {
        [spinnerView setFrame:[[UIScreen mainScreen] bounds]];
        [spinnerView setHidden:NO];
        [self displayDraftActionSheet];
    } else {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [self dismissViewControllerAnimated:NO completion:nil];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)displayDraftActionSheet {
    sheet = [[UIActionSheet alloc] initWithTitle:nil
                                        delegate:self
                               cancelButtonTitle:NSLocalizedString(@"ANNULER", @"Annuler")
                          destructiveButtonTitle:NSLocalizedString(@"EFFACER_LE_BROUILLON", @"Effacer le brouillon")
                               otherButtonTitles:NSLocalizedString(@"ENREGISTRER_LE_BROUILLON", @"Enregistrer le brouillon"), nil];
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [sheet addButtonWithTitle:NSLocalizedString(@"ANNULER", @"Annuler")];
        [sheet setCenter:self.view.center];
        DLog(@"Center: (%f, %f)", self.view.center.x, self.view.center.y);
    }
    
    [sheet setActionSheetStyle:UIActionSheetStyleAutomatic];
    [sheet showInView:self.view];
    
    DLog(@"Width: %f, Height: %f", self.view.frame.size.width, self.view.frame.size.height);
}

- (IBAction)togglePjMenuView:(id)sender {
    DLog(@"Affichage menu PJ ");
    
    [self.view endEditing:YES];
    [messageView resignFirstResponder];
    
    if ([self isShowingPJMenu]) {
        [self hidePJMenuView:sender];
    } else {
        [self showPJMenuView:sender];
    }
}

- (IBAction)hidePJMenuView:(id)sender {
    [pjButton setImage:[UIImage imageNamed:@"ico_trombonne"]
              forState:UIControlStateNormal];
    [pjMenu setHidden:YES];
}

- (IBAction)showPJMenuView:(id)sender {
    [self scrollViewDidScroll:sender];
    [pjButton setImage:[UIImage imageNamed:@"ico_trombonne_rouge"]
              forState:UIControlStateNormal];
    [pjMenu setHidden:NO];
}

/**
 * @return: retourne un tableau de NPEmail
 */
- (NSArray *) extractNPEmailFromTokenfield: (TITokenField *)tokenField{
    NSMutableArray *result = [NSMutableArray array];
    for (TIToken *token in [tokenField tokens]) {
        id representedOject = token.representedObject;
        // si on a un objet complexe dans le token
        if(representedOject != nil){
            // si l'objet complex est un email non persistant  (normalement le cas général)
            if ([representedOject isKindOfClass:[NPEmail class]]){
                [result addObject:representedOject];
            }//Sinon, si c'est un email persistant
            else if([representedOject isKindOfClass:[Email class]]){
                // NSLog(@"WARNING : EMAIL PERSISTANT SPOTTED");
                [result addObject:[NPConverter convertEmail:representedOject]];
            }
        }// si c'est une saisie libre
        else {
            [result addObject:[NPEmail objectWithIdMail:nil alias:nil mail:token.title]];
        }
        //
    }
    return [NSArray arrayWithArray:result];
}

- (void)fillMessageWithTextField:(UITextField *)textField{
    if (textField == tokenFieldTo) {
        TITokenField *toField = (TITokenField *)textField;
        self.message.to = [[self extractNPEmailFromTokenfield:toField] mutableCopy];
    }
    else if (textField == tokenFieldCc) {
        TITokenField *toField = (TITokenField *)textField;
        self.message.cc = [[self extractNPEmailFromTokenfield:toField] mutableCopy];
    }
    else if (textField == tokenFieldCci) {
        TITokenField *toField = (TITokenField *)textField;
        self.message.cci = [[self extractNPEmailFromTokenfield:toField]mutableCopy];
    }
    else if (textField == textFieldSubject){
        self.message.subject = textFieldSubject.text;
    }
}
- (BOOL)isShowingPJMenu{
    return ![pjMenu isHidden];
}



#pragma mark - Sending
// Send Message
- (IBAction)sendMessage:(id)sender {
    DLog(@"sendMessage");
    
    [self resignAll];
    NSError *error = nil;
    BOOL msgIsValid = [self.message isValid:&error];
    if (!msgIsValid) {
        UIAlertView *alert;
        NSString *alertTitle = @"";
        NSString *alertMessage = @"";
        
        NSString *alertCancelTitle = NSLocalizedString(@"OK", @"Ok");
        NSString *alertOtherTitle  = nil;
        
        //@TD : ajout code 3 pour renseignement d'un destinataire
        if (error.code == 2 || error.code == 3){
            alertMessage = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
        }
        else if (error.code == 1){
            alertMessage = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
            alertCancelTitle = @"Annuler";
            alertOtherTitle = @"Continuer";
        }
        else {
            alertMessage = @"Erreur inconnue";
        }
        alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                           message:alertMessage
                                          delegate:self
                                 cancelButtonTitle:alertCancelTitle
                                 otherButtonTitles:nil];
        if (alertOtherTitle){
            [alert addButtonWithTitle:alertOtherTitle];
        }
        [alert show];
    }else {
        [self processToSend:sender];
    }
}




#pragma mark - ProcessToSend
-(void)processToSend:(id)sender{
    
    isSending=YES;
    SendMessageInput *smi = [[SendMessageInput alloc] init];
    if(self.message.messageId){
        smi.messageId = self.message.messageId;
        
    }
    
    [smi generateSendInputWithTokenFieldTo:[self.message to]
                              TokenFieldCc:[self.message cc]
                              TokenFieldCi:[self.message cci]
                                   Subject:[self.message subject]
                                      Body:[self.message body]
                                 Important:[self.message isUrgent]
                                     MsgId:[self.message messageId]];
    ;
    
    //@TD contrôle replyType + messageTransferedId
    if (self.message.replyType &&![@"" isEqualToString:self.message.replyType]){
        [smi setReplyType:self.message.replyType];
    }
    
    if (([FORWARDED isEqualToString:self.message.replyType] || [REPLIED isEqualToString:self.message.replyType])&& self.message.messageTransferedId != [NSNumber numberWithInt:0]){
        [smi setMessageTransferedId:self.message.messageTransferedId];
    }
    
    //@TD
    if(self.attachmentManager.getAttachementsCount > 0){
        [smi addAttachments:[self.attachmentManager getAttachements]];
    }
    DLog(@"proceedToSend start");
    if (![self isConnectedToInternet]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"MSG_SAVED_TO_OUTBOX", @"Le message a été placé dans la boîte d'envoi et sera envoyé lors du rétablissement de la connexion réseau")
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Continuer", nil];
        [alert show];
        
        //Pour mettre dans Message à envoyer
        _operationType = SEND;
        _saveInfolderId = BOITE_D_ENVOI_ID_FOLDER;
        [self saveMessageInFolder:BOITE_D_ENVOI_ID_FOLDER operation:SEND smi:smi ];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        if (![[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            //TODO quiter la vue nouveau message
            [self dismissViewControllerAnimated:YES completion:nil];        }
        
    } else {
        [self.spinnerView setHidden:NO];
        
        DLog(@"sendInputGenerate end");
        DLog(@"start Request");
        Request *request = [[Request alloc] initWithService:S_ITEM_SEND_MESSAGE method:HTTP_POST headers:nil params:[smi generate]];
        request.delegate = self;
        [request execute];
        DLog(@"End Request");
    }
}

- (NSMutableDictionary*)cleanMessageFromAttachments:(NSMutableDictionary*)params input:(NSString*)input{
    if ([[params objectForKey:input] objectForKey:MESSAGE]) {
        NSMutableDictionary *tmpmessage = [[params objectForKey:input] objectForKey:MESSAGE];
        if ([[tmpmessage objectForKey:ATTACHMENTS] isKindOfClass:[NSArray class]] && [[tmpmessage objectForKey:ATTACHMENTS] count] > 0) {
            for (NSMutableDictionary *attachment in [tmpmessage objectForKey:ATTACHMENTS]) {
                if ([attachment objectForKey:A_FILE]) {
                    [attachment removeObjectForKey:A_FILE];
                }
            }
        }
    }
    return params;
}

- (void)runRequestService:(NSString*)_servivce withParams:(NSDictionary*)_params header:(NSMutableDictionary*)_header andMethod:(NSString*)_method {
    Request *request = [[Request alloc] initWithService:_servivce method:_method headers:_header params:_params];
    request.delegate = self;
    [request execute];
}


#pragma mark - AlertView
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self processToSend:alertView];
    }
}
#pragma mark - Save Draft
- (void)saveDraft:(NSNotification *)aNotification {
    DLog(@"NouveauMessageViewController2 saveDraft");
    [self.view endEditing:YES];
    
    if ([@"saveDraft" isEqualToString:aNotification.object]) {
        DLog(@"Notification to save Draft from background");
        isManipulatingADraft = YES;
    }
    
    if ([self needToSaveDraft]) {
        
        NSError *error = nil;
        BOOL msgIsValid = [self.message isValidForDraft:&error];
        
        if (!msgIsValid) {
            UIAlertView *alert;
            NSString *alertTitle = @"";
            NSString *alertMessage = @"";
            
            NSString *alertCancelTitle = NSLocalizedString(@"OK", @"Ok");
            NSString *alertOtherTitle  = nil;
            
            //@TD : ajout code 3 pour renseignement d'un destinataire
            if (error.code == 2 || error.code == 3){
                alertMessage = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
            }
            else if (error.code == 1){
                alertMessage = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
                alertCancelTitle = @"Annuler";
                alertOtherTitle = @"Continuer";
            }
            else {
                alertMessage = @"Erreur inconnue";
            }
            alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                               message:alertMessage
                                              delegate:self
                                     cancelButtonTitle:alertCancelTitle
                                     otherButtonTitles:nil];
            if (alertOtherTitle){
                [alert addButtonWithTitle:alertOtherTitle];
            }
            [alert show];
            
            
        } else {
            
            SendMessageInput *smi = [[SendMessageInput alloc] init];
            
            if(self.message.messageTransferedId) {
                smi.messageTransferedId = self.message.messageTransferedId;
                smi.replyType = FORWARDED;
            }
            
            [smi generateSendInputWithTokenFieldTo:[self.message to]
                                      TokenFieldCc:[self.message cc]
                                      TokenFieldCi:[self.message cci]
                                           Subject:[self.message subject]
                                              Body:[self.message body]
                                         Important:[self.message isUrgent]
                                             MsgId:[self.message messageId]];
            
            //@TD
            if(self.attachmentManager.getAttachements.count > 0){
                [smi addAttachments:self.attachmentManager.getAttachements];
            }
            if (!isManipulatingADraft) {
                [smi setMessageId:nil];
            }
            else {
                [smi setMessageId:[self.message messageId]];
            }
            
            if (smi.subject.length > 50) {
                smi.subject = [NSString stringWithFormat:@"%@...",[smi.subject substringToIndex:46]];
            }
            
            if (smi.body.length > 50000) {
                smi.body= [smi.body substringToIndex:49999];
            }
            //@TD
            if(![self isConnectedToInternet]){
                _operationType = DRAFT;
                _saveInfolderId = BROUILLON_ID_FOLDER;
                [self saveMessageInFolder:BROUILLON_ID_FOLDER operation:DRAFT smi:smi];
            }
            Request *request = [[Request alloc] initWithService:S_ITEM_DRAFT_MESSAGE method:HTTP_POST headers:nil params:[smi generateDraftInput]];
            request.delegate = self;
            [request execute];
            
        }
        [spinnerView setHidden:YES];
        //        [self.navigationController popToRootViewControllerAnimated:YES];
        // [self dismissViewControllerAnimated:YES completion:nil];
        //        } else {
        //            [spinnerView setHidden:YES];
        //        }
    }
}

- (BOOL)needToSaveDraft{
    [self resignAll];
    SendMessageInput *smi = [[SendMessageInput alloc] init];
    [smi generateSendInputWithTokenFieldTo:[self.message to]
                              TokenFieldCc:[self.message cc]
                              TokenFieldCi:[self.message cci]
                                   Subject:[self.message subject]
                                      Body:[self.message body]
                                 Important:[self.message isUrgent]
                                     MsgId:[self.message messageId]];
    //@TD
    if (smi.emails.count > 1 || smi.subject.length > 0 || smi.body.length > 0 ||[self.attachmentManager getAttachements].count > 0){
        return YES;
    }
    else {
        return NO;
    }
}
-(void)deleteDraft {
    
    for (Attachment *attachment in [attachmentManager getAttachements]) {
        NSLog(@"Delete attachment %@ ",attachment.fileName);
        [attachmentManager removeAttachment:attachment.fileName];
    }
    
    if (isManipulatingADraft && self.message && self.message.messageId) {
        
        NSMutableArray *messageIds = [[NSMutableArray alloc] initWithObjects:self.message.messageId, nil];
        
        
        
        UpdateMessagesInput* updateInput = [[UpdateMessagesInput alloc] init];
        [updateInput setMessageIds:messageIds];
        [updateInput setOperation:O_DELETE];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[updateInput generate]];
        Request *request = [[Request alloc] initWithService:S_ITEM_UPDATE_MESSAGES method:HTTP_POST params:params];
        request.delegate = self;
        [request execute];
        
        MessageDAO *messageDAO = (MessageDAO*)[[DAOFactory factory] newDAO:MessageDAO.class];
        Message * message = [messageDAO findMessageByMessageId:self.message.messageId];
        [messageDAO deleteObject:message];
        [self saveDB];
        
    }
    
}

-(void)saveDB{
    NSError *error;
    if (![[DAOFactory factory] save:&error]) {
        DLog(@"error save %@", [error userInfo]);
    }
}
- (void)saveMessageInFolder:(int)folderId operation:(NSString*)operation smi:(SendMessageInput*) smi{
    DLog(@"SaveMessageInFolder");
    Response *response = [[Response alloc] init];
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    NSString *inputKey = SEND_MESSAGE_INPUT;
    NSNumber *msgId = nil;
    if ([DRAFT isEqualToString:operation]) {
        inputKey = DRAFT_MESSAGES_INPUT;
        _sendInputGenerate = [smi generateDraftInput];
    }else {
        _sendInputGenerate = [smi generate];
    }
    
    if (!self.message.messageId) {
        msgId = [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]*-1];
    } else {
        msgId = self.message.messageId;
    }
    
    NSMutableDictionary *messageDict = [[_sendInputGenerate objectForKey:inputKey] objectForKey:MESSAGE];
    [messageDict setObject:strDate forKey:DATE];
    [messageDict setObject:[NSNumber numberWithInt:folderId] forKey:FOLDER_ID];
    
    if (self.message.messageId) {
        DLog(@"messageId %@",self.message.messageId);
        [ModificationDAO deleteModificationsMessageId:self.message.messageId forOperation:operation];
        [self saveDB];
    }
    
    DLog(@"saveMessageInFolder MessageId %d",self.message.messageId.intValue);
    
    Message *msg;
    
    [messageDict setObject:msgId forKey:MESSAGE_ID];
    
    DLog(@"saveMessageInFolder msgId %d",msgId.intValue);
    
    msg = [response parseMessage:messageDict];
    
    Modification* modif = [NSEntityDescription insertNewObjectForEntityForName: @"Modification" inManagedObjectContext: [[DAOFactory factory] managedObjectContext]];
    
    NSMutableDictionary *params = [self cleanMessageFromAttachments:[_sendInputGenerate mutableCopy] input:inputKey];
    
    modif.messageId = msgId;
    modif.operation = operation;
    modif.argument = params;
    modif.date = date;
    
    [self saveDB];
}
#pragma mark - UI

- (void)resignAll{
    [tokenFieldTo resignFirstResponder];
    [tokenFieldCc resignFirstResponder];
    [tokenFieldCci resignFirstResponder];
    [textFieldSubject resignFirstResponder];
    [messageView resignFirstResponder];
}


- (BOOL)isConnectedToInternet {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        DLog(@"NO INTERNET");
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - CCI UI
- (void)hideCCI{
    DLog(@"HIDE CCI");
    [self setMustCCIBeVisible: NO];
    [tokenFieldCc setPromptText:CC_CCI];
    [self countCellVisible];
    [self updateattachmentsViewFrame];
    [self.tableView reloadData];
}
- (void)showCCI{
    DLog(@"SHOW CCI");
    [self setMustCCIBeVisible: YES];
    [tokenFieldCc setPromptText:CC];
    [self updateattachmentsViewFrame];
    [self countCellVisible];
    [self.tableView reloadData];
}

#pragma mark - Attachment UI

/**
 Fonction qui gere l'apparition / disparition de la vue attachement
 */
-(IBAction)toggleAttachmentsTable {
    [self.view endEditing:YES];
    [messageView resignFirstResponder];
    if (![self isAttachmentTableVisible]) {
        DLog(@"Showing Attachments Table");
        
        [toggleAttachments setImage:[UIImage imageNamed:@"fleche_haut_gris"] forState:UIControlStateNormal];
        
    } else {
        [toggleAttachments setImage:[UIImage imageNamed:@"fleche_bas_gris"] forState:UIControlStateNormal];
        DLog(@"hiding Attachments Table");
        
    }
    [self countCellVisible];
    
    [self.tableView reloadData];
}

-(IBAction)deleteAttachment:(id)sender {
    UIButton *button = sender;
    //TODO: Faire supression PJ
    NSArray * tmpAttachments = [self.attachmentManager getAttachements];
    Attachment* attachmentToDel = [tmpAttachments objectAtIndex:button.tag];
    [self.attachmentManager removeAttachment:attachmentToDel.fileName];
    if([self.attachmentManager getAttachementsCount]<1){
        [self.attachmentsView removeFromSuperview];
    }
    [attachmentsCountLabel setText:[NSString stringWithFormat:@"%lu",(unsigned long)[self numberOfAttachmentsRows]]];
    [self countCellVisible];
    [self updateattachmentsViewFrame];
    [self.tableView reloadData];
    [self.attachmentsTable reloadData];
}
- (BOOL)mustAttachementBeVisible{
    if ([self.attachmentManager getAttachementsCount]> 0){
        return YES;
    }else{
        return NO;
        
    }
}

- (UITableViewCell *)attachmentsTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AttachmentsCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AttachmentsCell"];
    }
    
    NPAttachment *attachment = [self.attachmentManager getAttachements][indexPath.row];
    if (attachment.size.integerValue > 0) {
        [cell.textLabel setText:[NSString stringWithFormat:@"%@ - %dK",attachment.fileName, [attachment.size integerValue] ]];
    } else {
        [cell.textLabel setText:[NSString stringWithFormat:@"%@",attachment.fileName]];
    }
    
    
    [cell.imageView setImage:[UIImage imageNamed:@"img_fichierjoint"]];
    
    
    UIButton *delete = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [delete setTag:indexPath.row];
    [delete setImage:[UIImage imageNamed:@"croix"] forState:UIControlStateNormal];
    [delete addTarget:self action:@selector(deleteAttachment:) forControlEvents:UIControlEventTouchUpInside];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.textColor = [UIColor colorWithRed:0.1294117647 green:0.36862745098 blue:0.44705882352 alpha:1];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryView = delete;
    
    [attachmentsCountLabel setText:[NSString stringWithFormat:@"%lu",(unsigned long)[self numberOfAttachmentsRows]]];
    
    return cell;
}

- (void)updateattachmentsViewFrame {
    
    CGRect attachmentsViewFrame;
    attachmentsViewFrame = attachmentsView.frame;
    
    attachmentsViewFrame.size.width = widthView;
    [attachmentsView setFrame:attachmentsViewFrame];
    
    CGRect toggleAttachmentsViewFrame;
    toggleAttachmentsViewFrame = toggleAttachments.frame;
    
    toggleAttachmentsViewFrame.origin.x = widthView -37;
    toggleAttachmentsViewFrame.origin.y = 7;
    toggleAttachmentsViewFrame.size.width = 16;
    toggleAttachmentsViewFrame.size.height = 34;
    [toggleAttachments setFrame:toggleAttachmentsViewFrame];
    [self.attachmentsTable reloadData];
    
}


#pragma mark - TokenTableViewDelegate

- (NSInteger)countCellVisible {
    int visible = 3; // To, CC|CC_CI  Subject
    if ([self mustCCIBeVisible]){
        visible++;
    }
    if ([self mustAttachementBeVisible]) {
        visible++;// PJ Toggle
        visible++;// AttachmentTableView
    }
    numberOfShownCells = visible;
    //NSLog(@"Visible cell %d",visible);
    return visible;
}

- (NSInteger)bodyCellSize {
    return _oldHeight;
}

- (CGFloat)textViewHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITextView *calculationView = messageView;
    CGFloat textViewWidth = calculationView.frame.size.width;
    if (!calculationView.attributedText){
        calculationView = [[UITextView alloc]init];
        calculationView.attributedText = messageView.attributedText;
        textViewWidth = 290;
    }
    CGSize size = [calculationView sizeThatFits:CGSizeMake(textViewWidth, FLT_MAX)];
    
    messageView.frame = CGRectMake(calculationView.frame.origin.x, calculationView.frame.origin.y, calculationView.frame.size.width, MAX(size.height+80,_oldHeight));
    //NSLog(@"%f height",size.height);
    return MAX(size.height+80,_oldHeight);
}

#pragma mark - TokenTableViewDataSource
- (NSString *)tokenFieldPromptAtRow:(NSUInteger)row {
    return _tokenFieldTitles[row];
}

- (NSUInteger)numberOfTokenRows {
    return 3;
}

- (NSUInteger)numberOfAttachmentsRows{
    return [self.attachmentManager getAttachementsCount];
}


- (UIView *)accessoryViewForField:(TITokenField *)tokenField {
    return nil;
}

#pragma mark - TokenTableViewDataSource (Other table cells)

- (BOOL)isAttachmentTableVisible{
    return ![[toggleAttachments imageForState:UIControlStateNormal]isEqual:[UIImage imageNamed:@"fleche_bas_gris"]];
}


- (CGFloat)tokenTableView:(TITokenTableViewController *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case kOtherCellSubject:
            return 44;
        case kOtherCellBody:
            return [self textViewHeightForRowAtIndexPath:indexPath];
        case kOtherCellAttachments:
            if ([self mustAttachementBeVisible]) {
                return kCellHeight;
            } else {
                return 0;
            }
        case kOtherCellAttachmentsTableView:
            if ([self mustAttachementBeVisible] &&  [self isAttachmentTableVisible]) {
                return MIN(61*[attachmentManager getAttachementsCount],150);
            } else {
                return 0;
            }
        default:
            return 0;
    }
}

- (NSInteger)tokenTableView:(TITokenTableViewController *)tableView numberOfRowsInSection:(NSInteger)section {
    return kOtherCellCount;
}

- (UITableViewCell *)tokenTableView:(TITokenTableViewController *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    static NSString *CellIdentifierSubject = @"SubjectCell";
    static NSString *CellIdentifierAttachment = @"CellIdentifierAttachment";
    static NSString *CellIdentifierBody = @"BodyCell";
    
    UIView *contentSubview = nil;
    
    switch (indexPath.row) {
        case kOtherCellSubject:
            cell = [tableView.tableView dequeueReusableCellWithIdentifier:CellIdentifierSubject];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierSubject];
                [textFieldSubject setFrame:CGRectMake(10, 10, widthView - 60, 30)];
                //                contentSubview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.tableView.bounds.size.width, textFieldSubject.frame.size.height)];
                //On force le width a 1024 pour que les bouttons pjbutton et urgent fonctionne
                contentSubview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, textFieldSubject.frame.size.height)];
                [contentSubview addSubview:textFieldSubject];
                [contentSubview addSubview:pjButton];
                //                NSLayoutConstraint *myConstraint =[NSLayoutConstraint
                //                                                   constraintWithItem:pjButton
                //                                                   attribute:NSLayoutAttributeRight
                //                                                   relatedBy:NSLayoutRelationEqual
                //                                                   toItem:contentSubview
                //                                                   attribute:NSLayoutAttributeRight
                //                                                   multiplier:1.0
                //                                                   constant:0.0];
                //
                //                myConstraint.priority = 1000;
                //                pjButton.translatesAutoresizingMaskIntoConstraints = NO;
                //                [contentSubview addConstraint:myConstraint];
                
                [contentSubview addSubview:urgentButton];
                
                [cell.contentView addSubview:contentSubview];
            }
            
            break;
            
        case kOtherCellAttachments:
            cell = [tableView.tableView dequeueReusableCellWithIdentifier:CellIdentifierAttachment];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierAttachment];
            }
            if ([self mustAttachementBeVisible]) {
                contentSubview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2000, attachmentsView.frame.size.height)];
                [contentSubview addSubview:attachmentsView];
                [cell.contentView addSubview:contentSubview];
                
            } else {
                [attachmentsView removeFromSuperview];
            }
            break;
            
        case kOtherCellAttachmentsTableView:
            cell = [tableView.tableView dequeueReusableCellWithIdentifier:CellIdentifierAttachment];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierAttachment];
            }
            if ([self mustAttachementBeVisible] && [self isAttachmentTableVisible] ) {
                contentSubview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2000, attachmentsTable.frame.size.height)];
                [contentSubview addSubview:attachmentsTable];
                
                [cell.contentView addSubview:contentSubview];
                
            } else {
                [attachmentsTable removeFromSuperview];
            }
            break;
        case kOtherCellBody:
            cell = [tableView.tableView dequeueReusableCellWithIdentifier:CellIdentifierBody];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierBody];
                
            }
            cell.frame = CGRectMake(0, 0, widthView, heightView - numberOfShownCells * kCellHeight);
            contentSubview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthView, [self textViewHeightForRowAtIndexPath:indexPath])];
            [contentSubview addSubview:[self createMessageView]];
            for (UIView * view in [cell.contentView subviews]){
                [view removeFromSuperview];
            }
            
            [cell.contentView addSubview:contentSubview];
            break;
            
        default:
            cell = [tableView.tableView dequeueReusableCellWithIdentifier:CellIdentifierBody];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierBody];
                
            }
            cell.frame = CGRectMake(0, 0, widthView, heightView - numberOfShownCells * kCellHeight);
            contentSubview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthView, [self textViewHeightForRowAtIndexPath:indexPath])];
            [contentSubview addSubview:[self createMessageView]];
            for (UIView * view in [cell.contentView subviews]){
                [view removeFromSuperview];
            }
            
            [cell.contentView addSubview:contentSubview];
            break;
    }
    
    
    return cell;
}


- (void)attachmentsTableView:(UITableView *)tableView didSelectRowAtIndex:(NSIndexPath *)indexPath{
    
}

//-(void)updateFieldsSize {
//    CGRect frame;
//    for(NSUInteger i = 0; i < self.tokenDataSource.numberOfTokenRows; i++) {
//        if([_tokenFields objectAtIndex:i]) {
//            TITokenField *tokenField = [_tokenFields objectAtIndex:i];
//            frame = [tokenField frame];
//            frame.size.width = widthView;
//            [tokenField setFrame:frame];
//        }
//    }
//    CGRect msgViewFrame;
//    msgViewFrame = [messageView frame];
//    msgViewFrame.size.width = widthView;
//    [messageView setFrame:msgViewFrame];
//
//    CGRect textFieldSubjectFrame;
//    textFieldSubjectFrame = textFieldSubject.frame;
//    textFieldSubjectFrame.size.width = widthView - 60;
//    [textFieldSubject setFrame:textFieldSubjectFrame];
//
//    CGRect attachmentsViewFrame;
//    attachmentsViewFrame = attachmentsView.frame;
//
//    attachmentsViewFrame.size.width = widthView;
//    [attachmentsView setFrame:attachmentsViewFrame];
//
//}

#pragma mark - Image Take
-(IBAction)takePhoto:(id)sender {
    DLog(@"Take a photo");
    //Check if we can add more PJ
    if ([self.attachmentManager getTotalSize] >= MAX_MESSAGE_SIZE) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERREUR", @"Erreur")
                                                        message:NSLocalizedString(@"MESSAGE_ATTACHMENTS_TROP_VOLUMINEUX", @"Le message est trop volumineux (supérieur à 10Mo)")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                              otherButtonTitles:nil];
        
        [alert show];
    } else {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = NO;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePicker animated:YES completion:NULL];
    }
}
//@TD
-(IBAction)addPhoto:(id)sender {
    DLog(@"Choose a photo");
    //Check if we can add more PJ
    if ([self.attachmentManager getTotalSize] >= MAX_MESSAGE_SIZE) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERREUR", @"Erreur")
                                                        message:NSLocalizedString(@"MESSAGE_ATTACHMENTS_TROP_VOLUMINEUX", @"Le message est trop volumineux (supérieur à 10Mo)")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                              otherButtonTitles:nil];
        
        [alert show];
    } else {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = NO;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //[self presentViewController:imagePicker animated:YES completion:NULL];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            popoverControllerCamera = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
            UIView *view = ((UITapGestureRecognizer*)sender).view;
            [popoverControllerCamera
             presentPopoverFromRect:CGRectMake(view.frame.size.width / 2, view.frame.origin.y, 1, 1) inView:view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            
        } else {
            [self presentViewController:imagePicker animated:YES completion:NULL];
        }
        
    }
}

#pragma mark - Image Picker
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    DLog(@"Take a photo-Image Picker");
    if(![self isAttachmentTableVisible ]){
        [self toggleAttachmentsTable];
    }
    
    [self hidePJMenuView:picker];
    [self updateattachmentsViewFrame];
    [self.tableView reloadData];
    [self.attachmentsTable reloadData];
    // Pour faire disparaitre la vue des photos
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        [self.attachmentManager addAttachmentFromPickingMediaWithInfo:info];
        [popoverControllerCamera dismissPopoverAnimated:YES];
        
    }else {
        [picker dismissViewControllerAnimated:YES completion:^{
            [self.attachmentManager addAttachmentFromPickingMediaWithInfo:info];
        }];
    }
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    [self hidePJMenuView:picker];
}


#pragma mark UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView{
    // resize Textfield ,
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    //scroll to cursor
    [self scrollToCursorForTextView:textView];
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    lastTextInput = textView;
    //[self scrollViewToTextField:textView];
    //scroll to cursor
    [self scrollToCursorForTextView:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    self.message.body = textView.text;
}

#pragma mark UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    DLog(@"textFieldDidBeginEditing %@",textField);
    lastTextInput = textField;
    if ([textField isEqual:tokenFieldCc] && ![self mustCCIBeVisible] ) {
        [self showCCI];
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [tokenFieldCc becomeFirstResponder];
            [self scrollViewToTextField:tokenFieldCc];
        });
    }
    [self scrollToCursorForTextField:textField];
    [self scrollViewToTextField:textField];
    
    [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
}


-(void)textFieldDidEndEditing:(UITextField *)textField {
    //pb quand on a fini d'éditer le champs CCI mais que l'on veut éditer le champs CC cela ne fonctionne pas
    lastTextInput = textField;
    [self fillMessageWithTextField:textField];
    if ([textField isEqual:tokenFieldCci] && [[((TITokenField*)textField) tokens]  count]==0 ) {
        [self hideCCI];
        
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [textFieldSubject becomeFirstResponder];
        });
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textfield {
    UIResponder *nextField = nil;
    if([textfield isEqual:tokenFieldTo]) {
        nextField = tokenFieldCc;
    } else if ([textfield isEqual:tokenFieldCc]) {
        nextField = tokenFieldCci;
    } else if ([textfield isEqual:tokenFieldCci]) {
        nextField = textFieldSubject;
    } else if ([textfield isEqual:textFieldSubject]) {
        [messageView becomeFirstResponder];
        return NO;
    }
    [nextField becomeFirstResponder];
    [self scrollViewToTextField:nextField];
    return YES;
}

#pragma mark UIKeyboardDelegate
- (void)keyboardWillShow:(NSNotification *)notification{
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //NSLog(@"%f kbSize", kbSize.height);
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0.0, self.tableView.contentInset.bottom, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    
    //On cache le PJMenu
    [self hidePJMenuView:notification];
    
}

- (void)keyboardWillHide:(NSNotification *)notification{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.35];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0.0, self.tableView.contentInset.bottom, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    
    [UIView commitAnimations];
}
#pragma mark - ActionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [spinnerView setHidden:NO];
    if (buttonIndex == 0) {
        //Delete Draft is already exists
        [self deleteDraft];
        [self hideView:NO];
        
    } else if (buttonIndex == 1) {
        //Save Draft
        [self saveDraft:nil];
        //        operationType = DRAFT;
    } else {
        //Cancel
        [spinnerView setHidden:YES];
    }
}
#pragma mark -  UIManipulation


-(void)resetAttachmentsTablePosition {
    CGRect frame = attachmentsTable.frame;
    frame.origin.y = numberOfShownCells*kCellHeight+1;
    [attachmentsTable setFrame:frame];
}

// Handle Table Size & Field Size Updates FirstResponder ... etc
-(void)updateTableSize {
    [self updateOrientation];
    [self updateFieldsSize];
}

-(void)updateFieldsSize {
    CGRect frame;
    //    for(NSUInteger i = 0; i < self.tokenDataSource.numberOfTokenRows; i++) {
    //        NSString *tokenPromptText = [self.tokenDataSource tokenFieldPromptAtRow:i];
    //        if([_tokenFields objectForKey:tokenPromptText]) {
    //            TITokenField *tokenField = [_tokenFields objectForKey:tokenPromptText];
    //            frame = [tokenField frame];
    //            frame.size.width = widthView;
    //            [tokenField setFrame:frame];
    //        }
    //    }
    CGRect msgViewFrame;
    msgViewFrame = [messageView frame];
    msgViewFrame.size.width = widthView;
    [messageView setFrame:msgViewFrame];
    
    CGRect textFieldSubjectFrame;
    textFieldSubjectFrame = textFieldSubject.frame;
    textFieldSubjectFrame.size.width = widthView - 60;
    [textFieldSubject setFrame:textFieldSubjectFrame];
    
    CGRect attachmentsViewFrame;
    attachmentsViewFrame = attachmentsView.frame;
    
    attachmentsViewFrame.size.width = widthView;
    [attachmentsView setFrame:attachmentsViewFrame];
    
    //[self updateTextViewSize:messageView];
}

- (void)orientationChanged:(NSNotification *)note {
    [self updateTableSize];
    
    CGRect frame = self.pjMenu.frame;
    frame.origin.y = (self.tableView.frame.size.height - self.pjMenu.frame.size.height+ self.tableView.bounds.origin.y);
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        frame.origin.x = self.view.center.x-(self.pjMenu.frame.size.width/2);
    }
    
    [self.pjMenu setFrame:frame];
    CGRect framePjButton = self.pjButton.frame;
    framePjButton =CGRectMake(widthView-37, 7, 30, 30);
    [self.pjButton setFrame:framePjButton];
    [urgentButton setFrame:CGRectMake(widthView-65, 7, 40, 30)];
    [toggleAttachments setFrame:CGRectMake(widthView-37, 7, 34, 22)];
    
    
    CGRect attachmentsTableFrame = attachmentsTable.frame;
    attachmentsTableFrame.size.width = widthView;
    [attachmentsTable setFrame:attachmentsTableFrame];
    [self updateContentSize];
    
    //@TD 17998 TO MODIFY
    [spinnerView setFrame:[[UIScreen mainScreen] bounds]];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if(![spinnerView isHidden] && !isSending) {
            /* @WX - Anomalie 17883
             * Problème : Le menu n'est plus centré lorsqu'on change d'orientation
             * Solution : On l'enlève avec dismissWithClickedButton
             */
            //[sheet dismissWithClickedButtonIndex:3 animated:YES];
            if ([[self.navigationController visibleViewController] isKindOfClass:[UIAlertController class]]) {
                [sheet dismissWithClickedButtonIndex:2 animated:YES];
            }
            /* @WX - Fin des modifications */
            
            [spinnerView setHidden:NO];
            [self displayDraftActionSheet];
        }
    }
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) orient {
    return(YES);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    DLog(@"Scrolling");
    //DLog(@"scrollView %f",scrollView.contentOffset.y);
    //    [self.pjMenu setFrame:CGRectMake(scrollView.frame.size.width /2 - 160, scrollView.contentOffset.y, 320, 120)];
    
    // [self updateContentSize];
    
}

#pragma mark - Scrolling
/**
 * Make the UITableView Scroll to the position of the cursor, if not inside the visible rect of the tableView
 */
//POSITION CURSOR FOR BODY
- (void)scrollToCursorForTextView:(UITextView *)textView{
    CGRect cursorRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    cursorRect = [self.tableView convertRect:cursorRect fromView:textView];
    if (![self rectVisible:cursorRect]){
        cursorRect.size.height+=8;
        [self.tableView scrollRectToVisible:cursorRect animated:YES];
    }
}
//@TD
//POSITION CURSOR FOR cc:cci to
- (void)scrollToCursorForTextField:(UITextField *)textfield{
    CGRect cursorRect = [textfield caretRectForPosition:textfield.selectedTextRange.start];
    cursorRect = [self.tableView convertRect:cursorRect fromView:textfield];
    if (![self rectVisible:cursorRect]){
        cursorRect.size.height+=8;
    }
    [self.tableView scrollRectToVisible:cursorRect animated:YES];
}
/**
 * Return Yes si le rect en parametres est visible
 */
- (BOOL)rectVisible:(CGRect)rect {
    DLog(@"RectVisible");
    CGRect visibleRect;
    visibleRect.origin = self.tableView.contentOffset;
    visibleRect.origin.y += self.tableView.contentInset.top;
    visibleRect.size = self.tableView.bounds.size;
    visibleRect.size.height -= self.tableView.contentInset.top + self.tableView.contentInset.bottom;
    return CGRectContainsRect(visibleRect, rect);
}

//fonction qui permet de remonter le curseur au niveau du textfield en cours d'édition
- (void)scrollViewToTextField:(id)textField
{
    DLog(@" SCROLL VIEW TO TEXT FIELD ")
    // Set the current _scrollOffset, so we can return the user after editing
    // _scrollOffsetY = self.tableView.contentOffset.y;
    
    // Get a pointer to the text field's cell
    UITableViewCell *theTextFieldCell = (UITableViewCell *)[textField superview];
    
    // Get the text fields location
    CGPoint point = [theTextFieldCell convertPoint:theTextFieldCell.frame.origin toView:self.tableView];
    _point = point;
    NSLog(@"%f  %f",point.x,point.y);
    // Scroll to cell
    [self.tableView setContentOffset:CGPointMake(0, point.y-65) animated: YES];
    // Scroll to cell
    [self.tableView setContentOffset:CGPointMake(0, point.y-65) animated: NO];
    
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //Calcul la frame de la view pjmenu
    // NSLog(@"scrollView %f",scrollView.contentOffset.y);
    NSLog(@"scrollViewDidScroll SCROLL");
    CGRect frame = self.pjMenu.frame;
    frame.origin.y = (self.tableView.frame.size.height - self.pjMenu.frame.size.height+ self.tableView.bounds.origin.y);
    if (![[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        frame.origin.x = self.view.center.x-(self.pjMenu.frame.size.width/2);}
    [self.pjMenu setFrame:frame];
    [self.view bringSubviewToFront:self.pjMenu];
}
#pragma mark - Annuaire
/**
 @TD
 Fait apparaitre l'annuaire
 */
-(void)callAnnuaire:(id)sender{
    _dismissFromImagePicker = NO;
    NSString *query = @"";
    if ([ @"A :" isEqualToString:_currentSelectedTokenField.promptText]){
        query = tokenFieldTo.text;
        [tokenFieldTo setText:@""];
        tokenField =@"tokenFieldTo";
    }
    else if ([@"Cc :"isEqualToString:_currentSelectedTokenField.promptText]){
        query = tokenFieldCc.text;
        [tokenFieldCc setText:@""];
        [tokenFieldCc removesTokensOnEndEditing];
        
        tokenField = @"tokenFieldCc";
    }
    else if ([@"Cci :" isEqualToString:_currentSelectedTokenField.promptText]){
        query = tokenFieldCci.text;
        [tokenFieldCci setText:@""];
        [tokenFieldCci removesTokensOnEndEditing];
        
        tokenField = @"tokenFieldCci";
    }
    
    if (query.length < 4){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERREUR", @"Erreur")
                                                        message:NSLocalizedString(@"THREE_CHARS_MIN", @"Veuillez renseigner au moins 3 caractères")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    }
    
    UINavigationController *annuaireNavCtrl = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"AnnuaireNavigationController"];
    annuaireNavCtrl.modalPresentationStyle = UIModalPresentationFormSheet;
    
    AnnuaireViewController *annuaireController = [annuaireNavCtrl.childViewControllers objectAtIndex:0];
    annuaireController.delegate = self;
    [annuaireController setQuery:query];
    [annuaireController setComingFromNewMsg:YES];
    [annuaireController setNpMessage:self.message];
    
    //@TD ANO  18008
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        /* popoverControllerCamera = [[UIPopoverController alloc] initWithContentViewController:annuaireNavCtrl];
         UIView *view = ((UITapGestureRecognizer*)sender).view;
         [popoverControllerCamera presentPopoverFromRect:CGRectMake(view.frame.size.width, view.frame.origin.y, 1, 1)
         inView:view
         permittedArrowDirections:UIPopoverArrowDirectionAny
         animated:YES]; */
        /* @WX - Anomalie 18008
         * Warning: Attempt to present <NavigationController: 0x176c7770>  on <NouveauMessageViewController2: 0x163f3000> which is already presenting (null)
         * Solution : Enlever la vue déjà présente
         */
        [self dismissViewControllerAnimated:YES completion:nil];
        /* @WX - Fin des modifications */
    }
    
    [self presentViewController:annuaireNavCtrl animated:YES completion:nil];
}

//@TD
-(void)initFirstResponder {
    DLog(@"initFirstResponder");
    double delayInSeconds = 0.0001;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [tokenFieldTo resignFirstResponder];
        [tokenFieldCc resignFirstResponder];
        [tokenFieldCci resignFirstResponder];
        [textFieldSubject resignFirstResponder];
        [messageView resignFirstResponder];
        
        if (!tokenField) {
            if ([tokenField isEqual:tokenFieldTo]) {
                [tokenFieldTo becomeFirstResponder];
            } else if ([setFirstResponder isEqual:tokenFieldCc]) {
                [tokenFieldCc becomeFirstResponder];
            } else if ([setFirstResponder isEqual:tokenFieldCci]) {
                [tokenFieldCci becomeFirstResponder];
                
            }
        }
    });
}


#pragma mark - HTTP
-(void)httpResponse:(id)_responseObject {
    [spinnerView setHidden:YES];
    if ([_responseObject isKindOfClass:[SendMessageResponse class]]) {
        SendMessageResponse *sendMessageResponse = (SendMessageResponse*)_responseObject;
        
        SendMessageInput *smi = [[SendMessageInput alloc] init];
        [smi generateSendInputWithTokenFieldTo:[self.message to]
                                  TokenFieldCc:[self.message cc]
                                  TokenFieldCi:[self.message cci]
                                       Subject:[self.message subject]
                                          Body:[self.message body]
                                     Important:[self.message isUrgent]
                                         MsgId:[self.message messageId]];
        ;
        [smi addAttachments:[self.attachmentManager getAttachements]];
        NSMutableDictionary *messageDict = [[[smi generate] objectForKey:SEND_MESSAGE_INPUT] objectForKey:MESSAGE];
        [messageDict setObject:[sendMessageResponse.messageDictionary objectForKey:MESSAGE_ID] forKey:MESSAGE_ID];
        [messageDict setObject:[sendMessageResponse.messageDictionary objectForKey:DATE] forKey:DATE];
        [messageDict setObject:[sendMessageResponse.messageDictionary objectForKey:SIZE] forKey:SIZE];
        [messageDict setObject:[NSNumber numberWithInt:ENVOYES_ID_FOLDER] forKey:FOLDER_ID];
        if ([sendMessageResponse.messageDictionary objectForKey:ATTACHMENTS] ) {
            [messageDict setObject:[sendMessageResponse.messageDictionary objectForKey:ATTACHMENTS] forKey:ATTACHMENTS];
        }
        
        /*Message* msg = */[sendMessageResponse parseMessage:messageDict];// <=== save in base
        
        [sendMessageResponse saveToDatabase];
        
        if (isManipulatingADraft) {
            [self deleteDraft];
        }
        [self hideView:YES];
    }
    else if ([_responseObject isKindOfClass:[DraftMessageResponse class]]) {
        DraftMessageResponse *draftMessageResponse = (DraftMessageResponse*)_responseObject;
        
        SendMessageInput *smi = [[SendMessageInput alloc] init];
        [smi generateSendInputWithTokenFieldTo:[self.message to]
                                  TokenFieldCc:[self.message cc]
                                  TokenFieldCi:[self.message cci]
                                       Subject:[self.message subject]
                                          Body:[self.message body]
                                     Important:[self.message isUrgent]
                                         MsgId:[self.message messageId]];
        NSMutableDictionary *messageDict = [[[smi generate]  objectForKey:DRAFT_MESSAGES_INPUT] objectForKey:MESSAGE];
        [messageDict setObject:[draftMessageResponse.messageDictionary objectForKey:MESSAGE_ID] forKey:MESSAGE_ID];
        [messageDict setObject:[draftMessageResponse.messageDictionary objectForKey:DATE] forKey:DATE];
        [messageDict setObject:[draftMessageResponse.messageDictionary objectForKey:SIZE] forKey:SIZE];
        [messageDict setObject:[NSNumber numberWithInt:BROUILLON_ID_FOLDER] forKey:FOLDER_ID];
        if ([draftMessageResponse.messageDictionary objectForKey:ATTACHMENTS] ) {
            [messageDict setObject:[draftMessageResponse.messageDictionary objectForKey:ATTACHMENTS] forKey:ATTACHMENTS];
        }
        
        
        DLog(@" messageDict %@", messageDict);
        
        Message* msg = [draftMessageResponse parseMessage:messageDict];
        [draftMessageResponse saveToDatabase];
        
        self.message = [NPConverter convertMessage:msg];
        [self.message setMessageId: msg.messageId];
        self.isManipulatingADraft = YES;
        
        if (!isPreventingDismiss) {
            [self hideView:YES];
        } else {
            /*if ([attachmentManager getAttachementsByIdMessage:msg.messageId].count > 0) {
                NSArray *attachments = [attachmentManager getAttachements];
                for (NPAttachment *attachment in attachments) {
                    [self removeAttachmentFromMemory:attachment];
                    [attachmentManager removeAttachment:attachment.fileName];
                    [attachmentManager:attachment];
                }
             }*/
            [spinnerView setHidden:YES];
            isPreventingDismiss = NO;
            DLog(@"Draft Saved in Background");
            [[NSNotificationCenter defaultCenter] postNotificationName:DID_SAVE_DRAFT_NOTIF object:self];
        }
    }
}


- (void)httpError:(Error*)_error {
    [spinnerView setHidden:YES];
    
    if (_error != nil) {
        DLog(@"Error");
        DLog(@"error service %@",_error.service);
        DLog(@"error service %d",_error.httpStatusCode);
        DLog(@"error service %@",_error.errorMsg);
        DLog(@"error service %@",_error.errorType);
        DLog(@"error service %d",_error.errorCode);
        DLog(@"error service %@",_error.description);
        DLog(@"error service %@",_error.title);
        
        if (_error.httpStatusCode == 403 && _error.errorCode == 39) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERREUR", @"Erreur")
                                                            message:NSLocalizedString(@"MESSAGE_ATTACHMENTS_TROP_VOLUMINEUX", @"Le message est trop volumineux (supérieur à 10Mo)")
                                                           delegate: nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                                  otherButtonTitles:nil];
            
            [alert show];
        } else if (_error.httpStatusCode == 500 && _error.errorCode == 1) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERREUR", @"Erreur")
                                                            message:@"Un (au moins) des destinataires n'a pas une adresse MSSanté valide."
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                                  otherButtonTitles:nil];
            
            [alert show];
        } else {
            // [self saveMessageInFolder:_saveInfolderId operation:_operationType];
            // if (!msgSavedToOutboxError && [S_ITEM_SEND_MESSAGE isEqualToString:_error.service]) {
            if ([self isConnectedToInternet]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:NSLocalizedString(@"SERVICE_INDISPONIBLE", @"Service momentanément indisponible")
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"Continuer", nil];
                [alert show];
            }
            
            if (!isPreventingDismiss) {
                [self hideView:YES];
            }
        }
    }
}

- (void)setUrgent {
    [self.view endEditing:YES];
    self.message.isUrgent = !self.message.isUrgent;
    if (self.message.isUrgent) {
        [urgentButton setImage:[UIImage imageNamed:@"ico_important"] forState:UIControlStateNormal];
    } else {
        [urgentButton setImage:[UIImage imageNamed:@"ico_priorite_gris"] forState:UIControlStateNormal];
    }
}

//@TD
- (void)setStateUrgent{
    if (self.message.isUrgent) {
        [urgentButton setImage:[UIImage imageNamed:@"ico_important"] forState:UIControlStateNormal];
    } else {
        [urgentButton setImage:[UIImage imageNamed:@"ico_priorite_gris"] forState:UIControlStateNormal];
    }
    
}

- (void)hideView:(BOOL)isError {
    [[NSNotificationCenter defaultCenter] postNotificationName:HIDE_POPUP_NOTIF object:self];
    [spinnerView setHidden:YES];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self dismissViewControllerAnimated:NO completion:^{
            //TODO: Gestion de l'annuaire à faire
            //[self reset];
        }];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end