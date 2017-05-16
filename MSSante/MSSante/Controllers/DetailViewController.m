//
//  DetailViewController.m
//  MSSante
//
//  Affiche les details d'un message lorsqu'on click sur une cellule dans masterView
//
//  Created by labinnovation on 10/06/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "DetailViewController.h"
#import "Constant.h"
#import "UpdateMessagesInput.h"
#import "DAOFactory.h"
#import "Request.h"
#import "MessageDAO.h"
#import "MoveMessagesInput.h"
#import "PasswordStore.h"

#import "EmailTool.h"

@interface DetailViewController () {
    NSNumber *messageId;
    Attachment *currentAttachment;
    UITableViewCell *currentCell;
}

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController
@synthesize message, delegate;
@synthesize tableArray;
@synthesize attachmentsData;

#pragma mark - Managing the detail item

//Call first when controller is loaded
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideImageViewer:) name:HIDE_IMAGE_VIEWER_NOTIF object:nil];
    
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    self.title = @"";
//    pjIsHide = TRUE;
    [self.viewNoMail setHidden:NO];
    //Creation to custom button for shift (at left of masterView)
    UIImage *buttonImage = [UIImage imageNamed:@"bouton_palette_basBleu"];
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aButton setImage:buttonImage forState:UIControlStateNormal];
    aButton.frame = CGRectMake(0,0,50,50);
    [aButton addTarget:self action:@selector(openBarMenu:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:aButton];
    self.navigationItem.rightBarButtonItem = backButton;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        //Creation to custom button for create message (at right of masterView)
        [self.navigationItem setHidesBackButton:YES];
        UIImage *buttonImageRight = [UIImage imageNamed:@"bouton_retour"];
        UIButton *bButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [bButton setImage:buttonImageRight forState:UIControlStateNormal];
        bButton.frame = CGRectMake(0,0,50,35);
        [bButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *shiftButton = [[UIBarButtonItem alloc] initWithCustomView:bButton];
        self.navigationItem.leftBarButtonItem = shiftButton;
    }
    [self.bodyView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"d1@2x.png"]]];
    
    UITapGestureRecognizer *firstIconTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(firstIconTap:)];
    UITapGestureRecognizer *secondIconTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(secondIconTap:)];
    UITapGestureRecognizer *followTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(follow:)];
    UITapGestureRecognizer *unreadTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(unreadMsg:)];
    
    [self.deleteView addGestureRecognizer:firstIconTap];
    [self.followView addGestureRecognizer:followTap];
    [self.moveFolderView addGestureRecognizer:secondIconTap];
    if ([message.folderId isEqualToNumber:[NSNumber numberWithInt:CORBEILLE_ID_FOLDER]]) {
        [self.unreadView addGestureRecognizer:secondIconTap];
    } else {
        [self.unreadView addGestureRecognizer:unreadTap];
    }

}

-(void)viewDidAppear:(BOOL)animated {
    [self.attachmentsTableView reloadData];
}

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}



