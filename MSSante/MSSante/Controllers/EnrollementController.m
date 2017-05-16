//
//  EnrollementController.m
//  MSSante
//
//  Created by labinnovation on 11/06/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "EnrollementController.h"
#import "EnrollementBController.h"
#import "Constant.h"
#import "PasswordStore.h"
#import "AccesToUserDefaults.h"
#import "DAOFactory.h"

@interface EnrollementController()

@end

@implementation EnrollementController

#pragma mark - Synthesize ImageView
@synthesize barreProgression;

#pragma mark - Synthesize Label
@synthesize labelEtape;
@synthesize labelDepuis;
@synthesize labelConnectez;
@synthesize labelEspace;
@synthesize labelCliquez;

#pragma mark - Synthesize Button
@synthesize boutonContinuer;


#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    DLog(@"initWithNibName EnrollementController");
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - Managing View
- (void)viewDidLoad {
    [super viewDidLoad];
    DLog(@"viewDidLoad");
    
    UIImage *patternImage1 = [UIImage imageNamed:@"d1@2x.png"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:patternImage1];
    
    /* @WX - Anomalie 18094
     * Problème : Mauvais message sur la flèche retour (iPad uniquement)
     *
     * Solution : Ici, on laisse pour l'iPhone pour deux raisons.
     * La première est qu'elle n'a pas d'impact sur la flèche retour.
     * La deuxième est purement design. L'affichage est plus appréciable.
     */
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.navigationItem.title = NSLocalizedString(@"AJOUTER_CET_APPAREIL", @"Ajouter cet appareil");
    }
    /* @WX - Fin des modifications */
    
    [DAOFactory deleteFactory];
    NSLog(@"DAO deleteFactory");
    DLog(@"DAOFactory %@", [DAOFactory factory]);
    
    NSString *dbPath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"MSSante.sqlite"];
    [[NSFileManager defaultManager] removeItemAtPath:dbPath error:nil];
    
    [AccesToUserDefaults resetUserInfo];
    [PasswordStore resetPasswords];
    NSLog(@"PasswordStore resetPasswords");
}

- (void)viewWillAppear:(BOOL)animated {
    DLog(@"viewWillAppear");
    
    /* @WX - Anomalie 18094
     * Problème : Mauvais message sur la flèche retour (iPad uniquement)
     *
     * Solution : Ici, on met à jour le titre du "navigation bar".
     * La raison pour laquelle on cache d'abord la navigation bar pour modifier le titre
     * puis de la réaparraître est purement design.
     */
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [[self navigationController] setNavigationBarHidden:YES animated:NO];
        [self.navigationItem setTitle:NSLocalizedString(@"AJOUTER_CET_APPAREIL", @"Ajouter cet appareil")];
        [[self navigationController] setNavigationBarHidden:NO animated:NO];
    } else {
        [[self navigationController] setNavigationBarHidden:NO animated:YES];
    }
    /* @WX - Fin des modifications */
    
    CGRect frame = self.navigationController.navigationBar.frame;
    frame.origin.y = 20;
    [self.navigationController.navigationBar setFrame:frame];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)viewWillDisappear:(BOOL)animated {
    DLog(@"viewWillDisappear");
    
    /* @WX - Anomalie 18094
     * Problème : Mauvais message sur la flèche retour (iPad uniquement)
     *
     * Solution : Ici, on met à jour le titre du "navigation bar".
     * On met le titre à nil car la flèche retour du prochain viewController dépend
     * du "titre de ce viewController".
     */
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.navigationItem setTitle:nil];
    }
    /* @WX - Fin des modifications */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    barreProgression = nil;
    
    labelEtape = nil;
    labelDepuis = nil;
    labelConnectez = nil;
    labelEspace = nil;
    labelCliquez = nil;
    
    boutonContinuer = nil;
}


#pragma mark - Application Base Path
- (NSString *)applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    return basePath;
}


#pragma mark - Managing IBAction
- (IBAction)enrollementBController:(id)sender {
    EnrollementBController *enrollementBController;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        enrollementBController = [[EnrollementBController alloc] initWithNibName:@"EnrollementBController_iPhone"
                                                                          bundle:nil];
    } else {
        enrollementBController = [[EnrollementBController alloc] initWithNibName:@"EnrollementBController_iPad"
                                                                          bundle:nil];
    }
    
    [enrollementBController.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.navigationController pushViewController:enrollementBController animated:YES];
}

@end
