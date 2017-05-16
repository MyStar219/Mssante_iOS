//
//  WebViewController.h
//  MSSante
//
//  Created by Labinnovation on 03/09/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constant.h"

@interface WebViewController : UIViewController <UIWebViewDelegate>{
    NSURL *url;
    NSString *MIMEType;
    NSString *filePath;
}

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSString *MIMEType;
@property (strong, nonatomic) NSString *filePath;
@property (assign, nonatomic) BOOL isComingFromNewMsg;
- (IBAction)cancel:(id)sender;

@end
