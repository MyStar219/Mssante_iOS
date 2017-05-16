//
//  WebViewController.m
//  MSSante
//
//  Created by Labinnovation on 03/09/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "WebViewController.h"
#import "NSData+AES256.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "PasswordStore.h"

@interface WebViewController ()

@end

@implementation WebViewController

@synthesize url;
@synthesize MIMEType;
@synthesize filePath;
@synthesize isComingFromNewMsg;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURL *targetURL = [NSURL fileURLWithPath:filePath];
    NSData *content = [NSData dataWithContentsOfURL:targetURL];
    content = [content AES256DecryptWithKey:[[PasswordStore getInstance] getDbEncryptionKey]];
//    DLog(@"DataAfterDecryption %@",content);
    MIMEType = [self fileMIMEType:filePath];
    self.webView.delegate = self;
//    DLog(@"MIME %@",MIMEType);
    [self.webView loadData:content MIMEType:MIMEType textEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:@"/"]];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    [self.webView loadRequest:request];
	// Do any additional setup after loading the view.
    
}
//- (void) webViewDidFinishLoad:(UIWebView *)webView{
//    CGSize contentsize = self.webView.scrollView.contentSize;
//    CGSize viewSize = self.view.bounds.size;
//    
//    float rw = viewSize.width/contentsize.width;
//    [self.webView.scrollView setZoomScale:rw];
//    [self.webView.scrollView setMaximumZoomScale:rw];
//    [self.webView.scrollView setMinimumZoomScale:rw];
//}

-(void)viewWillAppear:(BOOL)animated {
    if (isComingFromNewMsg && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.navigationController.navigationBar setHidden:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (NSString*) fileMIMEType:(NSString*) file {
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)CFBridgingRetain([file pathExtension]), NULL);
    CFStringRef type = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    NSString *result = (NSString *)CFBridgingRelease(type);
    return result;
}
@end
