//
//  MasterViewController.m
//  MSSante
//
//  Controller qui gère l'affichage des messages en fonctions du dossier
//
//  Created by labinnovation on 10/06/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.

#import "MasterViewController.h"
#import "NouveauMessageViewController2.h"
#import "InitialisationFolders.h"
#import "HeaderMenuBarView.h"
#import "HeaderMenuCorbeilleView.h"
#import "UpdateMessagesInput.h"
#import "EmptyInput.h"
#import "SyncAndLaunchModification.h"
#import "Modification.h"
#import "ModificationDAO.h"
#import "PasswordStore.h"
#import "NPConverter.h"
#define IS_IOS_7_OR_EARLIER    ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)

@interface MasterViewController () {
    BOOL searchBarMayResign ;
    NSTimer *searchDelayer;
    NSString *priorSearchText;
    UILabel *chargementInitial;
    NSIndexPath *currentIndex;
    NSMutableArray *checkedMessages;
    NSMutableArray *favoriteMessages;
    NSNumber *selectMessage;
    BOOL isShownError;
    BOOL isCanalBlocked;
    BOOL searchNeverClicked;
    BOOL isIpad;
}

@end

@implementation MasterViewController
@synthesize fetchedResultsController, popoverController, backMenuViewController,masterFolderId, selectedMessages, listMessagesMaster;
@synthesize masterFolder;
@synthesize isComingFromFolderSelection;
@synthesize spinnerView;
@synthesize loadingActivityIndicator;
@synthesize changeNotificationStateIsRunning;
@synthesize isShown;
- (void)awakeFromNib{
    [super awakeFromNib];
}

//Call at first when the view is loaded
- (void)viewDidLoad{
    isShownError = NO;
    searchBarMayResign = YES;
    [super viewDidLoad];
    DLog(@"MasterViewController - viewDidLoad");
    
    if (_refreshHeaderView == nil) {
        
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
    }
    [self addNotification];
    //  update the last update date
    [_refreshHeaderView refreshLastUpdatedDate];
    
    [self initMasterViewController];
    
    if (isComingFromFolderSelection) {
        [self displayMessageOfFolder:masterFolderId];
    }
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    spinnerView = [[UIView alloc] initWithFrame: CGRectMake (0, 0, screenRect.size.width, screenRect.size.height)];
    [spinnerView setBackgroundColor:[UIColor blackColor]];
    [spinnerView setAlpha:0.7];
    loadingActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] ;
    loadingActivityIndicator.frame = CGRectMake(0.0, 0.0, 20,20);
    loadingActivityIndicator.center = spinnerView.center;
    loadingActivityIndicator.color = [UIColor whiteColor];
    [loadingActivityIndicator startAnimating];
    [spinnerView addSubview:loadingActivityIndicator];
    CGRect frame = CGRectMake(loadingActivityIndicator.frame.origin.x - 150, loadingActivityIndicator.frame.origin.y + 30, 300, 40);
    
    chargementInitial = [[UILabel alloc] initWithFrame:frame];
    [chargementInitial setTextAlignment:NSTextAlignmentCenter];
    [chargementInitial setText:NSLocalizedString(@"CHARGEMENT_INITIAL", @"Chargement initial ...")];
    [chargementInitial setBackgroundColor:[UIColor clearColor]];
    
    [spinnerView addSubview:chargementInitial];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        isIpad=NO;
    }else {
        isIpad=YES;
    }
    isLoadMoreMessages = NO;
    currentIndex = nil;
}

