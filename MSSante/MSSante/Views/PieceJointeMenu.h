//
//  PieceJointeMenu.h
//  MSSante
//
//  Created by Labinnovation on 09/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NouveauMessageViewController2;

@interface PieceJointeMenu : UIView 

@property (weak, nonatomic) IBOutlet UIView *addPhoto;
@property (weak, nonatomic) IBOutlet UIView *takePhoto;
- (void)assignViewController:(NouveauMessageViewController2*)controller;

@end
