//
//  ContainerViewController.m
//  MSSante
//
//  Created by Labinnovation on 29/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "ContainerViewController.h"

@interface ContainerViewController ()

@property (strong, nonatomic) NSString *currentSegueIdentifier;
@property (strong, nonatomic) UINavigationController *masterViewController;
@property (strong, nonatomic) UINavigationController *dossierViewController;
@property (assign, nonatomic) BOOL transitionInProgress;

@end

@implementation ContainerViewController

//Au chargement du controller, on charge la boite de récéption
//(par defaut, c'est la 1ère qui est affichée)
- (void)viewDidLoad {
    DLog(@"viewDidLoad ContainerViewController");
    [super viewDidLoad];
    self.transitionInProgress = NO;
    self.currentSegueIdentifier = MASTER_SEGUE;
    [self performSegueWithIdentifier:self.currentSegueIdentifier sender:nil];
}

//On overide la méthode prepareForSegue, appelé dans le storyboard au chargement du controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //Quand on charge un controller grâce aux segue, on initialise les variables de la classe
    
    if (([MASTER_SEGUE isEqualToString:segue.identifier]) && !self.masterViewController) {
        self.masterViewController = segue.destinationViewController;
    }
    // if (([segue.identifier isEqualToString:DOSSIER_SEGUE]) && !self.dossierViewController) {
    if (([DOSSIER_SEGUE isEqualToString:segue.identifier])) {
        self.dossierViewController = segue.destinationViewController;
    }
    
    // Si on charge la boite de récéption
    if ([MASTER_SEGUE isEqualToString:segue.identifier]) {
        // Si ce n'est pas la 1ere fois qu'on charge une vue
        if (self.childViewControllers.count > 0) {
            [self swapFromViewController:[self.childViewControllers objectAtIndex:0]
                        toViewController:self.masterViewController];
        } else {
            // Si c'est la 1ere fois qu'on charge une vue depuis ce controller,
            // on initialise le tableau de childViewController
            [self addChildViewController:segue.destinationViewController];
            CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            ((UIViewController *)segue.destinationViewController).view.frame = frame;
            [self.view addSubview:((UIViewController *)segue.destinationViewController).view];
            [segue.destinationViewController didMoveToParentViewController:self];
        }
    } else if ([DOSSIER_SEGUE isEqualToString:segue.identifier]) {
        [[self getDetailViewController] setDefaultParamsDetail];
        [self swapFromViewController:[self.childViewControllers objectAtIndex:0]
                    toViewController:self.dossierViewController];
    }
}

//Methode qui permet de changer de vue dans le container
- (void)swapFromViewController:(UIViewController *)fromViewController
              toViewController:(UIViewController *)toViewController {
    //La taille de la future vue doit être la même que l'ancienne (donc que le container)
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    toViewController.view.frame = frame;
    
    [fromViewController willMoveToParentViewController:nil];
    [self addChildViewController:toViewController];
    
    //Transition avec animation des controllers
    [self transitionFromViewController:fromViewController
                      toViewController:toViewController duration:0.2
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:nil
                            completion:^(BOOL finished) {
                                [fromViewController removeFromParentViewController];
                                [toViewController didMoveToParentViewController:self];
                                self.transitionInProgress = NO;
                            }];
}

- (MasterViewController*)getMasterViewController {
    return [[self.masterViewController childViewControllers] objectAtIndex:0];
}

- (MessageDetailViewController*)getDetailViewController {
    RootViewController *rootViewController = (RootViewController*)self.parentViewController;
    return rootViewController.detailViewController;
}

//Appelle un segue précis pour changer de controller (méthode appelé au click dans backMenu)
- (void)launchControllerWithSegue:(NSString*)segue {
    if (self.transitionInProgress) {
        return;
    }
    
    if (![self.currentSegueIdentifier isEqual:segue]) {
        self.transitionInProgress = YES;
        self.currentSegueIdentifier = segue;
        [self performSegueWithIdentifier:self.currentSegueIdentifier sender:nil];
    } else if ([segue isEqual:DOSSIER_SEGUE]) {
        self.transitionInProgress = YES;
        self.currentSegueIdentifier = segue;
        [self performSegueWithIdentifier:self.currentSegueIdentifier sender:nil];
    }
}

@end