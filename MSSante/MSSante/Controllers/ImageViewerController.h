//
//  ImageViewerController.h
//  MSSante
//
//  Created by Labinnovation on 14/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constant.h"

@interface ImageViewerController : UIViewController<UIScrollViewDelegate>
- (IBAction)cancel:(id)sender;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (assign, nonatomic) BOOL isComingFromNewMsg;
@end
