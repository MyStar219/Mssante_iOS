//
//  HeaderMenuBarView.m
//  MSSante
//
//  Created by Labinnovation on 06/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "HeaderMenuBarView.h"

@implementation HeaderMenuBarView {
    UIImageView *deleteIcon;
    UILabel *deleteLabel;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setView:frame];
        
    }
    return self;
}

-(void)setView:(CGRect)frame{
    int width = frame.size.width;
    int height = frame.size.height;
    int deleteViewOffsetLeft;
    int folderViewOffsetLeft;
    int unreadViewOffsetLeft;
    
    self.deleteView = [[UIView alloc] initWithFrame:CGRectMake(width-height, 0, height, height)];
    deleteViewOffsetLeft = self.deleteView.frame.size.width;
    deleteIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_corbeille"]];
    CGRect frameDeleteIcon = deleteIcon.frame;
    frameDeleteIcon.origin.x += self.deleteView.frame.size.width/2-frameDeleteIcon.size.width/2;
    frameDeleteIcon.origin.y += 7;
    deleteIcon.frame = frameDeleteIcon;
    
    deleteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, deleteIcon.frame.size.height + 3, self.deleteView.frame.size.width, frame.size.height/2)];
    deleteLabel.text = @"Corbeille";
    [deleteLabel setTextColor:[UIColor whiteColor]];
    [deleteLabel setBackgroundColor:[UIColor clearColor]];
    [deleteLabel setFont:[UIFont systemFontOfSize:10]];
    deleteLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.deleteView addSubview:deleteLabel];
    [self.deleteView addSubview:deleteIcon];
    
    [self addSubview:self.deleteView];
    
    self.unreadView = [[UIView alloc] initWithFrame:CGRectMake(width-height-deleteViewOffsetLeft, 9, height, height)];
    unreadViewOffsetLeft = deleteViewOffsetLeft * 2;
    UIImageView* unreadIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_nonlus"]];
    CGRect frameUnreadIcon = unreadIcon.frame;
    frameUnreadIcon.origin.x += self.unreadView.frame.size.width/2-frameUnreadIcon.size.width/2;
    frameUnreadIcon.origin.y += 7;
    unreadIcon.frame = frameUnreadIcon;
    
    UILabel *unreadLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, unreadIcon.frame.size.height + 3, self.unreadView.frame.size.width, frame.size.height/2)];
    unreadLabel.text = @"Non lus";
    [unreadLabel setTextColor:[UIColor whiteColor]];
    [unreadLabel setBackgroundColor:[UIColor clearColor]];
    [unreadLabel setFont:[UIFont systemFontOfSize:10]];
    unreadLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.unreadView addSubview:unreadIcon];
    [self.unreadView addSubview:unreadLabel];
    
    [self addSubview:self.unreadView];
    
    
    self.folderView = [[UIView alloc] initWithFrame:CGRectMake(width-height-unreadViewOffsetLeft, 6, height, height)];
    folderViewOffsetLeft = deleteViewOffsetLeft * 3;
    UIImageView* folderIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_dossier"]];
    CGRect frameFolderIcon = folderIcon.frame;
    frameFolderIcon.origin.x += self.folderView.frame.size.width/2-frameFolderIcon.size.width/2;
    frameFolderIcon.origin.y += 7;
    folderIcon.frame = frameFolderIcon;
    
    UILabel *folderLabel = [[UILabel alloc] initWithFrame:CGRectMake(-5, folderIcon.frame.size.height + 3, self.folderView.frame.size.width + 10, frame.size.height/2)];
    folderLabel.text = @"Déplacer vers";
    [folderLabel setTextColor:[UIColor whiteColor]];
    [folderLabel setBackgroundColor:[UIColor clearColor]];
    [folderLabel setFont:[UIFont systemFontOfSize:10]];
    folderLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.folderView addSubview:folderIcon];
    [self.folderView addSubview:folderLabel];
    
    [self addSubview:self.folderView];
    
    self.followView = [[UIView alloc] initWithFrame:CGRectMake(width-height-folderViewOffsetLeft, 1, height, height)];
    UIImageView* followIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_suivre"]];
    CGRect frameFollowIcon = followIcon.frame;
    frameFollowIcon.origin.x += self.followView.frame.size.width/2-frameFollowIcon.size.width/2;
    frameFollowIcon.origin.y += 7;
    followIcon.frame = frameFollowIcon;
    
    UILabel *followLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, followIcon.frame.size.height + 3, self.followView.frame.size.width, frame.size.height/2)];
    followLabel.text = @"Suivre";
    [followLabel setTextColor:[UIColor whiteColor]];
    [followLabel setBackgroundColor:[UIColor clearColor]];
    [followLabel setFont:[UIFont systemFontOfSize:10]];
    followLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.followView addSubview:followIcon];
    [self.followView addSubview:followLabel];
    
    [self addSubview:self.followView];
    
    
    [self setBackgroundColor:[UIColor colorWithRed:0.1294117647 green:0.36862745098 blue:0.44705882352 alpha:1]];
    
    [self setHidden:YES];
}