-(void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HIDE_POPUP_NOTIF object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UPDATE_NOTIF object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:REFRESH_CURRENT_FOLDER_NOTIF object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UPDATE_CURRENT_FOLDER_NOTIF object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HIDE_KEYBOARD object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MESSAGE_SENT_NOTIF object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FOLDER_INITIALIZATION_FINISHED_NOTIF object:nil];
}
-(void)addNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HIDE_POPUP_NOTIF object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UPDATE_NOTIF object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:REFRESH_CURRENT_FOLDER_NOTIF object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UPDATE_CURRENT_FOLDER_NOTIF object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HIDE_KEYBOARD object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MESSAGE_SENT_NOTIF object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FOLDER_INITIALIZATION_FINISHED_NOTIF object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hidePopup:) name:HIDE_POPUP_NOTIF object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNotif:) name:UPDATE_NOTIF object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCurrentFolder:) name:REFRESH_CURRENT_FOLDER_NOTIF object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCurrentFolder:) name:UPDATE_CURRENT_FOLDER_NOTIF object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard:) name:HIDE_KEYBOARD object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageSentNotif:) name:MESSAGE_SENT_NOTIF object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(folderInitDone:) name:FOLDER_INITIALIZATION_FINISHED_NOTIF object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    
    if (isComingFromFolderSelection) {
        [self createMenuButton];
    }
    for (UIView *subView in tableSearchBar.subviews) {
        //Find the button
        if([subView isKindOfClass:[UIButton class]])
        {
            //Change its properties
            UIButton *cancelButton = (UIButton *)[tableSearchBar.subviews lastObject];
            [cancelButton addTarget:self action:@selector(hideSearchBar:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    if ([[ShownFolder sharedInstance] folderId] && [PasswordStore plainPasswordIsSet]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_CURRENT_FOLDER_NOTIF object:[[ShownFolder sharedInstance] folderId]];
    }
}


+(void)majWhenReceivedNotification{
    
    //    NSNumber* folderId = [NSNumber numberWithInt:RECEPTION_ID_FOLDER];
    //    [ShownFolder sharedInstance].folderId = folderId;
    if ([[ShownFolder sharedInstance] folderId] && [PasswordStore plainPasswordIsSet]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_CURRENT_FOLDER_NOTIF object:[[ShownFolder sharedInstance] folderId]];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (!spinnerView.hidden) {
        [self updateSpinnerViewOrientation:toInterfaceOrientation];
    }
}

-(void)updateSpinnerViewOrientation:(UIInterfaceOrientation)orientation {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    CGFloat angle = 0;
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    switch (orientation) {
        case 1:
        default:
            angle = 0;
            break;
        case 2:
            angle = M_PI;
            break;
        case 3:
            screenWidth = screenRect.size.height;
            screenHeight = screenRect.size.width;
            angle = M_PI / 2;
            break;
        case 4:
            screenWidth = screenRect.size.height;
            screenHeight = screenRect.size.width;
            angle = - M_PI / 2;
            break;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [spinnerView setTransform:CGAffineTransformMakeRotation(angle)];
    [spinnerView setFrame: CGRectMake (0, 0, screenRect.size.width, screenRect.size.height)];
    [UIView commitAnimations];
    [loadingActivityIndicator setFrame:CGRectMake(screenWidth/2 - 10, screenHeight/2 -10, 20, 20)];
    [spinnerView addSubview:loadingActivityIndicator];
    CGRect frame = CGRectMake(loadingActivityIndicator.frame.origin.x - 150, loadingActivityIndicator.frame.origin.y + 30, 300, 40);
    [chargementInitial setFrame:frame];
    [UIView commitAnimations];
    
}

-(void)hideSearchBar:(UIButton *)sender {
    DLog(@"hideSearchBar");
    [self.view endEditing:YES];
    [tableSearchBar resignFirstResponder];
    [tableSearchBar endEditing:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    DLog(@"viewDidAppear MasterViewController");
    
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    DLog(@"orientation %d", orientation);
    [self updateSpinnerViewOrientation:orientation];
    
    self.mailTitleLabel.text = [AccesToUserDefaults getUserInfoChoiceMail];
    DLog(@"[PasswordStore plainPasswordIsSet] %d", [PasswordStore plainPasswordIsSet]);
    if ([PasswordStore plainPasswordIsSet]) {
        NSLog(@"PasswordStore passwdIsSet ? YES");
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            MessageDAO* messageDAO = (MessageDAO*)[[DAOFactory factory] newDAO:MessageDAO.class];
            if (masterFolderId && masterFolderId != [NSNumber numberWithInt:NON_LUS_ID_FOLDER] && masterFolderId != [NSNumber numberWithInt:SUIVIS_ID_FOLDER]) {
                if (tableSearchBar.text.length > 0) {
                    tableSearchBar.text = @"";
                } else {
                    
                    [listMessagesMaster removeAllObjects];
                    listMessagesMaster = [messageDAO findMessagesByFolderId:masterFolderId];
                    
                    [self.tableView reloadData];
                }
            } else if (masterFolderId.intValue == NON_LUS_ID_FOLDER) {
                [listMessagesMaster removeAllObjects];
                listMessagesMaster = [messageDAO findAllMessagesUnread];
                [self.tableView reloadData];
            } else if (masterFolderId.intValue == SUIVIS_ID_FOLDER) {
                [listMessagesMaster removeAllObjects];
                listMessagesMaster = [messageDAO findAllMessagesFollowed];
                [self.tableView reloadData];
            }
            
            if (listMessagesMaster.count == 0) {
                [headerMenu setHidden:YES];
            }
        }
        
        [self updateUnreadMsgCount];
        [self updateDraftMsgCount];
        [self updateBoiteDenvoiMsgCount];
    }
    DLog(@"endViewDidAppear MasterViewController");
    
}

-(void)addLoadMoreMessagesButton:(NSNumber*)folderId {
    if (listMessagesMaster.count > 0 && folderId.intValue != NON_LUS_ID_FOLDER && folderId.intValue != SUIVIS_ID_FOLDER && folderId.intValue != BOITE_D_ENVOI_ID_FOLDER)  {
        if (searchMethod == SEARCH_MORE_MESSAGES) {
            [loadMoreMessagesButton setTitle:NSLocalizedString(@"RECHERCHER_LES_MESSAGES_SUIVANTS",@"Rechercher les messages suivants") forState:UIControlStateNormal];
        } else if(searchMethod == LOAD_MORE_MESSAGES){
            [loadMoreMessagesButton setTitle:NSLocalizedString(@"CHARGER_LES_MESSAGES_SUIVANTS",@"Charger les messages suivants") forState:UIControlStateNormal];
        }
        self.tableView.tableFooterView = footerView;
    } else {
        self.tableView.tableFooterView = nil;
    }
}

-(void)initMasterViewController{
    searchNeverClicked = YES;
    isLoading = TRUE;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.containerController = (ContainerViewController*)[self.navigationController parentViewController];
        self.detailViewController = [self.containerController getDetailViewController];
        self.detailViewController.delegate = self;
    }
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithWhite:0.9 alpha:1];
    [self.nbMsgLabel.layer setCornerRadius:5];
    
    
    [self setDefaultParamMaster];
    
    //Table Header
    //search Bar
    tableSearchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 320, 45)];
    tableSearchBar.autocorrectionType=UITextAutocorrectionTypeNo;
    tableSearchBar.autocapitalizationType=UITextAutocapitalizationTypeNone;
    tableSearchBar.delegate=self;
    tableSearchBar.text = @"";
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        tableSearchBar.showsCancelButton=YES;
    }
    
    //Header Menu
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    [headerView addSubview:tableSearchBar];
    
    offset = 0;
    
    searchMethod = LOAD_MORE_MESSAGES;
    
    //Table Footer
    footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    loadMoreMessagesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loadMoreMessagesButton setFrame:CGRectMake(0, 0, 320, 50)];
    [loadMoreMessagesButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [loadMoreMessagesButton setTitle:NSLocalizedString(@"CHARGER_LES_MESSAGES_SUIVANTS",@"Charger les messages suivants") forState:UIControlStateNormal];
    [loadMoreMessagesButton setBackgroundColor:[UIColor clearColor]];
    [loadMoreMessagesButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [loadMoreMessagesButton addTarget:self action:@selector(loadMoreMessages) forControlEvents:UIControlEventTouchDown];
    
    activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGPoint center = footerView.center;
    center.x = 280;
    activityIndicator.center = center;
    [activityIndicator setHidesWhenStopped:YES];
    [activityIndicator stopAnimating];
    
    [footerView addSubview:loadMoreMessagesButton];
    [footerView addSubview:activityIndicator];
    searchMethod = LOAD_MORE_MESSAGES;
    [self addLoadMoreMessagesButton:masterFolderId];
    [self changeHeaderMenu:masterFolderId];
}

-(void)setDefaultParamMaster{
    
    isMenuDisplay = FALSE;
    checkedMessages = [[NSMutableArray alloc] init];
    favoriteMessages = [[NSMutableArray alloc] init];
    listMessagesMaster = [[NSMutableArray alloc] init];
    selectedMessages = [[NSMutableArray alloc] init];
    saveFavoriteState =[[NSMutableDictionary alloc] init];
    saveSwitchState =[[NSMutableDictionary alloc] init];
    
    for (int i = 0; i < listMessagesMaster.count; i ++){
        [saveSwitchState setValue:[NSNumber numberWithBool:FALSE] forKey:[NSString stringWithFormat:@"%d", i]];
        [saveFavoriteState setValue:[NSNumber numberWithBool:FALSE] forKey:[NSString stringWithFormat:@"%d", i]];
    }
    
    [self.detailViewController setDefaultParamsDetail];
}

-(void)loadMasterControllerWithFolder:(NSNumber*)folderId inFolderSubView:(BOOL)isFolderSubview{
    [self loadMasterControllerWithFolder:folderId inFolderSubView:isFolderSubview isInit:NO];
}

-(void)changeHeaderMenu:(NSNumber*)folderId{
    if ([folderId isEqualToNumber:[NSNumber numberWithInt:CORBEILLE_ID_FOLDER]]) {
        [headerMenu removeFromSuperview];
        headerMenu = [[HeaderMenuCorbeilleView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
        [(HeaderMenuCorbeilleView*)headerMenu setMasterViewController:self];
        [headerMenu setHidden:YES];
        [headerView addSubview:headerMenu];
    } else {
        [headerMenu removeFromSuperview];
        headerMenu = [[HeaderMenuBarView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
        [(HeaderMenuBarView*)headerMenu setMasterViewController:self];
        [headerMenu setHidden:YES];
        [headerView addSubview:headerMenu];
        //        BOOL hideButton = folderId == [NSNumber numberWithInt:BROUILLON_ID_FOLDER] || folderId == [NSNumber numberWithInt:BOITE_D_ENVOI_ID_FOLDER];
        
        if (folderId.intValue == BOITE_D_ENVOI_ID_FOLDER || folderId.intValue == BROUILLON_ID_FOLDER ) {
            [(HeaderMenuBarView*)headerMenu hideForDraft:YES];
            [(HeaderMenuBarView*)headerMenu isOutbox:YES];
        }
    }
    //
    //    if (folderId != [NSNumber numberWithInt:CORBEILLE_ID_FOLDER]){
    //        [headerMenu removeFromSuperview];
    //        headerMenu = [[HeaderMenuBarView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    //        [(HeaderMenuBarView*)headerMenu setMasterViewController:self];
    //        [headerMenu setHidden:YES];
    //        [headerView addSubview:headerMenu];
    //        BOOL hideButton = folderId == [NSNumber numberWithInt:BROUILLON_ID_FOLDER] || folderId == [NSNumber numberWithInt:BOITE_D_ENVOI_ID_FOLDER];
    //        [(HeaderMenuBarView*)headerMenu hideForDraft:hideButton];
    //    }
    //    else {
    //        [headerMenu removeFromSuperview];
    //        headerMenu = [[HeaderMenuCorbeilleView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    //        [(HeaderMenuCorbeilleView*)headerMenu setMasterViewController:self];
    //        [headerMenu setHidden:YES];
    //        [headerView addSubview:headerMenu];
    //    }
    
}

-(void)loadMasterControllerWithFolder:(NSNumber*)folderId inFolderSubView:(BOOL)isFolderSubview isInit:(BOOL)isInit{
    DLog(@"LoginProcess : loadMasterControllerWithFolder");
    currentIndex = nil;
    if ([AccesToUserDefaults getUserInfoEnrollement] && [PasswordStore plainPasswordIsSet]) {
        DLog(@"loadMasterControllerWithFolder");
        
        DLog(@"isFolderSubview %d",isFolderSubview);
        
        if (!isLoading){
            [self initMasterViewController];
        }
        else {
            [self setDefaultParamMaster];
        }
        
        DLog(@"folderId %@",folderId);
        [self changeHeaderMenu:folderId];
        
        tableSearchBar.text = @"";
        
        masterFolderId = folderId;
        
        [ShownFolder sharedInstance].folderId = masterFolderId;
        
        if (self.nbMsgLabel) {
            [self.nbMsgLabel setHidden:YES];
        }
        
        
        FolderDAO *folderDAO = (FolderDAO*)[[DAOFactory factory] newDAO:FolderDAO.class];
        masterFolder = [folderDAO findFolderByFolderId:folderId];
        
        
        
        DLog(@"loadMasterControllerWithFolder folderId  : %@", folderId);
        
        if (!isFolderSubview){
            [self createMenuButton];
        }
        else {
            [self createBackButton];
        }
        
        SearchMessagesInput* searchInput = [[SearchMessagesInput alloc] init];
        [searchInput setFolderId:folderId];
        DLog(@"isInit %d",isInit);
        DLog(@"masterFolder.initialized %d",masterFolder.initialized.boolValue);
        DLog(@"changeNotificationStateIsRunning %d",changeNotificationStateIsRunning);
        if (![AccesToUserDefaults getUserInfoEmailNotificationInitalized] && !changeNotificationStateIsRunning) {
            [AccesToUserDefaults deleteSyncToken];
            [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_SUCCESSFUL_NOTIF object:nil];
        }
        
        else if ([masterFolder.initialized isEqualToNumber:[NSNumber numberWithBool:NO]]) {
            DLog(@"Folder Not Initialized, reinitialization");
            //           [self.whiteView setHidden:NO];
            //            [self.loadingView setHidden:NO];
            //            [[[UIApplication sharedApplication] keyWindow] addSubview:spinnerView];
            DLog(@"[[InitialisationFolders sharedInstance] isRunning] %d",[[InitialisationFolders sharedInstance] isRunning]);
            if (![[InitialisationFolders sharedInstance] isRunning]) {
                [self runRequestService:S_ITEM_SEARCH_MESSAGES withParams:[searchInput generate] header:nil andMethod:HTTP_POST];
            }
        }
        
        else {
            DLog(@"loadMasterControllerWithFolder SyncAndLaunchModification");
            SyncAndLaunchModification *syncAndLaunchModif = [[SyncAndLaunchModification alloc] init];
            syncAndLaunchModif.delegate = self;
            [syncAndLaunchModif syncOnlyFolderId:masterFolderId];
            DLog(@"loadMasterControllerWithFolder SyncAndLaunchModification calling execute");
            [syncAndLaunchModif execute];
        }
        
        if ([folderId isEqualToNumber : [NSNumber numberWithInt:RECEPTION_ID_FOLDER]]){
            self.titleLabel.text = NSLocalizedString(@"RECEPTION" , @"Réception");
            [self createNewMessageButton];
        }
        else if ([folderId isEqualToNumber : [NSNumber numberWithInt:NON_LUS_ID_FOLDER]]){
            self.titleLabel.text = NSLocalizedString(@"NON_LUS", @"Non lus");
            //        self.navigationItem.rightBarButtonItem = nil;
            [self createNewMessageButton];
        }
        else if ([folderId isEqualToNumber : [NSNumber numberWithInt:SUIVIS_ID_FOLDER]]){
            self.titleLabel.text = NSLocalizedString(@"SUIVIS", @"Suivis");
            //        self.navigationItem.rightBarButtonItem = nil;
            [self createNewMessageButton];
        }
        else if ([folderId isEqualToNumber : [NSNumber numberWithInt:BROUILLON_ID_FOLDER]]){
            self.titleLabel.text = NSLocalizedString(@"BROUILLONS" , @"Brouillons");
            //        self.navigationItem.rightBarButtonItem = nil;
            [self createNewMessageButton];
        }
        else if ([folderId isEqualToNumber : [NSNumber numberWithInt:ENVOYES_ID_FOLDER]]){
            self.titleLabel.text = NSLocalizedString(@"ENVOYES" , @"Envoyés");
            //        self.navigationItem.rightBarButtonItem = nil;
            [self createNewMessageButton];
        }
        else if ([folderId isEqualToNumber : [NSNumber numberWithInt:CORBEILLE_ID_FOLDER]]){
            self.titleLabel.text = NSLocalizedString(@"CORBEILLE", @"Corbeille");
            [self createMenuCorbeilleButton];
        }
        else if ([folderId isEqualToNumber : [NSNumber numberWithInt:BOITE_D_ENVOI_ID_FOLDER]]){
            self.titleLabel.text = NSLocalizedString(@"BOITE_D_ENVOI", @"Boite d'envoi");
            //        self.navigationItem.rightBarButtonItem = nil;
            SyncAndLaunchModification *checkModif = [[SyncAndLaunchModification alloc] init];
            checkModif.delegate = self;
            [checkModif execute];
            [self createNewMessageButton];
        }
        else {
            self.titleLabel.text = masterFolder.folderName;
            //        self.navigationItem.rightBarButtonItem = nil;
            [self createNewMessageButton];
        }
        
        isShown = YES;
        //@TD
        searchMethod = LOAD_MORE_MESSAGES;
        [self displayMessageOfFolder:folderId];
        
        if (!isInit){
            
            NSMutableDictionary* wrongFolderInit = [AccesToUserDefaults getUserInfoWrongFolderInitDictionary];
            NSString *key = [NSString stringWithFormat:@"%@%@",FOLDER_ID,folderId];
            
            if (wrongFolderInit != nil && [[wrongFolderInit objectForKey:key] isEqual:[NSNumber numberWithBool:YES]]){
                DLog(@"Reinitialisation du dossier %@ (folderId)", folderId);
                SearchMessagesInput* _searchInput = [[SearchMessagesInput alloc] init];
                [_searchInput setFolderId:folderId];
                [self runRequestService:S_ITEM_SEARCH_MESSAGES withParams:[_searchInput generate] header:nil andMethod:HTTP_POST];
            }
            //            else {
            //
            //                DLog(@"loadMasterControllerWithFolder SyncAndLaunchModification");
            //                SyncAndLaunchModification *syncAndLaunchModif = [[SyncAndLaunchModification alloc] init];
            //                syncAndLaunchModif.delegate = self;
            //                DLog(@"loadMasterControllerWithFolder SyncAndLaunchModification calling execute");
            //                [syncAndLaunchModif execute];
            //            }
        }
    }
}

- (void)initialiserMessages {
    DLog(@"LoginProcess : initialiserMessages : calling ListFolder");
    [listMessagesMaster removeAllObjects];
    [self.tableView reloadData];
    [self.whiteView setHidden:NO];
    [[[UIApplication sharedApplication] keyWindow] addSubview:spinnerView];
    [self createMenuButton];
    [self createNewMessageButton];
    self.titleLabel.text = NSLocalizedString(@"RECEPTION" , @"Réception");
    ListFoldersInput *listInput = [[ListFoldersInput alloc] init];
    
    masterFolderId = [NSNumber numberWithInt: RECEPTION_ID_FOLDER];
    [ShownFolder sharedInstance].folderId = masterFolderId;
    [self runRequestService:S_FOLDER_LIST withParams:[listInput generate] header:nil andMethod:HTTP_POST];
}

- (void)runRequestService:(NSString*)_service withParams:(NSDictionary*)_params header:(NSMutableDictionary*)_header andMethod:(NSString*)_method {
    Request *request = [[Request alloc] initWithService:_service method:_method headers:_header params:_params];
    request.delegate = self;
    if ([_service isEqual:S_ITEM_FULL_TEXT_SEARCH_MESSAGES] || [_service isEqual:S_ITEM_SEARCH_MESSAGES]) {
        if ([request isConnectedToInternet]) {
            [request execute];
        } else {
            [activityIndicator stopAnimating];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:NSLocalizedString(@"CONNEXION_IMPOSSIBLE", @"Connexion impossible")
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Continuer", nil];
            [alert show];
            [loadMoreMessagesButton setEnabled:YES];
        }
        
    } else {
        // NSLog(@"runServiceRequest");
        [request execute];
    }
    
}

-(void)httpResponse:(id)_responseObject {
    
    if ([_responseObject isKindOfClass:[ListFoldersResponse class]]) {
        //        [(ListFoldersResponse*)_responseObject saveToDatabase];
        
        if (![AccesToUserDefaults getUserInfoSyncToken]) {
            DLog(@"LoginProcess : ListFoldersResponse : calling searchMessages for inbox");
            SearchMessagesInput* searchInput = [[SearchMessagesInput alloc] init];
            [searchInput setFolderId:[NSNumber numberWithInt:RECEPTION_ID_FOLDER ]];
            [searchInput setLimit:[NSNumber numberWithInt:50]];
            [self runRequestService:S_ITEM_SEARCH_MESSAGES withParams:[searchInput generate] header:nil andMethod:HTTP_POST];
            
            DLog(@"LoginProcess : ListFoldersResponse : no sync token calling InitialisationFolders");
            [[InitialisationFolders sharedInstance] start];
        } else {
            DLog(@"LoginProcess : ListFoldersResponse : sync token exists, folders are initialized, calling Sync");
            SyncInput* syncInput = [[SyncInput alloc] init];
            Request *request = [[Request alloc] initWithService:S_ITEM_SYNC method:HTTP_POST headers:nil params:[syncInput generate]];
            request.delegate = self;
            [request execute];
        }
    } else if ([_responseObject isKindOfClass:[SyncMessagesResponse class]]) {
        SyncMessagesResponse* syncMessagesResponse = _responseObject;
        [AccesToUserDefaults setUserInfoSyncToken:[syncMessagesResponse.syncDictionary objectForKey:TOKEN]];
        //        DLog(@"LoginProcess : ListFoldersResponse : calling InitialisationFolders");
        
        
    } else if ([_responseObject isKindOfClass:[SearchMessagesResponse class]]) {
        if (masterFolder.folderId != nil) {
            DLog(@"MasterFolder %d %@ %d",masterFolder.folderId.intValue, masterFolder.folderName, masterFolder.initialized.intValue);
            //            if ([masterFolder.initialized isEqualToNumber:[NSNumber numberWithBool:NO]]) {
            [masterFolder setInitialized:[NSNumber numberWithBool:YES]];
            [(SearchMessagesResponse*)_responseObject saveToDatabase];
            //            }
            
        }
        
        DLog(@"SearchMessagesResponse");
        searchMethod = LOAD_MORE_MESSAGES;
        if (isLoadMoreMessages) {
            [activityIndicator stopAnimating];
            [loadMoreMessagesButton setEnabled:YES];
            [self displayMessageOfFolder:masterFolderId];
        } else {
            if ([[(SearchMessagesResponse*)_responseObject messages] count] > 0){
                [self displayMessageOfFolder:masterFolderId];
            }
            else {
                //TODO
                [self displayMessageOfFolder:nil];
            }
            
            
        }
        
        
    } else if ([_responseObject isKindOfClass:[FullTextSearchMessagesResponse class]]) {
        DLog(@"FullTextSearchMessagesResponse");
        //        DLog(@"_responseObject messages %@",[(FullTextSearchMessagesResponse*)_responseObject messages]);
        DLog(@"_responseObject messages %d",[[(FullTextSearchMessagesResponse*)_responseObject messages] count]);
        searchMethod = SEARCH_MORE_MESSAGES;
        [activityIndicator stopAnimating];
        [loadMoreMessagesButton setEnabled:YES];
        
        //        [self displayMessageOfFolder:masterFolderId];
        DLog(@"tableSearchBar.text %@",tableSearchBar.text);
        
        for (Message *resultMessage in [(FullTextSearchMessagesResponse*)_responseObject messages]) {
            if (![self messageExistsInList:resultMessage]) {
                [listMessagesMaster addObject:resultMessage];
            }
        }
        
        [self.tableView reloadData];
    }
    
    [self resetLoadMoreMessagesButton:nil];
}

-(BOOL)messageExistsInList:(Message*)searchMessage{
    
    for (Message *message in listMessagesMaster) {
        if ([message.messageId isEqualToNumber:searchMessage.messageId]) {
            return YES;
        }
    }
    return NO;
}

-(void)messageSent:(id)responseObject{
    DLog(@"message send : %@", responseObject);
    [self displayMessageOfFolder:masterFolderId];
}

-(BOOL)messageInArray:(Message*)msg messages:(NSArray*)messages {
    for (Message *oldMsg in messages) {
        if ([oldMsg.messageId isEqualToNumber:msg.messageId]) {
            return YES;
        }
    }
    return  NO;
}

-(void)httpError:(Error*)error {
    [spinnerView removeFromSuperview];
    [self.whiteView setHidden:YES];
    [activityIndicator stopAnimating];
    [loadMoreMessagesButton setEnabled:YES];
    DLog(@"Master HttpError");
    if (error != nil){
        if (error.errorCode == 45 ){
            [self displayMessageOfFolder:masterFolderId];
        }
        DLog(@"MasterView Error Msg: %@", [error errorMsg]);
        DLog(@"MasterView Http Code: %d", [error httpStatusCode]);
        DLog(@"MasterView Error Code: %d", [error errorCode]);
    }
}

-(void)displayMessageOfFolder:(NSNumber*)folderId{
    
    DLog(@"displayMessageOfFolder : %@", folderId);
    MessageDAO *messageDAO = (MessageDAO*)[[DAOFactory factory] newDAO:MessageDAO.class];
    
    [listMessagesMaster removeAllObjects];
    
    self.tableView.tableFooterView = nil;
    
    if (!folderId){
        [self.tableView reloadData];
        return;
    }
    else if ([folderId isEqualToNumber:[NSNumber numberWithInt:NON_LUS_ID_FOLDER]]){
        NSMutableArray *allMessagesUnread = [messageDAO findAllMessagesUnread];
        listMessagesMaster = [allMessagesUnread mutableCopy];
        listMessagesMaster = [self sortArrayByDate:listMessagesMaster];
        [self.tableView reloadData];
        return;
    }
    else if ([folderId isEqualToNumber:[NSNumber numberWithInt:SUIVIS_ID_FOLDER]]){
        NSMutableArray *allMessagesFollowed = [messageDAO findAllMessagesFollowed];
        listMessagesMaster = [allMessagesFollowed mutableCopy];
        listMessagesMaster = [self sortArrayByDate:listMessagesMaster];
        [self.tableView reloadData];
        return;
    }
    else {
        listMessagesMaster = [messageDAO findMessagesByFolderId:folderId];
    }
    
    //    DLog(@"listMessages %@",listMessagesMaster);
    offset = listMessagesMaster.count;
    
    listMessagesMaster = [self sortArrayByDate:listMessagesMaster];
    //@TD
    searchMethod = LOAD_MORE_MESSAGES;
    [self addLoadMoreMessagesButton:folderId];
    [self.tableView reloadData];
    [self updateNotif:nil];
    
    masterFolderId = folderId;
}

-(void)updateNotif:(NSNotification*)notification{
    [self updateUnreadMsgCount];
    [self updateDraftMsgCount];
    [self updateBoiteDenvoiMsgCount];
}

-(void)refreshCurrentFolder:(NSNotification*)notification {
    
    DLog(@"Notification : refreshCurrentFolder");
    if ([[RequestQueue sharedInstanceQueue] isEmpty]) {
        SyncAndLaunchModification *syncAndLaunchModif = [[SyncAndLaunchModification alloc] init];
        syncAndLaunchModif.delegate = self;
        [syncAndLaunchModif syncOnlyFolderId:masterFolderId];
        
        
        if ([self isConnectedToInternet] ) {
            DLog(@"Launching Sync Request because there is no other sync requests in the queue and there is internet connection");
            [syncAndLaunchModif execute];
        }
    }
    
}

-(void)updateCurrentFolder:(NSNotification*)notification {
    [self.tableView reloadData];
    
    if ([notification.object isKindOfClass:[NSNumber class]]) {
        DLog(@"updateCurrentFolder notification.object %@",notification.object);
        NSNumber *folderId = notification.object;
        if (folderId.intValue > 0) {
            //            [self loadMasterControllerWithFolder:folderId inFolderSubView:YES];
            isComingFromFolderSelection = YES;
            [self syncSucces:nil];
        }
    }
}

-(void)folderInitDone:(NSNotification*)notification {
    //    if ([masterFolderId isEqualToNumber:notification.object]) {
    //        [self.loadingView setHidden:YES];
    
    FolderDAO *folderDAO = (FolderDAO*) [[DAOFactory factory] newDAO:FolderDAO.class];
    NSMutableArray *folders = [[folderDAO findAll] mutableCopy];
    
    for (Folder *folder in folders ) {
        [folder setInitialized:[NSNumber numberWithBool:YES]];
    }
    
    [spinnerView removeFromSuperview];
    [self.whiteView setHidden:YES];
    //    }
    
    DLog(@"folderInitDone");
}

- (void)updateDraftMsgCount {
    
    MessageDAO *messageDAO = (MessageDAO*)[[DAOFactory factory] newDAO:MessageDAO.class];
    NSMutableArray *listDrafts = [messageDAO findMessagesByFolderId:[NSNumber numberWithInt:BROUILLON_ID_FOLDER ]];
    
    [self.backMenuViewController setNbDraft:[NSString stringWithFormat:@"%d", [listDrafts count]]];
}

- (void)updateBoiteDenvoiMsgCount {
    MessageDAO *messageDAO = (MessageDAO*)[[DAOFactory factory] newDAO:MessageDAO.class];
    NSMutableArray *listEnvoi = [messageDAO findMessagesByFolderId:[NSNumber numberWithInt:BOITE_D_ENVOI_ID_FOLDER ]];
    
    [self.backMenuViewController setNbMsgWillSend:[NSString stringWithFormat:@"%d", listEnvoi.count]];
}

- (void)updateUnreadMsgCount {
    int msgCount = 0;
    
    MessageDAO *messageDAO = (MessageDAO*)[[DAOFactory factory] newDAO:MessageDAO.class];
    NSMutableArray *listReception = [messageDAO findMessagesByFolderId:[NSNumber numberWithInt:RECEPTION_ID_FOLDER ]];
    
    for (Message *message in listReception){
        if (![message.isRead boolValue]){
            msgCount++;
        }
    }
    
    if (msgCount == 0 || [masterFolderId intValue] != RECEPTION_ID_FOLDER){
        [self.nbMsgLabel setHidden:YES];
    } else {
        [self.nbMsgLabel setHidden:NO];
        self.nbMsgLabel.text = [NSString stringWithFormat:@"%d", msgCount];
    }
    
    [self.backMenuViewController setNbMsgUnread:[NSString stringWithFormat:@"%d", msgCount]];
}

#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return listMessagesMaster.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([listMessagesMaster[indexPath.row] isKindOfClass:[Message class]]) {
        return 65;
    } else {
        return 50;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return headerView;
}
//Method that allows you to customize the cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell_master" forIndexPath:indexPath];
    
    Message *message = listMessagesMaster[indexPath.row];
    NSArray *emails = [[message emails] allObjects];
    
    UIView *bgColorView = [[UIView alloc] init];
    [bgColorView setBackgroundColor:[UIColor colorWithRed:0.7294 green:0.7843 blue:0.8039 alpha:1]];
    [cell setSelectedBackgroundView:bgColorView];
    
    UILabel *labelMail = (UILabel *)[cell viewWithTag:15];
    UILabel *labelObjet = (UILabel *)[cell viewWithTag:2];
    UILabel *labelHeure = (UILabel *)[cell viewWithTag:4];
    UIButton *checkButton = (UIButton*)[cell viewWithTag:22];
    UIImageView *favoriteImage = (UIImageView*)[cell viewWithTag:42];
    UIImageView *importantImage = (UIImageView*)[cell viewWithTag:80];
    UIImageView *attachmentImage = (UIImageView*)[cell viewWithTag:76];
    
    [checkButton addTarget:self action:@selector(saveSwitch:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([message.isFavor boolValue]){
        [saveFavoriteState setValue:[NSNumber numberWithBool:TRUE] forKey:[NSString stringWithFormat:@"%d", indexPath.row]];
        [favoriteMessages addObject:message];
        [favoriteImage setImage:[UIImage imageNamed:@"etoile2_select"]];
    }
    else {
        [saveFavoriteState setValue:[NSNumber numberWithBool:FALSE] forKey:[NSString stringWithFormat:@"%d", indexPath.row]];
        [favoriteImage setImage:[UIImage imageNamed:@"etoile_noselect"]];
    }
    
    //if ([[saveSwitchState objectForKey:[NSString stringWithFormat:@"%d", indexPath.row]] boolValue]){
    if([checkedMessages containsObject:message.messageId]){
        [checkButton setBackgroundImage:[UIImage imageNamed:@"check_box2"] forState:UIControlStateNormal];
    }
    else {
        [checkButton setBackgroundImage:[UIImage imageNamed:@"check_box1"] forState:UIControlStateNormal];
    }
    
    labelMail.text = @"";
    for (Email* email in emails) {
        if (masterFolderId.intValue == ENVOYES_ID_FOLDER || masterFolderId.intValue == BOITE_D_ENVOI_ID_FOLDER || masterFolderId.intValue == BROUILLON_ID_FOLDER){
            if ([email.type isEqualToString:E_TO]){
                labelMail.text = [email address];
            }
        }
        else if ([E_FROM isEqualToString:email.type]){
            labelMail.text = [email address];
        }
    }
    
    if ((masterFolderId.intValue == ENVOYES_ID_FOLDER || masterFolderId.intValue == BOITE_D_ENVOI_ID_FOLDER || masterFolderId.intValue == BROUILLON_ID_FOLDER) && [@""isEqualToString:labelMail.text ]) {
        labelMail.text = NSLocalizedString(@"AUCUN_DESTINATAIRE", @"Aucun destinataire");
    }
    
    labelMail.font=[UIFont boldSystemFontOfSize:20];
    
    [importantImage setHidden:YES];
    [attachmentImage setHidden:YES];
    
    if ([message.isRead boolValue]){
        labelMail.font=[UIFont systemFontOfSize:18];
        labelMail.textColor = [UIColor colorWithRed:0.1294117647 green:0.36862745098 blue:0.44705882352 alpha:1];
    } else {
        labelMail.textColor = [UIColor darkGrayColor];
    }
    
    if ([message.isUrgent boolValue]){
        [importantImage setHidden:NO];
    }
    
    if ([message.isAttachment boolValue]){
        [attachmentImage setHidden:NO];
    }
    NSString* tmpBody = [message shortBody];
    
    if (tmpBody.length == 0) {
        tmpBody = [message body];
    }
    [labelObjet setAttributedText:[self stringToLabelOjectWithSubject:[message subject] andBody:tmpBody forLabel:labelObjet isRead:[message.isRead boolValue]]];
    labelHeure.text = [self dateToDisplay:message.date];
    
    //    DLog(@"MessageId %d",message.messageId.intValue);
    
    return cell;
}

-(NSAttributedString*)stringToLabelOjectWithSubject:(NSString*)subject andBody:(NSString*)body forLabel:(UILabel*)label isRead:(BOOL)isRead{
    body = [self deleteNewLineCharacter:body];
    subject = [self deleteNewLineCharacter:subject];
    float stringWidth=0;
    if(IS_IOS_7_OR_EARLIER){
        stringWidth = [subject sizeWithFont:label.font].width;
    }else {
        stringWidth =  [subject sizeWithAttributes:@{NSFontAttributeName: label.font}].width;
    }
    
    
    if (label.frame.size.width > 15 && stringWidth > label.frame.size.width){
        subject = [self getString:subject WithSize:stringWidth withLabel:label];
    }
    NSString *objet = @"";
    if ([body isEqual:@""]){
        if (stringWidth > label.frame.size.width){
            objet = [[NSString alloc] initWithFormat:@"%@...", subject];
        } else {
            objet = [[NSString alloc] initWithFormat:@"%@", subject];
        }
    }
    else {
        if (stringWidth > label.frame.size.width){
            objet = [[NSString alloc] initWithFormat:@"%@...\r%@", subject, body];
        } else {
            objet = [[NSString alloc] initWithFormat:@"%@ - %@", subject, body];
        }
    }
    UIFont *subjectfont=[UIFont fontWithName:@"Helvetica" size:15];
    UIFont *bodyfont=[UIFont fontWithName:@"Helvetica" size:14];
    
    if (!isRead) {
        subjectfont = [UIFont boldSystemFontOfSize:15];
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:objet attributes:
                                          [NSDictionary dictionaryWithObjectsAndKeys:paragraphStyle, NSParagraphStyleAttributeName,nil]];
    if (isRead) {
        [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.1294117647 green:0.36862745098 blue:0.43921568627 alpha:1] range:NSMakeRange(0,[subject length])];
    } else {
        [string addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0,[subject length])];
    }
    
    [string addAttribute:NSFontAttributeName value:subjectfont range:NSMakeRange(0,[subject length])];
    NSUInteger len = (NSUInteger) ([objet length] - [subject length]);
    
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange([subject length],len)];
    
    [string addAttribute:NSFontAttributeName value:bodyfont range:NSMakeRange([subject length],len)];
    
    return string;
}

-(NSString*)getString:(NSString*)string WithSize:(float)stringWidth withLabel:(UILabel*)label{
    
    while (stringWidth > label.frame.size.width - 15){
        string = [string substringToIndex:[string length] - 1];
        if(IS_IOS_7_OR_EARLIER){
            stringWidth = [string sizeWithFont:label.font].width;
        }else {
            stringWidth =  [string sizeWithAttributes:@{NSFontAttributeName: label.font}].width;
        }
        
    }
    return string;
}

-(NSString*)deleteNewLineCharacter:(NSString*)string{
    NSArray *split = [string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    split = [split filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
    return [split componentsJoinedByString:@" "];
}

-(NSString*)dateToDisplay:(NSDate*)_date{
    
    NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:_date];
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    NSString *strDate = nil;
    
    if([today day] == [otherDay day] && [today month] == [otherDay month] && [today year] == [otherDay year] && [today era] == [otherDay era]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm"];
        strDate = [dateFormatter stringFromDate:_date];
    }
    else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
        strDate = [dateFormatter stringFromDate:_date];
    }
    
    return strDate;
}

-(void)saveSwitch:(id)sender{
    UIButton *button = (UIButton *)sender;
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    Message *messageChecked = listMessagesMaster[indexPath.row];
    
    //if ([[saveSwitchState objectForKey:[NSString stringWithFormat:@"%d", indexPath.row]] boolValue]){
    if([checkedMessages containsObject:messageChecked.messageId]){
        [button setBackgroundImage:[UIImage imageNamed:@"check_box1"] forState:UIControlStateNormal];
        [saveSwitchState setValue:@NO forKey:[NSString stringWithFormat:@"%d", indexPath.row]];
        [checkedMessages removeObject:messageChecked.messageId];
    }
    else {
        [button setBackgroundImage:[UIImage imageNamed:@"check_box2"] forState:UIControlStateNormal];
        [saveSwitchState setValue:@YES forKey:[NSString stringWithFormat:@"%d", indexPath.row]];
        [checkedMessages addObject:messageChecked.messageId];
        
    }
    //Hide or show Menu Bar
    [headerMenu setHidden:YES];
    for (NSNumber* key in checkedMessages) {
        if (masterFolderId == [NSNumber numberWithInt:CORBEILLE_ID_FOLDER]){
            [(HeaderMenuCorbeilleView*)headerMenu justVider:NO];
        }
        [headerMenu setHidden:NO];
    }
    
    DLog(@"saveSwitch click : %@", saveSwitchState);
    DLog(@"CheckedMessage click : %@", checkedMessages);
    //[self selectedMessages];
    
}

-(void)hideOrShowMenuBar:(id)sender{
    [headerMenu setHidden:[headerMenu isHidden] ? NO : YES];
    [(HeaderMenuCorbeilleView*)headerMenu justVider:![headerMenu isHidden]];
    
    //    for (NSString* key in saveSwitchState) {
    //        NSNumber *value = [saveSwitchState objectForKey:key];
    //        if ([value boolValue]){
    //            [(HeaderMenuCorbeilleView*)headerMenu justVider:NO];
    //            [headerMenu setHidden:NO];
    //        }
    //    }
    for (NSString* key in checkedMessages) {
        [(HeaderMenuCorbeilleView*)headerMenu justVider:NO];
        [headerMenu setHidden:NO];
    }
}

-(void)saveFavorite:(id)sender{
    UIButton *button = (UIButton *)sender;
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    Message *message = listMessagesMaster[indexPath.row];
    if ([favoriteMessages containsObject:message]){
        [button setImage:[UIImage imageNamed:@"etoile_noselect"] forState:UIControlStateNormal];
        [saveFavoriteState setValue:@NO forKey:[NSString stringWithFormat:@"%d", indexPath.row]];
        [favoriteMessages removeObject:message];
    }
    else {
        [button setImage:[UIImage imageNamed:@"etoile2_select"] forState:UIControlStateNormal];
        [saveFavoriteState setValue:@YES forKey:[NSString stringWithFormat:@"%d", indexPath.row]];
        [favoriteMessages addObject:message];
    }
    
    [message setIsFavor:[saveFavoriteState objectForKey:[NSString stringWithFormat:@"%d", indexPath.row]]];
    
    NSMutableArray *arrayIdMessage = [[NSMutableArray alloc] initWithObjects:message.messageId, nil];
    
    UpdateMessagesInput* updateInput = [[UpdateMessagesInput alloc] init];
    [updateInput setMessageIds:arrayIdMessage];
    if ([message.isFavor boolValue]){
        [updateInput setOperation:O_FLAGGED];
    }
    else {
        [updateInput setOperation:O_UNFLAGGED];
    }
    [self runRequestService:S_ITEM_UPDATE_MESSAGES withParams:[updateInput generate] header:nil andMethod:HTTP_POST];
    
    [self saveDB];
}

//Method called when cell is clicked
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableSearchBar resignFirstResponder];
    [tableSearchBar endEditing:YES];
    [self.view endEditing:YES];
    if ([listMessagesMaster[indexPath.row] isKindOfClass:[Message class]]) {
        
        NPMessage *message = [NPConverter convertMessage:listMessagesMaster[indexPath.row]];
        Message *messagePersistant = listMessagesMaster[indexPath.row];
        
        
        if (masterFolderId.intValue == BROUILLON_ID_FOLDER) {
            
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            
            [params setObject:message forKey:MESSAGE];
            
            [params setObject:message.messageId forKey:MESSAGE_ID];
            //TODO REFACTO
            //            if (message.emails.count > 0) {
            //                NSMutableArray *toEmails = [NSMutableArray array];
            //                NSMutableArray *ccEmails = [NSMutableArray array];
            //                NSMutableArray *ciEmails = [NSMutableArray array];
            //                for (Email* email in message.emails) {
            //                    if ([E_TO isEqualToString:email.type]) {
            //                        [toEmails addObject:email];
            //                    } else if ([E_CC isEqualToString:email.type]) {
            //                        [ccEmails addObject:email];
            //                    } else if ([E_BCC isEqualToString:email.type]) {
            //                        [ciEmails addObject:email];
            //                    }
            //                }
            //                [params setObject:toEmails forKey:@"toEmails"];
            //                [params setObject:ccEmails forKey:@"ccEmails"];
            //                [params setObject:ciEmails forKey:@"ciEmails"];
            //}
            
            //            if (message.attachments.count > 0) {
            //                [params setObject:message.attachments forKey:ATTACHMENTS];
            //            }
            //
            if (message.subject.length > 0) {
                [params setObject:message.subject forKey:SUBJECT];
            }
            
            if (message.body.length > 0) {
                [params setObject:message.body forKey:BODY];
            }
            
            [params setObject:[NSNumber numberWithBool:YES] forKey:Q_DRAFT];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_NEW_MSG_VIEW_NOTIF object:params];
            [self resetSwitches];
            return;
        } else {
            
            if (![message.isRead boolValue]){
                [message setIsRead:[NSNumber numberWithBool:YES]];
                [messagePersistant setIsRead:[NSNumber numberWithBool:YES]];
                [self.tableView reloadData];
                DLog(@"messageId : %@", message.messageId);
                NSMutableArray *arrayIdMessage = [[NSMutableArray alloc] initWithObjects:message.messageId, nil];
                
                DLog(@"arrayIdMessage : %@", [arrayIdMessage description]);
                
                UpdateMessagesInput* updateInput = [[UpdateMessagesInput alloc] init];
                [updateInput setEmail:[AccesToUserDefaults getUserInfoChoiceMail]];
                [updateInput setMessageIds:arrayIdMessage];
                [updateInput setOperation:O_READ];
                [self runRequestService:S_ITEM_UPDATE_MESSAGES withParams:[updateInput generate] header:nil andMethod:HTTP_POST];
                
                [self saveDB];
                
                [self updateUnreadMsgCount];
            }
            
            currentIndex = indexPath;
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            // [[CurrentMessage sharedInstance] setMessage:message];
            //Method called when cell is clicked on iPad
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                //On load le bon message dans la vue de droite sur iPad
                [self.detailViewController setDetailItem:message.messageId];
                selectMessage=message.messageId;
                [self.detailViewController reloadData];
                
                
                
            }
        }
        
    }
    
}