-(void)updateMasterController:(NSString*)method{
    DLog(@"update detail method %@", method);
    [_menuView setHidden:YES];
    if([self delegate] != nil){
        [[self delegate] updateListMessage:message forMethod:method];
    }
    
    if ([TRASH_MESSAGE_DELEGATE isEqualToString:method]){
        [self.viewNoMail setHidden:NO];
    }
    else if ([DELETE_MESSAGE_DELEGATE isEqualToString:method]){
        [self.viewNoMail setHidden:NO];
    }
    else if ([RESTORE_MESSAGE_DELEGATE isEqualToString:method]){
        [self.viewNoMail setHidden:NO];
    }
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        if ([MOVE_TO_FOLDER_DELEGATE isEqualToString:method]){
            NSMutableArray *selectedMessages = [[NSMutableArray alloc] initWithObjects:message, nil];
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:selectedMessages forKey:SELECTED_MESSAGE];
            DLog(@"messageId : %@", message.folderId);
            [dict setObject:message.folderId forKey:MASTER_FOLDER_ID];
            [dict setObject:message.folderId forKey:CURRENT_FOLDER_ID];
            [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_MOVE_MSG_VIEW_NOTIF object:dict];
        }
        
        if (![method isEqualToString:FOLLOW_DELEGATE] && ![method isEqualToString:UNREAD_DELEGATE]) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    
    }
}
NSMutableArray *fromEmailsURI;
- (void)reloadDetailsView
{
    [self.repondreMenuButton setHidden:[message.folderId intValue] == BOITE_D_ENVOI_ID_FOLDER ? YES : NO];
    
    [self displayMenuBarCorbeilleOrNot];
    [self.loadingView setHidden:YES];
    [self.viewNoMail setHidden:YES];
    
    
    messageId = message.messageId;
    //TODO a modifier pour prendre en compte le multi envoie
    toEmails = [NSMutableArray array];
    ccEmails = [NSMutableArray array];
    fromEmails = [NSMutableArray array];
    fromEmailsURI = [NSMutableArray array];
    bccmEmails = [NSMutableArray array];
    toEmailsStrings = [NSMutableArray array];
    ccEmailsStrings = [NSMutableArray array];
    fromEmailsStrings = [NSMutableArray array];
    bccEmailsStrings = [NSMutableArray array];
    listAttachments = [NSMutableArray array];
    
    for (Email* email in [[message emails] allObjects]) {
        if ([email.type isEqualToString:E_FROM]){
            [fromEmails addObject:email];
            [fromEmailsURI addObject:[[email objectID]URIRepresentation]];
            [fromEmailsStrings addObject:[EmailTool emailtoString:email]];
        } else if ([email.type isEqualToString:E_TO]){
            [toEmails addObject:email];
            [toEmailsStrings addObject:[EmailTool emailtoString:email]];
        } else if ([email.type isEqualToString:E_CC]){
            [ccEmails addObject:email];
            [ccEmailsStrings addObject:[EmailTool emailtoString:email]];
        } else if ([email.type isEqualToString:E_BCC]){
            [bccmEmails addObject:email];
            [bccEmailsStrings addObject:[EmailTool emailtoString:email]];
        }
    }
    

    for (Attachment* attach in [message attachments]) {
        [listAttachments addObject:attach];
    }
    
    if ([listAttachments count] == 0){
        [self.hidePJButton setHidden:YES];
    }
    else {
        [self.hidePJButton setHidden:NO];

    }
    
    _fromLabel.text = [fromEmailsStrings componentsJoinedByString:@","];
    _toLabel.text = [toEmailsStrings componentsJoinedByString:@","];
    _ccLabel.text = [ccEmailsStrings componentsJoinedByString:@","];
    _objectLabel.text = [message subject];
    _nbPjLabel.text = [NSString stringWithFormat:@"%i", [listAttachments count]];
    NSString *msgBody = [message body];
    NSString *msgVolumineux = NSLocalizedString(@"MESSAGE_TROP_VOLUMINEUX", @"Le contenu du message est trop volumineux");
    if ([message.isBodyLarger boolValue]){
        msgBody = [NSString stringWithFormat:@"%@... %@", [message body], msgVolumineux ];
    }
    
    self.mailLabel.editable = NO;
    self.mailLabel.dataDetectorTypes = UIDataDetectorTypeLink;
    
    _mailLabel.text = msgBody;
    _dateLabel.text = [self dateToString:message.date];
    
    [self.attachmentsTableView reloadData];
    
    [self.attachmentsTableView setSeparatorColor:[UIColor colorWithWhite:0.85 alpha:1]];
    [self.attachmentsTableView setBackgroundColor:[UIColor lightGrayColor]];
}

-(NSString*)dateToString:(NSDate*)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    return strDate;
}

//Methode pour remettre à 0 les label et la vue details
-(void)setDefaultParamsDetail{
    
    [self.viewNoMail setHidden:NO];
    _fromLabel.text = @"";
    _toLabel.text = @"";
    _objectLabel.text = @"";
    _ccLabel.text = @"";
    _nbPjLabel.text = @"";
    _mailLabel.text = @"";
    _dateLabel.text = @"";
    _mailLabel.text = @"";
}

- (void)configureView
{
    // Update the user interface for the detail item.
    
    if (self.detailItem) {
        message = (Message*)_detailItem;
        [self reloadDetailsView];
    }
}

-(void)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)openBarMenu:(id)sender
{
    [_menuView setHidden:![_menuView isHidden]];
}

//Appelé quand on click sur répondre
- (IBAction)reply:(id)sender {
    if (_repondreView.hidden) {
        [_repondreView setHidden:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:HIDE_KEYBOARD object:nil];
        [self.view endEditing:YES];
    } else {
        [_repondreView setHidden:YES];
    }
    
}

