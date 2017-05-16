//
//  PieceJointeMenu.m
//  MSSante
//
//  Created by Labinnovation on 09/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "PieceJointeMenu.h"

@implementation PieceJointeMenu

@synthesize takePhoto, addPhoto;

- (id)initWithFrame:(CGRect)frame
{
//    self = [super initWithFrame:frame];
    self = [[[NSBundle mainBundle] loadNibNamed:@"PieceJointeMenu" owner:self options:nil] lastObject];
    [self setFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void)assignViewController:(NouveauMessageViewController2*)controller {
    UITapGestureRecognizer *addPhotoTap = [[UITapGestureRecognizer alloc] initWithTarget:controller action:@selector(addPhoto:)];
    UITapGestureRecognizer *takePhotoTap = [[UITapGestureRecognizer alloc] initWithTarget:controller action:@selector(takePhoto:)];
    [self.takePhoto addGestureRecognizer:takePhotoTap];
    [self.addPhoto addGestureRecognizer:addPhotoTap];
}
@end
