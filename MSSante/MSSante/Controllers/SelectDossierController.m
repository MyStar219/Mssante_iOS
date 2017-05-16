//
//  SelectDossierControllerViewController.m
//  MSSante
//
//  Created by Labinnovation on 08/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "SelectDossierController.h"

@interface SelectDossierController ()

@end

@implementation SelectDossierController

@synthesize spinnerView, tableArray, selectedMessages, messageFolderId, masterfolderId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    tableArray = [NSMutableArray array];
    [super viewDidLoad];
    
    [self.navigationItem setHidesBackButton:YES];
    UIImage *buttonImageRight = [UIImage imageNamed:@"bouton_retour"];
    UIButton *bButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [bButton setImage:buttonImageRight forState:UIControlStateNormal];
    bButton.frame = CGRectMake(0,0,50,35);
    [bButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:bButton];
    self.navigationItem.leftBarButtonItem = cancelItem;
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithWhite:0.9 alpha:1];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    titleLabel.textColor = [UIColor blackColor];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = NSLocalizedString(@"DEPLACER_MESSAGE", @"Déplacer un message");
    [self.navigationItem setTitleView:titleLabel];
    
    tableArray = [NSMutableArray array];
    
    FolderDAO *folderDAO = (FolderDAO*) [[DAOFactory factory] newDAO:FolderDAO.class];
    NSMutableArray *folders = [[folderDAO findFoldersByLevel:[NSNumber numberWithInt:0]] mutableCopy];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"folderName" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    folders = [[folders sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
    folders = [self sortFolders:folders];
    for (int i = 0; i < [folders count]; i++) {
        Folder *folder = [folders objectAtIndex:i];
        [self iterateFolders:folder];
    }
    
    [self.tableView reloadData];
}

- (IBAction)cancelButtonPressed:(id)sender {
    id obj = nil;
    if (selectedFolder) {
        obj = selectedFolder;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:HIDE_MOVE_MSG_VIEW_NOTIF object:obj];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [tableArray removeAllObjects];
    
    FolderDAO *folderDAO = (FolderDAO*) [[DAOFactory factory] newDAO:FolderDAO.class];
    NSMutableArray *folders = [[folderDAO findFoldersByLevel:[NSNumber numberWithInt:0]] mutableCopy];
    
    if ([folders count] >0){
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"folderName" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        folders = [[folders sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
        folders = [self sortFolders:folders];
        for (int i = 0; i < [folders count]; i++) {
            Folder *folder = [folders objectAtIndex:i];
            [self iterateFolders:folder];
        }
    }
    
    DLog(@"messageFolderId %d", messageFolderId.intValue);
    
    Folder *folder = [folderDAO findFolderByFolderId:messageFolderId];
    
    indexCurrentFolder = [tableArray indexOfObject:folder];
    
    [self.tableView reloadData];
    
    ListFoldersInput *listInput = [[ListFoldersInput alloc] init];
    Request *request = [[Request alloc] initWithService:S_FOLDER_LIST method:HTTP_POST headers:nil params:[listInput generate]];
    request.delegate = self;
    [request execute];
}

- (void)iterateFolders:(Folder*)folder {
    //    NSArray *array = [NSArray arrayWithObjects:[NSNumber numberWithInteger:6], nil];
    //    NSArray *foldersToCheck = [NSArray arrayWithObjects:[NSNumber numberWithInteger:2], [NSNumber numberWithInteger:3], [NSNumber numberWithInteger:5], nil];
    //skip drafts folder
    if ([folder.folderId intValue] != BROUILLON_ID_FOLDER) {
        //     BOOL addFolder = YES;
        //        if ([foldersToCheck containsObject:folder.folderId] && folder.folders.count == 0) {
        //            addFolder = NO;
        //        }
        
        //  if (addFolder) {
        [self.tableArray addObject:folder];
        NSMutableArray *folders = [NSMutableArray arrayWithArray:[folder.folders allObjects]];
        if ([folders count] > 0) {
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"folderName" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            folders = [[folders sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
            for (int i = 0; i <[folders count] ; i++) {
                Folder *_folder = [folders objectAtIndex:i];
                [self iterateFolders:_folder];
            }
        }
        //   }
        
    }
}


- (NSMutableArray*)sortFolders:(NSMutableArray*)folders {
    NSMutableArray *tmpArray = [NSMutableArray array];
    NSArray *foldersToCheck = [NSArray arrayWithObjects:[NSNumber numberWithInteger:2], [NSNumber numberWithInteger:3], [NSNumber numberWithInteger:5], nil];
    NSArray *currentFolders = [folders copy];
    for (Folder *folder in currentFolders) {
        if ([foldersToCheck containsObject:folder.folderId]) {
            [tmpArray addObject:folder];
            [folders removeObject:folder];
        }
    }
    
    [tmpArray addObjectsFromArray:folders];
    
    //    [tableArray initWithArray:tmpArray];
    return tmpArray;
}

-(void)httpResponse:(id)_responseObject {
    [spinnerView removeFromSuperview];
    if ([_responseObject isKindOfClass:[ListFoldersResponse class]]) {
        //        [(ListFoldersResponse*)_responseObject saveToDatabase];
        FolderDAO *folderDAO = (FolderDAO*) [[DAOFactory factory] newDAO:FolderDAO.class];
        NSMutableArray *folders = [[folderDAO findFoldersByLevel:[NSNumber numberWithInt:0]] mutableCopy];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"folderName" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        folders = [[folders sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
        
        folders = [self sortFolders:folders];
        
        [tableArray removeAllObjects];
        for (int i = 0; i < [folders count]; i++) {
            Folder *folder = [folders objectAtIndex:i];
            [self iterateFolders:folder];
        }
        
        [self.tableView reloadData];
    }
    
    else if ([_responseObject isKindOfClass:[NSString class]] && [S_ITEM_MOVE_MESSAGES isEqualToString:_responseObject]) {
        DLog(@"indexCurrentFolder %d", indexCurrentFolder);
        if (tableArray.count > 0 && tableArray.count > indexCurrentFolder &&  [[tableArray objectAtIndex:indexCurrentFolder] isKindOfClass:[Folder class]]) {
            Folder *folder = (Folder*)[tableArray objectAtIndex:indexCurrentFolder];
            DLog(@"Folder Id %d",folder.folderId.intValue);
            if (folder.folderId.intValue > 0) {
                double delayInSeconds = 0.1;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_CURRENT_FOLDER_NOTIF object:folder.folderId];
                });
                
                
            }
        }
        
    }
    
    
    
    
}

-(void)httpError:(Error*)error {
    [spinnerView removeFromSuperview];
    
    if (error != nil){
        DLog(@"SelectDossier Error Msg: %@", [error errorMsg]);
        DLog(@"SelectDossier Http Code: %d", [error httpStatusCode]);
        DLog(@"SelectDossier Error Code: %d", [error errorCode]);
        if (error.errorCode == 41){
            [self displayAlertWithMessage:NSLocalizedString(@"DOSSIER_N_EXISTE_PAS", @"Le dossier n'existe pas")];
        }
    }
}


-(void)displayAlertWithMessage:(NSString*)_message {
    DLog(@"displayAlertWithMessage");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERREUR", @"Erreur")
                                                    message:_message
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                          otherButtonTitles:nil];
    
    [alert show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)openMenu:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SlideToBackMenu" object:nil];
}


#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableArray.count;
}

//Method that allows you to customize the cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIImage *dossierBlueImage = [UIImage imageNamed:@"dossier_bleu"];
    UIImage *flecheSousDossierImage = [UIImage imageNamed:@"fleche_sousdossier"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"Cell"];
    }
    
    Folder *folder = self.tableArray[indexPath.row];
    [cell setIndentationLevel:[folder.level intValue]];
    cell.textLabel.text = folder.folderName;
    
    if([folder.level intValue] == 0) {
        if ([folder.folderId intValue] == 2) {
            [cell.imageView setImage:[UIImage imageNamed:@"ico_boitedereception_bleu"]];
            cell.textLabel.text = NSLocalizedString(@"BOITE_DE_RECEPTION", @"Boite de réception");
        } else if ([folder.folderId intValue] == 3) {
            [cell.imageView setImage:[UIImage imageNamed:@"ico_corbeille_bleue"]];
            cell.textLabel.text = NSLocalizedString(@"CORBEILLE", @"Corbeille");
        } else if ([folder.folderId intValue] == 5) {
            [cell.imageView setImage:[UIImage imageNamed:@"ico_msgenvoye_bleu"]];
            cell.textLabel.text = NSLocalizedString(@"MESSAGES_ENVOYES", @"Messages envoyés");
        } else {
            [cell.imageView setImage:dossierBlueImage];
        }
    } else {
        [cell.imageView setImage:flecheSousDossierImage];
    }
    
    if (indexPath.row == indexCurrentFolder) {
        cell.textLabel.alpha = 0.4;
    }
    else {
        cell.textLabel.alpha = 1;
    }
    
    [cell setBackgroundColor:[UIColor whiteColor]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == indexCurrentFolder) {
        return;
    }
    
    selectedFolder = [tableArray objectAtIndex:indexPath.row];
    
    NSMutableArray *messageIds = [[NSMutableArray alloc] init];
    for (Message* message in selectedMessages) {
        [messageIds addObject:message.messageId];
        message.folderId = selectedFolder.folderId;
    }
    
    [self saveDB];
    
    MoveMessagesInput *moveMessages = [[MoveMessagesInput alloc] init];
    [moveMessages setMessageIds:messageIds];
    [moveMessages setDestinationFolderId:selectedFolder.folderId];
    
    Request *request = [[Request alloc] initWithService:S_ITEM_MOVE_MESSAGES method:HTTP_POST headers:nil params:[moveMessages generate]];
    request.delegate = self;
    
    [request execute];
    DLog(@"updating database");
    [self cancelButtonPressed:self];
}

- (void)saveDB {
    NSError *error;
    if (![[DAOFactory factory] save:&error]) {
        DLog(@"error save %@", [error userInfo]);
    }
}

@end
