//
//  ChoixMessagerieViewController.h
//  MSSante
//
//  Created by Labinnovation on 03/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChoixMessagerieViewController : UIViewController<UITableViewDataSource, UITableViewDelegate> {
    NSIndexPath *selectedRow;
    NSMutableArray *listEmails;
    NSString *choiceMail;
}

@property (weak, nonatomic) IBOutlet UITableView *msgTableView;

- (void)reloadListMails:(NSMutableArray*)list;
- (IBAction)Valider:(id)sender;

@end
