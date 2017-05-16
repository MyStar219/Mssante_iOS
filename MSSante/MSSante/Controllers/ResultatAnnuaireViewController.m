//
//  ResultatAnnuaireViewController.m
//  MSSante
//
//  Created by Labinnovation on 28/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "ResultatAnnuaireViewController.h"
#import "Constant.h"
#import "Email.h"
#import "NPMessage.h"
#import "NPEmail.h"
#import "NPConverter.h"
#import "DAOFactory.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CLGeocoder.h>

#define kHeightLabel 25
#define IS_IOS_7_OR_EARLIER   ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)

@interface ResultatAnnuaireViewController () {
}

@end

@implementation ResultatAnnuaireViewController {
    UIViewController *curentViewController;
    
    /* @WX - Anomalie 17880
     * Cette variable permet d'accumuler la hauteur de chaque mail
     * afin de bien positionner le prochain mail dans la vue.
     */
    float heightAccuMailLabel;
    
    /* @WX - Anomalie 17880
     * Ces variables servent à prendre en compte les données qu'une seule fois
     * Elles sont utilisées dans la fonction cellForRowAtIndexPath
     */
    UILabel *titleProfessionLabel;
    UILabel *professionLabel;
    UILabel *titleSpecialiteLabel;
    UILabel *specialiteLabel;
    
    BOOL firstTimeAddTels;
    BOOL firstTimeAddMails;
    
    /* @WX - Anomalie SFD
     * Il faut accumuler la hauteur de la profession et de la spécialité
     * afin de bien positionner chaque détail.
     */
    float heightProfessionAndSpecialite;
}



@synthesize professionel;
@synthesize delegate;
@synthesize comingFromNewMsg;

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
    DLog(@"ResultatAnnuaireViewController - viewDidLoad");
    
    /* @WX - Anomalie 17880 et anomalie SFD
     * Initialisation des variables
     */
    NSInteger i = 1;
    heightAccuMailLabel = 0.0;
    heightProfessionAndSpecialite = 0.0;
    firstTimeAddTels = YES;
    firstTimeAddMails = YES;
    
    /* @WX - Anomalie 17880 (version iOS 7)
     * Pour ajuster le placement de la TableView
     * A la base, la variable heightFirstRow a été initialisée a 170
     */
    heightFirstRow = 68;
    /* @WX - Fin des modifications */
    
    listAdresse = [[NSMutableArray alloc] init];
    listAdresse = [professionel.listAdresse mutableCopy];
    
    /* @WX - Anomalie 17880 (version iOS 7)
     * Pour ajuster le placement de la TableView
     */
    
    if (professionel.profession) {
        i = 1;
        while (professionel.profession.length > 16*i) {
            ++i;
        }
        
        heightFirstRow += kHeightLabel + 10*i;
    }
    
    if (professionel.specialite) {
        i = 1;
        while (professionel.specialite.length > 16*i) {
            ++i;
        }
        
        heightFirstRow += kHeightLabel + 10*i;
    }
    /* @WX - Fin des modifications */
    
    if (professionel.listMails.count > 0 || professionel.numTel.count > 0 ){
        heightFirstRow += (kHeightLabel * professionel.numTel.count);
        
        for (NSString * mail in professionel.listMails) {
            /* @WX - Anomalie 17880 (version iOS 7)
             * Pour ajuster le placement de la TableView
             */
            
            /*
             heightFirstRow += kHeightLabel;
             
             if(mail.length >72){
             heightFirstRow+=45;
             } else if(mail.length >54){
             heightFirstRow+=35;
             } else if(mail.length >36){
             heightFirstRow+=25;
             } else if(mail.length > 18){
             heightFirstRow+=15;
             }
             */
            
            i = 1;
            while (mail.length > 16*i) {
                ++i;
            }
            
            heightFirstRow += kHeightLabel + 10*i;
            /* @WX - Fin des modifications */
        }
    }
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithWhite:0.9 alpha:1];
    
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectZero];
    titleView.textColor = [UIColor blackColor];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.text = NSLocalizedString(@"RESULTAT", @"Résultat");
    [titleView sizeToFit];
    [self.navigationItem setTitleView:titleView];
    
    // It will remove extra separators from tableView
    // self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Add
