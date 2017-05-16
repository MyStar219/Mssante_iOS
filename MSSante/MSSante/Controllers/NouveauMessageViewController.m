//
//  Created by jac on 9/14/12.
//

#import "NouveauMessageViewController.h"
#import "Names.h"
#import "Constant.h"
#import "ModificationDAO.h"
#import "Modification.h"
#import "AnnuaireViewController.h"
#import "PasswordStore.h"
#import "UpdateMessagesInput.h"
#import "DownloadAttachmentInput.h"
#import "DownloadAttachmentResponse.h"
#import "EmailTool.h"

#define kOtherCellSubject 0
#define kOtherCellAttachments 1
#define kOtherCellBody 2
#define kOtherCellCount 3
#define kOtherCellBodyHeight 300

#define kCellHeight 42

@implementation NouveauMessageViewController {

    
}


@synthesize tokenTableViewController = _tokenTableViewController, toEmails, fromEmails, ccEmails, ciEmails, replyType, message;

@synthesize imageSelect;
@synthesize popoverControllerCamera;
@synthesize imagePicker;
@synthesize sendDelegate;
@synthesize sendInput;
@synthesize messageId;
@synthesize messageTransferedId;
@synthesize tokenFieldCc, tokenFieldCi, tokenFieldTo;
@synthesize setFirstResponder;
@synthesize emailAddresses;
@synthesize isActive;
@synthesize annuaireSearchString;
@synthesize isDraft;
@synthesize isComingFromMessageDetail;
@synthesize isComingFromAnnuaire;
@synthesize previousViewController;