-(void)saveDB{
    NSLog(@"saveDB in MasterViewController");
    NSError *error;
    if (![[DAOFactory factory] save:&error]) {
        DLog(@"error save %@", [error userInfo]);
    }
}

- (IBAction)loadMoreMessages {
    DLog(@"loadMoreMessages");
    [activityIndicator startAnimating];
    [loadMoreMessagesButton setEnabled:NO];
    [self searchMoreMessages];
}

- (void)searchMoreMessages {
    DLog(@"searchMoreMessages");
    DLog(@"masterFolderId %@",masterFolderId);
    //    FullTextSearchMessagesInput* searchInput = [[FullTextSearchMessagesInput alloc] init];
    id searchInput ;
    NSString *searchService;
    if (searchMethod == SEARCH_MORE_MESSAGES || tableSearchBar.text.length > 0) {
        searchInput = [[FullTextSearchMessagesInput alloc] init];
        [searchInput setSearchString:tableSearchBar.text];
        searchService = S_ITEM_FULL_TEXT_SEARCH_MESSAGES;
    } else {
        searchInput = [[SearchMessagesInput alloc] init];
        searchService = S_ITEM_SEARCH_MESSAGES;
        isLoadMoreMessages = YES;
    }
    [searchInput setFolderId:masterFolderId];
    
    //    [searchInput setOffset:[NSNumber numberWithInt:offset]];
    if ([listMessagesMaster count] > 0) {
        Message *last = [listMessagesMaster lastObject];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
        NSString *stringFromDate = [formatter stringFromDate:last.date];
        DLog(@"stringFromDate %@",stringFromDate);
        
        [searchInput setBefore:stringFromDate];
    }
    [searchInput setLimit:[NSNumber numberWithInt:SEARCH_MESSAGES_LIMIT]];
    [self runRequestService:searchService withParams:[searchInput generate] header:nil andMethod:HTTP_POST];
}

