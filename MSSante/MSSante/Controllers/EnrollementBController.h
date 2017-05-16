//
//  EnrollementBController.h
//  MSSante
//
//  Created by Work on 6/12/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ZBarReaderView.h"
#import "ZBarReaderViewController.h"

@interface EnrollementBController : UIViewController <ZBarReaderDelegate> {
    BOOL isAutorotate;
    BOOL canRotateToAllOrientations;

    UIView *activityView;
    UITextView *resultText;
}

#pragma mark - View
@property (nonatomic, retain) IBOutlet UIImageView *resultImage;
@property (nonatomic, retain) IBOutlet UITextView *resultText;
@property (nonatomic, retain) IBOutlet UIImageView *barreProgression;

#pragma mark - Label
@property (weak, nonatomic) IBOutlet UILabel *labelEtape;
@property (weak, nonatomic) IBOutlet UILabel *labelCode;
@property (weak, nonatomic) IBOutlet UILabel *labelCliquez;

#pragma mark - Button
@property (weak, nonatomic) IBOutlet UIButton *boutonContinuer;

#pragma mark - Methods
- (void)readQrCode:(id)jsonObject;

#pragma mark - IBAction
- (IBAction)Scan:(id)sender;

@end