#pragma mark - lifecycle
- (id)init {
    self = [super init];
    
    if (self) {
        _tokenFieldTitles = @[TO, CC, CI];
        _oldHeight = kOtherCellBodyHeight;
        messageId     = nil;
        toEmailsStrings = [NSMutableArray array];
        fromEmailsStrings = [NSMutableArray array];
        ccEmailsStrings = [NSMutableArray array];
        ciEmailsStrings = [NSMutableArray array];
        attachmentsArray = [NSMutableArray array];
        attachmentsBytes = [NSMutableDictionary dictionary];
        currentIndex = 0;
        setFirstResponder = nil;
        startedEditCcField = NO;
        dismissFromImagePicker = NO;
        dismissFromAnnuaire = NO;
        viewAttachment = NO;
        dontDismiss = NO;
        totalAttachmentsSize = 0;
        sendInput = [[SendMessageInput alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad {
    DLog(@"NouveauMessageViewController viewDidLoad");
    [super viewDidLoad];
    self.isActive = YES;
    [self setupNotificationCenter];
    
    if (self.message) {
        DLog(@"message.subject %@",message.subject);
        if (![@"<Sans objet>" isEqualToString:message.subject]) {
            subject = message.subject;
        }
        body = message.body;
    }
    
    numberOfShownCells = 3;
    hideCiField = YES;
    urgent = NO;
    //numberOfAttachments = 0;
    
    [self updateOrientation];
    
    [self.navigationItem setLeftBarButtonItem: [self createLeftButton]];
    [self.navigationController.navigationBar setTintColor: [UIColor colorWithWhite:0.9 alpha:1]];
    [self.navigationItem setTitleView: [self createTitleLabel]];
    [self.navigationItem setRightBarButtonItem:[self createSendButton]];
    
 
    
    if ([_tokenFields objectForKey:TO]) {
        tokenFieldTo = [_tokenFields objectForKey:TO];
        if ([toEmails count] > 0) {
            for (NSObject *emailObject in toEmails) {
                Email *email;
                if ([emailObject isKindOfClass:[Email class]]){
                    email = (Email*)emailObject;
                }
                else{
                    
                    email = (Email *)[message.managedObjectContext objectWithID:[message.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:((NSURL *)emailObject)] ];
                    
                }
                [toEmailsStrings addObject:[EmailTool emailtoString:email]];
                [tokenFieldTo addTokenWithTitle:[EmailTool emailtoString:email] representedObject:email];
                
            }
            [tokenFieldTo showTokens:[toEmailsStrings componentsJoinedByString:@","]];
        }
        [tokenFieldTo setReturnKeyType:UIReturnKeyNext];
        
        tokenFieldTo.delegate = self;
        
        [tokenFieldTo addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        
        toLastTokensCount = tokenFieldTo.tokens.count;
        [tokenFieldTo resignFirstResponder];
    }
    
    if ([_tokenFields objectForKey:CC]) {
        tokenFieldCc = [_tokenFields objectForKey:CC];
        if ([ccEmails count] > 0) {
            hideCiField = NO;
            numberOfShownCells = 4;
            for (Email *email in ccEmails) {
                [ccEmailsStrings addObject:[EmailTool emailtoString:email]];
                [tokenFieldCc addTokenWithTitle:[EmailTool emailtoString:email] representedObject:email];
            }
        } else {
            [tokenFieldCc setPromptText:CC_CCI];
        }
        ccLastTokensCount = tokenFieldCc.tokens.count;
        [tokenFieldCc setReturnKeyType:UIReturnKeyNext];
        tokenFieldCc.delegate = self;
        [tokenFieldCc addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [self textFieldShouldReturn:tokenFieldCc];
    }
    
    if ([_tokenFields objectForKey:CI]) {
        tokenFieldCi = [_tokenFields objectForKey:CI];
        if ([ciEmails count] > 0) {
            for (Email *email in ciEmails) {
                [ciEmailsStrings addObject:[EmailTool emailtoString:email]];
                [tokenFieldCi addTokenWithTitle:[EmailTool emailtoString:email] representedObject:email];
            }
        }
        [tokenFieldCi setReturnKeyType:UIReturnKeyNext];
        tokenFieldCi.delegate = self;
        [tokenFieldCi addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        ciLastTokensCount = tokenFieldCi.tokens.count;
        
        if (hideCiField) {
            [tokenFieldCi setHidden:YES];
        }
        [self textFieldShouldReturn:tokenFieldCi];
    }
    
    [self updateSubjectAndMessage];
    DLog(@"subject %@",subject);
    
    [self setupMessageView];
    [self setupTextFieldSubject];
    [self setupAttachmentsView];
    [self setupPjButton];
    [self setupUrgentButton];
    [self setupPjMenu];
    
    [self.tableView addSubview:pjMenu];
    
    DLog(@"messageId %@", messageId);
}

- (void)viewWillAppear:(BOOL)animated {
       [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    DLog(@"NouveauMessageViewController viewDidAppear");
    [super viewDidAppear:animated];
    
    [self orientationChanged:nil];
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    [self setupSpinnerView];
    [window addSubview:spinnerView];
    
    [spinnerView addSubview:[self createActivityIndicator]];
    
    
    DLog(@"dismissFromImagePicker %d",dismissFromImagePicker);
    
    // par défaut cacher la vue des attachement et mettre fleche vers le bas
    if (!dismissFromImagePicker && !dismissFromAnnuaire && !viewAttachment) {
        
        double delayInSeconds = 0.0000001;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // code to be executed on main thread.If you want to run in another thread, create other queue
            [attachmentsTable setHidden:YES];
            [toggleAttachments setImage:[UIImage imageNamed:@"fleche_bas_gris"] forState:UIControlStateNormal];
        });
        
        [self initFirstResponder];
    } else if (dismissFromAnnuaire) {
    // rien faire
    } else if (viewAttachment) {
    // rien faire
    }
    else {
        [self showPjMenuView];
        //        [self toggleAttachmentsTable];
    }
    
    [self updateNumberOfAttachments]; //Modified 29/07/2014 #jnicco
    [self.tableView reloadData];
    dismissFromImagePicker = NO;
    dismissFromAnnuaire = NO;
    viewAttachment = NO;
}

#pragma mark - Setup

-(UIBarButtonItem *)createLeftButton {
    UIImage *buttonImageLeft = [UIImage imageNamed:@"bouton_retour"];
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aButton setImage:buttonImageLeft forState:UIControlStateNormal];
    aButton.frame = CGRectMake(0,0,50,33);
    [aButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:aButton];
}
-(UIBarButtonItem*)createSendButton{
    //Creation to custom button for create message (at right of masterView)
    UIImage *buttonImageRight = [UIImage imageNamed:@"bouton_envoyer"];
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aButton setImage:buttonImageRight forState:UIControlStateNormal];
    aButton.frame = CGRectMake(0.0,0.0,buttonImageRight.size.width,buttonImageRight.size.height);
    [aButton addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithCustomView:aButton];
    return sendButton;
}
-(UILabel *)createTitleLabel {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    titleLabel.textColor = [UIColor blackColor];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = NSLocalizedString(@"NOUVEAU_MESSAGE", @"Nouveau message");
    return titleLabel;
}
-(UIActivityIndicatorView *)createActivityIndicator{
    UIActivityIndicatorView *activityIndicator;
    activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] ;
    activityIndicator.frame = CGRectMake(0.0, 0.0, 20,20);
    activityIndicator.center = spinnerView.center;
    activityIndicator.color = [UIColor whiteColor];
    [activityIndicator startAnimating];
    return activityIndicator;
}

-(void)setupAttachmentsView {
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
        [attachmentsView addSubview:attachmentsCountLabel];
        
        addingAttachmentSpinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(labelFrame.size.width + 20, 11, 20, 20)];
        [addingAttachmentSpinner stopAnimating];
        [addingAttachmentSpinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [addingAttachmentSpinner setHidesWhenStopped:YES];
        [addingAttachmentSpinner setBackgroundColor:[UIColor whiteColor]];
        [attachmentsView addSubview:addingAttachmentSpinner];
        
        CGFloat tokenFieldBottom = CGRectGetMaxY(label.frame);
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, tokenFieldBottom+11, attachmentsView.frame.size.width, 1)];
        [separator setBackgroundColor:[UIColor colorWithWhite:0.7 alpha:0.5]];
        
        toggleAttachments = [[UIButton alloc] initWithFrame:CGRectMake(widthView-37, 7, 34, 22)];
        [toggleAttachments setImage:[UIImage imageNamed:@"fleche_haut_gris"] forState:UIControlStateNormal];
        [toggleAttachments addTarget:self action:@selector(toggleAttachmentsTable)  forControlEvents:UIControlEventTouchUpInside];
        [attachmentsView addSubview:toggleAttachments];
        [attachmentsView addSubview:separator];
    }
}
-(void)setupMessageView {
    if (!messageView) {
        CGRect frame = CGRectMake(0, 0, widthView, heightView - numberOfShownCells * kCellHeight);
        messageView = [[UITextView alloc] initWithFrame:frame];
        [messageView setScrollEnabled:NO];
        [messageView setAutoresizingMask:UIViewAutoresizingNone];
        [messageView setDelegate:self];
        [messageView setFont:[UIFont systemFontOfSize:15]];
        messageView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        
        messageView.delegate = self;
        if ([body length] > 0) {
            [messageView setText:body];
        }
    }
}
-(void)setupNotificationCenter {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveDraft:)
                                                 name:@"saveDraft"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdateTokens:)
                                                 name:@"didUpdateTokens"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didAddToken:)
                                                 name:@"didAddToken"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:) 
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:[UIDevice currentDevice]];
}
-(void)setupPjButton {
    pjButton =[[UIButton alloc] initWithFrame:CGRectMake(widthView-37, 7, 30, 30)];
    [pjButton setImage:[UIImage imageNamed:@"ico_trombonne"] forState:UIControlStateNormal];
    [pjButton addTarget:self
                 action:@selector(showPjMenuView)
       forControlEvents:UIControlEventTouchUpInside];
}
-(void)setupPjMenu{
    pjMenu = [[PieceJointeMenu alloc] initWithFrame:CGRectMake(self.view.frame.size.width /2 - 160, self.view.frame.size.height - 120, 320, 120)];
    [pjMenu assignViewController:self];
    [pjMenu setHidden:YES];
//    [pjMenu setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    
//    NSLayoutConstraint *myConstraint =[NSLayoutConstraint
//                                       constraintWithItem:pjMenu
//                                       attribute:NSLayoutAttributeBottom
//                                       relatedBy:NSLayoutRelationEqual
//                                       toItem:pjMenu.superview
//                                       attribute:NSLayoutAttributeBottom
//                                       multiplier:1
//                                       constant:0];
//    [pjMenu addConstraint:myConstraint];
}
-(void)setupSpinnerView{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    spinnerView = [[UIView alloc] initWithFrame: CGRectMake (0, 0, screenRect.size.width, screenRect.size.height)];
    [spinnerView setBackgroundColor:[UIColor blackColor]];
    [spinnerView setAlpha:0.5];
    [spinnerView setHidden:YES];
}
-(void)setupTextFieldSubject {
    if(!textFieldSubject) {
        textFieldSubject = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, widthView - 60, 30)];
        textFieldSubject.placeholder = @"Objet";
        if ([subject length] > 0) {
            [textFieldSubject setText:subject];
        }
        [textFieldSubject setReturnKeyType:UIReturnKeyNext];
        textFieldSubject.delegate = self;
    }
}
-(void)setupUrgentButton{
    urgentButton = [[UIButton alloc] initWithFrame:CGRectMake(widthView-65, 7, 40, 30)];
    [urgentButton setImage:[UIImage imageNamed:@"ico_priorite_gris"] forState:UIControlStateNormal];
    [urgentButton addTarget:self action:@selector(setUrgent)  forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - actions
/**
 Fait apparaitre l'annuaire
 */
-(void)callAnnuaire:(id)sender{
    dismissFromImagePicker = NO;
    dismissFromAnnuaire = YES;
    NSString *query = @"";
    if ([ @"A :" isEqualToString:_currentSelectedTokenField.promptText]){
        query = tokenFieldTo.text;
        [toEmailsStrings removeLastObject];
        [tokenFieldTo showTokens:[toEmailsStrings componentsJoinedByString:@","]];
        setFirstResponder = tokenFieldTo;
    }
    else if ([@"Cc :"isEqualToString:_currentSelectedTokenField.promptText]){
        query = tokenFieldCc.text;
        [ccEmailsStrings removeLastObject];
        [tokenFieldCc showTokens:[ccEmailsStrings componentsJoinedByString:@","]];
        setFirstResponder = tokenFieldCc;
    }
    else if ([@"Cci :" isEqualToString:_currentSelectedTokenField.promptText]){
        query = tokenFieldCi.text;
        [ciEmailsStrings removeLastObject];
        [tokenFieldCi showTokens:[ciEmailsStrings componentsJoinedByString:@","]];
        setFirstResponder = tokenFieldCi;
    }
    //#jnicco On ne pas faire de recherche si la query ne contient pas au moins 3 caractère.
    //Mais je ne sais pas pourquoi, le length est incrémenté de 1
    //"z" renvoie une taille de 2, "ze" renvoie une taille de 3 etc...
    if (query.length < 4){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERREUR", @"Erreur")
                                                        message:NSLocalizedString(@"THREE_CHARS_MIN", @"Veuillez renseigner au moins 3 caractères")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    annuaireSearchString = query;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    }
    UINavigationController *annuaireNavCtrl = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"AnnuaireNavigationController"];
    annuaireNavCtrl.modalPresentationStyle = UIModalPresentationFormSheet;
    
    AnnuaireViewController *controller = [annuaireNavCtrl.childViewControllers objectAtIndex:0];
    controller.delegate = self;
    [controller setQuery:query];
    [controller setComingFromNewMsg:YES];
    //
    [self presentViewController:annuaireNavCtrl animated:YES completion:nil];
}

/**
 Ajoute un mail dans le champ courant sélectionner.
 */
-(void)addMailToNouveauMessage:(Email*)mail{
    if ([@"A :" isEqualToString:_currentSelectedTokenField.promptText]){
        [tokenFieldTo addTokenWithTitle:[EmailTool emailtoString:mail] representedObject:mail];
        [tokenFieldTo showTokens:[toEmailsStrings componentsJoinedByString:@","]];
        setFirstResponder = tokenFieldTo;
    }
    else if ([@"Cc :" isEqualToString:_currentSelectedTokenField.promptText]){
        [tokenFieldCc addTokenWithTitle:[EmailTool emailtoString:mail] representedObject:mail];
        [tokenFieldCc showTokens:[ccEmailsStrings componentsJoinedByString:@","]];
        setFirstResponder = tokenFieldCc;
    }
    else if ([@"Cci :" isEqualToString:_currentSelectedTokenField.promptText]){
        [tokenFieldCi addTokenWithTitle:[EmailTool emailtoString:mail] representedObject:mail];
        [tokenFieldCi showTokens:[ccEmailsStrings componentsJoinedByString:@","]];
        setFirstResponder = tokenFieldCi;
    }
    annuaireSearchString = nil;
    [self initFirstResponder];
}

/**
 Fonction qui gere l'apparition / disparition de la vue attachement
 */
-(IBAction)toggleAttachmentsTable {
    [self.view endEditing:YES];
    [messageView resignFirstResponder];
    if (attachmentsTable.hidden) {
        DLog(@"Showing Attachments Table");
        [attachmentsTable setHidden:NO];
        [toggleAttachments setImage:[UIImage imageNamed:@"fleche_haut_gris"] forState:UIControlStateNormal];
    } else {
        [attachmentsTable setHidden:YES];
        [toggleAttachments setImage:[UIImage imageNamed:@"fleche_bas_gris"] forState:UIControlStateNormal];
        DLog(@"hiding Attachments Table");
    }
}

// Handle Attachments
-(IBAction)addPhoto:(id)sender {
    if (totalAttachmentsSize >= MAX_MESSAGE_SIZE) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERREUR", @"Erreur")
                                                        message: NSLocalizedString(@"MESSAGE_ATTACHMENTS_TROP_VOLUMINEUX", @"Le message est trop volumineux (supérieur à 10Mo)")
                                                       delegate: nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                              otherButtonTitles:nil];
        
        [alert show];
    } else {
        imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = NO;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
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
-(IBAction)takePhoto:(id)sender {
    if (totalAttachmentsSize >= MAX_MESSAGE_SIZE) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERREUR", @"Erreur")
                                                        message: NSLocalizedString(@"MESSAGE_ATTACHMENTS_TROP_VOLUMINEUX", @"Le message est trop volumineux (supérieur à 10Mo)")
                                                       delegate: nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                              otherButtonTitles:nil];
        
        [alert show];
    } else {
        imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = NO;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePicker animated:YES completion:NULL];
    }
}
-(void)addAttachment:(Attachment*)attachment {
    if(![attachmentsArray containsObject:attachment]){
        [attachmentsArray addObject:attachment];
    
        hasAttachments = YES;
        [attachmentsTable setHidden:NO];
        [attachmentsTable reloadData];
        currentIndex++;
       // numberOfAttachments++;
    }
    
    [self updateNumberOfAttachments];
}
-(void)addAttachmentToSendInput:(Attachment*)attachment {
    NSNumber *part = nil;                                                                                                                                                                                           
    if (attachment.part != [NSNumber numberWithInt:0]){
        part = attachment.part;
    }
    
    id bytes = nil;
    if ([attachmentsBytes objectForKey:attachment.fileName]) {
        bytes = [attachmentsBytes objectForKey:attachment.fileName];
    }
    
    [sendInput addAttachment:part contentType:attachment.contentType size:attachment.size fileName:attachment.fileName file:bytes attachmentMsgId:attachment.message.messageId];
    [attachmentsBytes setObject:attachment.fileName forKey:attachment.fileName];
}
-(void)removeAttachmentFromSendInput:(NSString*)fileName {
    [sendInput removeAttachment:fileName];
}
-(IBAction)deleteAttachment:(id)sender {
    UIButton *button = sender;
    //numberOfAttachments--;
    Attachment *attachment = [attachmentsArray objectAtIndex:button.tag];
    totalAttachmentsSize -= attachment.size.intValue;
    [self removeAttachmentFromSendInput:attachment.fileName];
    [attachmentsArray removeObjectAtIndex:button.tag];
    [attachmentsTable reloadData];
    [self updateNumberOfAttachments];
    [self deleteAttachmentByObject:attachment];
}
-(void)deleteAttachmentByObject:(Attachment*)_attachment {
    __block Attachment* attachment = _attachment;
    NSBlockOperation* saveOp = [NSBlockOperation blockOperationWithBlock: ^{
        DLog(@"Start Deleting Attachment");
        if (![REPLIED isEqualToString:replyType] && ![FORWARDED isEqualToString:replyType]) {
            NSString *filePath = [Tools getAttachmentFilePath:attachment.fileName];
            if (filePath) {
                BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
                if (fileExists) {
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    NSError *error;
                    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
                    if (!success) DLog(@"Error Deleting Attachment: %@", [error localizedDescription]);
                }
            }
        }
        [attachmentsBytes removeObjectForKey:attachment.fileName];
    }];
    
    [saveOp setCompletionBlock:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            DLog(@"Finish Deleting");
            attachment = nil;
        }];
    }];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:saveOp];
}
-(void)updateNumberOfAttachments {
    [attachmentsCountLabel setText:[NSString stringWithFormat:@"%d",[attachmentsArray count]]];
    numberOfShownCells = 5;
    hasAttachments = YES;
    //if (numberOfAttachments <= 0) {
    if ([attachmentsArray count]<=0) {
        hasAttachments = NO;
        numberOfShownCells = 4;
        //numberOfAttachments = 0;
        [attachmentsTable setHidden:YES];
    }
    if (hideCiField) {
        numberOfShownCells--;
    }
    
    [self resetAttachmentsTablePosition];
}
-(IBAction)showPjMenuView {
    [self.view endEditing:YES];
    [messageView resignFirstResponder];
    if (pjMenu.hidden) {
        [pjButton setImage:[UIImage imageNamed:@"ico_trombonne_rouge"] forState:UIControlStateNormal];
        [pjMenu setHidden:NO];
    } else {
        [pjButton setImage:[UIImage imageNamed:@"ico_trombonne"] forState:UIControlStateNormal];
        [pjMenu setHidden:YES];
    }
}
-(IBAction)setUrgent {
    [self.view endEditing:YES];
    urgent = !urgent;
    if (urgent) {
        [urgentButton setImage:[UIImage imageNamed:@"ico_important"] forState:UIControlStateNormal];
    } else {
        [urgentButton setImage:[UIImage imageNamed:@"ico_priorite_gris"] forState:UIControlStateNormal];
    }
}

