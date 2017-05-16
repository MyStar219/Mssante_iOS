//
//  AnnuaireViewController.m
//  MSSante
//
//  Created by Labinnovation on 28/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "AnnuaireViewController.h"
#import "Constant.h"
#import "Request.h"
#import "SearchRecipientInput.h"
#import "SearchRecipientResponse.h"
#import "ResultatAnnuaireViewController.h"

@interface AnnuaireViewController () {
    int minChars;
    BOOL errorShown;
}

@end

@implementation AnnuaireViewController

@synthesize delegate, query, comingFromNewMsg;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        errorShown =  NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    listAnnuaire = [[NSMutableArray alloc] init];
    
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    
    [self.spinner setHidden:YES];

    minChars = 3;
    
//    if (comingFromNewMsg) {
//        minChars = 4;
//    }
    
//    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
//    [self.tableView addGestureRecognizer:gestureRecognizer];
    
    self.searchBar.delegate = self;
    self.searchBar.showsCancelButton = NO;
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithWhite:0.9 alpha:1];
    UILabel * titleView = [[UILabel alloc] initWithFrame:CGRectZero];
    titleView.textColor = [UIColor blackColor];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.text = NSLocalizedString(@"ANNUAIRE", @"Annuaire");
    [self.navigationItem setTitleView:titleView];
    [titleView sizeToFit];

}

- (void) viewDidAppear:(BOOL)animated {
    if (query.length > 0) {
//        NSString *que = @"!@#$%^&*()_+|abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
//        NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"] invertedSet];
//        NSString *resultString = [[query componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
        
        NSMutableCharacterSet *allowedChars = [[NSCharacterSet alphanumericCharacterSet] mutableCopy];
        [allowedChars addCharactersInString:@" àáâãäåòóôõöøèéêëçìíîïùúûüÿñ"];
        NSCharacterSet *notAllowedChars = [allowedChars invertedSet];
        NSString *resultString = [[query componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
//        query = resultString;
        
//        DLog(@"resultString %@ %d", resultString, resultString.length);
        [self.searchBar setText:resultString];
        if (resultString.length >= minChars) {
            DLog(@"query %@",resultString);
            DLog(@"query %d",resultString.length);
            [self searchBarSearchButtonClicked:self.searchBar];
        } else {
            [self.noResults setHidden:NO];
            [self.searchBar becomeFirstResponder];
        }
       // query = resultString;
//        [self.tableView reloadData];

    } else {
        [self.searchBar setPlaceholder:@"Recherche(1)"];
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"annuaire_cell" forIndexPath:indexPath];
    
    UILabel *labelNom = (UILabel *)[cell viewWithTag:11];
    UILabel *labelProfession = (UILabel *)[cell viewWithTag:12];
    UILabel *labelAddress = (UILabel *)[cell viewWithTag:13];
    
    Professionel *professionel = [listAnnuaire objectAtIndex:indexPath.row];
//    NSMutableDictionary *dictAdresse = [professionel.listAdresse objectAtIndex:0];
    
    labelNom.text = [NSString stringWithFormat:@"%@ %@",professionel.nom, professionel.prenom];
    
    NSMutableString* profession = [NSMutableString stringWithString:@""];
    if (professionel.profession.length > 0) {
        [profession appendString:professionel.profession];
        if (professionel.specialite.length > 0) {
            [profession appendFormat:@" - %@",professionel.specialite];
        }
    }
    
    labelProfession.text = profession;
    NSString* adress = @"";
    int count = 0;
    DLog(@"count %d",professionel.listAdresse.count);
    for (NSMutableDictionary *adresse in professionel.listAdresse) {
        
        if ([adresse objectForKey:CODE_POSTAL]){
            adress = [adress stringByAppendingString:[NSString stringWithFormat:@"%@", [adresse objectForKey:CODE_POSTAL]]];
        }
        if ([adresse objectForKey:COMMUNE]){
            adress = [adress stringByAppendingString:[NSString stringWithFormat:@" %@", [adresse objectForKey:COMMUNE]]];
        }
        count++;
        if (count < professionel.listAdresse.count) {
            adress = [adress stringByAppendingString:@", "];
        }
        
    }
    
//    if ([dictAdresse objectForKey:ADRESSE]){
//        adress = [adress stringByAppendingString:[dictAdresse objectForKey:ADRESSE]];
//    }
//    if ([dictAdresse objectForKey:CODE_POSTAL]){
//        adress = [adress stringByAppendingString:[NSString stringWithFormat:@", %@", [dictAdresse objectForKey:CODE_POSTAL]]];
//    }
//    if ([dictAdresse objectForKey:COMMUNE]){
//        adress = [adress stringByAppendingString:[NSString stringWithFormat:@" %@", [dictAdresse objectForKey:COMMUNE]]];
//    }
    labelAddress.text = adress;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    [self.tableView setHidden:listAnnuaire.count == 0 ? YES : NO];
    return listAnnuaire.count;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{

}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //return ([searchBar.text length] + [text length] - range.length > 30) ? NO : YES;
    if ([text isEqualToString:@"\n"]){
        return YES;
    }
    NSString *newText = [searchBar.text stringByReplacingCharactersInRange:range withString:text];
    return newText.length <= 30;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (searchBar.text.length < minChars ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERREUR", @"Erreur")
                                                        message:NSLocalizedString(@"THREE_CHARS_MIN", @"Veuillez renseigner au moins 3 caractères")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                              otherButtonTitles:nil];
        [alert show];

    } else {
        SearchRecipientInput* searchInput = [[SearchRecipientInput alloc] init];
        
        [searchInput setSearchString:searchBar.text];
        Request* request = [[Request alloc] initWithService:S_ANNUAIRE_SEARCH_RECIPIENT method:HTTP_POST headers:nil params:[searchInput generate]];
        request.delegate = self;
        //Correction ano 16507
        [self.searchBar setText:searchBar.text];
        
        query = searchBar.text;
        DLog("Query = %@",query);
        if ([request isConnectedToInternet]) {
            [request execute];
            [self.spinner setHidden:NO];
            [self.noResults setHidden:YES];
            errorShown = NO;

        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERREUR", @"Erreur")
                                                            message:NSLocalizedString(@"CONNEXION_IMPOSSIBLE", @"Connexion impossible")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                                  otherButtonTitles:nil];
            [alert show];
            
        }
        
        [searchBar resignFirstResponder];
        [searchBar endEditing:YES];

    }
    
    
}