-(void)hideForDraft:(BOOL)isHide{
    [self.followView setHidden:isHide];
    [self.folderView setHidden:isHide];
    [self.unreadView setHidden:isHide];
}

-(void)isOutbox:(BOOL)isOutbox {
    [deleteIcon removeFromSuperview];
    [deleteLabel removeFromSuperview];
    deleteIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_supprimer"]];
    CGRect frameDeleteIcon = deleteIcon.frame;
    frameDeleteIcon.origin.x += self.deleteView.frame.size.width/2-frameDeleteIcon.size.width/2;
    frameDeleteIcon.origin.y += 7;
    deleteIcon.frame = frameDeleteIcon;
    deleteLabel.text = @"Supprimer";
    [self.deleteView addSubview:deleteIcon];
    [self.deleteView addSubview:deleteLabel];
    [self.deleteView setNeedsDisplay];
}

-(void)setMasterViewController:(MasterViewController *)masterViewController{
    _masterViewController = masterViewController;
    UITapGestureRecognizer *deleteTap = [[UITapGestureRecognizer alloc] initWithTarget:_masterViewController action:@selector(deleteMsg:)];
    UITapGestureRecognizer *unreadTap = [[UITapGestureRecognizer alloc] initWithTarget:_masterViewController action:@selector(unreadMsg:)];
    UITapGestureRecognizer *folderTap = [[UITapGestureRecognizer alloc] initWithTarget:_masterViewController action:@selector(insertToFolder:)];
    UITapGestureRecognizer *followTap = [[UITapGestureRecognizer alloc] initWithTarget:_masterViewController action:@selector(followMsg:)];
    
    [self.deleteView addGestureRecognizer:deleteTap];
    [self.unreadView addGestureRecognizer:unreadTap];
    [self.folderView addGestureRecognizer:folderTap];
    [self.followView addGestureRecognizer:followTap];
}


-(void)setDetailViewController:(MessageDetailViewController *)detailViewController{
    _detailViewController = detailViewController;
    UITapGestureRecognizer *deleteTap = [[UITapGestureRecognizer alloc] initWithTarget:_detailViewController action:@selector(deleteMsg:)];
    UITapGestureRecognizer *unreadTap = [[UITapGestureRecognizer alloc] initWithTarget:_detailViewController action:@selector(unreadMsg:)];
    UITapGestureRecognizer *folderTap = [[UITapGestureRecognizer alloc] initWithTarget:_detailViewController action:@selector(insertToFolder:)];
    UITapGestureRecognizer *followTap = [[UITapGestureRecognizer alloc] initWithTarget:_detailViewController action:@selector(followMsg:)];
    
    [self.deleteView addGestureRecognizer:deleteTap];
    [self.unreadView addGestureRecognizer:unreadTap];
    [self.folderView addGestureRecognizer:folderTap];
    [self.followView addGestureRecognizer:followTap];
}

@end