#pragma mark - Image Picker
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    
    CGSize newSize = chosenImage.size;
    
    //    DLog(@"Image height %f width %f",newSize.height, newSize.width);
    
    //    newSize.width /= 1;
    //    newSize.height /= 1;
    
    newSize.width /= 3;
    newSize.height /= 3;
    
    //    DLog(@"Image height %f width %f",newSize.height, newSize.width);
    
    //    chosenImage = [chosenImage resizedImage:newSize interpolationQuality:0.5];
    
    //    self.imageSelect.image = [chosenImage resizedImage:newSize interpolationQuality:0.5];
    
    NSString *imageName = nil;
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    NSString* filePath;
    
    if ([info objectForKey:UIImagePickerControllerReferenceURL]) {
        NSURL *imageFileURL = [info objectForKey:UIImagePickerControllerReferenceURL];
        imageName = [imageFileURL lastPathComponent];
        filePath = [Tools getAttachmentFilePath:imageName];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
        if ([attachmentsBytes objectForKey:imageName] || fileExists) {
            NSString *filename = [[imageFileURL lastPathComponent] stringByDeletingPathExtension];
            NSString *ext = [imageFileURL pathExtension];
            imageName = [NSString stringWithFormat:@"%@%d.%@",filename,(int)timestamp,ext];
        }
    } else {
        chosenImage = [chosenImage resizedImage:newSize interpolationQuality:0.5];
    }
    
    if (imageName.length == 0) {
        imageName = [NSString stringWithFormat:@"IMG%d.jpeg",(int)timestamp];
    }
    
    filePath = [Tools getAttachmentFilePath:imageName];
    
    DLog(@"filePath %@",filePath);
    
    __block NSData *imgData;
    __block NSData* encryptedData;
    
    Attachment *attachment= [NSEntityDescription insertNewObjectForEntityForName: @"Attachment" inManagedObjectContext: [[DAOFactory factory] managedObjectContext]];
    [attachment setFileName:imageName];
    
    [attachment setContentType:IMAGE_JPEG];
    [self addAttachment:attachment];
    
    NSBlockOperation* saveOp = [NSBlockOperation blockOperationWithBlock: ^{
        DLog(@"Start Saving");
        
        imgData = UIImageJPEGRepresentation(chosenImage, 1);
        int size = ceil(imgData.length/1024);
        totalAttachmentsSize += size;
        [attachment setSize:[NSNumber numberWithInt:size]];
        if (filePath) {
            encryptedData = [imgData AES256EncryptWithKey:[[PasswordStore getInstance] getDbEncryptionKey]];
            if (encryptedData) {
                [encryptedData writeToFile:filePath atomically:YES];
                DLog(@"Save Image");
            }
            NSString *imageString = [imgData base64Encoding];
            [attachmentsBytes setObject:imageString forKey:imageName];
            [self addAttachmentToSendInput:attachment];
        }
    }];
    
    // Use the completion block to update our UI from the main queue
    [saveOp setCompletionBlock:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            DLog(@"Finish Saving");
            [self.attachmentsTable reloadData];
        }];
    }];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:saveOp];
    
    dismissFromImagePicker = YES;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && imagePicker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        [popoverControllerCamera dismissPopoverAnimated:YES];
    } else {
        [picker dismissViewControllerAnimated:YES completion:^{
            [self showPjMenuView];
        }];
    }
    
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    dismissFromImagePicker = YES;
    [picker dismissViewControllerAnimated:YES completion:^{
        [self showPjMenuView];
    }];
}


#pragma mark - Utils


-(NSString*)getMessageResponse{
    NSMutableString* date = [[self dateToStringWithoutSeconds:message.date] mutableCopy];
    [date insertString:@" à" atIndex:10];
    NSString *emailFromString = @"";
    NSString *alias = @"";
    for (Email* email in [[message emails] allObjects]) {
        if ([E_FROM isEqualToString:email.type]){
            emailFromString = email.address;
            alias = email.name;
        }
    }
    
    return [NSString stringWithFormat:@"\n\nLe %@, %@ <%@> a écrit :\n\n",date, alias, emailFromString];
}

-(NSString*)dateToString:(NSDate*)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    return strDate;
}

-(NSString*)dateToStringWithoutSeconds:(NSDate*)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    return strDate;
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
    for(NSUInteger i = 0; i < self.tokenDataSource.numberOfTokenRows; i++) {
        NSString *tokenPromptText = [self.tokenDataSource tokenFieldPromptAtRow:i];
        if([_tokenFields objectForKey:tokenPromptText]) {
            TITokenField *tokenField = [_tokenFields objectForKey:tokenPromptText];
            frame = [tokenField frame];
            frame.size.width = widthView;
            [tokenField setFrame:frame];
        }
    }
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
    
    [self updateTextViewSize:messageView];
}

-(void)orientationChanged:(NSNotification *)note {
    [self updateTableSize];
    
    [pjMenu setFrame:CGRectMake(self.view.frame.size.width /2 - 160, self.view.frame.size.height - 130, 320, 120)];
    [pjButton setFrame:CGRectMake(widthView-37, 7, 30, 30)];
    [urgentButton setFrame:CGRectMake(widthView-65, 7, 40, 30)];
    [toggleAttachments setFrame:CGRectMake(widthView-37, 7, 34, 22)];
    
    
    CGRect attachmentsTableFrame = attachmentsTable.frame;
    attachmentsTableFrame.size.width = widthView;
    [attachmentsTable setFrame:attachmentsTableFrame];
    
    [self updateContentSize];
}

//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
//    DLog(@"Scrolling");
//    DLog(@"scrollView %f",scrollView.contentOffset.y);
//    [pjMenu setFrame:CGRectMake(scrollView.frame.size.width /2 - 160, scrollView.contentOffset.y, 320, 120)];
//    [self updateContentSize];
//}

-(void)resetFirsResponder {
    id currentResponder = nil;
    if ([tokenFieldTo isFirstResponder]) {
        currentResponder = tokenFieldTo;
    } else if([tokenFieldCc isFirstResponder]) {
        currentResponder = tokenFieldCc;
    } else if ([tokenFieldCi isFirstResponder]) {
        currentResponder = tokenFieldCi;
    } else if ([messageView isFirstResponder]) {
        currentResponder = messageView;
    }
    [textFieldSubject becomeFirstResponder];
    if (currentResponder) {
        [currentResponder becomeFirstResponder];
    }
}

-(void)scrollToTop {
    double delayInSeconds = 0.0001;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        CGPoint scrollPoint = CGPointMake(1,1);
        [self.tableView setContentOffset:scrollPoint animated:NO];
    });
}

