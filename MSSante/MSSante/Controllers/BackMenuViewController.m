//
//  BackMenuViewController.m
//  MSSante
//
//  Created by labinnovation on 13/06/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "BackMenuViewController.h"
#import "Constant.h"
#import "RootViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Constant.h"
#import "NouveauMessageViewController2.h"

@interface BackMenuViewController ()

@end

@implementation BackMenuViewController
@synthesize footerBackMenuView;
@synthesize nbDraft, nbMsgUnread, nbMsgWillSend, selectedRow;
@synthesize contentView;
@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        DLog(@"init BackMenuViewController");
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openPref:) name:OPEN_PREFERENCES object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openAnnuaire:) name:OPEN_ANNUAIRE object:nil];
    selectedRow = 0;
    nbMsgWillSend = @"0";
    nbMsgUnread = @"0";
    nbDraft = @"0";
    iconListDisable = [[NSMutableArray alloc] initWithObjects:@"ico_reception2", @"ico_nonlus_grand2", @"ico_msgsuivi2", @"ico_brouillon2", @"ico_msgenvoye2", @"ico_corbeille_grand2", @"ico_dossier_grand2", @"ico_boite_envoi2", nil];
/*    [[NSMutableArray alloc] initWithObjects:@"ico_reception", @"ico_nonlus_grand", @"ico_msgsuivi", @"ico_brouillon", @"ico_msgenvoye", @"ico_corbeille_grand", @"ico_dossier_grand", @"ico_boite_envoi", nil];*/
    folderList = [[NSMutableArray alloc] initWithObjects:NSLocalizedString(@"BOITE_DE_RECEPTION", @"Boite de réception"),
                  NSLocalizedString(@"NON_LUS", @"Non lus"),
                  NSLocalizedString(@"MESSAGES_SUIVIS", @"Messages suivis"),
                  NSLocalizedString(@"BROUILLONS", @"Brouillons"),
                  NSLocalizedString(@"MESSAGES_ENVOYES", @"Messages envoyés"),
                  NSLocalizedString(@"CORBEILLE", @"Corbeille"),
                  NSLocalizedString(@"DOSSIERS", @"Dossiers"),
                  NSLocalizedString(@"BOITE_D_ENVOI", @"Boite d'envoi"), nil];
    
    self.tableView.scrollsToTop = NO;
    
    DLog(@"viewDidLoad BackMenuViewController");
}

