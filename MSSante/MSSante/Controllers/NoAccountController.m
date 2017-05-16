//
//  NoAccountController.m
//  MSSante
//
//  Created by Labinnovation on 17/03/2015.
//  Copyright (c) 2015 Capgemini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NoAccountController.h"

@implementation NoAccountController

#pragma mark - Synthesize Label
@synthesize labelRdv;
@synthesize labelActivation;
@synthesize labelProfessionnel;
@synthesize labelTitulaire;
@synthesize labelEquipe;


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
}

- (void) viewWillAppear:(BOOL)animated {
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    CGRect navBarFrame = self.navigationController.navigationBar.frame;
    navBarFrame.origin.y = 20;
    [self.navigationController.navigationBar setFrame:navBarFrame];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [self setLabelRdv:nil];
    [self setLabelActivation:nil];
    [self setLabelProfessionnel:nil];
    [self setLabelTitulaire:nil];
    [self setLabelEquipe:nil];
}

@end
