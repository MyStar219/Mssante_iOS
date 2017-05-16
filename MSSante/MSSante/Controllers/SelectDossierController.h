//
//  SelectDossierControllerViewController.h
//  MSSante
//
//  Created by Labinnovation on 08/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Request.h"
#import "ListFoldersInput.h"
#import "MoveMessagesInput.h"
#import "RequestFinishedDelegate.h"
#import "MasterViewController.h"
#import "FolderDAO.h"
#import "Message.h"

@interface SelectDossierController : UITableViewController <RequestFinishedDelegate> {
    NSMutableArray *tableArray;
    Folder *selectedFolder;
    NSNumber *messageFolderId;
    NSNumber *masterfolderId;
    int indexCurrentFolder;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) MasterViewController *masterViewController;

- (IBAction)openMenu:(id)sender;
@property (strong, nonatomic) UIView *spinnerView;
@property (strong,nonatomic) NSMutableArray *tableArray;
@property (strong, nonatomic) NSMutableArray *selectedMessages;
@property (strong, nonatomic) NSNumber *messageFolderId;
@property (strong, nonatomic) NSNumber *masterfolderId;
@end