-(void)initFirstResponder {
    DLog(@"initFirstResponder");
    double delayInSeconds = 0.0001;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //        [tokenFieldTo resignFirstResponder];
        [tokenFieldCc resignFirstResponder];
        [tokenFieldCi resignFirstResponder];
        [textFieldSubject resignFirstResponder];
        [messageView resignFirstResponder];
        if (!setFirstResponder) {
            [tokenFieldTo becomeFirstResponder];
            
            //            if (tokenFieldTo && [toEmails count] == 0) {
            //                [tokenFieldTo becomeFirstResponder];
            //            }
            //            else if (textFieldSubject && [subject length] == 0) {
            //                [textFieldSubject becomeFirstResponder];
            //            }
            //            else {
            //                [messageView becomeFirstResponder];
            //            }
        } else {
            if ([setFirstResponder isEqual:tokenFieldTo]) {
                if (annuaireSearchString) {
                    [tokenFieldTo setText:annuaireSearchString];
                }
                [tokenFieldTo resignFirstResponder];
                [tokenFieldTo becomeFirstResponder];
            } else if ([setFirstResponder isEqual:tokenFieldCc]) {
                [tokenFieldCc becomeFirstResponder];
                if (annuaireSearchString) {
                    [tokenFieldCc setText:annuaireSearchString];
                }
            } else if ([setFirstResponder isEqual:tokenFieldCi]) {
                [tokenFieldCi becomeFirstResponder];
                if (annuaireSearchString) {
                    [tokenFieldCi setText:annuaireSearchString];
                }
                
            }
        }
    });
}

#pragma mark - UITextViewDelegate

-(void)textViewDidBeginEditing:(UITextView *)textView {
    //set focus to beginning of text field and scroll to top
 /*   if ([textView isEqual:messageView]) {
        messageView.selectedRange = NSMakeRange(0, 0);
               [self scrollToTop];
        attachmentsTable.hidden = YES;
        
        if (tokenFieldCi.tokens.count == 0 && tokenFieldCc.tokens.count == 0) {
            [self resetCiTextField];
            [self updateTextViewSize:textView];
            //[self updateContentSize];
            double delayInSeconds = 0.1;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [messageView becomeFirstResponder];
            });
        }
    }
  */
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    DLog(@"textViewShouldBeginEditing");
    if (textView == messageView) {
        [attachmentsTable setHidden:YES];
        [toggleAttachments setImage:[UIImage imageNamed:@"fleche_bas_gris"]
                           forState:UIControlStateNormal];
  /*      CGFloat height = kCellHeight * 3;
        if (!hideCiField) {
            height += kCellHeight;
        }
        
        if (hasAttachments) {
            height += kCellHeight;
        }
        //        DLog(@"height %f", height);
        
        height -= kCellHeight*3;
        
        UIScrollView *myTableView;
        if([self.tableView.superview isKindOfClass:[UIScrollView class]]) {
            myTableView = (UIScrollView *)self.tableView.superview;
        } else {
            myTableView = self.tableView;
        }
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        myTableView.contentInset = contentInsets;
        myTableView.scrollIndicatorInsets = contentInsets;
        
        CGPoint scrollPoint = CGPointMake(0.0, height +20);
        [myTableView setContentOffset:scrollPoint animated:NO];
   */
    }
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView {
    
    [self updateTextViewSize:textView];
	[self updateContentSize];
    if ([textView isEqual:messageView]) {
        attachmentsTable.hidden = YES;
        
    }
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    //    DLog(@"textFieldShouldBeginEditing %@",textField);
    returnClickCount = 0;
  /*  UIScrollView *myTableView;
    if([self.tableView.superview isKindOfClass:[UIScrollView class]]) {
        myTableView = (UIScrollView *)self.tableView.superview;
    } else {
        myTableView = self.tableView;
    }
    
    CGPoint scrollPoint;
    
    if ([textField isEqual:tokenFieldCc]) {
        scrollPoint = CGPointMake(0.0, 0);
    } else if ([textField isEqual:tokenFieldCi]) {
        scrollPoint = CGPointMake(0.0, 0);
    } else if ([textField isEqual:textFieldSubject]) {
        scrollPoint = CGPointMake(0.0, 0);
        if (!hideCiField) {
            scrollPoint = CGPointMake(0.0, kCellHeight);
        }
    }
    CGRect frame = self.tableView.frame;
    frame.origin.y = 60;
    self.tableView.frame = frame;
    if (scrollPoint.y != currentScrollPoint.y) {
        DLog(@"textFieldShouldBeginEditing scrollPoint %f",scrollPoint.y);
        [myTableView setContentOffset:scrollPoint animated:NO];
    }
    currentScrollPoint = scrollPoint;
    */
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textfield {
    //    DLog(@"textFieldShouldReturn %@",textfield);
    [self scrollTableWhileEditingTextField:textfield tokenRemoved:NO];
    returnClickCount++;
    id nextField = nil;
    if([textfield isEqual:tokenFieldTo]) {
        if (tokenFieldTo.tokens.count == 0 || returnClickCount == 2 || toLastTokensCount != tokenFieldTo.tokens.count)  {
            nextField = textFieldSubject;
        }
    } else if ([textfield isEqual:tokenFieldCc]) {
        if (tokenFieldCc.tokens.count == 0 || returnClickCount == 2 || ccLastTokensCount != tokenFieldCc.tokens.count)  {
            nextField = tokenFieldCi;
        }
    } else if ([textfield isEqual:tokenFieldCi]) {
        if (tokenFieldCi.tokens.count == 0 || returnClickCount == 2 || ciLastTokensCount != tokenFieldCi.tokens.count)  {
            nextField = textFieldSubject;
        }
    } else if ([textfield isEqual:textFieldSubject]) {
        [messageView becomeFirstResponder];
        return NO;
    }
    
    [nextField becomeFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    //    DLog(@"textFieldDidBeginEditing %@",textField);
    if ([textField isEqual:tokenFieldCc] && hideCiField && !startedEditCcField) {
        [tokenFieldCi setHidden:NO];
        if (numberOfShownCells < 5) {
            numberOfShownCells++;
        }
        hideCiField = NO;
        [tokenFieldCc setPromptText:CC];
        startedEditCcField = YES;
        [self resetAttachmentsTablePosition];
        [self.tableView reloadData];
        
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [tokenFieldCc becomeFirstResponder];
        });
    }
    
    if (![lastField isEqual:textField] && ![textField isEqual:tokenFieldCi] && [lastField isEqual:tokenFieldCc] && tokenFieldCi.tokens.count == 0 && tokenFieldCc.tokens.count == 0) {
        [self resetCiTextField];
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [textField becomeFirstResponder];
        });
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    //    DLog(@"textFieldDidEndEditing %@",textField);
    if (startedEditCcField) {
        startedEditCcField = NO;
    } else {
        if (([textField isEqual:tokenFieldCi]) && tokenFieldCi.tokens.count == 0 && tokenFieldCc.tokens.count == 0) {
            [self resetCiTextField];
            double delayInSeconds = 0.1;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [textFieldSubject becomeFirstResponder];
            });
        }
    }
    lastField = textField;
    
    
  /*  UIScrollView *myTableView;
    if([self.tableView.superview isKindOfClass:[UIScrollView class]]) {
        myTableView = (UIScrollView *)self.tableView.superview;
    } else {
        myTableView = self.tableView;
    }
    
    if ([textField isEqual:tokenFieldTo] || [textField isEqual:tokenFieldCc] || [textField isEqual:tokenFieldCi]) {
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 0, 0.0);
        myTableView.contentInset = contentInsets;
        myTableView.scrollIndicatorInsets = contentInsets;
    }
    */
}

-(void)textFieldDidChange:(UITextField*)sender {
    returnClickCount = 0;
    toLastTokensCount = tokenFieldTo.tokens.count;
    ccLastTokensCount = tokenFieldCc.tokens.count;
    ciLastTokensCount = tokenFieldCi.tokens.count;
    //    DLog(@"textFieldDidChange");
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //    DLog(@"textFieldDidChange");
    //    [self scrollTableWhileEditingTextField:textField];
    //    if ([textField isEqual:textFieldSubject]) {
    //        NSUInteger newLength = [textField.text length] + [string length] - range.length;
    //        return (newLength > 50) ? NO : YES;
    //    }
    return YES;
}

-(void)updateTextViewSize:(UITextView *)textView {
    CGFloat newHeight = textView.contentSize.height + textView.font.lineHeight;
    
    if(newHeight < heightView - numberOfShownCells * kCellHeight) {
        newHeight = heightView - numberOfShownCells * kCellHeight;
    }
    
    //    if ([textView isFirstResponder]) {
    //        DLog(@"isFirstResponder");
    //        newHeight -= 264;
    //    }
    
	CGRect newTextFrame = textView.frame;
	newTextFrame.size = textView.contentSize;
	newTextFrame.size.height = newHeight;
    
	if (newHeight < _oldHeight){
		newTextFrame.size.height = _oldHeight;
        
	}
    
	[textView setFrame:newTextFrame];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [self scrollToCursorForTextView:textView];
    _oldHeight = newHeight;
}


- (void)scrollToCursorForTextView: (UITextView*)textView {
    
    CGRect cursorRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    
    cursorRect = [self.tableView convertRect:cursorRect fromView:textView];
    
    if (![self rectVisible:cursorRect]) {
        cursorRect.size.height += 8; // To add some space underneath the cursor
        [self.tableView scrollRectToVisible:cursorRect animated:YES];
    }
}
- (BOOL)rectVisible: (CGRect)rect {
    CGRect visibleRect;
    visibleRect.origin = self.tableView.contentOffset;
    visibleRect.origin.y += self.tableView.contentInset.top;
    visibleRect.size = self.tableView.bounds.size;
    visibleRect.size.height -= self.tableView.contentInset.top + self.tableView.contentInset.bottom;
    
    return CGRectContainsRect(visibleRect, rect);
}


#pragma mark - Token
-(void)scrollTableWhileEditingTextField:(UITextField*)textfield tokenRemoved:(BOOL)tokenRemoved{
 }

