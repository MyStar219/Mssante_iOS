//
//  NouveauMessageDrawer.m
//  MSSante
//
//  Created by Labinnovation on 06/11/2014.
//  Copyright (c) 2014 Capgemini. All rights reserved.
//

#import "NouveauMessageViewController2.h"
#import "NouveauMessageDrawer.h"

@interface NouveauMessageDrawer ()

@property (nonatomic, weak) NouveauMessageViewController2 *master;

@end


@implementation NouveauMessageDrawer

@synthesize master;

- (id)initWithMaster:(NouveauMessageViewController2 *)theMaster {
    self = [super init];
    if (self){
        self.master = theMaster;
    }
    return self;
}

- (UIBarButtonItem *)createLeftButton {
    UIImage *buttonImageLeft = [UIImage imageNamed:@"bouton_retour"];
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aButton setImage:buttonImageLeft forState:UIControlStateNormal];
    aButton.frame = CGRectMake(0, 0, 50, 33);
    [aButton addTarget:self.master
                action:@selector(cancelButtonPressed:)
      forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:aButton];
}

- (UIBarButtonItem*)createSendButton {
    //Creation to custom button for create message (at right of masterView)
    UIImage *buttonImageRight = [UIImage imageNamed:@"bouton_envoyer"];
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aButton setImage:buttonImageRight forState:UIControlStateNormal];
    aButton.frame = CGRectMake(0.0, 0.0, buttonImageRight.size.width, buttonImageRight.size.height);
    [aButton addTarget:self.master
                action:@selector(sendMessage:)
      forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithCustomView:aButton];
    return sendButton;
}

- (UILabel *)createTitleLabel {
    CGFloat widthLabel = self.master.navigationController.navigationBar.frame.size.width;
    CGFloat heightLabel = self.master.navigationController.navigationBar.frame.size.height;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, widthLabel, heightLabel)];
    titleLabel.textColor = [UIColor blackColor];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = NSLocalizedString(@"NOUVEAU_MESSAGE", @"Nouveau message");
    return titleLabel;
}

- (void)setupNotificationCenter {
    [[NSNotificationCenter defaultCenter] addObserver:self.master
                                             selector:@selector(saveDraft:)
                                                 name:@"saveDraft"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self.master
                                             selector:@selector(didUpdateTokens:)
                                                 name:@"didUpdateTokens"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self.master
                                             selector:@selector(didAddToken:)
                                                 name:@"didAddToken"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self.master
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self.master
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self.master
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self.master
                                             selector:@selector(orientationChanged:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
}

- (UIButton *)createPjButton {
    CGFloat widthView = self.master.view.frame.size.width;
    UIButton *pjButton = [[UIButton alloc] initWithFrame:CGRectMake(widthView - 37, 7, 30, 30)];
    [pjButton setImage:[UIImage imageNamed:@"ico_trombonne"] forState:UIControlStateNormal];
    [pjButton addTarget:self.master
                 action:@selector(togglePjMenuView:)
       forControlEvents:UIControlEventTouchUpInside];
    return pjButton;
}

- (PieceJointeMenu *)createPjMenu {
    UIView *containerView = self.master.tableView;
    PieceJointeMenu *pjMenu = [[PieceJointeMenu alloc] initWithFrame:CGRectMake(0, 0, 320, 120)];
    // PieceJointeMenu *pjMenu = [[PieceJointeMenu alloc] initWithFrame:CGRectMake(0, 0, 120, 320)];
    
    //NSLog(@"Container %@",containerView);
    //constraint for PJMenu
    [containerView addSubview:pjMenu];
    NSLayoutConstraint *myConstraint =[NSLayoutConstraint
                                       constraintWithItem:pjMenu
                                       attribute:NSLayoutAttributeBottom
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:containerView
                                       attribute:NSLayoutAttributeBottom
                                       multiplier:1.0
                                       constant:0.0];
    
    myConstraint.priority = 1000;
    pjMenu.translatesAutoresizingMaskIntoConstraints = YES;
    [containerView addConstraint:myConstraint];
    [pjMenu assignViewController:self.master];
    [pjMenu setHidden:YES];
    return pjMenu;
}

- (UIView *)createSpinnerView {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect frameSpinnerView = CGRectMake (0, 0, screenRect.size.width, screenRect.size.height);
    UIView *spinnerView = [[UIView alloc] initWithFrame:frameSpinnerView];
    [spinnerView setBackgroundColor:[UIColor blackColor]];
    [spinnerView setAlpha:0.5];
    [spinnerView setHidden:YES];
    
    UIActivityIndicatorView *activityIndicator;
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] ;
    activityIndicator.frame = CGRectMake(0.0, 0.0, 20,20);
    activityIndicator.color = [UIColor whiteColor];
    activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [activityIndicator startAnimating];
    
    [spinnerView addSubview:activityIndicator];
    
    NSLayoutConstraint *myConstraint = [NSLayoutConstraint constraintWithItem:activityIndicator
                                                                    attribute:NSLayoutAttributeCenterX
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:spinnerView
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:1
                                                                     constant:0];
    [spinnerView addConstraint:myConstraint];
    
    myConstraint = [NSLayoutConstraint constraintWithItem:activityIndicator
                                                attribute:NSLayoutAttributeCenterY
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:spinnerView
                                                attribute:NSLayoutAttributeCenterY
                                               multiplier:1
                                                 constant:0];
    [spinnerView addConstraint:myConstraint];
    
    return spinnerView;
}

- (UITextField *)createTextFieldSubject {
    CGRect frameTextField = CGRectMake(10, 10, self.master.widthView - 60, 30);
    UITextField *textFieldSubject = [[UITextField alloc] initWithFrame:frameTextField];
    [textFieldSubject setPlaceholder: @"Objet"];
    [textFieldSubject setReturnKeyType:UIReturnKeyNext];
    textFieldSubject.delegate = self.master;
    return textFieldSubject;
}

- (UIButton *)createUrgentButton {
    CGRect frameTextField = CGRectMake(self.master.view.frame.size.width - 65, 7, 40, 30);
    UIButton *urgentButton = [[UIButton alloc] initWithFrame:frameTextField];
    [urgentButton setImage:[UIImage imageNamed:@"ico_priorite_gris"] forState:UIControlStateNormal];
    [urgentButton addTarget:self.master
                     action:@selector(setUrgent)
           forControlEvents:UIControlEventTouchUpInside];
    return urgentButton;
}

@end
