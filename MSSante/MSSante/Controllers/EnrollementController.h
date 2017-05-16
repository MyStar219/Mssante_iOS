//
//  EnrollementController.h
//  MSSante
//
//  Created by labinnovation on 11/06/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EnrollementController : UIViewController  {
    BOOL isAutorotate;
}

@property (strong, nonatomic) id detailItem;

#pragma mark - ImageView
@property (weak, nonatomic) IBOutlet UIImageView *barreProgression;

#pragma mark - Label
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *labelEtape;
@property (weak, nonatomic) IBOutlet UILabel *labelDepuis;
@property (weak, nonatomic) IBOutlet UILabel *labelConnectez;
@property (weak, nonatomic) IBOutlet UILabel *labelEspace;
@property (weak, nonatomic) IBOutlet UILabel *labelCliquez;

#pragma mark - Button
@property (weak, nonatomic) IBOutlet UIButton *boutonContinuer;

#pragma mark - IBAction
- (IBAction)enrollementBController:(id)sender;

@end