- (IBAction)openMenu:(id)sender{
    [tableSearchBar resignFirstResponder];
    [[NSNotificationCenter defaultCenter] postNotificationName:SLIDE_BACK_MENU_NOTIF object:nil];
}

-(void)createNewMessageButton{
    //Creation to custom button for create message (at right of masterView)
    UIImage *buttonImageLeft = [UIImage imageNamed:@"bouton_ecriremsg"];
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aButton setImage:buttonImageLeft forState:UIControlStateNormal];
    aButton.frame = CGRectMake(0.0,0.0,buttonImageLeft.size.width,buttonImageLeft.size.height);
    [aButton addTarget:self action:@selector(ecrireMsg:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *shiftButton = [[UIBarButtonItem alloc] initWithCustomView:aButton];
    self.navigationItem.rightBarButtonItem = shiftButton;
}

-(void)createMenuButton{
    //Creation to custom button for create message (at right of masterView)
    UIImage *buttonImageRight = [UIImage imageNamed:@"bouton_menu"];
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aButton setImage:buttonImageRight forState:UIControlStateNormal];
    aButton.frame = CGRectMake(0.0,0.0,buttonImageRight.size.width,buttonImageRight.size.height);
    [aButton addTarget:self action:@selector(openMenu:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *shiftButton = [[UIBarButtonItem alloc] initWithCustomView:aButton];
    self.navigationItem.leftBarButtonItem = shiftButton;
}

-(void)createMenuCorbeilleButton{
    //Creation to custom button for create message (at right of masterView)
    UIImage *buttonImage = [UIImage imageNamed:@"bouton_palette_basBleu"];
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aButton setImage:buttonImage forState:UIControlStateNormal];
    aButton.frame = CGRectMake(0.0,0.0,50,50);
    [aButton addTarget:self action:@selector(hideOrShowMenuBar:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:aButton];
    self.navigationItem.rightBarButtonItem = backButton;
    DLog(@"self.navigationItem.right : %@", self.navigationItem.rightBarButtonItem);
}

-(void)createBackButton{
    [self.navigationItem setHidesBackButton:YES];
    UIImage *buttonImageRight = [UIImage imageNamed:@"bouton_retour"];
    UIButton *bButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [bButton setImage:buttonImageRight forState:UIControlStateNormal];
    bButton.frame = CGRectMake(0,0,50,35);
    [bButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *shiftButton = [[UIBarButtonItem alloc] initWithCustomView:bButton];
    self.navigationItem.leftBarButtonItem = shiftButton;
}

//Inutilisé
-(void)selectFirstRow{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if ([listMessagesMaster count] > 0){
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionBottom];
            [[self.tableView delegate] tableView:self.tableView didSelectRowAtIndexPath:indexPath];
        }
    }
}

-(void)selectMessageById:(NSNumber*)messageId {
    [self.tableView reloadData];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if ([listMessagesMaster count] > 0){
            int row = 0;
            for (Message *message in listMessagesMaster) {
                if ([message.messageId isEqualToNumber:messageId]) {
                    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:row inSection:0];
                    [self.tableView selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionNone];
                    [[self.tableView delegate] tableView:self.tableView didSelectRowAtIndexPath:indexPath];
                    break;
                }
                row++;
            }
            
        }
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    if (searchNeverClicked && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ) {
        [self searchBarSearchButtonClicked:tableSearchBar];
        searchNeverClicked = NO;
    }
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self searchMessages:searchBar.text];
}

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if ([@" " isEqualToString:searchBar.text]) {
        searchBar.text = @"";
    }
    
    return YES;
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    if ([@" " isEqualToString:searchBar.text]) {
        searchBar.text = @"";
    }
    
    
    [self resetLoadMoreMessagesButton:searchBar];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    //    DLog(@"tableSearchBar %@",tableSearchBar);
    //    [tableSearchBar setText:@"sdsdsdsdsdsd "];
    //    DLog(@"tableSearchBar isFirstResponder %d",[tableSearchBar isFirstResponder]);
    //    [tableSearchBar becomeFirstResponder];
    if (searchNeverClicked && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self searchBarSearchButtonClicked:tableSearchBar];
        searchNeverClicked = NO;
    }
    
    
    [tableSearchBar resignFirstResponder];
    
    //    [self.searchDisplayController.searchBar resignFirstResponder];
    //    [self.view endEditing:YES];
    //    DLog(@"tableSearchBar isFirstResponder %d",[tableSearchBar isFirstResponder]);
    //    [self.view endEditing:YES];
    //    [tableSearchBar endEditing:YES];
    //    [self.tableView endEditing:YES];
    //    [tableSearchBar setText:@""];
    
    //    for (UIView *subView in tableSearchBar.subviews) {
    //        if ([subView respondsToSelector:@selector(resignFirstResponder)]) {
    //            [subView resignFirstResponder];
    //            [subView endEditing:YES];
    //        }
    //    }
}