- (UILabel *)addTel:(NSString*)mail forRow:(int)row atView:(UIView*)view bottomLabel:(UILabel*)bottomLabel {
    float height = kHeightLabel;
    
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @1};
    
    /* @WX - Anomalie 17880
     * Mise à jour de la hauteur du label
     */
    UILabel* titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 68 + heightProfessionAndSpecialite + (height*row), 120, height)];
    titlelabel.text = [NSString stringWithFormat:@"Téléphone %d :", row + 1];
    [titlelabel setTextColor:[UIColor darkGrayColor]];
    
    UILabel* telLabel = [[UILabel alloc] initWithFrame:CGRectMake(147, 68 + heightProfessionAndSpecialite + (height*row), self.tableView.frame.size.width - 120 - 20 - 10, height)];
    /* @WX - Fin des modifications */
    
    [telLabel setTag:[bottomLabel tag] + 1];
    telLabel.attributedText = [[NSAttributedString alloc] initWithString:mail
                                                              attributes:underlineAttribute];
    
    UITapGestureRecognizer *tapForMail = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(launchCall:)];
    [tapForMail setNumberOfTapsRequired:1];
    [telLabel setUserInteractionEnabled:YES];
    [telLabel addGestureRecognizer:tapForMail];
    
    [view addSubview:titlelabel];
    [view addSubview:telLabel];
    
    return telLabel;
}

- (UILabel *)addEmailAdresse:(NSString*)mail forRow:(int)row atView:(UIView*)view bottomLabel:(UILabel*)bottomLabel {
    float height = kHeightLabel;
    
    int nbPhone = professionel.numTel.count;
    float decalageY = height * nbPhone;
    
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @1};
    
    /* @WX - Anomalie 17880
     * Mise à jour de la hauteur du label
     */
    UILabel* titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 68 + heightProfessionAndSpecialite + decalageY + heightAccuMailLabel, 73, height)];
    titlelabel.text = [NSString stringWithFormat:@"Email %d :", row + 1];
    [titlelabel setTextColor:[UIColor darkGrayColor]];
    
    UILabel* mailLabel = [[UILabel alloc] initWithFrame:CGRectMake(101, 68 + heightProfessionAndSpecialite + decalageY + heightAccuMailLabel + 3, self.tableView.frame.size.width - 73 - 20 - 10, height)];
    /* @WX - Fin des modifications */
    
    [mailLabel setTag:[bottomLabel tag] + 1];
    mailLabel.attributedText = [[NSAttributedString alloc] initWithString:mail
                                                               attributes:underlineAttribute];
    mailLabel.lineBreakMode = NSLineBreakByWordWrapping;
    mailLabel.numberOfLines = 0;
    [mailLabel sizeToFit];
    
    /* @WX - Anomalie 17880
     * Incrémentation de l'accumulation des hauteurs
     */
    heightAccuMailLabel += mailLabel.frame.size.height;
    /* @WX - Fin des modifications */
    
    UITapGestureRecognizer *tapForMail = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(launchEmail:)];
    [tapForMail setNumberOfTapsRequired:1];
    [mailLabel setUserInteractionEnabled:YES];
    [mailLabel addGestureRecognizer:tapForMail];
    
    [view addSubview:mailLabel];
    [view addSubview:titlelabel];
    
    return mailLabel;
}