-(BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

-(void)httpError:(Error *)_error{
    DLog(@"AnnuaireViewController httpError : %@", _error);
    if (!errorShown) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[_error title]
                                                        message:[_error errorMsg]
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                              otherButtonTitles:nil];
        [alert show];
        errorShown = YES;
    }
    
    [self.spinner setHidden:YES];

    [self.view endEditing:YES];
    [self.searchBar resignFirstResponder];
    
    [self.noResults setHidden:YES];
    
}

-(void)httpResponse:(id)_responseObject{
    DLog(@"AnnuaireViewController httpResponse : %@", [_responseObject listProfessionels]);
    listAnnuaire = [_responseObject listProfessionels];
    [self.tableView reloadData];
    [self.spinner setHidden:YES];
    [self.tableView setUserInteractionEnabled:YES];
    [self.noResults setHidden:listAnnuaire.count != 0];
    
    errorShown = NO;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    DLog(@"delegate : %@", delegate);
    NSIndexPath *index = [self.tableView indexPathForSelectedRow];
    ResultatAnnuaireViewController *resultatCtrl = segue.destinationViewController;
    [resultatCtrl setProfessionel:[listAnnuaire objectAtIndex:index.row]];
    //@TD transfert
    if(comingFromNewMsg)
    {
        [resultatCtrl setComingFromNewMsg:YES];
    }
    resultatCtrl.delegate = delegate;
}

- (IBAction)goBack:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^(void) {
        NouveauMessageViewController2 *newMsg = (NouveauMessageViewController2*)self.delegate;
       //newMsg.setFirstResponder = field;
        [newMsg initFirstResponder];
    }];
    
    
}

- (BOOL) searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self.tableView setUserInteractionEnabled:NO];
    [self.searchBar setShowsCancelButton:NO animated:NO];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    DLog(@"HERE");
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.searchBar isFirstResponder] && [touch view] != self.searchBar) {
        [self.searchBar resignFirstResponder];
        [self.tableView setUserInteractionEnabled:YES];
    }
    [super touchesBegan:touches withEvent:event];
}
@end