-(BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

-(void)resetLoadMoreMessagesButton:(UISearchBar*)searchBar {
    if (searchBar) {
        if (searchBar.text.length > 0) {
            searchMethod = SEARCH_MORE_MESSAGES;
        } else {
            searchMethod = LOAD_MORE_MESSAGES;
        }
    }
    
    DLog(@"resetLoadMoreMessagesButton : masterFolderId.intValue %d",masterFolderId.intValue );
    
    //    DLog(@"searchMethod %lu",(unsigned long)searchMethod);
    if (listMessagesMaster.count > 0 && masterFolderId.intValue != NON_LUS_ID_FOLDER && masterFolderId.intValue != SUIVIS_ID_FOLDER && masterFolderId.intValue != BOITE_D_ENVOI_ID_FOLDER)  {
        if (searchMethod == SEARCH_MORE_MESSAGES) {
            [loadMoreMessagesButton setTitle:NSLocalizedString(@"RECHERCHER_LES_MESSAGES_SUIVANTS",@"Rechercher les messages suivants") forState:UIControlStateNormal];
        } else if(searchMethod == LOAD_MORE_MESSAGES){
            [loadMoreMessagesButton setTitle:NSLocalizedString(@"CHARGER_LES_MESSAGES_SUIVANTS",@"Charger les messages suivants") forState:UIControlStateNormal];
        }
        self.tableView.tableFooterView = footerView;
    } else {
        self.tableView.tableFooterView = nil;
    }
    //
    //
    //    if (searchMethod == SEARCH_MORE_MESSAGES) {
    //        [loadMoreMessagesButton setTitle:NSLocalizedString(@"RECHERCHER_LES_MESSAGES_SUIVANTS",@"Rechercher les messages suivants") forState:UIControlStateNormal];
    //    } else if(searchMethod == LOAD_MORE_MESSAGES){
    //        [loadMoreMessagesButton setTitle:NSLocalizedString(@"CHARGER_LES_MESSAGES_SUIVANTS",@"Charger les messages suivants") forState:UIControlStateNormal];
    //    }
    //    self.tableView.tableFooterView = footerView;
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [self resetLoadMoreMessagesButton:searchBar];
    //    [searchBar resignFirstResponder];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self searchMessages:searchText];
}

- (NSMutableArray*)sortArrayByDate:(NSMutableArray*)array {
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSArray *sortedArray = [NSArray arrayWithObject: descriptor];
    [array sortUsingDescriptors:sortedArray];
    return  array;
}

-(void)searchMessages:(NSString*)query {
    //    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(searchRequest:) object:nil];
    //    [self performSelector:@selector(searchRequest:) withObject:query afterDelay:1];
    
    //    [NSObject cancelPreviousPerformRequestsWithTarget:self
    //                                             selector:@selector(doDelayedSearch:)
    //                                               object:searchDelayer];
    //    priorSearchText = query;
    //    if (YES /* ...or whatever validity test you want to apply */)
    //        [self performSelector:@selector(doDelayedSearch:)
    //                   withObject:query
    //                   afterDelay:1.5];
    
    //    [searchDelayer invalidate], searchDelayer=nil;
    //    if (YES /* ...or whatever validity test you want to apply */)
    //        searchDelayer = [NSTimer scheduledTimerWithTimeInterval:1
    //                                                         target:self
    //                                                       selector:@selector(doDelayedSearch:)
    //                                                       userInfo:query
    //                                                        repeats:NO];
    
    [self searchRequest:query];
}

-(void)doDelayedSearch:(NSTimer *)t
{
    assert(t == searchDelayer);
    [self searchRequest:searchDelayer.userInfo];
    //    searchDelayer = nil; // important because the timer is about to release and dealloc itself
}

-(void)searchRequest:(NSString*)query {
    
    if(![query isEqualToString:@""]){
        searchBarMayResign = NO;
        
        //    DLog(@"masterFolder.folderId %@",masterFolderId);
        MessageDAO *messageDAO = (MessageDAO*)[[DAOFactory factory] newDAO:MessageDAO.class];
        
        DLog(@"query %@", query);
        listMessagesMaster = [self sortArrayByDate:[messageDAO searchMessages:query folderId:masterFolderId]];
        
        if ([listMessagesMaster count] % SEARCH_MESSAGES_LIMIT == 0 && masterFolderId.intValue != NON_LUS_ID_FOLDER && masterFolderId.intValue != SUIVIS_ID_FOLDER && masterFolderId.intValue != BOITE_D_ENVOI_ID_FOLDER && ![tableSearchBar.text isEqualToString:@""]) {
            searchMethod = SEARCH_MORE_MESSAGES;
            [loadMoreMessagesButton setTitle:NSLocalizedString(@"RECHERCHER_LES_MESSAGES_SUIVANTS",@"Rechercher les messages suivants") forState:UIControlStateNormal];
            self.tableView.tableFooterView = footerView;
        }
        
        [self.tableView reloadData];
        DLog(@"query %@",query);
        
        searchBarMayResign = YES;
        //@TD
        //recharge la liste de messages lors de la fin de la recherche.
    }else {
        MessageDAO *messageDAO = (MessageDAO*)[[DAOFactory factory] newDAO:MessageDAO.class];
        
        DLog(@"query %@", query);
        listMessagesMaster = [self sortArrayByDate:[messageDAO findMessagesByFolderId:masterFolderId]];

        [self reloadTableViewDataSource];
        [self.tableView reloadData];
    }
}


//Method called when cell is clicked on iPhone
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([[segue identifier] isEqualToString:@"segueToDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Message *message = listMessagesMaster[indexPath.row];
        [[CurrentMessage sharedInstance] setMessage:message];
        [[segue destinationViewController] setDetailItem:message.messageId];
        [[segue destinationViewController] setMasterViewController:self];
        [[segue destinationViewController] setDelegate:self];
        
    }
    
    
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if (BROUILLON_ID_FOLDER == masterFolderId.intValue) {
        return NO;
    }
    
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar;
{
    return searchBarMayResign;
}
-(void) deleteMsg:(NSNumber *)msgId IfFlag:(NSString *)flag{
    ModificationDAO *modifDAO = (ModificationDAO*)[[DAOFactory factory] newDAO:ModificationDAO.class];
    DLog(@"messageId %@",msgId);
    NSMutableArray *listModification = [modifDAO findModificationByMessageId:msgId];
    DLog(@"listModification %d",listModification.count);
    if (listModification.count > 0){
        for (Modification *modif in listModification){
            if ([flag isEqualToString:modif.operation]){
                [modifDAO deleteObject:modif];
                [self saveDB];
            }
        }
    }
}
-(void)deleteMsg:(id)sender {
    if (masterFolderId.intValue == BOITE_D_ENVOI_ID_FOLDER || masterFolderId.intValue == BROUILLON_ID_FOLDER) {
        [self definitivDeletMsg:sender];
    } else {
        NSMutableArray* arrayMessagesSelected = [[NSMutableArray alloc] init];
        NSMutableArray *arrayIdsMessage = [[NSMutableArray alloc] init];
        for(NSNumber *messageId in checkedMessages) {
            Message *message =[self getMessagebyIdInListMaster:messageId];
            [arrayMessagesSelected addObject:message];
            if (message.folderId.intValue == BOITE_D_ENVOI_ID_FOLDER){
                [self deleteMsg:message.messageId IfFlag:SEND];
            } else if (message.folderId.intValue == BROUILLON_ID_FOLDER){
                [self deleteMsg:message.messageId IfFlag:DRAFT];
            }
            message.folderId = [NSNumber numberWithInt:CORBEILLE_ID_FOLDER];
        }
        [listMessagesMaster removeObjectsInArray:arrayMessagesSelected];
        for (Message* message in arrayMessagesSelected){
            [arrayIdsMessage addObject:message.messageId];
            //@TD Set la view messageDetailsview a blanc, le message étant supprimer
            [self.detailViewController setBlankView:message.messageId];
        }
        
        [self.tableView reloadData];
        
        if ([arrayMessagesSelected count] >0){
            UpdateMessagesInput* updateInput = [[UpdateMessagesInput alloc] init];
            [updateInput setMessageIds:arrayIdsMessage];
            [updateInput setOperation:O_TRASH];
            [self runRequestService:S_ITEM_UPDATE_MESSAGES withParams:[updateInput generate] header:nil andMethod:HTTP_POST];
        }
        [self updateUnreadMsgCount];
        [self saveDB];
        [self resetSwitches];
        
        if(isIpad){
            if([checkedMessages containsObject:selectMessage]){
                selectMessage=nil;
            }else {
                if(selectMessage){
                    [self selectMessageById:selectMessage];
                }
            }
        }
    }
    
    
}
#pragma mark New Gestion messages
-(Message*)getMessagebyIdInListMaster:(NSNumber*)messageId{
    Message *returnMessage=nil;
    for(Message *message in listMessagesMaster){
        if([message.messageId isEqualToNumber:messageId]){
            return message;
        }
    }
    return returnMessage;
}
-(BOOL)isContainMessage:(NSNumber*)messageId inArray:(NSMutableArray*)array{
    BOOL isContain=NO;
    for(Message *message in array){
        if([message.messageId isEqualToNumber:messageId]){
            isContain=YES;
        }
    }
    return isContain;
}


-(void)insertToFolder:(id)sender {
    
    NSMutableArray* arrayMessagesSelected = [[NSMutableArray alloc] init];
    for(NSNumber *messageId in checkedMessages) {
        Message *message =[self getMessagebyIdInListMaster:messageId];
        [arrayMessagesSelected addObject:message];
    }
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:arrayMessagesSelected forKey:SELECTED_MESSAGE];
    
    if ((masterFolderId.intValue == NON_LUS_ID_FOLDER || masterFolderId.intValue == SUIVIS_ID_FOLDER) && checkedMessages.count == 1) {
        Message *selectedMessage = [arrayMessagesSelected objectAtIndex:0];
        [dict setObject:selectedMessage.folderId forKey:CURRENT_FOLDER_ID];
    } else {
        [dict setObject:masterFolderId forKey:CURRENT_FOLDER_ID];
    }
    
    [dict setObject:masterFolderId forKey:MASTER_FOLDER_ID];
    [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_MOVE_MSG_VIEW_NOTIF object:dict];
    
    [listMessagesMaster removeObjectsInArray:arrayMessagesSelected];
    [self.tableView reloadData];
    
    [self resetSwitches];
    if(isIpad){
        if([checkedMessages containsObject:selectMessage]){
            selectMessage=nil;
        }else {
            if(selectMessage){
                [self selectMessageById:selectMessage];
            }
            
        }
    }
}

-(void)resetSwitches {
    saveSwitchState =[NSMutableDictionary dictionary];
    [headerMenu setHidden:YES];
    [tableSearchBar setHidden:NO];
    //NSArray *cells = [self.tableView visibleCells];
    //    if (cells.count > 0) {
    //        for (UITableViewCell *cell in cells) {
    //            UIButton *checkButton = (UIButton*)[cell viewWithTag:22];
    //            [checkButton setBackgroundImage:[UIImage imageNamed:@"check_box1"] forState:UIControlStateNormal];
    //            [checkButton setSelected:NO];
    //        }
    //    }
    [checkedMessages removeAllObjects];
}

-(void)followMsg:(id)sender {
    NSMutableArray* arrayMessagesSelected = [[NSMutableArray alloc] init];
    NSMutableArray *arrayIdsMessageFlag = [[NSMutableArray alloc] init];
    NSMutableArray *arrayIdsMessageUnFlag = [[NSMutableArray alloc] init];
    for(NSNumber *messageId in checkedMessages) {
        Message *message = [self getMessagebyIdInListMaster:messageId];
        [arrayMessagesSelected addObject:message];
        if ([message.isFavor boolValue]){
            [message setIsFavor:[NSNumber numberWithBool:NO]];
            [favoriteMessages addObject:message];
        }
        else {
            [message setIsFavor:[NSNumber numberWithBool:YES]];
            [favoriteMessages removeObject:message];
        }
    }
    if ([masterFolderId isEqualToNumber:[NSNumber numberWithInt:SUIVIS_ID_FOLDER]]){
        [listMessagesMaster removeObjectsInArray:arrayMessagesSelected];
        for (Message* message in arrayMessagesSelected) {
            //@TD Set la view messageDetailsview a blanc, le message état supprimer
            [self.detailViewController setBlankView:message.messageId];
        }
    }
    
    for (Message* message in arrayMessagesSelected) {
        if ([message.isFavor boolValue]){
            [arrayIdsMessageFlag addObject:message.messageId];
            
        }
        else {
            [arrayIdsMessageUnFlag addObject:message.messageId];
        }
    }
    
    [self.tableView reloadData];
    
    if ([arrayIdsMessageUnFlag count] >0){
        UpdateMessagesInput* updateInput = [[UpdateMessagesInput alloc] init];
        [updateInput setMessageIds:arrayIdsMessageUnFlag];
        [updateInput setOperation:O_UNFLAGGED];
        
        [self runRequestService:S_ITEM_UPDATE_MESSAGES withParams:[updateInput generate] header:nil andMethod:HTTP_POST];
        
    }
    if ([arrayIdsMessageFlag count] >0){
        UpdateMessagesInput* updateInput = [[UpdateMessagesInput alloc] init];
        [updateInput setMessageIds:arrayIdsMessageFlag];
        [updateInput setOperation:O_FLAGGED];
        [self runRequestService:S_ITEM_UPDATE_MESSAGES withParams:[updateInput generate] header:nil andMethod:HTTP_POST];
    }
    
    [self saveDB];
    [self resetSwitches];
    if(isIpad){
        if (![masterFolderId isEqualToNumber:[NSNumber numberWithInt:SUIVIS_ID_FOLDER]]){
            if(selectMessage){
                [self selectMessageById:selectMessage];
            }
        }else {
            if([checkedMessages containsObject:selectMessage]){
                selectMessage=nil;
            }else {
                if(selectMessage){
                    [self selectMessageById:selectMessage];
                }
            }
        }
    }
}

-(void)unreadMsg:(id)sender{
    NSMutableArray *arrayIdsMessageRead = [[NSMutableArray alloc] init];
    NSMutableArray *arrayIdsMessageUnRead = [[NSMutableArray alloc] init];
    NSMutableArray *arrayMessagesSelected = [[NSMutableArray alloc] init];
    for(NSNumber *messageId in checkedMessages) {
        Message *message = [self getMessagebyIdInListMaster:messageId];
        [arrayMessagesSelected addObject:message];
        if ([message.isRead boolValue]){
            [arrayIdsMessageRead addObject:message.messageId];
            [message setIsRead:[NSNumber numberWithBool:NO]];
        }
        else {
            [arrayIdsMessageUnRead addObject:message.messageId];
            [message setIsRead:[NSNumber numberWithBool:YES]];
        }
    }
    if ([masterFolderId isEqualToNumber:[NSNumber numberWithInt:NON_LUS_ID_FOLDER]]){
        [listMessagesMaster removeObjectsInArray:arrayMessagesSelected];
    }
    for (Message* message in arrayMessagesSelected) {
        //@TD Set la view // a blanc, le message état supprimer
        [self.detailViewController setBlankView:message.messageId];
    }
    
    [self.tableView reloadData];
    
    if ([arrayIdsMessageUnRead count] >0){
        UpdateMessagesInput* updateInput = [[UpdateMessagesInput alloc] init];
        [updateInput setMessageIds:arrayIdsMessageUnRead];
        [updateInput setOperation:O_READ];
        
        [self runRequestService:S_ITEM_UPDATE_MESSAGES withParams:[updateInput generate] header:nil andMethod:HTTP_POST];
        
    }
    if ([arrayIdsMessageRead count] >0){
        UpdateMessagesInput* updateInput = [[UpdateMessagesInput alloc] init];
        [updateInput setMessageIds:arrayIdsMessageRead];
        [updateInput setOperation:O_UNREAD];
        [self runRequestService:S_ITEM_UPDATE_MESSAGES withParams:[updateInput generate] header:nil andMethod:HTTP_POST];
    }
    if(isIpad){
        if (![masterFolderId isEqualToNumber:[NSNumber numberWithInt:NON_LUS_ID_FOLDER]]){
            if([checkedMessages containsObject:selectMessage]){
                selectMessage=nil;
            }else {
                if(selectMessage){
                    [self selectMessageById:selectMessage];
                }
            }
        }
    }
    [self saveDB];
    [self updateUnreadMsgCount];
    [self resetSwitches];
}

-(void)definitivDeletMsg:(id)sender{
    MessageDAO *messageDAO = (MessageDAO*)[[DAOFactory factory] newDAO:MessageDAO.class];
    NSMutableArray *arrayIdsMessage = [[NSMutableArray alloc] init];
    NSMutableArray *arrayMessage = [[NSMutableArray alloc] init];
    
    for(NSNumber *messageId in checkedMessages) {
        Message *message = [self getMessagebyIdInListMaster:messageId];
        [arrayIdsMessage addObject:message.messageId];
        [arrayMessage addObject:message];
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
        [messageDAO deleteObject:message];
    }
    [listMessagesMaster removeObjectsInArray:arrayMessage];
    
    for (NSNumber* msgId in arrayIdsMessage) {
        //@TD Set la view messageDetailsview a blanc, le message étant supprimer
        [self.detailViewController setBlankView:msgId];
    }
    
    [self.tableView reloadData];
    
    if ([arrayIdsMessage count] >0 && ![masterFolderId isEqualToNumber:[NSNumber numberWithInt:BOITE_D_ENVOI_ID_FOLDER]]){
        UpdateMessagesInput* updateInput = [[UpdateMessagesInput alloc] init];
        [updateInput setMessageIds:arrayIdsMessage];
        [updateInput setOperation:O_DELETE];
        [self runRequestService:S_ITEM_UPDATE_MESSAGES withParams:[updateInput generate] header:nil andMethod:HTTP_POST];
    }
    
    [self saveDB];
    [self resetSwitches];
    if(isIpad){
        if([checkedMessages containsObject:selectMessage]){
            selectMessage=nil;
        }else {
            if (selectMessage){
                [self selectMessageById:selectMessage];
            }
        }
    }
    
}

-(void)viderCorbeille:(id)sender{
    
    NSMutableArray *trashMessageIds = [NSMutableArray array];
    MessageDAO *messageDAO = (MessageDAO*)[[DAOFactory factory] newDAO:MessageDAO.class];
    for (Message *message in listMessagesMaster){
        [trashMessageIds addObject:message.messageId];
        [messageDAO deleteObject:message];
        //@TD Set la view messageDetailsview a blanc, le message étant supprimer
        [self.detailViewController setBlankView:message.messageId];
        
    }
    [listMessagesMaster removeAllObjects];
    [self.tableView reloadData];
    
    
    EmptyInput* emptyInput = [[EmptyInput alloc] init];
    [emptyInput setFolderId:[NSNumber numberWithInt:CORBEILLE_ID_FOLDER]];
    //    [self runRequestService:S_FOLDER_EMPTY withParams:[emptyInput generate] header:nil andMethod:HTTP_POST];
    
    Request *request = [[Request alloc] initWithService:S_FOLDER_EMPTY method:HTTP_POST headers:nil params:[emptyInput generate]];
    request.delegate = self;
    request.trashMessageIds = trashMessageIds;
    [request execute];
    
    [self saveDB];
    [self resetSwitches];
    
    
}

-(void)restoreMsg:(id)sender{
    NSMutableArray *arrayIdsMessage = [[NSMutableArray alloc] init];
    NSMutableArray *arrayMessage = [[NSMutableArray alloc] init];
    
    for(NSNumber *messageId in checkedMessages) {
        Message *message = [self getMessagebyIdInListMaster:messageId];
        [arrayIdsMessage addObject:message.messageId];
        message.folderId = [NSNumber numberWithInt:RECEPTION_ID_FOLDER];
        [arrayMessage addObject:message];
    }
    [listMessagesMaster removeObjectsInArray:arrayMessage];
    
    for (NSNumber* msgId in arrayIdsMessage) {
        //@TD Set la view messageDetailsview a blanc, le message étant supprimer
        [self.detailViewController setBlankView:msgId];
    }
    
    [self.tableView reloadData];
    
    if ([arrayIdsMessage count] > 0) {
        MoveMessagesInput *moveMessages = [[MoveMessagesInput alloc] init];
        [moveMessages setMessageIds:arrayIdsMessage];
        [moveMessages setDestinationFolderId:[NSNumber numberWithInt:RECEPTION_ID_FOLDER]];
        [self runRequestService:S_ITEM_MOVE_MESSAGES withParams:[moveMessages generate] header:nil andMethod:HTTP_POST];
    }
    
    [self saveDB];
    [self resetSwitches];
    
    if(isIpad) {
        if ([checkedMessages containsObject:selectMessage]) {
            selectMessage=nil;
        } else {
            if(selectMessage) {
                [self selectMessageById:selectMessage];
            }
        }
    }
}

- (void)updateListMessage:(Message *)messageModify forMethod:(NSString *)method {
    DLog(@"updateListMessage");
    NSUInteger messageIndex = [listMessagesMaster indexOfObject:messageModify];
    if ([method isEqual:TRASH_MESSAGE_DELEGATE]){
        [listMessagesMaster removeObjectIdenticalTo:messageModify];
        
        if([checkedMessages containsObject:messageModify.messageId]){
            [checkedMessages removeObject:messageModify.messageId];
        }
        if(checkedMessages.count==0){
            [headerMenu setHidden:YES];
        }
        selectMessage=nil;
        [self.tableView reloadData];
    }
    else if ([method isEqual:DELETE_MESSAGE_DELEGATE]){
        [listMessagesMaster removeObjectIdenticalTo:messageModify];
        if([checkedMessages containsObject:selectMessage]){
            [checkedMessages removeObject:selectMessage];
        }
        if(checkedMessages.count==0){
            [headerMenu setHidden:YES];
        }
        selectMessage=nil;
        [self.tableView reloadData];
    }
    else if ([method isEqual:RESTORE_MESSAGE_DELEGATE]){
        [listMessagesMaster removeObjectIdenticalTo:messageModify];
        if([checkedMessages containsObject:messageModify.messageId]){
            [checkedMessages removeObject:messageModify.messageId];
        }
        if(checkedMessages.count==0){
            [headerMenu setHidden:YES];
        }
        selectMessage=nil;
        [self.tableView reloadData];
    }
    else if ([method isEqual:FOLLOW_DELEGATE]){
        if(masterFolderId.intValue == SUIVIS_ID_FOLDER){
            [listMessagesMaster removeObjectIdenticalTo:messageModify];
            [self.detailViewController setBlankView:messageModify.messageId];
            if([checkedMessages containsObject:messageModify.messageId]){
                [checkedMessages removeObject:messageModify.messageId];
            }
            if(checkedMessages.count==0){
                [headerMenu setHidden:YES];
            }
            selectMessage=nil;
        }
        
        [saveFavoriteState setValue:[NSNumber numberWithBool:TRUE] forKey:[NSString stringWithFormat:@"%lu", (unsigned long)messageIndex]];
        [favoriteMessages addObject:messageModify];
        [self.tableView reloadData];
        if(isIpad && masterFolderId.intValue != SUIVIS_ID_FOLDER){
            [self selectMessageById:messageModify.messageId];
        }
    } else if ([method isEqual:UNREAD_DELEGATE]) {
        [self updateUnreadMsgCount];
        [self.tableView reloadData];
        
        // [self reselecteMessage];
        
        if (masterFolderId.intValue == SUIVIS_ID_FOLDER) {
            [listMessagesMaster removeObjectIdenticalTo:messageModify];
            if ([checkedMessages containsObject:messageModify.messageId]) {
                [checkedMessages removeObject:messageModify.messageId];
            }
            if (checkedMessages.count==0) {
                [headerMenu setHidden:YES];
            }
            selectMessage = nil;
        } else {
            if(isIpad) {
                [self.detailViewController setBlankView:messageModify.messageId];
                selectMessage = nil;
            }
        }
    } else if ([method isEqual:MOVE_TO_FOLDER_DELEGATE]) {
        DLog(@"Moving Message");
        [selectedMessages removeAllObjects];
        [selectedMessages addObject:messageModify];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:selectedMessages forKey:SELECTED_MESSAGE];
        [dict setObject:masterFolderId forKey:MASTER_FOLDER_ID];
        [dict setObject:messageModify.folderId forKey:CURRENT_FOLDER_ID];
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_MOVE_MSG_VIEW_NOTIF object:dict];
        if([checkedMessages containsObject:selectMessage]){
            [checkedMessages removeObject:selectMessage];
        }
        if(checkedMessages.count==0){
            [headerMenu setHidden:YES];
        }
        selectMessage=nil;
    }
}

