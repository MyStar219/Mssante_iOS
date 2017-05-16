//
//  DossierController.m
//  MSSante
//
//  Created by Labinnovation on 24/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "DossierController.h"
#import "Constant.h"
#import "ListFoldersResponse.h"
#import "FolderDAO.h"

@interface DossierController ()

@end

@implementation DossierController

@synthesize tableArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    tableArray = [NSMutableArray array];
    
    UILabel * titleView = [[UILabel alloc] initWithFrame:CGRectZero];
    titleView.textColor = [UIColor blackColor];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.text = NSLocalizedString(@"DOSSIERS", @"Dossiers");
    [self.navigationItem setTitleView:titleView];
    [titleView sizeToFit];
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    [tableArray removeAllObjects];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
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
    
    if([folders count] <= 4){
        [self displayAlertNodirectory];
    }else {
        
    [self.tableView reloadData];
    
    ListFoldersInput *listInput = [[ListFoldersInput alloc] init];
    Request *request = [[Request alloc] initWithService:S_FOLDER_LIST method:HTTP_POST headers:nil params:[listInput generate]];
    request.delegate = self;
    [request execute];
    }
    
}

-(void)httpResponse:(id)_responseObject {
//    [spinnerView removeFromSuperview];
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
    }
    
    
    
    [self.tableView reloadData];
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

- (void)iterateFolders:(Folder*)folder {
//    NSArray *array = [NSArray arrayWithObjects:[NSNumber numberWithInteger:6], nil];
    NSArray *foldersToCheck = [NSArray arrayWithObjects:[NSNumber numberWithInteger:2], [NSNumber numberWithInteger:3], [NSNumber numberWithInteger:5], nil];
    //skip drafts folder
    if ([folder.folderId intValue] != 6) {
        BOOL addFolder = YES;
        if ([foldersToCheck containsObject:folder.folderId] && [folder.folders count] == 0) {
            addFolder = NO;
        }
        
         if (addFolder) {
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
        }
    }
}


-(void)httpError:(Error*)error {
//    [spinnerView removeFromSuperview];
    
    if (error != nil){
        DLog(@"MasterView Error Msg: %@", [error errorMsg]);
        DLog(@"MasterView Http Code: %d", [error httpStatusCode]);
        DLog(@"MasterView Error Code: %d", [error errorCode]);
    }
}

- (void)didReceiveMemoryWarning
{
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    Folder *folder = self.tableArray[indexPath.row];
    [cell setIndentationLevel:[folder.level intValue]];
    cell.textLabel.text = folder.folderName;
    if([folder.level intValue] == 0) {
        if ([folder.folderId intValue] == RECEPTION_ID_FOLDER) {
            [cell.imageView setImage:[UIImage imageNamed:@"ico_boitedereception_bleu"]];
            cell.textLabel.text = NSLocalizedString(@"BOITE_DE_RECEPTION", @"Boite de réception");
        } else if ([folder.folderId intValue] == CORBEILLE_ID_FOLDER) {
            [cell.imageView setImage:[UIImage imageNamed:@"ico_corbeille_bleue"]];
            cell.textLabel.text = NSLocalizedString(@"CORBEILLE", @"Corbeille");
        } else if ([folder.folderId intValue] == ENVOYES_ID_FOLDER) {
            [cell.imageView setImage:[UIImage imageNamed:@"ico_msgenvoye_bleu"]];
            cell.textLabel.text = NSLocalizedString(@"MESSAGES_ENVOYES", @"Messages envoyés");
        } else {
            [cell.imageView setImage:dossierBlueImage];
        }
        
    } else {
        [cell.imageView setImage:flecheSousDossierImage];
    }
    
    [cell setBackgroundColor:[UIColor whiteColor]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"segueDossierToMaster" sender:indexPath];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSIndexPath *indexPath = (NSIndexPath *)sender;
    selectedFolder = [tableArray objectAtIndex:indexPath.row];
    MasterViewController *masterViewControllerInFolder = segue.destinationViewController;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.rootViewController.masterViewControllerDossier = masterViewControllerInFolder;
    [ShownFolder sharedInstance].folderId = selectedFolder.folderId;
    [masterViewControllerInFolder loadMasterControllerWithFolder:selectedFolder.folderId inFolderSubView:YES];
    [masterViewControllerInFolder setIsComingFromFolderSelection:YES];
}

-(void) displayAlertNodirectory {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"AUCUN_DOSSIER", @"Aucun dossier")
                                                    message:nil
                                                   delegate: nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                          otherButtonTitles:nil];
    
    [alert show];
}
@end
