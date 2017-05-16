//
//  NouveauMessageDrawer.h
//  MSSante
//
//  Created by Labinnovation on 06/11/2014.
//  Copyright (c) 2014 Capgemini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NouveauMessageDrawer : NSObject

- (id)initWithMaster:(NouveauMessageViewController2 *)theMaster;
- (UIBarButtonItem *)createLeftButton;
- (UIBarButtonItem*)createSendButton;
- (UILabel *)createTitleLabel;
// - (UIActivityIndicatorView *)createActivityIndicator;
- (void)setupNotificationCenter ;
- (UIButton *)createPjButton ;
- (PieceJointeMenu *)createPjMenu;
- (UIView *)createSpinnerView;
- (UITextField *)createTextFieldSubject;
- (UIButton *)createUrgentButton;

@end
