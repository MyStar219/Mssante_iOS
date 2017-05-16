//
//  AccueilController.m
//  MSSante
//
//  Created by Work on 6/11/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "AccueilController.h"
#import "EnrollementController.h"
#import "NoAccountController.h"

@interface AccueilController()

@end

@implementation AccueilController

#pragma mark - Synthesize ImageView
@synthesize logo;

#pragma mark - Synthesize Label
@synthesize labelBienvenue;
@synthesize labelAcces;
@synthesize labelOperation;
@synthesize labelPasCompte;

#pragma mark - Synthesize Button
@synthesize boutonAjouter;
@synthesize boutonPasCompte;


#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    DLog(@"initWithNibName AccueilController");
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - Managing View
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    UIImage *patternImage1 = [UIImage imageNamed:@"d1@2x.png"];
    UIImage *patternImage2 = [UIImage imageNamed:@"d2@2x.png"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:patternImage1];
    self.MiddleView.backgroundColor = [UIColor colorWithPatternImage:patternImage2];
    
    DLog(@"viewDidLoad AccueilController");
}

- (void)viewWillAppear:(BOOL)animated {
    // Hide navigation bar from the welcome screen
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    DLog(@"viewWillAppear AccueilController");
}

- (void)viewDidAppear:(BOOL)animated {
    DLog(@"viewDidAppear AccueilController");
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    logo = nil;
    
    labelBienvenue = nil;
    labelAcces = nil;
    labelOperation = nil;
    labelPasCompte = nil;
    
    boutonAjouter = nil;
    boutonPasCompte = nil;
}


#pragma mark - Application Base Path
- (NSString *)applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    return basePath;
}


#pragma mark - Managing IBAction
- (IBAction)EnrolerCeTerminal:(id)sender {
    EnrollementController *enrollementController;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        enrollementController = [[EnrollementController alloc] initWithNibName:@"EnrollementController_iPhone"
                                                                        bundle:nil];
        DLog(@"EnrollementController_iPhone.xib");
    } else {
        enrollementController = [[EnrollementController alloc] initWithNibName:@"EnrollementController_iPad"
                                                                        bundle:nil];
        DLog(@"EnrollementController_iPad.xib");
    }
    
    [enrollementController.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.navigationController pushViewController:enrollementController animated:YES];
}

- (IBAction)pasDeCompte:(id)sender {
    NoAccountController *noAccountController;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        noAccountController = [[NoAccountController alloc] initWithNibName:@"NoAccountController_iPhone"
                                                                    bundle:nil];
        DLog(@"NoAccountController_iPhone.xib");
    } else {
        noAccountController = [[NoAccountController alloc] initWithNibName:@"NoAccountController_iPad"
                                                                    bundle:nil];
        DLog(@"NoAccountController_iPad.xib");
    }
    
    [noAccountController.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.navigationController pushViewController:noAccountController animated:YES];
}

@end