-(void)didUpdateTokens:(NSNotification *)aNotification {
    TITokenField *textField = (TITokenField *)aNotification.object;
    [self scrollTableWhileEditingTextField:textField tokenRemoved:YES];
}

-(void)didAddToken:(NSNotification *)aNotification {
    DLog(@"didAddToken");
    TITokenField *textField = (TITokenField *)aNotification.object;
    [self scrollTableWhileEditingTextField:textField tokenRemoved:NO];
}

-(void)resetCiTextField{
    [tokenFieldCi setHidden:YES];
    if (numberOfShownCells > 3) {
        numberOfShownCells--;
    }
    if (hasAttachments) {
        numberOfShownCells = 4;
    }
    //    DLog(@"numberOfShownCells %d",numberOfShownCells);
    hideCiField = YES;
    [tokenFieldCc setPromptText:CC_CCI];
    [self resetAttachmentsTablePosition];
    [self.tableView reloadData];
    
}


#pragma mark - Keyboard

- (void)keyboardDidShow: (NSNotification *) notif{
    [pjButton setImage:[UIImage imageNamed:@"ico_trombonne"] forState:UIControlStateNormal];
    [pjMenu setHidden:YES];
}

//resize the table view if keyboard will show
- (void)keyboardWillShow:(NSNotification *)aNotification {
    if(keyboardShown)
        return;
    
    keyboardShown = YES;
    
    // Get the keyboard size
    UIScrollView *tableView;
    if([self.tableView.superview isKindOfClass:[UIScrollView class]])
        tableView = (UIScrollView *)self.tableView.superview;
    else
        tableView = self.tableView;
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [tableView.superview convertRect:[aValue CGRectValue] fromView:nil];
    
    // Get the keyboard's animation details
    NSTimeInterval animationDuration;
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    UIViewAnimationCurve animationCurve;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    
    // Determine how much overlap exists between tableView and the keyboard
    CGRect tableFrame = tableView.frame;
    CGFloat tableLowerYCoord = tableFrame.origin.y + tableFrame.size.height ;
    keyboardOverlap = tableLowerYCoord - keyboardRect.origin.y;
    if(self.inputAccessoryView && keyboardOverlap>0)
    {
        CGFloat accessoryHeight = self.inputAccessoryView.frame.size.height;
        keyboardOverlap -= accessoryHeight;
        
        tableView.contentInset = UIEdgeInsetsMake(0, 0, accessoryHeight, 0);
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, accessoryHeight, 0);
    }
    
    if(keyboardOverlap < 0)
        keyboardOverlap = 0;
    
    if(keyboardOverlap != 0)
    {
        tableFrame.size.height -= (keyboardOverlap);
        
        NSTimeInterval delay = 0;
        if(keyboardRect.size.height)
        {
            delay = (1 - keyboardOverlap/keyboardRect.size.height)*animationDuration;
            animationDuration = animationDuration * keyboardOverlap/keyboardRect.size.height;
        }
        
        [UIView animateWithDuration:animationDuration
                              delay:delay
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{ tableView.frame = tableFrame; }
                         completion:^(BOOL finished){ [self tableAnimationEnded:nil finished:nil contextInfo:nil]; }];
    }
 
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    if(!keyboardShown)
        return;
    
    keyboardShown = NO;
    
    UIScrollView *tableView;
    if([self.tableView.superview isKindOfClass:[UIScrollView class]])
        tableView = (UIScrollView *)self.tableView.superview;
    else
        tableView = self.tableView;
    if(self.inputAccessoryView)
    {
        tableView.contentInset = UIEdgeInsetsZero;
        tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
    }
    
    if(keyboardOverlap == 0)
        return;
    
    // Get the size & animation details of the keyboard
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [tableView.superview convertRect:[aValue CGRectValue] fromView:nil];
    
    NSTimeInterval animationDuration;
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    UIViewAnimationCurve animationCurve;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    
    CGRect tableFrame = tableView.frame;
    tableFrame.size.height += keyboardOverlap +60;
    tableFrame.origin.y = 0;
    [self scrollToTop];
    if(keyboardRect.size.height)
        animationDuration = animationDuration * keyboardOverlap/keyboardRect.size.height;
    
    [UIView animateWithDuration:animationDuration delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{ tableView.frame = tableFrame; }
                     completion:nil];
   
}

- (void) tableAnimationEnded:(NSString*)animationID finished:(NSNumber *)finished contextInfo:(void *)context {
    // Scroll to the active cell
    //    if(activeCellIndexPath) {
    //        [self.tableView scrollToRowAtIndexPath:activeCellIndexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    //        [self.tableView selectRowAtIndexPath:activeCellIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    //    }
}



#pragma mark - AlertView
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self proceedToSend];
    } else {
        [spinnerView setHidden:YES];
    }
}

#pragma mark - ActionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [spinnerView setHidden:NO];
    if (buttonIndex == 0) {
        //Delete Draft is already exists
        [self deleteDraft];
        
    } else if (buttonIndex == 1) {
        //Save Draft
        [self saveDraft:nil];
        operationType = DRAFT;
    } else {
        //Cancel
        [spinnerView setHidden:YES];
    }
}

#pragma mark - Sending
// Send Message
- (IBAction)sendMessage:(id)sender {
    DLog(@"sendMessage Start");
    [spinnerView setHidden:NO];
    //DismissKeyboard to tokenize text in tokenfields
    [self.view endEditing:YES];
    
 //   [self generateSendInput];
    DLog(@"sendMessage Verification Start");
    BOOL error = YES;
    if (sendInput.emails.count > 1) {
        BOOL proceed = YES;
        //verifier le format d'adresse mail
        for (NSString* email in emailAddresses) {
            if (![EmailTool isValidEmail:email]) {
                proceed = NO;
                break;
            }
        }
        
        if (proceed) {
            //confirmer l'envoie sans objet et body
            BOOL hugeAttachments = NO;
            
            
            NSData *bodyData = [sendInput.body dataUsingEncoding:NSUTF8StringEncoding];
            
            long size = ceil(bodyData.length / 1024);
            
            //            totalAttachmentsSize += size;
            if (sendInput.attachments.count > 0) {
                if (totalAttachmentsSize + size > MAX_MESSAGE_SIZE) {
                    hugeAttachments = YES;
                }
            }
            
            DLog(@"Total attachment size %ld",totalAttachmentsSize);
            
            
            
            
            if (sendInput.subject.length == 0 && sendInput.body.length == 0 && sendInput.attachments.count == 0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:NSLocalizedString(@"MESSAGE_CONFIRMATION_PAS_DE_CORPS_NI_OBJET" , @"Etes vous sûr de vouloir envoyer le message sans objet ni contenu ?")
                                                               delegate:self
                                                      cancelButtonTitle:@"Annuler"
                                                      otherButtonTitles:@"Continuer", nil];
                [alert show];
                error = NO;
            }
            else if (sendInput.subject.length > 50){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERREUR", @"Erreur")
                                                                message: NSLocalizedString(@"OBJET_MESSAGE_SUPERIEUR_50", @"L'objet ne doit pas dépasser 50 caractères")
                                                               delegate: nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                                      otherButtonTitles:nil];
                
                [alert show];
            } else if (hugeAttachments) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERREUR", @"Erreur")
                                                                message: NSLocalizedString(@"MESSAGE_ATTACHMENTS_TROP_VOLUMINEUX", @"Le message est trop volumineux (supérieur à 10Mo)")
                                                               delegate: nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                                      otherButtonTitles:nil];
                
                [alert show];
            } else if (sendInput.body.length > 50000) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERREUR", @"Erreur")
                                                                message: NSLocalizedString(@"MESSAGE_TROP_VOLUMINEUX", @"Le contenu du message est trop volumineux")
                                                               delegate: nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                                      otherButtonTitles:nil];
                
                [alert show];
            }
            else {
                error = NO;
                [self proceedToSend];
                return;
            }
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:NSLocalizedString(@"FORMAT_DESTINATAIRES_INVALIDE" , @"Le format des destinataires est invalide")
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:NSLocalizedString(@"RENSEIGNER_UN_DESTINATAIRE", @"Veuillez renseigner un destinataire")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    if (error) {
        [spinnerView setHidden:YES];
    }
    
    DLog(@"sendMessage Verification End");
}



-(void)proceedToSend {
    DLog(@"proceedToSend start");
    if (![self isConnectedToInternet]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"MSG_SAVED_TO_OUTBOX", @"Le message a été placé dans la boîte d'envoi et sera envoyé lors du rétablissement de la connexion réseau")
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Continuer", nil];
        [alert show];
        msgSavedToOutboxError = YES;
        
    }
    operationType = SEND;
    saveInfolderId = BOITE_D_ENVOI_ID_FOLDER;
    
    
    //    NSBlockOperation* saveOp = [NSBlockOperation blockOperationWithBlock: ^{
    sendInputGenerate = [sendInput generate];
    DLog(@"sendInputGenerate end");
    DLog(@"start Request");
    Request *request = [[Request alloc] initWithService:S_ITEM_SEND_MESSAGE method:HTTP_POST headers:nil params:sendInputGenerate];
    request.delegate = self;
    [request execute];
    
    //    }];
    
    // Use the completion block to update our UI from the main queue
    //    [saveOp setCompletionBlock:^{
    //        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    DLog(@"End Request");
    //        }];
    //    }];
    
    //    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    //    [queue addOperation:saveOp];
    if (![self isConnectedToInternet]){
        [self hideView:YES];
    }
}

-(void)removeAttachmentFromMemory:(Attachment*)attachmentToRemove {
    if ([attachmentsBytes objectForKey:attachmentToRemove.fileName]) {
        [attachmentsBytes removeObjectForKey:attachmentToRemove.fileName];
    }
    
    
    for (Attachment *attachment in attachmentsArray) {
        if ([attachmentToRemove.fileName isEqualToString:attachment.fileName]) {
            [attachmentsArray removeObject:attachment];
            break;
        }
    }
}