//Appelé quand on veut afficher/masquer les pièces jointes
- (IBAction)hidePJInfo:(id)sender {
    if (self.attachmentsTableView.hidden) {
        DLog(@"show table");
        self.attachmentsTableView.hidden = NO;
        [self.attachmentsTableView reloadData];
        [self.hidePJButton setBackgroundImage:[UIImage imageNamed:@"fleche_haut"] forState:UIControlStateNormal];
    } else {
        DLog(@"hide table");
        self.attachmentsTableView.hidden = YES;
        [self.hidePJButton setBackgroundImage:[UIImage imageNamed:@"fleche_bas"] forState:UIControlStateNormal];
    }
}

- (void)secondIconTap:(id)sender {
    DLog(@"secondIconTap");
    DLog(@"message %@",[message description]);

    if (message.folderId == [NSNumber numberWithInt:CORBEILLE_ID_FOLDER]){
        [self deleteForEver:YES];
    }
    else {
        if (message.folderId.intValue != 0) {
            [self updateMasterController : MOVE_TO_FOLDER_DELEGATE];
        }
    
    }
}

-(void)deleteForEver:(BOOL)sync{
    MessageDAO *messageDAO = (MessageDAO*)[[DAOFactory factory] newDAO:MessageDAO.class];
    if (message.attachments.count > 0) {
        for (Attachment *attachment in message.attachments) {
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
    }
    
    if ([message.folderId isEqualToNumber:[NSNumber numberWithInt:BOITE_D_ENVOI_ID_FOLDER]]) {
        ModificationDAO *modifDAO = (ModificationDAO*)[[DAOFactory factory] newDAO:ModificationDAO.class];
        NSMutableArray *listModification = [modifDAO findModificationByMessageId:message.messageId];
        if (listModification.count > 0){
            for (Modification *modif in listModification){
                if ([modif.operation isEqualToString:SEND]){
                    [modifDAO deleteObject:modif];
                }
            }
        }
    }
    
    [messageDAO deleteObject:message];
    
    if (sync) {
        NSMutableArray *arrayIdsMessage = [[NSMutableArray alloc] init];
        [arrayIdsMessage addObject:message.messageId];
        if ([arrayIdsMessage count] >0){
            UpdateMessagesInput* updateInput = [[UpdateMessagesInput alloc] init];
            [updateInput setMessageIds:arrayIdsMessage];
            [updateInput setOperation:O_DELETE];
            [self runRequestService:S_ITEM_UPDATE_MESSAGES withParams:[updateInput generate] header:nil andMethod:HTTP_POST];
        }
    }
    
    [self saveDB];
    [self updateMasterController : DELETE_MESSAGE_DELEGATE];
}

- (void)follow:(id)sender {
    NSMutableArray *arrayIdsMessage = [[NSMutableArray alloc] init];
    
    [arrayIdsMessage addObject:message.messageId];
    UpdateMessagesInput* updateInput = [[UpdateMessagesInput alloc] init];
    [updateInput setMessageIds:arrayIdsMessage];
    if ([message.isFavor boolValue]){
        message.isFavor = [NSNumber numberWithBool:NO];
        [updateInput setOperation:O_UNFLAGGED];
    }
    else {
        message.isFavor = [NSNumber numberWithBool:YES];
        [updateInput setOperation:O_FLAGGED];
    }
    [self runRequestService:S_ITEM_UPDATE_MESSAGES withParams:[updateInput generate] header:nil andMethod:HTTP_POST];
    
    [self saveDB];
//    [_menuView setHidden:YES];
    [self updateMasterController : FOLLOW_DELEGATE];
}


-(void)unreadMsg:(id)sender{
    NSMutableArray *arrayIdsMessage = [[NSMutableArray alloc] init];
    [arrayIdsMessage addObject:message.messageId];
    
    UpdateMessagesInput* updateInput = [[UpdateMessagesInput alloc] init];
    
    if ([message.isRead boolValue]){
        [updateInput setOperation:O_UNREAD];
        [message setIsRead:[NSNumber numberWithBool:NO]];
    } else {
        [updateInput setOperation:O_READ];
        [message setIsRead:[NSNumber numberWithBool:YES]];
    }
    
    [updateInput setMessageIds:arrayIdsMessage];
    
    [self runRequestService:S_ITEM_UPDATE_MESSAGES withParams:[updateInput generate] header:nil andMethod:HTTP_POST];
    
    [self saveDB];
    [self updateMasterController : UNREAD_DELEGATE];
//    [self updateUnreadMsgCount];
//    [self resetSwitches];
}

- (void)firstIconTap:(id)sender {
    if (message.folderId == [NSNumber numberWithInt:CORBEILLE_ID_FOLDER]){
        [self restoreMessage];
    }
    else if([message.folderId isEqualToNumber:[NSNumber numberWithInt:BOITE_D_ENVOI_ID_FOLDER]]){
        [self deleteForEver:NO];
    } else {
        [self trashMessage];
    }
}

-(void)restoreMessage{
    NSMutableArray *arrayIdsMessage = [[NSMutableArray alloc] init];
    [arrayIdsMessage addObject:message.messageId];
    
    MoveMessagesInput *moveMessages = [[MoveMessagesInput alloc] init];
    [moveMessages setMessageIds:arrayIdsMessage];
    [moveMessages setDestinationFolderId:[NSNumber numberWithInt:RECEPTION_ID_FOLDER]];
    message.folderId = [NSNumber numberWithInt:RECEPTION_ID_FOLDER];
    [self runRequestService:S_ITEM_MOVE_MESSAGES withParams:[moveMessages generate] header:nil andMethod:HTTP_POST];
    [self updateMasterController : RESTORE_MESSAGE_DELEGATE];
    [self saveDB];
}

-(void)trashMessage{
    NSMutableArray *arrayIdsMessage = [[NSMutableArray alloc] init];
    if ([message.folderId intValue] == BOITE_D_ENVOI_ID_FOLDER){
        ModificationDAO *modifDAO = (ModificationDAO*)[[DAOFactory factory] newDAO:ModificationDAO.class];
        NSMutableArray *listModification = [modifDAO findModificationByMessageId:message.messageId];
        if (listModification.count > 0){
            for (Modification *modif in listModification){
                if ([modif.operation isEqualToString:SEND]){
                    [modifDAO deleteObject:modif];
                    [self saveDB];
                }
            }
        }
    }
    
    [arrayIdsMessage addObject:message.messageId];
    
    UpdateMessagesInput* updateInput = [[UpdateMessagesInput alloc] init];
    message.folderId = [NSNumber numberWithInt:CORBEILLE_ID_FOLDER];
    [updateInput setOperation:O_TRASH];
    [updateInput setMessageIds:arrayIdsMessage];
    [self runRequestService:S_ITEM_UPDATE_MESSAGES withParams:[updateInput generate] header:nil andMethod:HTTP_POST];
    [self updateMasterController : TRASH_MESSAGE_DELEGATE];
    [self saveDB];
}

- (void)runRequestService:(NSString*)_servivce withParams:(NSDictionary*)_params header:(NSMutableDictionary*)_header andMethod:(NSString*)_method {
    Request *request = [[Request alloc] initWithService:_servivce method:_method headers:_header params:_params];
    request.delegate = self;
    [request execute];
}

-(void)httpError:(Error *)_error{
    [self.loadingView setHidden:YES];
    [currentCell setAccessoryView:nil];
}

-(void)httpResponse:(id)_responseObject{
    [self.loadingView setHidden:YES];
    if ([_responseObject isKindOfClass:[DownloadAttachmentResponse class]]) {
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
        NSLog(@"PasswordStore getInstance getDbEncryptKey");
        if (encryptedData) {
            [encryptedData writeToFile:filePath atomically:YES];
        }
        
        [currentCell setAccessoryView:nil];
        
        [self viewAttachment:data filePath:filePath attachment:currentAttachment];
    }
    else if ([_responseObject isKindOfClass:[NSString class]] && [_responseObject isEqualToString:@"S_ITEM_UPDATE_MESSAGES"]){
        
    }
}

-(void)viewAttachment:(NSData*)data filePath:(NSString*)filePath attachment:(Attachment*)attachment {
    
    if ([EmailTool attachmentIsImage:attachment]) {
        UIImage *image = [[UIImage alloc] initWithData:data];
        if (image) {
            [self performSegueWithIdentifier:@"segueToImageViewer" sender:image];
        } else {
            //TODO Wrong Format
        }
        
    } else if ([EmailTool attachmentIsViewable:attachment]) {
        [self performSegueWithIdentifier:@"segueToWebViewer" sender:filePath];
    }
}


- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
    
}


- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
    
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
    
}

-(void)saveDB{
    NSLog(@"SAVE DB IN DetailViewController");
    NSError *error;
    if (![[DAOFactory factory] save:&error]) {
        DLog(@"error save %@", [error userInfo]);
    }
}

- (IBAction)transferer:(id)sender {
    [_repondreView setHidden:YES];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:message forKey:MESSAGE];
    
    if (message.isAttachment){
        [params setObject:listAttachments forKey:ATTACHMENTS];
    }
    [params setObject:FORWARDED forKey:REPLY_TYPE];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_NEW_MSG_VIEW_NOTIF object:params];
}

- (IBAction)repondreATous:(id)sender {
    [_repondreView setHidden:YES];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    //setting to field
    if ([fromEmailsURI count] > 0) {
        [params setObject:fromEmailsURI forKey:@"toEmails"];
    }
    
    //setting cc field
    if ([toEmails count] > 0) {
        NSMutableArray *__ccEmails = [NSMutableArray array];
        NSString *myEmail = [AccesToUserDefaults getUserInfoChoiceMail];
        for (Email* email in toEmails) {
            if (![email.address isEqual:myEmail]) {
                [__ccEmails addObject:email];
            }
        }
        [params setObject:__ccEmails forKey:@"ccEmails"];
    }
    
    [params setObject:message forKey:MESSAGE];
    [params setObject:REPLIED forKey:REPLY_TYPE];
    //setting subject
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_NEW_MSG_VIEW_NOTIF object:params];
}

