//
//  AnnuaireViewController.h
//  MSSante
//
//  Created by Labinnovation on 28/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequestFinishedDelegate.h"
#import "AnnuaireDelegate.h"
#import "NouveauMessageViewController2.h"
#import "NPMessage.h"

@class  NouveauMessageViewController2;
@interface AnnuaireViewController : UIViewController <RequestFinishedDelegate, UITabBarDelegate, UISearchBarDelegate, UITableViewDataSource>{
    NSMutableArray *listAnnuaire;
    __weak id <AnnuaireDelegate>delegate;
    NSString *query;
    BOOL comingFromNewMsg;
}
@property (nonatomic, strong) NSString *query;
@property (nonatomic, weak) id<AnnuaireDelegate>delegate;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)goBack:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (nonatomic, assign) BOOL comingFromNewMsg;
@property (weak, nonatomic) IBOutlet UILabel *noResults;
 //@TD transfert
@property (weak,nonatomic) NPMessage * npMessage;

@end
