//
//  ChoixMessagerieViewController.m
//  MSSante
//
//  Created by Labinnovation on 03/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "ChoixMessagerieViewController.h"
#import "AccesToUserDefaults.h"
#import "CustomChoixMsgCell.h"
#import "Constant.h"

@interface ChoixMessagerieViewController ()

@end

@implementation ChoixMessagerieViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    /* @WX - Amélioration Sonar
     * Décommenter le if pour l'initialisation
     */
    /*if (self) {
        // Custom initialization
     }*/
    return self;
}


#pragma mark - Managing View
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    listEmails = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadListMails:(NSMutableArray*) list {
    listEmails = [list mutableCopy];
    [self.msgTableView reloadData];
}


#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [listEmails count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

//Method that allows you to customize the cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *simpleTableIdentifier = @"CustomChoixMailCell";
    CustomChoixMsgCell *cell = (CustomChoixMsgCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomChoixMailCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.mailLabel.text = [listEmails objectAtIndex:indexPath.row];
    
    if (selectedRow && indexPath.row == selectedRow.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

//Method called when cell is clicked
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(selectedRow) {
        UITableViewCell* uncheckCell = [self.msgTableView cellForRowAtIndexPath:selectedRow];
        uncheckCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    UITableViewCell* cell = [self.msgTableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    selectedRow = indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}


#pragma mark - IBAction
- (IBAction)Valider:(id)sender {
    if([AccesToUserDefaults getUserInfo]) {
        [AccesToUserDefaults setUserInfoChoiceMail:[listEmails objectAtIndex:selectedRow.row]];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_SUCCESSFUL_NOTIF object:FIRST_CONNEXION];
}

@end
