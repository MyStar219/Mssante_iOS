//
//  HeaderMenuCorbeilleView.m
//  MSSante
//
//  Created by Labinnovation on 09/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "HeaderMenuCorbeilleView.h"

@implementation HeaderMenuCorbeilleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        int width = self.frame.size.width;
        int height = self.frame.size.height;
        int viderViewOffsetLeft;
        int restoreViewOffsetLeft;
        
        self.viderCorbeilleView = [[UIView alloc] initWithFrame:CGRectMake(width-30-height, 5, height+30, height)];
        viderViewOffsetLeft = self.viderCorbeilleView.frame.size.width;
        UIImageView *viderIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_vider"]];
        CGRect frameViderIcon = viderIcon.frame;
        frameViderIcon.origin.x += self.viderCorbeilleView.frame.size.width/2-frameViderIcon.size.width/2;
        frameViderIcon.origin.y += 7;
        viderIcon.frame = frameViderIcon;
        
        UILabel *viderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, viderIcon.frame.size.height + 3, self.viderCorbeilleView.frame.size.width, self.frame.size.height/2)];
        viderLabel.text = @"Vider la corbeille";
        [viderLabel setTextColor:[UIColor whiteColor]];
        [viderLabel setBackgroundColor:[UIColor clearColor]];
        [viderLabel setFont:[UIFont systemFontOfSize:10]];
        viderLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.viderCorbeilleView addSubview:viderLabel];
        [self.viderCorbeilleView addSubview:viderIcon];
        
        [self addSubview:self.viderCorbeilleView];
        
        self.restoreView = [[UIView alloc] initWithFrame:CGRectMake(width-height-viderViewOffsetLeft, 4, height, height)];
        restoreViewOffsetLeft = viderViewOffsetLeft + self.restoreView.frame.size.width + 10;
        UIImageView* restoreIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_restaurer"]];
        CGRect frameRestoreIcon = restoreIcon.frame;
        frameRestoreIcon.origin.x += self.restoreView.frame.size.width/2-frameRestoreIcon.size.width/2;
        frameRestoreIcon.origin.y += 7;
        restoreIcon.frame = frameRestoreIcon;
        
        UILabel *restoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, restoreIcon.frame.size.height + 3, self.restoreView.frame.size.width, self.frame.size.height/2)];
        restoreLabel.text = @"Restaurer";
        [restoreLabel setTextColor:[UIColor whiteColor]];
        [restoreLabel setBackgroundColor:[UIColor clearColor]];
        [restoreLabel setFont:[UIFont systemFontOfSize:10]];
        restoreLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.restoreView addSubview:restoreIcon];
        [self.restoreView addSubview:restoreLabel];
        
        [self addSubview:self.restoreView];
        
        self.deleteView = [[UIView alloc] initWithFrame:CGRectMake(width-height-restoreViewOffsetLeft, 6, height, height)];
        UIImageView* folderIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_supprimer"]];
        CGRect frameFolderIcon = folderIcon.frame;
        frameFolderIcon.origin.x += self.deleteView.frame.size.width/2-frameFolderIcon.size.width/2;
        frameFolderIcon.origin.y += 7;
        folderIcon.frame = frameFolderIcon;
        
        UILabel *folderLabel = [[UILabel alloc] initWithFrame:CGRectMake(-5, folderIcon.frame.size.height + 3, self.deleteView.frame.size.width + 10, self.frame.size.height/2)];
        folderLabel.text = @"Supprimer";
        [folderLabel setTextColor:[UIColor whiteColor]];
        [folderLabel setBackgroundColor:[UIColor clearColor]];
        [folderLabel setFont:[UIFont systemFontOfSize:10]];
        folderLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.deleteView addSubview:folderIcon];
        [self.deleteView addSubview:folderLabel];
        
        [self addSubview:self.deleteView];
        
        
        [self setBackgroundColor:[UIColor colorWithRed:0.1294117647 green:0.36862745098 blue:0.44705882352 alpha:1]];
        
        [self setHidden:YES];
        
    }
    return self;
}

-(void)justVider:(BOOL)isHide{
    [self.deleteView setHidden:isHide];
    [self.restoreView setHidden:isHide];
}

-(void)setMasterViewController:(MasterViewController *)masterViewController{
    _masterViewController = masterViewController;
    UITapGestureRecognizer *deleteTap = [[UITapGestureRecognizer alloc] initWithTarget:_masterViewController action:@selector(definitivDeletMsg:)];
    UITapGestureRecognizer *viderTap = [[UITapGestureRecognizer alloc] initWithTarget:_masterViewController action:@selector(viderCorbeille:)];
    UITapGestureRecognizer *restoreTap = [[UITapGestureRecognizer alloc] initWithTarget:_masterViewController action:@selector(restoreMsg:)];
    
    [self.deleteView addGestureRecognizer:deleteTap];
    [self.viderCorbeilleView addGestureRecognizer:viderTap];
    [self.restoreView addGestureRecognizer:restoreTap];
}

@end