#pragma mark - Table Management
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return professionel.listAdresse.count + 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell_pres_professionel" forIndexPath:indexPath];
        
        UILabel *nomLabel = (UILabel *)[cell viewWithTag:11];
        UILabel *prenomLabel = (UILabel *)[cell viewWithTag:12];
        
        /* @WX - Anomalie SFD
         * Correction du label en le mettant en "attributed text"
         * et non en "plain text"
         */
        // UILabel *professionLabel = (UILabel *)[cell viewWithTag:13];
        // UILabel *specialiteLabel = (UILabel *)[cell viewWithTag:14];
        
        /* @WX - Fin des modifications */
        
        // NSString *name = [NSString stringWithFormat:@"%@ %@", professionel.nom, professionel.prenom];
        
        nomLabel.text = professionel.nom;
        prenomLabel.text = professionel.prenom;
        
        /* @WX - Anomalie SFD
         * Correction du label en le mettant en "attributed text"
         * et non en "plain text"
         */
        // professionLabel.text = professionel.profession;
        // specialiteLabel.text = professionel.specialite;
        
        UILabel *lastLabel = prenomLabel;
        
        if(professionel.profession != nil && ![professionel.profession isEqualToString:@""]) {
            if (titleProfessionLabel == nil) {
                titleProfessionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 68, 120, 20)];
                titleProfessionLabel.text = [NSString stringWithFormat:@"Profession :"];
                [titleProfessionLabel setTextColor:[UIColor darkGrayColor]];
                
                [cell addSubview:titleProfessionLabel];
            }
            
            if (professionLabel == nil) {
                professionLabel = [[UILabel alloc] initWithFrame:CGRectMake(123, 68, tableView.frame.size.width - 120 - 20 - 10, 20)];
                professionLabel.attributedText = [[NSAttributedString alloc] initWithString:professionel.profession];
                professionLabel.lineBreakMode = NSLineBreakByWordWrapping;
                professionLabel.numberOfLines = 0;
                [professionLabel sizeToFit];
                
                [cell addSubview:professionLabel];
            }
            
            heightProfessionAndSpecialite = professionLabel.frame.size.height + 5;
            lastLabel = professionLabel;
        }
        
        if(professionel.specialite != nil && ![professionel.specialite isEqualToString:@""]) {
            if (titleSpecialiteLabel == nil) {
                titleSpecialiteLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 68 + heightProfessionAndSpecialite, 120, 20)];
                titleSpecialiteLabel.text = [NSString stringWithFormat:@"Spécialité :"];
                [titleSpecialiteLabel setTextColor:[UIColor darkGrayColor]];
                
                [cell addSubview:titleSpecialiteLabel];
            }
            
            if (specialiteLabel == nil) {
                specialiteLabel = [[UILabel alloc] initWithFrame:CGRectMake(118, 68 + heightProfessionAndSpecialite, tableView.frame.size.width - 120 - 20 - 10, 20)];
                specialiteLabel.attributedText = [[NSAttributedString alloc] initWithString:professionel.specialite];
                specialiteLabel.lineBreakMode = NSLineBreakByWordWrapping;
                specialiteLabel.numberOfLines = 0;
                [specialiteLabel sizeToFit];
                
                [cell addSubview:specialiteLabel];
            }
            
            heightProfessionAndSpecialite += specialiteLabel.frame.size.height + 5;
            lastLabel = specialiteLabel;
        }
        /* @WX - Fin des modifications */
        
        // telLabel.text = [NSString stringWithFormat:@"%@", professionel.numTel];
        
        /* @WX - Anomalie 17880
         * Problème : Ré-ajout des numéros de téléphone qui deviennent plus gras.
         * Solution : Mettre un booléen pour savoir si c'est la première fois
         */
        if (firstTimeAddTels) {
            for (int i = 0; i < professionel.numTel.count; i++) {
                lastLabel = [self addTel:[professionel.numTel objectAtIndex:i] forRow:i atView:cell bottomLabel:lastLabel];
            }
            firstTimeAddTels = NO;
        }
        
        /* @WX - Anomalie 17880
         * Problème : Dédoublement des adresses mails
         * Solution : Mettre un booléen pour savoir si c'est la première fois
         */
        if (firstTimeAddMails) {
            for (int i = 0; i < professionel.listMails.count; i++) {
                [self addEmailAdresse:[professionel.listMails objectAtIndex:i] forRow:i atView:cell bottomLabel:lastLabel];
            }
            firstTimeAddMails = NO;
        }
        /* @WX - Fin des modifications */
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell_adresse_professionel" forIndexPath:indexPath];
        
        UILabel *labelAdresseNumero = (UILabel *)[cell viewWithTag:1];
        UILabel *labelTitreAdresse = (UILabel *)[cell viewWithTag:2];
        UILabel *labelRue = (UILabel *)[cell viewWithTag:3];
        UILabel *labelCpCommune = (UILabel *)[cell viewWithTag:4];
        
        NSMutableDictionary *dictAdresse = [professionel.listAdresse objectAtIndex:indexPath.row - 1];
        
        /* @WX - Anomalie 17880
         * Changement du labelAdresseNumero
         * Avant, on avait quelque chose qui ressemblait à "Adresse 12334213" avec labelAdresseNumero.text
         */
        // labelAdresseNumero.text = [labelAdresseNumero.text stringByAppendingString:[NSString stringWithFormat:@"%d", indexPath.row]];
        labelAdresseNumero.text = [@"Adresse " stringByAppendingString:[NSString stringWithFormat:@"%d", indexPath.row]];
        /* @WX - Fin des modifications */
        
        labelTitreAdresse.text = [dictAdresse objectForKey:NOM_STRUCTURE];
        labelRue.text = [dictAdresse objectForKey:ADRESSE];
        
        NSString *cpCommune = @"";
        if ([dictAdresse objectForKey:CODE_POSTAL]) {
            cpCommune = [cpCommune stringByAppendingString:[NSString stringWithFormat:@"%@", [dictAdresse objectForKey:CODE_POSTAL]]];
        }
        if ([dictAdresse objectForKey:COMMUNE]) {
            cpCommune = [cpCommune stringByAppendingString:[NSString stringWithFormat:@" %@", [dictAdresse objectForKey:COMMUNE]]];
        }
        
        labelCpCommune.text = cpCommune;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return;
    }
    
    NSMutableDictionary *dictAdresse = [professionel.listAdresse objectAtIndex:indexPath.row - 1];
    
    NSString* cpCommune = @"";
    if ([dictAdresse objectForKey:CODE_POSTAL]) {
        cpCommune = [cpCommune stringByAppendingString:[NSString stringWithFormat:@"%@", [dictAdresse objectForKey:CODE_POSTAL]]];
    }
    if ([dictAdresse objectForKey:COMMUNE]) {
        cpCommune = [cpCommune stringByAppendingString:[NSString stringWithFormat:@" %@", [dictAdresse objectForKey:COMMUNE]]];
    }
    
    NSString* adresse = [NSString stringWithFormat:@"%@ %@", [dictAdresse objectForKey:ADRESSE], cpCommune];
    [self launchMap:adresse];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        /* @WX - Anomalie 17880
         * Ajuster le placement de la liste des adresses
         */
        //return heightFirstRow;
        if (IS_IOS_7_OR_EARLIER) {
            return heightFirstRow + 10;
        }
        
        return 68 + heightProfessionAndSpecialite + (kHeightLabel * professionel.numTel.count) + heightAccuMailLabel + 10;
        /* @WX - Fin des modifications */
    }
    
    return 105;
}


