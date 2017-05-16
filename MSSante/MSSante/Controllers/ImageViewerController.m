//
//  ImageViewerController.m
//  MSSante
//
//  Created by Labinnovation on 14/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "ImageViewerController.h"

@interface ImageViewerController () {
    CGFloat zoomScale;
    BOOL zoomed;
    CGRect screenBounds;
    CGSize screenSize;
    CGFloat screenHeight;
    CGFloat screenWidth;
    UIInterfaceOrientation orientation;
}
@property (nonatomic, strong) UIImageView *imageView;
- (void)centerScrollViewContents;
- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer;
- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer;
@end

@implementation ImageViewerController
@synthesize scrollView;
@synthesize image;
@synthesize imageView;
@synthesize isComingFromNewMsg;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    DLog(@"init ImageViewerController");
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        zoomed = NO;
    }
    return self;
}

- (void)centerScrollViewContents {
    CGSize boundsSize = scrollView.bounds.size;
    CGRect contentsFrame = imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    imageView.frame = contentsFrame;
}


- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
    // 1
    CGPoint pointInView = [recognizer locationInView:imageView];
    
    // 2
    zoomed = NO;
    CGFloat newZoomScale;
    if (scrollView.zoomScale > scrollView.minimumZoomScale) {
        zoomed = YES;
    }
    
    if (zoomed) {
        newZoomScale = scrollView.minimumZoomScale;
        zoomed = NO;
    } else {
        newZoomScale = scrollView.maximumZoomScale;
        zoomed = YES;
    }
    
    
    // 3
    CGSize scrollViewSize = scrollView.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    // 4
    [scrollView zoomToRect:rectToZoomTo animated:YES];
}

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer {
    // Zoom out slightly, capping at the minimum zoom scale specified by the scroll view
    CGFloat newZoomScale = scrollView.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, scrollView.minimumZoomScale);
    [scrollView setZoomScale:newZoomScale animated:YES];
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that you want to zoom
    return imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so you need to re-center the contents
    [self centerScrollViewContents];
}

- (void)updateOrientation {
    screenBounds = [[UIScreen mainScreen] bounds];
    screenSize = screenBounds.size;
    orientation = [UIApplication sharedApplication].statusBarOrientation;
    //portrait
    if(orientation == 0 || orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        screenHeight = screenSize.height - 64;
        screenWidth = screenSize.width;
        
    } //landscape
    else if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        screenHeight = screenSize.width - 64;
        screenWidth = screenSize.height;
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (isComingFromNewMsg) {
            [scrollView setFrame:CGRectMake(0, 44, screenWidth, screenHeight)];
            [self centerScrollViewContents];
        }
    }
}

- (void)orientationChanged:(NSNotification*)notification {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self updateOrientation];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (isComingFromNewMsg) {
            [self updateOrientation];
        } else {
            [scrollView setFrame:CGRectMake(0, 44, 540, 576)];
        }
        
    }
    imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    [scrollView addSubview:imageView];
    
    // 2
    scrollView.contentSize = image.size;
    
    zoomScale = image.size.width / scrollView.frame.size.width;
    
    // 3
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [scrollView addGestureRecognizer:doubleTapRecognizer];
    
    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
    twoFingerTapRecognizer.numberOfTapsRequired = 1;
    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
    [scrollView addGestureRecognizer:twoFingerTapRecognizer];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (isComingFromNewMsg && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.navigationController.navigationBar setHidden:YES];
    }
    // 4
    CGRect scrollViewFrame = scrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    scrollView.minimumZoomScale = minScale;
    
    // 5
    scrollView.maximumZoomScale = 1.0f;
    scrollView.zoomScale = minScale;
    
    // 6
    [self centerScrollViewContents];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (IBAction)cancel:(id)sender {
    DLog(@"Annuler");
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (isComingFromNewMsg) {
            [self.navigationController.navigationBar setHidden:NO];
            [self.navigationController popViewControllerAnimated:YES];
            
        } else {
           [[NSNotificationCenter defaultCenter] postNotificationName:HIDE_IMAGE_VIEWER_NOTIF object:self]; 
        }
        
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