- (IBAction)repondreAction:(id)sender {

    [_repondreView setHidden:YES];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    //setting to field
    if ([fromEmailsURI count] > 0) {
        [params setObject:fromEmailsURI forKey:@"toEmails"];
    }
    
    [params setObject:message forKey:MESSAGE];
    [params setObject:REPLIED forKey:REPLY_TYPE];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_NEW_MSG_VIEW_NOTIF object:params];
}

#pragma mark - TokenTableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int height = listAttachments.count * 60;
    if (listAttachments.count > 2) {
        height = 150;
    }
    CGRect frame = self.attachmentsTableView.frame;
    frame.size.height = height;
    frame.size.width = self.view.frame.size.width;

    [self.attachmentsTableView setFrame:frame];
    return listAttachments.count;
}

//Method that allows you to customize the cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AttachmentCell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AttachmentCell"];
    }
    
    Attachment *attachment = listAttachments[indexPath.row];
    NSMutableString* textLabel = [NSMutableString stringWithFormat:@"%@",attachment.fileName ];
    DLog(@"attachment.size %d", attachment.size.intValue);
    if (attachment.size.intValue <= 0) {
        NSString* filePath = [Tools getAttachmentFilePath:attachment.fileName];
    
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
        if (fileExists) {
            NSURL *url = [NSURL fileURLWithPath:filePath];
            NSData *content = [NSData dataWithContentsOfURL:url];
            [attachment setSize:[NSNumber numberWithInt:ceil(content.length/1024) ]];
        }
    }
    
    if (attachment.size.intValue > 0) {
        [textLabel appendFormat:@" - %dK",[attachment.size intValue]];
    }
    
    [cell.textLabel setText:textLabel];
    [cell.imageView setImage:[UIImage imageNamed:@"img_fichierjoint"]];

    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.textColor = [UIColor colorWithRed:0.1294117647 green:0.36862745098 blue:0.44705882352 alpha:1];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UIButton *delete = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [delete setTag:indexPath.row];
    [delete setImage:[UIImage imageNamed:@"croix"] forState:UIControlStateNormal];
    [delete addTarget:self action:@selector(deleteAttachment:) forControlEvents:UIControlEventTouchUpInside]; 
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Attachment* attachment = listAttachments[indexPath.row];
    
    if ([EmailTool attachmentIsSupported:attachment]) {
        NSString *filePath;
        
        NSURL *url;
        BOOL fileExists = NO;
        NSData *content;
        
        if (message.folderId.intValue == BOITE_D_ENVOI_ID_FOLDER || message.folderId.intValue == BROUILLON_ID_FOLDER || message.folderId.intValue == ENVOYES_ID_FOLDER) {
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
            [self.loadingView setHidden:NO];
            DownloadAttachmentInput *downloadInput = [[DownloadAttachmentInput alloc] init];
            [downloadInput setMessageId:messageId];
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
                [self.loadingView setHidden:YES];
            }
            
            
//            currentCell = [tableView cellForRowAtIndexPath:indexPath];
//            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//            [activityIndicator setHidesWhenStopped:YES];
//            [activityIndicator startAnimating];
//            [currentCell setAccessoryView:activityIndicator];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"FORMAT_DE_FICHIER_NON_SUPPORTE", @"Aucune application disponible pour ouvrir cette pièce jointe")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                              otherButtonTitles:nil];
        [alert show];
        
    }
    
}