#pragma mark - Launch
- (void)launchCall:(UITapGestureRecognizer*)sender {
    UILabel* telLabel = (UILabel*)sender.view;
    NSString* _string = [telLabel.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        NSString *_pattern = @"^((\\+|00)33\\s?|0)[1-9](\\s?\\d{2}){4}$";
        NSError  *regexError  = nil;
        if ([_string length] > 0 && [_pattern length] > 0) {
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:_pattern options:NSRegularExpressionCaseInsensitive error:&regexError];
            if(!regexError) {
                int nb =[regex   numberOfMatchesInString:_string options:0 range:NSMakeRange(0, _string.length)];
                if (nb != 0 ){
                    NSString *phoneNumber = [@"tel:" stringByAppendingString:_string];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
                }
            }
        }
    } else {
        //@TD 18020
        NSString *phoneNumber = [@"facetime://" stringByAppendingString:_string];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    }
}

- (void)launchEmail:(UITapGestureRecognizer*)sender {
    UILabel *mailLabel = (UILabel*) sender.view;
    NSString *mail = mailLabel.text;
    
    // if([delegate respondsToSelector:@selector(addMailToNouveauMessage:)]){
    if(comingFromNewMsg) {
        Email *email = [NSEntityDescription insertNewObjectForEntityForName: @"Email" inManagedObjectContext: [[DAOFactory factory] managedObjectContext]];
        email.name = [NSString stringWithFormat:@"%@ %@", professionel.nom, professionel.prenom];
        email.address = mail;
        email.type = E_TO;
        [delegate addMailToNouveauMessage:email];
        [self dismissViewControllerAnimated:NO completion:nil];
    } else {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            curentViewController = self.navigationController;
            [self dismissViewControllerAnimated:NO completion:^{
                [self executeLaunchEmail:mail];
            }];
        } else {
            [self executeLaunchEmail:mail];
        }
    }
}

