//
//  DossierController.h
//  MSSante
//
//  Created by Labinnovation on 24/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Request.h"
#import "ListFoldersInput.h"
#import "RequestFinishedDelegate.h"
#import "MasterViewController.h"

@interface DossierController : UIViewController <UITableViewDelegate, UITableViewDataSource, RequestFinishedDelegate> {
    NSMutableArray *tableArray;
    Folder *selectedFolder;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) MasterViewController *masterViewController;

- (IBAction)openMenu:(id)sender;
@property (strong,nonatomic) NSMutableArray *tableArray;
@end