-(void)displayMenuBarCorbeilleOrNot{
    DLog(@"displayMenuCorbeilleOrNot : %@", message.folderId);
    
    UIImageView *firstImgView = (UIImageView*)[self.deleteView viewWithTag:11];
    UILabel *firstLabel = (UILabel*)[self.deleteView viewWithTag:12];
    
    UIImageView *secondImgView = (UIImageView*)[self.moveFolderView viewWithTag:21];
    UILabel *secondLabel = (UILabel*)[self.moveFolderView viewWithTag:22];
    
    UIImageView *unreadImgView = (UIImageView*)[self.unreadView viewWithTag:121];
    UILabel *unreadlabel = (UILabel*)[self.unreadView viewWithTag:122];
    
    [unreadImgView setImage:[UIImage imageNamed:@"ico_nonlus_grand"]];
    unreadlabel.text = @"Non lus";
    
    UITapGestureRecognizer *unreadTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(unreadMsg:)];
    [self.unreadView addGestureRecognizer:unreadTap];
    
    if (message.folderId == [NSNumber numberWithInt:BOITE_D_ENVOI_ID_FOLDER]){
        
        [self.followView setHidden:YES];
        [self.moveFolderView setHidden:YES];
        [self.unreadView setHidden:YES];
        [self.deleteView setHidden:NO];
        [firstImgView setImage:[UIImage imageNamed:@"ico_supprimer"]];
        firstLabel.text = @"Supprimer";
    }
    else if(message.folderId == [NSNumber numberWithInt:CORBEILLE_ID_FOLDER]){
        [self.followView setHidden:YES];
        [self.moveFolderView setHidden:YES];
        [self.deleteView setHidden:NO];
        [self.unreadView setHidden:NO];
        [firstImgView setImage:[UIImage imageNamed:@"ico_restaurer"]];
        firstLabel.text = @"Restaurer";
        
        secondImgView = (UIImageView*)[self.unreadView viewWithTag:121];
        secondLabel = (UILabel*)[self.unreadView viewWithTag:122];
        
        [secondImgView setImage:[UIImage imageNamed:@"ico_supprimer"]];
        CGRect frame = secondImgView.frame;
        [secondImgView setFrame:frame];
        secondLabel.text = @"Supprimer";
        DLog(@"Here");
        UITapGestureRecognizer *secondIconTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(secondIconTap:)];

        [self.unreadView addGestureRecognizer:secondIconTap];
    }
    else {
        [self.followView setHidden:NO];
        [self.moveFolderView setHidden:NO];
        [self.deleteView setHidden:NO];
        [self.unreadView setHidden:NO];
        
        [firstImgView setImage:[UIImage imageNamed:@"ico_corbeille_grand"]];
        firstLabel.text = @"Corbeille";
        
        [secondImgView setImage:[UIImage imageNamed:@"ico_dossier_grand"]];
        secondLabel.text = @"Déplacer vers";        
    }
}





-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"segueToImageViewer"]) {
        UIImage *image = (UIImage*)sender;
        ImageViewerController *imageViewController = segue.destinationViewController;
        [imageViewController setImage:image];
    } else if ([segue.identifier isEqualToString:@"segueToWebViewer"]) {
//        NSURL *path = (NSURL*)sender;
        NSString *path = (NSString*)sender;
        WebViewController *webViewController = segue.destinationViewController;
//        [webViewController setUrl:path];
        [webViewController setFilePath:path];
        
    }
        
    
    
}

- (void)hideImageViewer:(NSNotification *)pNotification{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
