//
//  MasterViewController.h
//  MSSante
//
//  Created by labinnovation on 10/06/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BackMenuViewController.h"
#import <CoreData/CoreData.h>
#import "RequestFinishedDelegate.h"
#import "MessageDAO.h"
#import "FolderDAO.h"
#import "DetailViewController.h"
#import "AccueilController.h"

#import "Email.h"
#import "Message.h"
#import "Constant.h"
#import "BackMenuViewController.h"
#import "AppDelegate.h"
#import "Request.h"

#import "DAOFactory.h"
#import "ConnectionController.h"
#import "EnrollementController.h"
#import <QuartzCore/QuartzCore.h>
#import "AccesToUserDefaults.h"
#import "SearchMessagesInput.h"
#import "ListFoldersInput.h"
#import "SyncInput.h"
#import "ListFoldersResponse.h"
#import "SearchMessagesResponse.h"
#import "SyncMessagesResponse.h"
#import "Folder.h"
#import "RootViewController.h"
#import "ContainerViewController.h"
#import "FullTextSearchMessagesResponse.h"
#import "FullTextSearchMessagesInput.h"
#import "ShownFolder.h"
#import "EGORefreshTableHeaderView.h"
#import "CurrentMessage.h"

@class MessageDetailViewController;

@interface MasterViewController : UIViewController <EGORefreshTableHeaderDelegate, DetailDelegate, NSFetchedResultsControllerDelegate, RequestFinishedDelegate, UISearchBarDelegate, SyncAndSendModifDelegate, UIAlertViewDelegate> {
    
	EGORefreshTableHeaderView *_refreshHeaderView;
    NSDictionary *saveSwitchState;
    NSDictionary *saveFavoriteState;
    NSFetchedResultsController *fetchedResultsController;
//    NSManagedObjectContext *managedObjectContext;
    BOOL isMenuDisplay;
    BOOL isLoading;
    BOOL _reloading;
    NSMutableArray *tableArray;
    NSMutableArray *listMessagesMaster;
    NSMutableArray *selectedMessages;
    NSNumber *masterFolderId;
    UIPopoverController * popoverController;
    NSUInteger offset;
    UISearchBar *tableSearchBar;
    UIView *headerMenu;
    UIView *footerView;
    UIButton *loadMoreMessagesButton;
    NSUInteger searchMethod;
    UIActivityIndicatorView *activityIndicator;
    UIView *headerView;
    BOOL isLoadMoreMessages;
    BOOL isComingFromFolderSelection;
    Folder* masterFolder;
    BOOL changeNotificationStateIsRunning;
    
    UIView *spinnerView;
    UIActivityIndicatorView *loadingActivityIndicator;
    BOOL isShown;
}
@property (weak, nonatomic) IBOutlet UIView *whiteView;

@property (weak, nonatomic) IBOutlet UIView *MenuBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) MessageDetailViewController *detailViewController;
@property (strong, nonatomic) BackMenuViewController *backMenuViewController;
@property (strong, nonatomic) ContainerViewController *containerController;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UILabel *nbMsgLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *mailTitleLabel;
@property (strong,nonatomic) UIPopoverController * popoverController;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) NSNumber *masterFolderId;
@property (strong, nonatomic) NSMutableArray *selectedMessages;
@property (strong, nonatomic) NSMutableArray *listMessagesMaster;
@property (assign, nonatomic) BOOL isComingFromFolderSelection;
@property (assign, nonatomic) BOOL changeNotificationStateIsRunning;
@property (strong, nonatomic) Folder* masterFolder;
@property (strong, nonatomic) UIView *spinnerView;
@property (strong, nonatomic) UIActivityIndicatorView *loadingActivityIndicator;
@property (assign, nonatomic) BOOL isShown;
- (IBAction)openMenu:(id)sender;

- (void)runRequestService:(NSString*)_servivce withParams:(NSDictionary*)_params header:(NSMutableDictionary*)_header andMethod:(NSString*)_method;
-(void)loadMasterControllerWithFolder:(NSNumber*)folderName inFolderSubView:(BOOL)isFolderSubview;
-(void)loadMasterControllerWithFolder:(NSNumber*)folderId inFolderSubView:(BOOL)isFolderSubview isInit:(BOOL)isInit;
-(void)initMasterViewController;
- (IBAction)ecrireMsg:(id)sender;
- (void)initialiserMessages;
- (void)deleteTableViewContent;
-(void)removeNotification;
-(void)addNotification;
-(Message*)getMessagebyIdInListMaster:(NSNumber*)messageId;

-(void)deleteMsg:(id)sender;
-(void)insertToFolder:(id)sender;
-(void)followMsg:(id)sender;
-(void)unreadMsg:(id)sender;
-(void)definitivDeletMsg:(id)sender;
-(void)viderCorbeille:(id)sender;
-(void)restoreMsg:(id)sender;

-(void)displayMessageOfFolder:(NSNumber*)folderId;
-(void)resetSwitches;
-(void)selectMessageByMessageId:(NSNumber*)selecteMessageId;
-(BOOL)reselecteMessage;


+(void)majWhenReceivedNotification;
@end