- (void)executeLaunchEmail:(NSString*)mail {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    Email *email = [NSEntityDescription insertNewObjectForEntityForName: @"Email" inManagedObjectContext: [[DAOFactory factory] managedObjectContext]];
    email.name = [NSString stringWithFormat:@"%@ %@", professionel.nom, professionel.prenom];
    email.address = mail;
    email.type = E_TO;
    
    //@TD
    NPEmail * npEmail = [[NPEmail alloc ] init];
    npEmail = [NPConverter convertEmail:email];
    NPMessage* message = [[NPMessage alloc] init];
    NSMutableArray * to = [[NSMutableArray alloc] init];
    [to addObject:npEmail];
    [message setTo:to];
    [params setObject:message  forKey:MESSAGE];
    
    NSMutableArray *listEmail = [[NSMutableArray alloc] initWithObjects:email, nil];
    [params setObject:listEmail forKey:@"toEmails"];
    [params setObject:FROM_ANNAUIRE forKey:FROM_ANNAUIRE];
    //    [params setObject:self.navigationController forKey:CURRENT_NAV_CONTROLLER];
    //    if (curentViewController) {
    //        [params setObject:curentViewController forKey:CURRENT_VIEW_CONTROLLER];
    //    }
    [self dismissViewControllerAnimated:NO completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_NEW_MSG_VIEW_NOTIF object:params];
}

- (void)launchMap:(NSString*)adresse {
    Class mapItemClass = [MKMapItem class];
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)]) {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:adresse
                     completionHandler:^(NSArray *placemarks, NSError *error) {
                         
                         // Convert the CLPlacemark to an MKPlacemark
                         // Note: There's no error checking for a failed geocode
                         CLPlacemark *geocodedPlacemark = [placemarks objectAtIndex:0];
                         MKPlacemark *placemark = [[MKPlacemark alloc]
                                                   initWithCoordinate:geocodedPlacemark.location.coordinate
                                                   addressDictionary:geocodedPlacemark.addressDictionary];
                         
                         // Create a map item for the geocoded address to pass to Maps app
                         MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
                         [mapItem setName:geocodedPlacemark.name];
                         
                         // Set the directions mode to "Driving"
                         // Can use MKLaunchOptionsDirectionsModeWalking instead
                         NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving};
                         
                         // Get the "Current User Location" MKMapItem
                         MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
                         
                         // Pass the current location and destination map items to the Maps app
                         // Set the direction mode in the launchOptions dictionary
                         [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem] launchOptions:launchOptions];
                         
                     }];
    }
}


#pragma mark - IBAction
- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