-(void)httpResponse:(id)_responseObject {
    [spinnerView setHidden:YES];
    if ([_responseObject isKindOfClass:[SendMessageResponse class]]) {
        SendMessageResponse *sendMessageResponse = (SendMessageResponse*)_responseObject;
        
        NSMutableDictionary *messageDict = [[sendInputGenerate objectForKey:SEND_MESSAGE_INPUT] objectForKey:MESSAGE];
        [messageDict setObject:[sendMessageResponse.messageDictionary objectForKey:MESSAGE_ID] forKey:MESSAGE_ID];
        [messageDict setObject:[sendMessageResponse.messageDictionary objectForKey:DATE] forKey:DATE];
        [messageDict setObject:[sendMessageResponse.messageDictionary objectForKey:SIZE] forKey:SIZE];
        [messageDict setObject:[NSNumber numberWithInt:ENVOYES_ID_FOLDER] forKey:FOLDER_ID];
        if ([sendMessageResponse.messageDictionary objectForKey:ATTACHMENTS] ) {
            [messageDict setObject:[sendMessageResponse.messageDictionary objectForKey:ATTACHMENTS] forKey:ATTACHMENTS];
        }
        
        Message* msg = [sendMessageResponse parseMessage:messageDict];
        
        if (msg.attachments.count > 0) {
            for (Attachment *attachment in msg.attachments) {
                [self removeAttachmentFromMemory:attachment];
            }
        }
        
        [sendMessageResponse saveToDatabase];
        [self hideView:YES];
        
    } else if ([_responseObject isKindOfClass:[DraftMessageResponse class]]) {
        DraftMessageResponse *draftMessageResponse = (DraftMessageResponse*)_responseObject;
        
        NSMutableDictionary *messageDict = [[sendInputGenerate objectForKey:DRAFT_MESSAGES_INPUT] objectForKey:MESSAGE];
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
        
        message = msg;
        messageId = msg.messageId;
        isDraft = YES;
        
        DLog(@"messageId %@",messageId);
        DLog(@"dontDismiss %d",dontDismiss);
        
        if (!dontDismiss) {
            [self hideView:YES];
        } else {
            if (msg.attachments.count > 0) {
                for (Attachment *attachment in msg.attachments) {
                    [self removeAttachmentFromMemory:attachment];
                    [self removeAttachmentFromSendInput:attachment.fileName];
                    [self addAttachmentToSendInput:attachment];
                }
            }
            [spinnerView setHidden:YES];
            dontDismiss = NO;
            DLog(@"Draft Saved in Background");
            [[NSNotificationCenter defaultCenter] postNotificationName:DID_SAVE_DRAFT_NOTIF object:self];
        }
        
    } else if ([_responseObject isKindOfClass:[DownloadAttachmentResponse class]]) {
        DownloadAttachmentResponse *response = (DownloadAttachmentResponse*) _responseObject;
        
        NSString *filename = currentAttachment.fileName;
        NSString *filePath = [Tools getAttachmentFilePath:filename];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
        if (fileExists) {
            NSDate *date = [NSDate date];
            NSTimeInterval timestamp = [date timeIntervalSince1970];
            NSString *currentFileName = [filename stringByDeletingPathExtension];
            NSString *ext = [filename pathExtension];
            filename = [NSString stringWithFormat:@"%@%d.%@",currentFileName,(int)timestamp,ext];
            filePath = [Tools getAttachmentFilePath:filename];
        }
        
        [currentAttachment setLocalFileName:filename];
        
        [self saveDB];
        
        NSData* data = [Tools base64DataFromString:response.file];
        
        NSData* encryptedData = [data AES256EncryptWithKey:[[PasswordStore getInstance] getDbEncryptionKey]];
        
        if (encryptedData) {
            [encryptedData writeToFile:filePath atomically:YES];
        }
        
        [self viewAttachment:data filePath:filePath attachment:currentAttachment];
    }
    
}

-(void)httpError:(Error*)error {
    [spinnerView setHidden:YES];
    if (error != nil){
        DLog(@"Error");
        
        if (error.httpStatusCode == 403 && error.errorCode == 39) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERREUR", @"Erreur")
                                                            message: NSLocalizedString(@"MESSAGE_ATTACHMENTS_TROP_VOLUMINEUX", @"Le message est trop volumineux (supérieur à 10Mo)")
                                                           delegate: nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                                  otherButtonTitles:nil];
            
            [alert show];
        } else {
            DLog(@"saveInfolderId %d",saveInfolderId);
            DLog(@"operationType %@",operationType);
            DLog(@"error service %@",error.service);
            
            [self saveMessageInFolder:saveInfolderId operation:operationType];
            
            if (!msgSavedToOutboxError && [S_ITEM_SEND_MESSAGE isEqualToString:error.service]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:NSLocalizedString(@"SERVICE_INDISPONIBLE", @"Service momentanément indisponible")
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"Continuer", nil];
                [alert show];
            }
            
            if (!dontDismiss) {
                [self hideView:YES];
            }
            
        }
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

-(void)saveDB{
    NSError *error;
    if (![[DAOFactory factory] save:&error]) {
        DLog(@"error save %@", [error userInfo]);
    }
}

//Save Draft
- (IBAction)cancelButtonPressed:(id)sender {
    [self.view endEditing:YES];    
    
    if ([self needToSaveDraft]) {
        sheet = [[UIActionSheet alloc] initWithTitle:nil
                                            delegate:self
                                   cancelButtonTitle:NSLocalizedString(@"ANNULER", @"Annuler")
                              destructiveButtonTitle:NSLocalizedString(@"EFFACER_LE_BROUILLON", @"Effacer le brouillon")
                                   otherButtonTitles:NSLocalizedString(@"ENREGISTRER_LE_BROUILLON", @"Enregistrer le brouillon"), nil];
        
        [sheet showInView:self.view];
        [spinnerView setHidden:NO];
    } else {
        [self hideView:YES];
    }
}

-(BOOL)needToSaveDraft{
 //  [self generateSendInput];
    if (sendInput.emails.count > 1 || sendInput.subject.length > 0 || sendInput.body.length > 0 || sendInput.attachments.count > 0){
        return YES;
    }
    else {
        return NO;
    }
}

-(void)deleteDraft {
    
    for (Attachment *attachmnet in attachmentsArray) {
        [self deleteAttachmentByObject:attachmnet];
    }
    
    [attachmentsArray removeAllObjects];
    
    if (isDraft && message && messageId) {
        DLog(@"DeleteDraft messageId %@", messageId);
        NSMutableArray *messageIds = [[NSMutableArray alloc] initWithObjects:messageId, nil];
        
        
        
        UpdateMessagesInput* updateInput = [[UpdateMessagesInput alloc] init];
        [updateInput setMessageIds:messageIds];
        [updateInput setOperation:O_DELETE];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[updateInput generate]];
        Request *request = [[Request alloc] initWithService:S_ITEM_UPDATE_MESSAGES method:HTTP_POST params:params];
        request.delegate = self;
        [request execute];
        
        MessageDAO *messageDAO = (MessageDAO*)[[DAOFactory factory] newDAO:MessageDAO.class];
        [messageDAO deleteObject:message];
        [self saveDB];
        messageId = nil;
        message = nil;
    }
    [self hideView:NO];
}

-(void)hideView:(BOOL)isError {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:HIDE_POPUP_NOTIF object:self];
    
    [spinnerView setHidden:YES];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self dismissViewControllerAnimated:NO completion:^{
                
                if (self.isComingFromAnnuaire && self.previousViewController) {
                    [self presentViewController:self.previousViewController animated:NO completion:nil];
                }
                [self reset];
                [self setIsActive:NO];
            
        }];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

-(void)reset {
    messageId     = nil;
    toEmailsStrings = [NSMutableArray array];
    fromEmailsStrings = [NSMutableArray array];
    ccEmailsStrings = [NSMutableArray array];
    ciEmailsStrings = [NSMutableArray array];
    attachmentsArray = [NSMutableArray array];
    attachmentsBytes = [NSMutableDictionary dictionary];
    subject = nil;
    body = nil;
    sendInput = nil;
    message = nil;
    operationType = nil;
}