-(void)viewDidAppear:(BOOL)animated{
    parentView = [self parentViewController];
    self.masterViewController = [(RootViewController*)parentView masterViewController];
    DLog(@"viewDidAppear BackMenuViewController");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setNbMsgUnread:(NSString *)_nbMsgUnread{
    nbMsgUnread = _nbMsgUnread;
    [self.tableView reloadData];
}
-(void)setNbDraft:(NSString *)_nbDraft{
    nbDraft = _nbDraft;
    [self.tableView reloadData];
}
-(void)setNbMsgWillSend:(NSString *)_nbMsgWillSend{
    nbMsgWillSend = _nbMsgWillSend;
    [self.tableView reloadData];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return folderList.count;
}

-(void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //ON dismiss la view messageDetailVC si on est dessus et sur iphone car elle se trouve au dessus
    if( [[self.masterViewController.navigationController topViewController] isKindOfClass:[MessageDetailViewController class]]
       && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        [[self.masterViewController.navigationController topViewController] dismissViewControllerAnimated:NO completion:nil];
        [self.masterViewController.navigationController popToRootViewControllerAnimated:NO];
    }
    
    if (indexPath.row != 6){
        [self saveDraftIfNeeded];
            if (selectedRow == 6){
                [(RootViewController*)parentView launchControllerWithSegue:MASTER_SEGUE];
                [[(RootViewController*)parentView masterViewControllerDossier] removeNotification];
                [[(RootViewController*)parentView masterViewController] addNotification];
            }
            
            NSNumber* folderId;
            switch (indexPath.row) {
                case 0:
                    folderId = [NSNumber numberWithInt:RECEPTION_ID_FOLDER];
                    break;
                    
                case 1:
                    folderId = [NSNumber numberWithInt:NON_LUS_ID_FOLDER];
                    break;
                    
                case 2:
                    folderId = [NSNumber numberWithInt:SUIVIS_ID_FOLDER];
                    break;
                    
                case 3:
                    folderId = [NSNumber numberWithInt:BROUILLON_ID_FOLDER];
                    break;
                    
                case 4:
                    folderId = [NSNumber numberWithInt:ENVOYES_ID_FOLDER];
                    break;
                    
                case 5:
                    folderId = [NSNumber numberWithInt:CORBEILLE_ID_FOLDER];
                    break;
                    
                case 7:
                    folderId = [NSNumber numberWithInt:BOITE_D_ENVOI_ID_FOLDER];
                    break;
                    
                default:
                    folderId = [NSNumber numberWithInt:RECEPTION_ID_FOLDER];
                    break;
            }
            [self.masterViewController loadMasterControllerWithFolder:folderId inFolderSubView:NO];
            [[(RootViewController*)parentView navController] popToRootViewControllerAnimated:NO];
    }else {
        [self saveDraftIfNeeded];
        [[(RootViewController*)parentView navController] popToRootViewControllerAnimated:NO];
        [[(RootViewController*)parentView masterViewController] removeNotification];
        [(RootViewController*)parentView launchControllerWithSegue:DOSSIER_SEGUE];
    }
    selectedRow = indexPath.row;
    [[NSNotificationCenter defaultCenter] postNotificationName:SLIDE_BACK_MENU_NOTIF object:nil];
    
}

-(void)saveDraftIfNeeded{
    id currentController = [(RootViewController*)parentView navController].viewControllers.lastObject;
    if ([currentController isKindOfClass:[NouveauMessageViewController2 class]] && ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)) {
        [currentController saveDraft:nil];
    
    }
}

//Method that allows you to customize the cells
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    UIImageView *icon = (UIImageView *)[cell viewWithTag:5];
    UILabel *textLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *intLabel = (UILabel *)[cell viewWithTag:2];
    
    
    
    textLabel.text = [folderList objectAtIndex:indexPath.row];
    
    [icon setContentMode:UIViewContentModeCenter] ;
    [icon setImage:[UIImage imageNamed:[iconListDisable objectAtIndex:indexPath.row]]];
    
    [intLabel.layer setCornerRadius:3];
    
    if (indexPath.row == 0){
        if (![nbMsgUnread isEqual:@"0"]){
            [intLabel setHidden:NO];
            intLabel.text = nbMsgUnread;
        }
        else {
            [intLabel setHidden:YES];
        }
    }
    else if (indexPath.row == 3){
        if (![nbDraft  isEqual:@"0"]){
            [intLabel setHidden:NO];
            intLabel.text = nbDraft;
        }
        else {
            [intLabel setHidden:YES];
        }
    }
    else if (indexPath.row == 7){
        if (![nbMsgWillSend  isEqual:@"0"]){
            [intLabel setHidden:NO];
            intLabel.text = nbMsgWillSend;
        }
        else {
            [intLabel setHidden:YES];
        }
    }
    return cell;
}

-(void)openPref:(NSNotification*)pNotification{
    [self performSegueWithIdentifier:@"segueToChangePassword" sender:self];
}

-(void)openAnnuaire:(NSNotification*)pNotification{
    RootViewController* rootViewCtrl = (RootViewController*)[self parentViewController];
    [rootViewCtrl enableUserInteractionForTableView:TRUE];
    [self performSegueWithIdentifier:@"segueToAnnuaire" sender:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return HEIGHT_HEADER_BACK_MENU;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return HEIGHT_FOOTER_BACK_MENU;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    headerBackMenuView = [[HeaderBackMenuView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, HEIGHT_HEADER_BACK_MENU)];
    [headerBackMenuView setName];
	return headerBackMenuView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    
    footerBackMenuView = [[FooterBackMenuView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, HEIGHT_FOOTER_BACK_MENU)];
	return footerBackMenuView;
}


@end
