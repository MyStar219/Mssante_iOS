//
//  ResultatAnnuaireViewController.h
//  MSSante
//
//  Created by Labinnovation on 28/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Professionel.h"
#import "AnnuaireDelegate.h"

@interface ResultatAnnuaireViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    Professionel* professionel;
    NSMutableArray* listAdresse;
    __weak id <AnnuaireDelegate>delegate;
    int heightFirstRow;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) id<AnnuaireDelegate>delegate;

@property (strong, nonatomic) Professionel* professionel;
@property (assign, nonatomic) BOOL comingFromNewMsg;

- (IBAction)goBack:(id)sender;

@end