-(void)saveDraftInBackground{
    BOOL validEmails = YES;
    BOOL noValidEmails = NO;
    DLog(@"emailAddresses %d",emailAddresses.count);
    
    DLog(@"saveDraft : operationType %@",operationType);
    
 //   [self generateSendInput];
    NSDictionary *email;
    NSArray *sendInputEmails = [sendInput.emails copy];
    NSMutableArray *newEmails = [NSMutableArray array];
    for (email in sendInputEmails) {
        if ([EmailTool isValidEmail:[email objectForKey:E_EMAIL]]) {
            [newEmails addObject:email];
        }
    }
    
    DLog(@"newEmails count %d",newEmails.count);
    
    if (newEmails.count == 1) {
        noValidEmails = YES;
    }
    
    sendInput.emails = [newEmails mutableCopy];
    [sendInput.message setObject:sendInput.emails forKey:ADDRESSES];
    
    BOOL error = NO;
    
    BOOL hugeAttachments = NO;
    
    NSData *bodyData = [sendInput.body dataUsingEncoding:NSUTF8StringEncoding];
    long size = ceil(bodyData.length / 1024);
    
    if (sendInput.attachments.count > 0) {
        for (Attachment *attachment in attachmentsArray) {
            DLog(@"attachment size %d",attachment.size.intValue);
            size += attachment.size.intValue;
        }
    }
    
    if (size > MAX_MESSAGE_SIZE) {
        hugeAttachments = YES;
    }
    
    UIAlertView *alert;
    if (!validEmails) {
        alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERREUR", @"Erreur")
                                           message: NSLocalizedString(@"FORMAT_DESTINATAIRES_INVALIDE" , @"Le format des destinataires est invalide")
                                          delegate: nil
                                 cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                 otherButtonTitles:nil];
        
        
        error = YES;
    }
     else if (hugeAttachments) {
        alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERREUR", @"Erreur")
                                           message: NSLocalizedString(@"MESSAGE_ATTACHMENTS_TROP_VOLUMINEUX", @"Le message est trop volumineux (supérieur à 10Mo)")
                                          delegate: nil
                                 cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                 otherButtonTitles:nil];
        
        
        error = YES;
    } else if (sendInput.body.length > 50000) {
        alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERREUR", @"Erreur")
                                           message: NSLocalizedString(@"MESSAGE_TROP_VOLUMINEUX", @"Le contenu du message est trop volumineux")
                                          delegate: nil
                                 cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                 otherButtonTitles:nil];
        
        //            [alert show];
        error = YES;
    } else if (noValidEmails && sendInput.subject.length == 0 && sendInput.body.length == 0 && sendInput.attachments.count == 0) {
        error = YES;
        if (!dontDismiss) {
            [self hideView:NO];
        }
        dontDismiss = NO;
    }
    
    
   
    if (!error && isActive) {
        DLog(@"messageId %@",messageId);
        if (messageId.intValue > 0) {
            [sendInput setMessageId:messageId];
        }
        
        if (!isDraft) {
            [sendInput setMessageId:nil];
        }
        
        if (sendInput.subject.length > 50) {
            //                sendInput.subject = [sendInput.subject substringToIndex:46];
            sendInput.subject = [NSString stringWithFormat:@"%@...",[sendInput.subject substringToIndex:46]];
        }
        
        if (sendInput.body.length > 50000) {
            sendInput.body= [sendInput.body substringToIndex:49999];
        }
        
        sendInputGenerate = [sendInput generateDraftInput];
        
        NSMutableDictionary *messageDict = [[sendInputGenerate objectForKey:DRAFT_MESSAGES_INPUT] objectForKey:MESSAGE];
        if ([messageDict objectForKey:FOLDER_ID]) {
            [messageDict removeObjectForKey:FOLDER_ID];
        }
        
        if ([messageDict objectForKey:DATE]) {
            [messageDict removeObjectForKey:DATE];
        }
        
        if ([messageDict objectForKey:SIZE]) {
            [messageDict removeObjectForKey:SIZE];
        }
        
        operationType = DRAFT;
        saveInfolderId = BROUILLON_ID_FOLDER;
        
        Request *request = [[Request alloc] initWithService:S_ITEM_DRAFT_MESSAGE method:HTTP_POST headers:nil params:sendInputGenerate];
        request.delegate = self;
        [request execute];
    }
    
}
    
-(void)saveDraft:(NSNotification *)aNotification {
    [self.view endEditing:YES];
    
    if ([@"saveDraft" isEqualToString:aNotification.object]) {
        
        DLog(@"Notification to save Draft from background");
        dontDismiss = YES;
    }
    
    if (isActive) {
        BOOL validEmails = YES;
        BOOL noValidEmails = NO;
        DLog(@"emailAddresses %d",emailAddresses.count);
        
        DLog(@"saveDraft : operationType %@",operationType);
        
  //      [self generateSendInput];
        NSDictionary *email;
        NSArray *sendInputEmails = [sendInput.emails copy];
        NSMutableArray *newEmails = [NSMutableArray array];
        for (email in sendInputEmails) {
            if ([EmailTool isValidEmail:[email objectForKey:E_EMAIL]]) {
                [newEmails addObject:email];
            }
        }
        
        DLog(@"newEmails count %d",newEmails.count);
        
        if (newEmails.count == 1) {
            noValidEmails = YES;
        }
        
        sendInput.emails = [newEmails mutableCopy];
        [sendInput.message setObject:sendInput.emails forKey:ADDRESSES];
        
        BOOL error = NO;
        
        BOOL hugeAttachments = NO;
        
        NSData *bodyData = [sendInput.body dataUsingEncoding:NSUTF8StringEncoding];
        long size = ceil(bodyData.length / 1024);
        
        if (sendInput.attachments.count > 0) {
            for (Attachment *attachment in attachmentsArray) {
                DLog(@"attachment size %d",attachment.size.intValue);
                size += attachment.size.intValue;
            }
        }
        
        if (size > MAX_MESSAGE_SIZE) {
            hugeAttachments = YES;
        }
        
        UIAlertView *alert;
        if (!validEmails) {
            alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERREUR", @"Erreur")
                                               message: NSLocalizedString(@"FORMAT_DESTINATAIRES_INVALIDE" , @"Le format des destinataires est invalide")
                                              delegate: nil
                                     cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                     otherButtonTitles:nil];
            
            
            error = YES;
        } else if (hugeAttachments) {
            alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERREUR", @"Erreur")
                                               message: NSLocalizedString(@"MESSAGE_ATTACHMENTS_TROP_VOLUMINEUX", @"Le message est trop volumineux (supérieur à 10Mo)")
                                              delegate: nil
                                     cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                     otherButtonTitles:nil];
            
            
            error = YES;
        } else if (sendInput.body.length > 50000) {
            alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERREUR", @"Erreur")
                                               message: NSLocalizedString(@"MESSAGE_TROP_VOLUMINEUX", @"Le contenu du message est trop volumineux")
                                              delegate: nil
                                     cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                     otherButtonTitles:nil];
            
            //            [alert show];
            error = YES;
        } else if (noValidEmails && sendInput.subject.length == 0 && sendInput.body.length == 0 && sendInput.attachments.count == 0) {
            error = YES;
            if (!dontDismiss) {
                [self hideView:NO];
            }
            dontDismiss = NO;
        }
        
        
        if (alert && ![@"saveDraft" isEqual:aNotification.object]) {
            [alert show];
        }
        
        if (!error && isActive) {
            DLog(@"messageId %@",messageId);
            if (messageId.intValue > 0) {
                   ;
            }
            
            if (!isDraft) {
                [sendInput setMessageId:nil];
            }
            
            if (sendInput.subject.length > 50) {
                //                sendInput.subject = [sendInput.subject substringToIndex:46];
                sendInput.subject = [NSString stringWithFormat:@"%@...",[sendInput.subject substringToIndex:46]];
            }
            
            if (sendInput.body.length > 50000) {
                sendInput.body= [sendInput.body substringToIndex:49999];
            }
            
            sendInputGenerate = [sendInput generateDraftInput];
            
            NSMutableDictionary *messageDict = [[sendInputGenerate objectForKey:DRAFT_MESSAGES_INPUT] objectForKey:MESSAGE];
            if ([messageDict objectForKey:FOLDER_ID]) {
                [messageDict removeObjectForKey:FOLDER_ID];
            }
            
            if ([messageDict objectForKey:DATE]) {
                [messageDict removeObjectForKey:DATE];
            }
            
            if ([messageDict objectForKey:SIZE]) {
                [messageDict removeObjectForKey:SIZE];
            }
            
            operationType = DRAFT;
            saveInfolderId = BROUILLON_ID_FOLDER;
            
            Request *request = [[Request alloc] initWithService:S_ITEM_DRAFT_MESSAGE method:HTTP_POST headers:nil params:sendInputGenerate];
            request.delegate = self;
            
            [request execute];
        } else {
            [spinnerView setHidden:YES];
        }
    }
    
}

- (void)saveMessageInFolder:(int)folderId operation:(NSString*)operation {
    
    Response *response = [[Response alloc] init];
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    NSString *inputKey = SEND_MESSAGE_INPUT;
    NSNumber *msgId = nil;
    if ([DRAFT isEqualToString:operation]) {
        inputKey = DRAFT_MESSAGES_INPUT;
    }
    
    if (!messageId) {
        msgId = [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]*-1];
    } else {
        msgId = messageId;
    }
    NSMutableDictionary *messageDict = [[sendInputGenerate objectForKey:inputKey] objectForKey:MESSAGE];
    [messageDict setObject:strDate forKey:DATE];
    [messageDict setObject:[NSNumber numberWithInt:folderId] forKey:FOLDER_ID];
    
    if (messageId) {
        DLog(@"messageId %@",messageId);
        [ModificationDAO deleteModificationsMessageId:messageId forOperation:operation];
        [self saveDB];
    }
    
    DLog(@"saveMessageInFolder MessageId %d",messageId.intValue);
    
    Message *msg;
    if (isDraft) {
        MessageDAO* messageDAO = (MessageDAO*)[[DAOFactory factory] newDAO:MessageDAO.class];
        
        msg = [messageDAO findMessageByMessageId:messageId];
        if (msg) {
            [messageDict setObject:messageId forKey:MESSAGE_ID];
        }
    } else {
        [messageDict setObject:msgId forKey:MESSAGE_ID];
    }
    
    DLog(@"saveMessageInFolder msgId %d",msgId.intValue);
    
    msg = [response parseMessage:messageDict];
    
    Modification* modif = [NSEntityDescription insertNewObjectForEntityForName: @"Modification" inManagedObjectContext: [[DAOFactory factory] managedObjectContext]];
    
    NSMutableDictionary *params = [self cleanMessageFromAttachments:[sendInputGenerate mutableCopy] input:inputKey];
    
    modif.messageId = msgId;
    modif.operation = operation;
    modif.argument = params;
    modif.date = date;
    
    [self saveDB];
}

#pragma mark - TokenTableViewDataSource

- (NSString *)tokenFieldPromptAtRow:(NSUInteger)row {
    return _tokenFieldTitles[row];
}

- (NSUInteger)numberOfTokenRows {
    return _tokenFieldTitles.count;
}

- (UIView *)accessoryViewForField:(TITokenField *)tokenField {
    //    UIButton * addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    //   	[addButton addTarget:self action:@selector(showContactsPicker:) forControlEvents:UIControlEventTouchUpInside];
    //   	[tokenField setRightView:addButton];
    //    return addButton;
    return nil;
}