- (BOOL)isConnectedToInternet {
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        return NO;
    }
    return YES;
}

#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    //  should be calling your tableviews data source model to reload
    //  put here just for demo
    
    DLog(@"reloadTableViewDataSource MasterFolderID %d",masterFolderId.intValue);
    SyncAndLaunchModification *syncAndLaunchModif = [[SyncAndLaunchModification alloc] init];
    syncAndLaunchModif.delegate = self;
    [syncAndLaunchModif syncOnlyFolderId:masterFolderId];
    
    if ([self isConnectedToInternet]) {
        [syncAndLaunchModif execute];
        _reloading = YES;
    } else {
        double delayInSeconds = 1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self syncError:nil];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:NSLocalizedString(@"CONNEXION_IMPOSSIBLE", @"Connexion impossible")
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Continuer", nil];
            [alert show];
        });
    }
    
}

- (void)doneLoadingTableViewData{
    //  model should call this when its done loading
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date]; // should return date data source was last changed
}

-(void)syncSucces:(id)responseObject{
    DLog(@"MasterFolderId %@",masterFolderId);
    
    DLog(@"[[ShownFolder sharedInstance] folderId] %@",[[ShownFolder sharedInstance] folderId]);
    
    DLog(@"syncSucces master : %@", [responseObject description]);
    NSNumber *showFolder = [[ShownFolder sharedInstance] folderId];
    if ([FolderDAO folderExists:showFolder] || showFolder.intValue == SUIVIS_ID_FOLDER || showFolder.intValue == BOITE_D_ENVOI_ID_FOLDER || showFolder.intValue == NON_LUS_ID_FOLDER ) {
        [self displayMessageOfFolder:showFolder];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERREUR", @"Erreur")
                                                        message:NSLocalizedString(@"DOSSIER_SUPPRIME", @"Ce dossier a été supprimé")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                              otherButtonTitles:nil];
        [alert show];
        
    }
    
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil];
    
    [self selectCurrentMsg];
}

