//
//  AccueilController.h
//  MSSante
//
//  Created by Work on 6/11/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccueilController : UIViewController

#pragma mark - View
@property (weak, nonatomic) IBOutlet UIView *MiddleView;
@property (weak, nonatomic) IBOutlet UIImageView *logo;

#pragma mark - Label
@property (weak, nonatomic) IBOutlet UILabel *labelBienvenue;
@property (weak, nonatomic) IBOutlet UILabel *labelAcces;
@property (weak, nonatomic) IBOutlet UILabel *labelOperation;
@property (weak, nonatomic) IBOutlet UILabel *labelPasCompte;

#pragma mark - Button
@property (weak, nonatomic) IBOutlet UIButton *boutonAjouter;
@property (weak, nonatomic) IBOutlet UIButton *boutonPasCompte;

#pragma mark - IBAction
- (IBAction)EnrolerCeTerminal:(id)sender;
- (IBAction)pasDeCompte:(id)sender;

@end