#pragma mark - TokenTableViewDataSource (Other table cells)

- (CGFloat)tokenTableView:(TITokenTableViewController *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case kOtherCellSubject:
            return 44;
        case kOtherCellBody:
            [self updateTextViewSize:messageView];
            return _oldHeight;
        case kOtherCellAttachments:
            if (numberOfShownCells == 5 || (numberOfShownCells == 4 && hideCiField)) {
                return kCellHeight;
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
    static NSString *CellIdentifierBody = @"BodyCell";
    
    UIView *contentSubview = nil;
    // todo save the cells to keep their text active
    switch (indexPath.row) {
        case kOtherCellSubject:
            cell = [tableView.tableView dequeueReusableCellWithIdentifier:CellIdentifierSubject];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierSubject];
                contentSubview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2000, textFieldSubject.frame.size.height)];
                [contentSubview addSubview:textFieldSubject];
                [contentSubview addSubview:pjButton];
                [contentSubview addSubview:urgentButton];
                [cell.contentView addSubview:contentSubview];
            }
            
            break;
            
        case kOtherCellAttachments:
            
            cell = [tableView.tableView dequeueReusableCellWithIdentifier:CellIdentifierSubject];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierSubject];
            }
            
            if (hasAttachments) {
                contentSubview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2000, attachmentsView.frame.size.height)];
                [contentSubview addSubview:attachmentsView];
            } else {
                contentSubview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2000, 0)];
                [attachmentsView removeFromSuperview];
            }
            
            break;
            
        case kOtherCellBody:
            cell = [tableView.tableView dequeueReusableCellWithIdentifier:CellIdentifierBody];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierBody];
                cell.frame = CGRectMake(0, 0, widthView, heightView - numberOfShownCells * kCellHeight);
            }
            contentSubview = messageView;
            break;
            
        default:
            break;
    }
    
    if(contentSubview && cell) {
        BOOL addSubview = YES;
        for (UIView * subView in [cell.contentView subviews]) {
            if(subView == contentSubview) {
                addSubview = NO;
                break;
            }
        }
        
        if(addSubview) {
            [cell.contentView addSubview:contentSubview];
            if ([contentSubview isEqual:messageView]) {
                [self updateTextViewSize:messageView];
            }
        }
    }
    
    return cell;
}

- (UITableViewCell *)attachmentsTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AttachmentsCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AttachmentsCell"];
    }
    
    Attachment *attachment = attachmentsArray[indexPath.row];
    if (attachment.size.integerValue > 0) {
        [cell.textLabel setText:[NSString stringWithFormat:@"%@ - %dK",attachment.fileName, [attachment.size integerValue] ]];
    } else {
        [cell.textLabel setText:[NSString stringWithFormat:@"%@",attachment.fileName]];
    }
    
    //    DLog(@"attachment Name %@",attachment.fileName);
    //    [cell.textLabel setText:[NSString stringWithFormat:@"%@ - %dK",attachment.fileName, [attachment.size integerValue] ]];
    
    [cell.imageView setImage:[UIImage imageNamed:@"img_fichierjoint"]];
    
    
    UIButton *delete = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [delete setTag:indexPath.row];
    [delete setImage:[UIImage imageNamed:@"croix"] forState:UIControlStateNormal];
    [delete addTarget:self action:@selector(deleteAttachment:) forControlEvents:UIControlEventTouchUpInside];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.textColor = [UIColor colorWithRed:0.1294117647 green:0.36862745098 blue:0.44705882352 alpha:1];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setAccessoryView:delete];
    
    return cell;
}

- (void)attachmentsTableView:(UITableView *)tableView didSelectRowAtIndex:(NSIndexPath *)indexPath {
    Attachment *attachment = attachmentsArray[indexPath.row];
    
    if ([EmailTool attachmentIsSupported:attachment]) {
        NSString *filePath;
        
        NSURL *url;
        BOOL fileExists = NO;
        NSData *content;
        
        if (!attachment.localFileName) {
            attachment.localFileName = attachment.fileName;
        }
        
        if (attachment.localFileName.length > 0) {
            filePath = [Tools getAttachmentFilePath:attachment.localFileName];
            url = [NSURL fileURLWithPath:filePath];
            fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
        }
        
        if (fileExists) {
            content = [NSData dataWithContentsOfURL:url];
            content = [content AES256DecryptWithKey:[[PasswordStore getInstance] getDbEncryptionKey]];
            [self viewAttachment:content filePath:filePath attachment:attachment];
        } else {
            [spinnerView setHidden:NO];
            DownloadAttachmentInput *downloadInput = [[DownloadAttachmentInput alloc] init];
            [downloadInput setMessageId:messageId];
            
            DLog(@"attachment.part %@",attachment.part);
            if (attachment.part) {
                [downloadInput setPart:attachment.part];
                
                currentAttachment = attachment;
                Request *request = [[Request alloc] initWithService:S_ATTACHMENT_DOWNLOAD method:HTTP_POST headers:nil params:[downloadInput generate]];
                request.delegate = self;
                request.attachmentFileName = attachment.fileName;
                if ([request isConnectedToInternet]) {
                    [request execute];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                    message:NSLocalizedString(@"CONNEXION_IMPOSSIBLE_ATTACHMENT", @"Aucune connexion : fichier indisponible")
                                                                   delegate:self
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:@"Continuer", nil];
                    [alert show];
                    [spinnerView setHidden:YES];
                }
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:NSLocalizedString(@"CONNEXION_IMPOSSIBLE_ATTACHMENT", @"Aucune connexion : fichier indisponible")
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"Continuer", nil];
                [alert show];
                [spinnerView setHidden:YES];
            }
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"FORMAT_DE_FICHIER_NON_SUPPORTE", @"Aucune application disponible pour ouvrir cette pièce jointe")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                              otherButtonTitles:nil];
        [alert show];
        
    }
    DLog(@"didSelectRowAtIndexPath");
}


-(void)viewAttachment:(NSData*)data filePath:(NSString*)filePath attachment:(Attachment*)attachment {
    DLog(@"viewAttachment %@",filePath);
    id toSend = nil;
    if ([EmailTool attachmentIsImage:attachment]) {
        UIImage *image = [[UIImage alloc] initWithData:data];
        if (image) {
            toSend = image;
            //            [self performSegueWithIdentifier:@"segueToImageViewer" sender:image];
        } else {
            //TODO Wrong Format
        }
        
    } else if ([EmailTool attachmentIsViewable:attachment]) {
        toSend = filePath;
        //        [self performSegueWithIdentifier:@"segueToWebViewer" sender:filePath];
    }
    
    if (toSend) {
        viewAttachment = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:VIEW_ATTACHMENT_FROM_NEW_MSG object:toSend];
    }
    
}

- (void)showContactsPicker:(id)sender {
    
	// Show some kind of contacts picker in here.
	// For now, here's how to add and customize tokens.
    
	NSArray * names = [Names listOfNames];
    
	TIToken * token = [_currentSelectedTokenField addTokenWithTitle:[names objectAtIndex:(arc4random() % names.count)]];
	[token setAccessoryType:TITokenAccessoryTypeDisclosureIndicator];
	// If the size of the token might change, it's a good idea to layout again.
	[_currentSelectedTokenField layoutTokensAnimated:YES];
    
	NSUInteger tokenCount = _currentSelectedTokenField.tokens.count;
	[token setTintColor:((tokenCount % 3) == 0 ? [TIToken redTintColor] : ((tokenCount % 2) == 0 ? [TIToken greenTintColor] : [TIToken blueTintColor]))];
}



#pragma mark - TokenTableViewControllerDelegate

-(void)tokenTableViewController:(TITokenTableViewController *)tokenTableViewController didSelectTokenField:(TITokenField *)tokenField {
    _currentSelectedTokenField = tokenField;
}


-(void)setMessage:(Message *)_message {
    
    DLog(@"setMessage %@", _message);
    
    message = _message;
    
    
    //    for (Email* email in [[message emails] allObjects]) {
    //        if ([email.type isEqualToString:E_FROM]){
    //            [fromEmailsStrings addObject:[self emailtoString:email]];
    //        } else if ([email.type isEqualToString:E_TO]){
    //            [toEmailsStrings addObject:[self emailtoString:email]];
    //        } else if ([email.type isEqualToString:E_CC]){
    //            [ccEmailsStrings addObject:[self emailtoString:email]];
    //        }
    //    }
    
    body = message.body;
    
    subject = message.subject;
}

-(void)updateSubjectAndMessage {
    DLog(@"running [self updateSubjectAndMessage];");
    if ([subject length]>0){
        NSString *tmpsubject = @"";
        if (![@"<Sans objet>" isEqualToString:subject]) {
            tmpsubject = subject;
        } else {
            subject = tmpsubject;
        }
        
        if ([REPLIED isEqualToString:replyType]){
            
            subject = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"RE", @"Re:"),tmpsubject];
        }
        else if ([FORWARDED isEqualToString:replyType]){
            subject = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"TR", @"Tr:"),tmpsubject];
        }
    }
    
    if (([REPLIED isEqualToString:replyType] || [FORWARDED isEqualToString:replyType])){
        body = [NSString stringWithFormat:@"\n\n%@\n\n%@",[self getMessageResponse],message.body];
    }
}

-(void)didReceiveMemoryWarning {
    DLog(@"didReceiveMemoryWarning");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:NSLocalizedString(@"MEMOIRE_INSUFFISANTE_SUR_VOTRE_MOBILE", @"Mémoire insuffisante sur votre mobile!")
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                          otherButtonTitles:nil];
    [alert show];
    
    [attachmentsBytes removeAllObjects];
    [attachmentsArray removeAllObjects];
    
   // numberOfAttachments = 0;
    hasAttachments = NO;
    [self.tableView reloadData];
    
    [self hideView:NO];
}


@end