-(void)selectCurrentMsg {
    if ([[[CurrentMessage sharedInstance] message] messageId] != nil) {
        DLog(@"selectCurrentMsg [[[CurrentMessage sharedInstance] message] messageId] %@",[[[CurrentMessage sharedInstance] message] messageId]);
        [self selectMessageById:[[[CurrentMessage sharedInstance] message] messageId]];
    } else if (currentIndex) {
        [self.tableView selectRowAtIndexPath:currentIndex animated:NO scrollPosition:UITableViewScrollPositionNone];
        
        //        if (listMessagesMaster.count >= currentIndex.row) {
        //            NSNumber *currentMsgId = [[listMessagesMaster objectAtIndex:currentIndex.row] messageId];
        //            DLog(@"currentMsgId %@",currentMsgId);
        //            DLog(@"[[[CurrentMessage sharedInstance] message] messageId] %@",[[[CurrentMessage sharedInstance] message] messageId]);
        //            if ([[[[CurrentMessage sharedInstance] message] messageId] isEqualToNumber:currentMsgId]) {
        //                [self.tableView selectRowAtIndexPath:currentIndex animated:NO scrollPosition:UITableViewScrollPositionNone];
        //            }
        //
        //        }
        
    }
}

-(void)syncError:(id)responseObject{
    DLog(@"syncError master : %@", [responseObject description]);
    if ([responseObject isKindOfClass:[Error class]]) {
        Error *error = (Error*)responseObject;
        if (error.httpStatusCode == 403) {
            NSString *errorMsg = [error errorMsg];
            if ([error errorCode] == 34){
                errorMsg = NSLocalizedString(@"ERREUR_NO_MESSAGERIE", @"Authentification impossible : l’utilisateur n’a pas d’adresse de messagerie");
            } else if ([error errorCode] == 0){
                errorMsg = NSLocalizedString(@"INFO_CONNEXION_INVALID", @"Les informations de connexion sont invalides");
            }
            
            if (error.errorCode != 45 && error.errorCode != 41 && error.errorCode != 4500) {
                if (!isShownError) {
                    if (error.errorCode == 44) {
                        isCanalBlocked = YES;
                        [self.view endEditing:YES];
                        [tableSearchBar endEditing:YES];
                    }
                    
                    /* @WX - Anomalie 18086
                     * Problème : A l'étape 1 d'enrôlement, on a un affichage d'erreur "Veuillez vous enrôler de nouveau"
                     * Solution : Mettre un booléen pour savoir si on est bien à cette étape
                     *
                     * (cf. Request -> handleRequestError & ConnectionController -> login)
                     */
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:IS_NOT_ENROLLEMENT]) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERREUR", @"Erreur")
                                                                        message:errorMsg
                                                                       delegate:self
                                                              cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                                              otherButtonTitles:nil];
                        
                        [alert show];
                        isShownError = YES;
                    }
                    /* @WX - Fin des modifications */
                }
            }
            
            //            if (error.errorCode != 44) {
            
            //            }
            
        }
    }
    [self displayMessageOfFolder:masterFolderId];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil];
    
    [self selectCurrentMsg];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    isShownError = NO;
    if (isCanalBlocked) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DECONNEXION_NOTIF object:nil];
        isCanalBlocked = NO;
    }
}


- (void)deleteTableViewContent{
    [listMessagesMaster removeAllObjects];
    [self.nbMsgLabel setHidden:YES];
    [self.tableView reloadData];
}

- (IBAction)ecrireMsg:(id)sender {
    [tableSearchBar endEditing:YES];
    NSDictionary* contents = [NSDictionary dictionaryWithObject:self.navigationController forKey:CURRENT_NAV_CONTROLLER];
    [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_NEW_MSG_VIEW_NOTIF object:contents];
}

-(void)hidePopup:(NSNotification*)pNotification {
    SyncAndLaunchModification *syncAndLaunchModif = [[SyncAndLaunchModification alloc] init];
    syncAndLaunchModif.delegate = self;
    DLog(@"HidePopup FolderId %d",masterFolderId.intValue);
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && masterFolderId.intValue > 0) {
        [self displayMessageOfFolder:masterFolderId];
    }
    
    [syncAndLaunchModif initFolderId:masterFolderId];
    [syncAndLaunchModif execute];
}

-(void)hideKeyboard:(NSNotification*)pNotification {
    [tableSearchBar endEditing:YES];
}

-(void)messageSentNotif:(NSNotification*)pNotification {
    if (masterFolderId) {
        [self displayMessageOfFolder:masterFolderId];
        [self.detailViewController.noEmailsLabel setHidden:NO];
    }
}

-(void)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

-(void)selectMessageByMessageId:(NSNumber*)selecteMessageId{
    DLog(@"selecteMessageId %@",selecteMessageId);
    NSIndexPath *indexPath = nil;
    for (Message *msg in listMessagesMaster) {
        DLog(@"msg.id %@",msg.messageId);
        if ([msg.messageId isEqualToNumber:selecteMessageId]) {
            indexPath = [NSIndexPath indexPathForItem:[listMessagesMaster indexOfObject:msg] inSection:0];
            break;
        }
    }
    
    if(indexPath) {
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
}

-(BOOL)reselecteMessage {
    if (currentIndex) {
        [self.tableView selectRowAtIndexPath:currentIndex animated:NO scrollPosition:UITableViewScrollPositionNone];
        return YES;
    } else {
        DLog(@"reselecteMessage  : Can't select Message!");
    }
    return NO;
}


@end
