//
//  MessageDetailViewController.m
//  MSSante
//
//  Created by Labinnovation on 14/10/13.
//  Copyright (c) 2013 Capgemini                            . All rights reserved.
//

#import "MessageDetailViewController.h"
#import "Attachment.h"
#import "Constant.h"
#import "UpdateMessagesInput.h"
#import "DAOFactory.h"
#import "Request.h"
#import "MessageDAO.h"
#import "MoveMessagesInput.h"
#import "PasswordStore.h"
#import "DownloadAttachmentInput.h"
#import "DownloadAttachmentResponse.h"
#import "Tools.h"
#import "NSData+AES256.h"
#import "ImageViewerController.h"
#import "WebViewController.h"
#import "ModificationDAO.h"
#import "SubjectCell.h"
#import "EmailCell.h"
#import "BodyCell.h"
#import "NSManagedObject+Clone.h"
#import "EmailTool.h"
#import "NPConverter.h"
#import "Message.h"
#import "AttachmentManager.h"

#define HORISONTAL_PADDING          15
#define MSG_INFO_CELL_LINE_HEIGHT   18
#define SEPRATOR_HEIGHT             1
#define MSG_OPTIONS_WIDTH           70
#define DEFAULT_CELL_HEIGHT         50
#define DEFAULT_EMAIL_HEIGHT        35
#define DEFAULT_ATTACHMENT_ROW_SIZE 60

#define OBJET_MSG                   @"Objet"
#define DE_MSG                      @"De"
#define A_MSG                       @"A"
#define CC_MSG                      @"Cc"
#define CCI_MSG                     @"Cci"
#define PJ_MSG                      @"Pièces jointes"

#define MAX_NUM_OF_CHARS_PER_LINE   25
#define MAX_NUM_OF_CHARS_PER_LINE_IPAD_PORTORAIT    40
#define MAX_NUM_OF_CHARS_PER_LINE_IPAD_LANDSCAPE    75
#define MORE_LABEL_WIDTH            200

#define kSectionSubject             0
#define kSectionEmails              1
#define kSectionAttachments         2
#define kSectionBody                3


#define kCellFrom                   0
#define kCellTo                     1
#define kCellCc                     2
#define kCellCci                    3
#define kCellPJ                     4

#define NUMBER_OF_SECTIONS          4
#define IS_IOS_7_OR_EARLIER    ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
@interface MessageDetailViewController (){
NSAttributedString *objectAttributedString;
NSString *objectPlainString;

NSAttributedString *fromAttributedString;
NSString *fromPlainString;

NSAttributedString *toAttributedString;
NSString *toPlainString;

NSAttributedString *ccAttributedString;
NSString *ccPlainString;

NSAttributedString *cciAttributedString;
NSString *cciPlainString;

NSAttributedString *pjAttributedString;
NSString *pjPlainString;

UIFont *cellFont;
CGRect screenBounds;
CGSize screenSize;
CGFloat screenHeight;
CGFloat screenWidth;
UIInterfaceOrientation orientation;

UIView *seprator;
CGRect sepratorFrame;

NSMutableArray *toEmails;
NSMutableArray *ccEmails;
NSMutableArray *fromEmails;
NSMutableArray *fromEmailsURI;
NSMutableArray *cciEmails;
NSMutableArray *toEmailsStrings;
NSMutableArray *ccEmailsStrings;
NSMutableArray *fromEmailsStrings;
NSMutableArray *cciEmailsStrings;
NSString *from;
NSString *to;
NSString *cc;
NSString *cci;
BOOL showDetails;

CGRect moreLabelFrame;
UILabel *moreLabel;

BOOL showAttachments;

NSString *body;

UIButton *showAttachmentsList;

NSMutableArray *attachments;
UILabel *dateLabel;

NSString *messageDateString;

UIButton *replyButton;

BOOL showReplyMenu;

UIView *replyMenu;
CGRect replyMenuFrame;

UIView *replyMenuButtonView;
UIView *replyToAllMenuButtonView;
UIView *forwardMenuButtonView;

Attachment *currentAttachment;

UIView *loadingView;

UIView *messageOptionsMenu;

CGRect messageOptionsMenuFrame;

NSAttributedString *details;
NSAttributedString *masquerLesDetails;

CGFloat cellWidth;

CGRect dateLabelFrame;
CGRect replyButtonFrame;
CGRect showAttachmentsListFrame;

UIView *restoreView;
UIView *deleteView;
UIView *trashView;
UIView *unreadView;
UIView *moveView;
UIView *flagView;

NSUInteger maxCharsPerLine;

CGRect noEmailsLabelFrame;
BOOL fromIsFullyShown;
BOOL toIsFullyShown;
UIFont *bodyFont;
    CGFloat bodyHeight;}
@property (nonatomic, retain) NSAttributedString *objectAttributedString;
@property (nonatomic, retain) NSString *objectPlainString;
@property (nonatomic, retain) NSAttributedString *fromAttributedString;
@property (nonatomic, retain) NSString *fromPlainString;
@property (nonatomic, retain) NSAttributedString *toAttributedString;
@property (nonatomic, retain) NSString *toPlainString;
@property (nonatomic, retain) NSAttributedString *ccAttributedString;
@property (nonatomic, retain) NSString *ccPlainString;
@property (nonatomic, retain) NSAttributedString *cciAttributedString;
@property (nonatomic, retain) NSString *cciPlainString;
@property (nonatomic, retain) NSAttributedString *pjAttributedString;
@property (nonatomic, retain) NSString *pjPlainString;
@property (nonatomic, retain) UIFont *cellFont;
@property (nonatomic, assign) CGRect screenBounds;
@property (nonatomic, assign) CGSize screenSize;
@property (nonatomic, assign) CGFloat screenHeight;
@property (nonatomic, assign) CGFloat screenWidth;
@property (nonatomic, assign) UIInterfaceOrientation orientation;
@property (nonatomic, retain) IBOutlet UIView *seprator;
@property (nonatomic, assign) CGRect sepratorFrame;
@property (nonatomic, retain) NSMutableArray *toEmails;
@property (nonatomic, retain) NSMutableArray *ccEmails;
@property (nonatomic, retain) NSMutableArray *fromEmails;
@property (nonatomic, retain) NSMutableArray *cciEmails;
@property (nonatomic, retain) NSMutableArray *toEmailsStrings;
@property (nonatomic, retain) NSMutableArray *ccEmailsStrings;
@property (nonatomic, retain) NSMutableArray *fromEmailsStrings;
@property (nonatomic, retain) NSMutableArray *cciEmailsStrings;
@property (nonatomic, retain) NSString *from;
@property (nonatomic, retain) NSString *to;
@property (nonatomic, retain) NSString *cc;
@property (nonatomic, retain) NSString *cci;
@property (nonatomic, assign, getter=isShowDetails) BOOL showDetails;
@property (nonatomic, assign) CGRect moreLabelFrame;
@property (nonatomic, retain) IBOutlet UILabel *moreLabel;
@property (nonatomic, assign, getter=isShowAttachments) BOOL showAttachments;
@property (nonatomic, retain) NSString *body;
@property (nonatomic, retain) IBOutlet UIButton *showAttachmentsList;
@property (nonatomic, retain) NSArray *attachments;
@property (nonatomic, retain) IBOutlet UILabel *dateLabel;
@property (nonatomic, retain) NSString *messageDateString;
@property (nonatomic, retain) IBOutlet UIButton *replyButton;
@property (nonatomic, assign, getter=isShowReplyMenu) BOOL showReplyMenu;
@property (nonatomic, retain) IBOutlet UIView *replyMenu;
@property (nonatomic, assign) CGRect replyMenuFrame;
@property (nonatomic, retain) IBOutlet UIView *replyMenuButtonView;
@property (nonatomic, retain) IBOutlet UIView *replyToAllMenuButtonView;
@property (nonatomic, retain) IBOutlet UIView *forwardMenuButtonView;
@property (nonatomic, retain) Attachment *currentAttachment;
@property (nonatomic, retain) IBOutlet UIView *loadingView;
@property (nonatomic, retain) IBOutlet UIView *messageOptionsMenu;
@property (nonatomic, assign) CGRect messageOptionsMenuFrame;
@property (nonatomic, retain) NSAttributedString *details;
@property (nonatomic, retain) NSAttributedString *masquerLesDetails;
@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, assign) CGRect dateLabelFrame;
@property (nonatomic, assign) CGRect replyButtonFrame;
@property (nonatomic, assign) CGRect showAttachmentsListFrame;
@property (nonatomic, retain) IBOutlet UIView *restoreView;
@property (nonatomic, retain) IBOutlet UIView *deleteView;
@property (nonatomic, retain) IBOutlet UIView *trashView;
@property (nonatomic, retain) IBOutlet UIView *unreadView;
@property (nonatomic, retain) IBOutlet UIView *moveView;
@property (nonatomic, retain) IBOutlet UIView *flagView;
@property (nonatomic, assign) NSUInteger maxCharsPerLine;
@property (nonatomic, assign) CGRect noEmailsLabelFrame;
@property (nonatomic, assign, getter=isFromIsFullyShown) BOOL fromIsFullyShown;
@property (nonatomic, assign, getter=isToIsFullyShown) BOOL toIsFullyShown;
@property (nonatomic, retain) UIFont *bodyFont;
@property (nonatomic, assign) CGFloat bodyHeight;

@property (nonatomic, retain) NPMessage *npMessage;
@end

@implementation MessageDetailViewController {

}

@synthesize objectAttributedString;
@synthesize objectPlainString;
@synthesize fromAttributedString;
@synthesize fromPlainString;
@synthesize toAttributedString;
@synthesize toPlainString;
@synthesize ccAttributedString;
@synthesize ccPlainString;
@synthesize cciAttributedString;
@synthesize cciPlainString;
@synthesize pjAttributedString;
@synthesize pjPlainString;
@synthesize cellFont;
@synthesize screenBounds;
@synthesize screenSize;
@synthesize screenHeight;
@synthesize screenWidth;
@synthesize orientation;
@synthesize seprator;
@synthesize sepratorFrame;
@synthesize toEmails;
@synthesize ccEmails;
@synthesize fromEmails;
@synthesize cciEmails;
@synthesize toEmailsStrings;
@synthesize ccEmailsStrings;
@synthesize fromEmailsStrings;
@synthesize cciEmailsStrings;
@synthesize from;
@synthesize to;
@synthesize cc;
@synthesize cci;
@synthesize showDetails;
@synthesize moreLabelFrame;
@synthesize moreLabel;
@synthesize showAttachments;
@synthesize body;
@synthesize showAttachmentsList;
@synthesize attachments;
@synthesize dateLabel;
@synthesize messageDateString;
@synthesize replyButton;
@synthesize showReplyMenu;
@synthesize replyMenu;
@synthesize replyMenuFrame;
@synthesize replyMenuButtonView;
@synthesize replyToAllMenuButtonView;
@synthesize forwardMenuButtonView;
@synthesize currentAttachment;
@synthesize loadingView;
@synthesize messageOptionsMenu;
@synthesize messageOptionsMenuFrame;
@synthesize details;
@synthesize masquerLesDetails;
@synthesize cellWidth;
@synthesize dateLabelFrame;
@synthesize replyButtonFrame;
@synthesize showAttachmentsListFrame;
@synthesize restoreView;
@synthesize deleteView;
@synthesize trashView;
@synthesize unreadView;
@synthesize moveView;
@synthesize flagView;
@synthesize maxCharsPerLine;
@synthesize noEmailsLabelFrame;
@synthesize fromIsFullyShown;
@synthesize toIsFullyShown;
@synthesize bodyFont;
@synthesize bodyHeight;
@synthesize delegate;
@synthesize message;
@synthesize npMessage;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    DLog(@"viewDidLoad MessageDetailViewController");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideImageViewer:) name:HIDE_IMAGE_VIEWER_NOTIF object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    
    self.tableView.separatorColor = [UIColor whiteColor];
    
    screenBounds = [[UIScreen mainScreen] bounds];
    screenSize = screenBounds.size;
    screenWidth = screenSize.width;
    screenHeight = screenSize.height - 64;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self updateOrientation];
    } else {
        cellWidth = screenWidth;
        maxCharsPerLine = MAX_NUM_OF_CHARS_PER_LINE;
    }
    
    
    sepratorFrame = CGRectMake(0, 0, cellWidth, SEPRATOR_HEIGHT);
    seprator = [[UIView alloc] initWithFrame:sepratorFrame];
    [seprator setBackgroundColor:[UIColor lightGrayColor]];
    showDetails = NO;
    showAttachments = NO;
    showReplyMenu = NO;
    
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    details = [[NSAttributedString alloc] initWithString:@"Détails" attributes:underlineAttribute];
    masquerLesDetails = [[NSAttributedString alloc] initWithString:@"Masquer les détails" attributes:underlineAttribute];
    
    moreLabelFrame = CGRectMake(HORISONTAL_PADDING, DEFAULT_EMAIL_HEIGHT, MORE_LABEL_WIDTH, DEFAULT_EMAIL_HEIGHT - 1);
    moreLabel = [[UILabel alloc] initWithFrame:moreLabelFrame];
    [moreLabel setUserInteractionEnabled:YES];
    [moreLabel setTextColor:[UIColor colorWithRed:0.1294117647 green:0.36862745098 blue:0.44705882352 alpha:1]];
    
    UITapGestureRecognizer *moreLabelGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleDetails:)];
    [moreLabel addGestureRecognizer:moreLabelGesture];
    
    showAttachmentsListFrame = CGRectMake(cellWidth - 45, 5, 35, 20);
    showAttachmentsList = [[UIButton alloc] initWithFrame:showAttachmentsListFrame];
    [showAttachmentsList setBackgroundImage:[UIImage imageNamed:@"fleche_bas"] forState:UIControlStateNormal];
    [showAttachmentsList addTarget:self action:@selector(toggleAttachments:) forControlEvents:UIControlEventTouchDown];
    
    [self.tableView setAllowsSelection:YES];
    
    [self refreshDateAndReplyButton];
    
    [dateLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    [dateLabel setTextAlignment:NSTextAlignmentRight];
    [dateLabel setNumberOfLines:2];
    [dateLabel setTextColor:[UIColor lightGrayColor]];
    [dateLabel setBackgroundColor:[UIColor clearColor]];
    
    
    
    
    [replyButton setBackgroundImage:[UIImage imageNamed:@"fleche_repondreA_petit"] forState:UIControlStateNormal];
    [replyButton addTarget:self action:@selector(toggleReplyMenu:) forControlEvents:UIControlEventTouchDown];
    
    if (BOITE_D_ENVOI_ID_FOLDER == [message.folderId intValue]){
        [replyButton setHidden:YES];
    } else {
        [replyButton setHidden:NO];
    }
    
    replyMenuFrame = CGRectMake((cellWidth / 2) - 160, screenHeight - 150, 320, 150);
    [self generateReplyMenu];
    
    [self.view addSubview:dateLabel];
    [self.view addSubview:replyButton];
    
    messageOptionsMenuFrame = CGRectMake(0, 0, cellWidth, 60);
    [self generateMessageOptionsMenu];
    [self.view addSubview:messageOptionsMenu];
    
    UIImage *buttonImage = [UIImage imageNamed:@"bouton_palette_basBleu"];
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aButton setImage:buttonImage forState:UIControlStateNormal];
    aButton.frame = CGRectMake(0,0,50,50);
    [aButton addTarget:self action:@selector(openBarMenu:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithCustomView:aButton];
    self.navigationItem.rightBarButtonItem = menuButton;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self.navigationItem setHidesBackButton:YES];
        UIImage *buttonImageRight = [UIImage imageNamed:@"bouton_retour"];
        UIButton *bButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [bButton setImage:buttonImageRight forState:UIControlStateNormal];
        bButton.frame = CGRectMake(0,0,50,35);
        [bButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *shiftButton = [[UIBarButtonItem alloc] initWithCustomView:bButton];
        self.navigationItem.leftBarButtonItem = shiftButton;
    }
    
    noEmailsLabelFrame = CGRectMake(0, 0, cellWidth, screenHeight);
    _noEmailsLabel = [[UILabel alloc] initWithFrame:noEmailsLabelFrame];
    [_noEmailsLabel setText:@"Aucun mail sélectionné"];
    [_noEmailsLabel setTextColor:[UIColor blackColor]];
    [_noEmailsLabel setBackgroundColor:[UIColor whiteColor]];
    [_noEmailsLabel setTextAlignment:NSTextAlignmentCenter];
    [_noEmailsLabel setHidden:YES];
    
    [self.view addSubview:_noEmailsLabel];
    
    loadingView = [[UIView alloc] initWithFrame: CGRectMake (0, 0, cellWidth, screenHeight)];
    [loadingView setBackgroundColor:[UIColor blackColor]];
    [loadingView setAlpha:0.5];
    [loadingView setHidden:YES];
    [self.view addSubview:loadingView];
    UIActivityIndicatorView *activityIndicator;
    activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] ;
    activityIndicator.frame = CGRectMake(0.0, 0.0, 20,20);
    activityIndicator.center = loadingView.center;
    activityIndicator.color = [UIColor whiteColor];
    [activityIndicator startAnimating];
    [loadingView addSubview:activityIndicator];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [_noEmailsLabel setHidden:NO];
    }
    
    if (message){
        npMessage = [NPConverter convertMessage:message];
        AttachmentManager *attachmentManager = [[AttachmentManager alloc] init];
        attachments = [attachmentManager getAttachementsByIdMessage:npMessage.messageId];
    }
    
    DLog(@"maxNumberOfchars %d", maxCharsPerLine);
    [self configureView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)refreshDateAndReplyButton {
    CGSize maxSize = CGSizeMake(cellWidth - 2 * HORISONTAL_PADDING, CGFLOAT_MAX);
    CGFloat subjectCellHeihgt;
    if(IS_IOS_7_OR_EARLIER){
             subjectCellHeihgt = [objectPlainString sizeWithFont:cellFont constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping].height + 2 * HORISONTAL_PADDING + 3;
    }else{  
    //@TD  POUR IOS 8
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attrDict = [NSDictionary dictionaryWithObjectsAndKeys:cellFont,NSFontAttributeName,paragraphStyle,NSParagraphStyleAttributeName,nil];
    CGRect labelRect = [objectPlainString boundingRectWithSize:(CGSize){maxSize.width, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin attributes:attrDict context:nil];
    CGSize size = labelRect.size;
    CGFloat height = ceilf(size.height);
     subjectCellHeihgt=height + 2 * HORISONTAL_PADDING + 3 ;
    }
    
    dateLabelFrame = CGRectMake(cellWidth - 80, subjectCellHeihgt + 10, 70, 30);
    if (dateLabel == nil) {
        dateLabel = [[UILabel alloc] initWithFrame:dateLabelFrame];
    } else {
        [dateLabel setFrame:dateLabelFrame];
    }
    
    if (messageDateString.length > 0) {
        [dateLabel setText:messageDateString];
    }
    
    replyButtonFrame = CGRectMake(cellWidth - 60, subjectCellHeihgt + dateLabelFrame.size.height + 20, 50, 50);
    if (replyButton == nil) {
        replyButton = [[UIButton alloc] initWithFrame:replyButtonFrame];
    } else {
        [replyButton setFrame:replyButtonFrame];
    }
}

-(void)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (bodyHeight > 0) {
        [self.tableView reloadData];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    DLog(@"didReceiveMemoryWarning");
}


- (void)orientationChanged:(NSNotification*)notification {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self updateOrientation];
        [self.tableView reloadData];
    }
}
- (void)updateOrientation {
    screenBounds = [[UIScreen mainScreen] bounds];
    screenSize = screenBounds.size;
    orientation = [UIApplication sharedApplication].statusBarOrientation;
    if(IS_IOS_7_OR_EARLIER){
        //portrait
        if(orientation == 0 || orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
            screenHeight = screenSize.height - 64;
            screenWidth = screenSize.width;
            
        } //landscape
        else if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
            screenHeight = screenSize.width - 64;
            screenWidth = screenSize.height;
        }
    }else {
        screenHeight = screenSize.height - 64;
        screenWidth = screenSize.width;
        
    }

    
    cellWidth = screenWidth - 320;
    
    if (cellWidth == 448) {
        maxCharsPerLine = MAX_NUM_OF_CHARS_PER_LINE_IPAD_PORTORAIT;
    } else if(cellWidth == 704) {
        maxCharsPerLine = MAX_NUM_OF_CHARS_PER_LINE_IPAD_LANDSCAPE;
    } else {
        maxCharsPerLine = MAX_NUM_OF_CHARS_PER_LINE;
    }
    
    showAttachmentsListFrame.origin.x = cellWidth - 45;
    showAttachmentsList.frame = showAttachmentsListFrame;
    
    dateLabelFrame.origin.x = cellWidth - 80;
    dateLabel.frame = dateLabelFrame;
    
    replyButtonFrame.origin.x = cellWidth - 60;
    replyButton.frame = replyButtonFrame;
    
    sepratorFrame.size.width = cellWidth;
    seprator.frame = sepratorFrame;
    
    CGRect loadingFrame = loadingView.frame;
    loadingFrame.size.width = cellWidth;
    loadingFrame.size.height = screenHeight;
    [loadingView setFrame:loadingFrame];
    
    
    [_noEmailsLabel setFrame:loadingFrame];
    
    replyMenuFrame.origin.x = cellWidth/2 - 160;
    replyMenuFrame.origin.y = screenHeight - 150;
    [replyMenu setFrame:replyMenuFrame];
    
    messageOptionsMenuFrame.size.width = cellWidth;
    [self generateMessageOptionsMenu];
    //    [self.view addSubview:messageOptionsMenu];
    
    DLog(@"screenWidth %f",screenWidth);
    DLog(@"screenHeight %f",screenHeight);
    DLog(@"cellWidth %f",cellWidth);
    
    [self refreshDateAndReplyButton];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return NUMBER_OF_SECTIONS;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGSize maxSize = CGSizeMake(cellWidth - 2 * HORISONTAL_PADDING, CGFLOAT_MAX);
    CGFloat height = 0;
    CGFloat labelHeight;
    CGSize labelSize;
    NSString *cellString = nil;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attrDict = [NSDictionary dictionaryWithObjectsAndKeys:cellFont,NSFontAttributeName,paragraphStyle,NSParagraphStyleAttributeName,nil];
    CGRect labelRect = [objectPlainString boundingRectWithSize:(CGSize){maxSize.width, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin attributes:attrDict context:nil];
    CGSize size = labelRect.size;
    CGFloat heightCell = ceilf(size.height);
    switch (indexPath.section) {
        case kSectionSubject:
            if (IS_IOS_7_OR_EARLIER){
            labelSize = [objectPlainString sizeWithFont:cellFont constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
            labelHeight = labelSize.height;
            //int lines = labelHeight/cellFont.lineHeight;
            }else{
                          labelHeight=heightCell;
            }
  
            
            height = labelHeight + 2 * HORISONTAL_PADDING + 3;
            break;
        case kSectionEmails:
            switch (indexPath.row) {
                case kCellFrom:
                    cellString = fromPlainString;
                    break;
                case kCellTo:
                    cellString = toPlainString;
                    break;
                case kCellCc:
                    if (cc.length > 0) {
                        cellString = ccPlainString;
                    }
                    break;
                case kCellCci:
                    if (cci.length > 0) {
                        cellString = cciPlainString;
                    }
                    break;
                case kCellPJ:
                    cellString = pjPlainString;
                    break;
            }
            maxSize.width -= MSG_OPTIONS_WIDTH;
            if(IS_IOS_7_OR_EARLIER){
                labelSize = [cellString sizeWithFont:cellFont constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
                labelHeight = labelSize.height;
            }else{
                CGRect labelRect = [cellString boundingRectWithSize:(CGSize){maxSize.width, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin attributes:attrDict context:nil];
                CGSize size = labelRect.size;
                CGFloat heightCell = ceilf(size.height);
                labelHeight=heightCell;
            }
            height = 0;
            
            if (showDetails) {
                if (labelHeight > 0 && cellString.length > 0) {
                    height = labelHeight + 10;
                }
                
                if (indexPath.row == kCellFrom) {
                    DLog(@"height %f", height);
                }
                
                if ((hasCCi && _showCci && indexPath.row == kCellCci) || (!hasCCi && hasCC && indexPath.row == kCellCc) || (!hasCCi && !hasCC && indexPath.row == kCellTo)) {
                    height += DEFAULT_EMAIL_HEIGHT;
                }
                
                if (hasAttachments && indexPath.row == kCellPJ) {
                    height = DEFAULT_EMAIL_HEIGHT;
                }
            } else {
                if (indexPath.row == kCellFrom) {
                    fromIsFullyShown = NO;
                    if (labelHeight <= DEFAULT_EMAIL_HEIGHT) {
                        fromIsFullyShown = YES;
                    }
                } else if (indexPath.row == kCellTo) {
                    toIsFullyShown = NO;
                    if (labelHeight <= DEFAULT_EMAIL_HEIGHT) {
                        toIsFullyShown = YES;
                    }
                }
                
                if (indexPath.row == kCellFrom || (indexPath.row == kCellPJ && hasAttachments)) {
                    height = DEFAULT_EMAIL_HEIGHT;
                } else if(indexPath.row == kCellTo) {
                    height = DEFAULT_EMAIL_HEIGHT * 2;
                } else {
                    height = 0;
                }
            }
            
            break;
        case kSectionAttachments:
            height = 0;
            if (showAttachments) {
                height = 60;
            }
            break;
            
        case kSectionBody:
            if (YES) {
                
                CGFloat objetlabelHeight;
                if(IS_IOS_7_OR_EARLIER){
                CGSize objetLabelSize = [objectPlainString sizeWithFont:cellFont constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
                 objetlabelHeight = objetLabelSize.height;
                }else{
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
                paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                NSDictionary *attrDict = [NSDictionary dictionaryWithObjectsAndKeys:cellFont,NSFontAttributeName,paragraphStyle,NSParagraphStyleAttributeName,nil];
                CGRect labelRect = [objectPlainString boundingRectWithSize:(CGSize){maxSize.width, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin attributes:attrDict context:nil];
                CGSize size = labelRect.size;
                CGFloat heightCell = ceilf(size.height);
                 objetlabelHeight = heightCell;
                }
                height = self.tableView.frame.size.height - (objetlabelHeight + 2 * HORISONTAL_PADDING + 2) - (DEFAULT_EMAIL_HEIGHT * 3);
                
                if (hasAttachments) {
                    height -= DEFAULT_EMAIL_HEIGHT;
                }
                
                if (showAttachments) {
                    height -= numberOfAttachments * DEFAULT_ATTACHMENT_ROW_SIZE;
                }
                
                
                if (bodyHeight > 0) {
                    labelHeight = bodyHeight;
                } else {
                    if(IS_IOS_7_OR_EARLIER){
                        labelSize = [body sizeWithFont:bodyFont constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
                        labelHeight = labelSize.height;
                    }else{
                    NSDictionary *attrDict = [NSDictionary dictionaryWithObjectsAndKeys:bodyFont,NSFontAttributeName,paragraphStyle,NSParagraphStyleAttributeName,nil];
                    CGRect labelRect = [body boundingRectWithSize:(CGSize){maxSize.width, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin attributes:attrDict context:nil];
                    CGSize size = labelRect.size;
                    CGFloat heightCell = ceilf(size.height);

                    labelHeight=heightCell;
                    }
                }
                
//                DLog(@"labelHeight %f ",labelHeight);
//                labelHeight = [self textViewHeightForString:body andWidth:maxSize.width];
//                labelHeight = bodyHeight;
                
//                DLog(@"labelHeight %f ",labelHeight);
                if (labelHeight > height) {
                    height = labelHeight;
                    
                    //Fix different line height between UITextView and sizeWithFont lineHeight
//                    CGFloat lineCount = labelSize.height / bodyFont.lineHeight;
//                    CGFloat additional = lineCount * 1.1;
//                    
//                    height += additional;
                }
                
                
                height += 2 * HORISONTAL_PADDING;
//                DLog(@"maxSize %f",maxSize.width);
//                DLog(@"labelHeight %f",labelHeight);
//                DLog(@"labelSize %f",labelSize.width);
//                DLog(@"height %f",height);
            }
            
    }
    
    //    DLog(@" height %f section %d row %d", height, indexPath.section, indexPath.row);
    
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    int num = 1;
    if (section == 1) {
        num = 5;
    } else if (section == 2) {
        num = numberOfAttachments;
    }
    
    
    //    DLog(@"numberOfRowsInSection %d in section %d",num, section);
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifierSubject = @"subjectCell";
    static NSString *CellIdentifierEmail = @"emailCell";
    static NSString *CellIdentifierAttachment = @"AttachmentCell";
    static NSString *CellIdentifierBody = @"bodyCell";
    
    UITableViewCell* cell = nil;
    
    UIView *contentSubview = nil;
    
    CGFloat labelWidth;
    CGFloat height = 0;
    NSAttributedString *cellString = nil;
    CGRect cellFrame;
    SubjectCell *subjectCell;
    
    EmailCell *emailCell;
    
    BodyCell *bodyCell;
    
    switch (indexPath.section) {
        case kSectionSubject:
            subjectCell = (SubjectCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifierSubject];
            if (subjectCell == nil) {
                subjectCell = [[SubjectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierSubject];
            }
    
            cellFrame = CGRectMake(subjectCell.frame.origin.x, subjectCell.frame.origin.y, cellWidth, [self tableView:tableView heightForRowAtIndexPath:indexPath]);
            subjectCell.frame = cellFrame;
            sepratorFrame.origin.y = subjectCell.frame.size.height - 2;
            subjectCell.subjectLabel.frame = CGRectMake(HORISONTAL_PADDING, 0, subjectCell.frame.size.width - 2 * HORISONTAL_PADDING, subjectCell.frame.size.height);
            if (objectAttributedString) {
                subjectCell.subjectLabel.attributedText = objectAttributedString;
            }
            
            subjectCell.bottomSeparator.frame = sepratorFrame;
            
            subjectCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return  subjectCell;

        case kSectionEmails:
            emailCell = (EmailCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifierEmail];
            if (emailCell == nil) {
                emailCell = [[EmailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierEmail];
            }
            
            cellFrame = CGRectMake(emailCell.frame.origin.x, emailCell.frame.origin.y, cellWidth, [self tableView:tableView heightForRowAtIndexPath:indexPath]);
            emailCell.frame = cellFrame;
            
            labelWidth = emailCell.frame.size.width - 2 * HORISONTAL_PADDING - MSG_OPTIONS_WIDTH;
            height = DEFAULT_EMAIL_HEIGHT ;
            moreLabelFrame.size.width = labelWidth;
            
            switch (indexPath.row) {
                case kCellFrom:
                    cellString = fromAttributedString;
                    break;
                case kCellTo:
                    cellString = toAttributedString;
                    break;
                case kCellCc:
                    cellString = ccAttributedString;
                    break;
                case kCellCci:
                    cellString = cciAttributedString;
                    break;
                case kCellPJ:
                    cellString = pjAttributedString;
                    break;
            }
            
            if (showDetails) {
                height = emailCell.frame.size.height;
                if ((hasCCi && _showCci && indexPath.row == kCellCci) || (!hasCCi && hasCC && indexPath.row == kCellCc) || (!hasCCi && !hasCC && indexPath.row == kCellTo)) {
                    [moreLabel setAttributedText:masquerLesDetails];
                    height = emailCell.frame.size.height - DEFAULT_EMAIL_HEIGHT;
                    moreLabelFrame.origin.y = height;
                    moreLabel.frame = moreLabelFrame;
                    [emailCell addMoreLabelToCell:moreLabel];
                }
            } else {
                height = DEFAULT_EMAIL_HEIGHT;
                if (indexPath.row == kCellTo) {
                    moreLabelFrame.origin.y = height ;
                    moreLabel.frame = moreLabelFrame;
                    if (!toIsFullyShown || !fromIsFullyShown || hasCC || (hasCCi && _showCci)) {
                        moreLabel.attributedText = details;
                    } else {
                        moreLabel.attributedText = nil;
                    }
                    [emailCell addMoreLabelToCell:moreLabel];
                } else if (indexPath.row == kCellCc || indexPath.row == kCellCci) {
                    height = 0;
                }
            }
            
            if (!hasAttachments && indexPath.row == kCellPJ) {
                height = 0;
            }
            if ((!showDetails && (indexPath.row != 2 && indexPath.row != 3)) || showDetails) {
                [emailCell.emailLabel setFrame:CGRectMake(HORISONTAL_PADDING, 0, labelWidth, height)];
                emailCell.emailLabel.attributedText = cellString;
            }
            
            if (indexPath.row == 4 && hasAttachments) {
                if (showAttachments) {
                    [showAttachmentsList setBackgroundImage:[UIImage imageNamed:@"fleche_haut"] forState:UIControlStateNormal];
                } else {
                    [showAttachmentsList setBackgroundImage:[UIImage imageNamed:@"fleche_bas"] forState:UIControlStateNormal];
                }
                [emailCell addToggleAttachmentsToCell:showAttachmentsList];
            }
            
            emailCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return emailCell;
        case kSectionAttachments:
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierAttachment];
                cellFrame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cellWidth, [self tableView:tableView heightForRowAtIndexPath:indexPath]);
                [cell setFrame:cellFrame];
            } else {
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierAttachment forIndexPath:indexPath];
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierAttachment];
                }
            }
            
            cell.contentView.backgroundColor = [UIColor lightGrayColor];
            
            [cell.contentView setUserInteractionEnabled:YES];
            
            if (attachments.count >0) {
                Attachment *attachment = attachments[indexPath.row];
                NSMutableString* textLabel = [NSMutableString stringWithFormat:@"%@",attachment.fileName ];
                if (attachment.size.intValue <= 0) {
                    NSString* filePath = [Tools getAttachmentFilePath:attachment.fileName];
                    
                    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
                    if (fileExists) {
                        NSURL *url = [NSURL fileURLWithPath:filePath];
                        NSData *content = [NSData dataWithContentsOfURL:url];
                        DLog(@"content.length %d",content.length);
                        if (content.length > 0) {
                            [attachment setSize:[NSNumber numberWithInt:ceil(content.length/1024) ]];
                        }
                    
                    }
                }
                
                if (attachment.size.intValue > 0) {
                    [textLabel appendFormat:@" - %dK",[attachment.size intValue]];
                }
                
                [cell.textLabel setText:textLabel];
                [cell.imageView setImage:[UIImage imageNamed:@"img_fichierjoint"]];
                
                cell.textLabel.font = [UIFont systemFontOfSize:14];
                cell.textLabel.textColor = [UIColor colorWithRed:0.1294117647 green:0.36862745098 blue:0.44705882352 alpha:1];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                [cell.imageView setBackgroundColor:[UIColor clearColor]];
                [cell.textLabel setBackgroundColor:[UIColor clearColor]];
            }
            
            break;
        case kSectionBody:
            
            bodyCell = (BodyCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifierBody];
            if (bodyCell == nil) {
                bodyCell = [[BodyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierBody];
            }
            
            cellFrame = CGRectMake(bodyCell.frame.origin.x, bodyCell.frame.origin.y, cellWidth, [self tableView:tableView heightForRowAtIndexPath:indexPath]);
            bodyCell.frame = cellFrame;

            bodyCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            CGFloat _labelWidth = bodyCell.frame.size.width - 2 * HORISONTAL_PADDING;
            CGFloat _height = bodyCell.frame.size.height;
            
            CGSize maxSize = CGSizeMake(cellWidth - 2 * HORISONTAL_PADDING, CGFLOAT_MAX);
//            DLog(@"maxSize %f", maxSize.width);
//            CGSize labelSize = [body sizeWithFont:bodyFont constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
//            CGFloat labelHeight = labelSize.height;
//            DLog(@"labelHeight %f", labelHeight);
//            if (labelHeight < height) {
//                height = labelHeight;
//            }
            
            
            height += 10;
            
//            DLog(@"bodyTextView height %f",height);
//            
//            DLog(@"bodyCell.bodyTextView.frame %f",bodyCell.bodyTextView.frame.size.height);
            
            bodyCell.bodyTextView.frame = CGRectMake(HORISONTAL_PADDING, HORISONTAL_PADDING, _labelWidth, _height);
            
            bodyCell.bodyTextView.text = body;
            BOOL firstTimeToSetBodyHeight = NO;
            if (!bodyHeight) {
                firstTimeToSetBodyHeight = YES;
                bodyHeight = [bodyCell.bodyTextView sizeThatFits:maxSize].height;
            }
            
            
            if (firstTimeToSetBodyHeight) {
                [self.tableView reloadData];
            }

            
//            DLog(@"body %@",body);
//            
//            DLog(@"bodyCell.bodyTextView.frame %f",bodyCell.bodyTextView.frame.size.height);
            
            return bodyCell;

    }
    
    [contentSubview setUserInteractionEnabled:YES];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DLog(@"didSelectRowAtIndexPath");
    
    if (indexPath.section == kSectionAttachments) {
        Attachment* attachment = attachments[indexPath.row];
        
        if ([EmailTool attachmentIsSupported:attachment]) {
            NSString *filePath;
            
            NSURL *url;
            BOOL fileExists = NO;
            NSData *content;
            
            if (message.folderId.intValue == BOITE_D_ENVOI_ID_FOLDER || message.folderId.intValue == BROUILLON_ID_FOLDER || message.folderId.intValue == ENVOYES_ID_FOLDER) {
                attachment.localFileName = attachment.fileName;
            }
            
            if (attachment.localFileName.length > 0 ) {
                filePath = [Tools getAttachmentFilePath:attachment.localFileName];
                url = [NSURL fileURLWithPath:filePath];
                fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
            } else if (attachment.fileName.length > 0 ){
                filePath = [Tools getAttachmentFilePath:attachment.fileName];
                url = [NSURL fileURLWithPath:filePath];
                fileExists = [[NSFileManager
                               defaultManager] fileExistsAtPath:filePath];
 
                
            }
            
            if (fileExists) {
                content = [NSData dataWithContentsOfURL:url];
                content = [content AES256DecryptWithKey:[[PasswordStore getInstance] getDbEncryptionKey]];
                [self viewAttachment:content filePath:filePath attachment:attachment];
            } else {
                [loadingView setHidden:NO];
                DownloadAttachmentInput *downloadInput = [[DownloadAttachmentInput alloc] init];
                [downloadInput setMessageId:message.messageId];
                [downloadInput setPart:attachment.part];
                
                currentAttachment = attachment;
                Request *request = [[Request alloc] initWithService:S_ATTACHMENT_DOWNLOAD method:HTTP_POST headers:nil params:[downloadInput generate]];
                request.delegate = self;
                request.attachmentFileName = attachment.fileName;
                if ([request isConnectedToInternet]) {
                    [request execute];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                    message:NSLocalizedString(@"CONNEXION_IMPOSSIBLE_ATTACHMENT", @"Aucune connexion : fichier indisponible")
                                                                   delegate:self
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:@"Continuer", nil];
                    [alert show];
                    [loadingView setHidden:YES];
                }
            }
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:NSLocalizedString(@"FORMAT_DE_FICHIER_NON_SUPPORTE", @"Aucune application disponible pour ouvrir cette pièce jointe")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                                                  otherButtonTitles:nil];
            [alert show];
            
        }
    }
}


- (void)setDetailItem:(NSNumber *)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = [newDetailItem copy];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        // Update the view.
        [self configureView];
        }
    }
}

//Permet d'afficher l'écran blanc de non message selectionné si l'on vient de supprimer/déplacer le message
- (void)setBlankView:(NSNumber *)msgId
{
    if ([npMessage.messageId isEqualToNumber:msgId ]) {
        [self setDetailItem:nil];
    }
}


-(void)configureView {
    DLog(@"detailItem %@",_detailItem);
    DLog(@"message %@",message);
    DLog(@"message %@",message.messageId);
    
    [replyMenu setHidden:YES];
    
    bodyFont = [UIFont fontWithName:@"Helvetica" size:14];
    bodyHeight = 0;
    
    if (self.detailItem) {
        message = [MessageDAO findMessageByMessageId:self.detailItem];
        npMessage = [NPConverter convertMessage:message];
        toEmails = [NSMutableArray array];
        
        ccEmails = [NSMutableArray array];
        fromEmails = [NSMutableArray array];
        fromEmailsURI = [NSMutableArray array];
        cciEmails = [NSMutableArray array];
        toEmailsStrings = [NSMutableArray array];
        ccEmailsStrings = [NSMutableArray array];
        fromEmailsStrings = [NSMutableArray array];
        cciEmailsStrings = [NSMutableArray array];
        hasAttachments = NO;
        hasCC = NO;
        hasCCi = NO;
        
        for (Email* email in [[message emails] allObjects]) {
            if ([E_FROM isEqualToString:email.type]){
                [fromEmails addObject:email];
                [fromEmailsStrings addObject:[EmailTool emailtoString:email]];
                [fromEmailsURI addObject:[[email objectID]URIRepresentation]];
            } else if ([E_TO isEqualToString:email.type]){
                [toEmailsStrings addObject:[EmailTool emailtoString:email]];
                [toEmails addObject:[NPConverter convertEmail:email]];
            } else if ([E_CC isEqualToString:email.type]){
                [ccEmailsStrings addObject:[EmailTool emailtoString:email]];
                [ccEmails addObject:[NPConverter convertEmail:email]];
            } else if ([E_BCC isEqualToString:email.type]){
                [cciEmailsStrings addObject:[EmailTool emailtoString:email]];
                [cciEmails addObject:[NPConverter convertEmail:email]];
            }
        }
        
        if (ccEmails.count > 0) {
            hasCC = YES;
        }
        
        if (cciEmails.count > 0) {
            hasCCi = YES;
        }
        
        if (!maxCharsPerLine) {
            maxCharsPerLine = MAX_NUM_OF_CHARS_PER_LINE;
        }
        
        objectAttributedString = [self generateLabel:OBJET_MSG content:npMessage.subject];
        objectPlainString = [NSString stringWithFormat:@"%@ : %@",OBJET_MSG,npMessage.subject];
        
        //@TD: On ajoute "Sans Objet" si le message n'en contient pas.
        if([npMessage.subject isEqualToString:@""]){
            objectAttributedString = [self generateLabel:OBJET_MSG content:NSLocalizedString(@"SANS_OBJET", @"<Sans objet>")];
        }
        
        from = [EmailTool splitEmails:fromEmailsStrings maxCharactersPerLine:maxCharsPerLine label:DE_MSG];
        fromAttributedString = [self generateLabel:DE_MSG content:from];
        fromPlainString = [NSString stringWithFormat:@"%@ : %@",DE_MSG,from];
        
        to = [EmailTool splitEmails:toEmailsStrings maxCharactersPerLine:maxCharsPerLine label:A_MSG];
        toAttributedString = [self generateLabel:A_MSG content:to];
        
        toPlainString = [NSString stringWithFormat:@"%@ : %@",A_MSG,to];
        
        cc = [EmailTool splitEmails:ccEmailsStrings maxCharactersPerLine:maxCharsPerLine label:CC_MSG];
        ccAttributedString = [self generateLabel:CC_MSG content:cc];
        ccPlainString = [NSString stringWithFormat:@"%@ : %@",CC_MSG,cc];

        cci = [EmailTool splitEmails:cciEmailsStrings maxCharactersPerLine:maxCharsPerLine label:CCI_MSG];
        cciAttributedString = [self generateLabel:CCI_MSG content:cci];
        cciPlainString = [NSString stringWithFormat:@"%@ : %@",CCI_MSG,cci];

        if (npMessage) {
            AttachmentManager *attachmentManager = [[AttachmentManager alloc] init];
            attachments = [attachmentManager getAttachementsByIdMessage:npMessage.messageId];
            
            if([attachmentManager getAttachementsCount] > 0){
                hasAttachments = YES;
                numberOfAttachments = message.attachments.count;
            }
            
            pjAttributedString = [self generateLabel:PJ_MSG content:[NSString stringWithFormat:@"%d",numberOfAttachments]];

            body = npMessage.body;
            messageDateString = [EmailTool dateToString:npMessage.date];
            
            if ([npMessage.isBodyLarger boolValue]){
                NSString *msgVolumineux = NSLocalizedString(@"MESSAGE_DETAIL_TROP_VOLUMINEUX", @" \nMessage trop volumineux, veuillez-vous connecter au portail Web pour le visualiser entièrement");
                body = [NSString stringWithFormat:@"%@... %@", body, msgVolumineux ];
            }
            
            DLog(@"setting Message date String %@",messageDateString);
            _showCci = NO;
            
            if (npMessage.folderId.intValue == BOITE_D_ENVOI_ID_FOLDER || npMessage.folderId.intValue == ENVOYES_ID_FOLDER) {
                _showCci = YES;
            }
        }
    } else {
        [_noEmailsLabel setHidden:NO];
    }
}

- (void)generateReplyMenu {
    replyMenu = [[UIView alloc] initWithFrame:replyMenuFrame];
    [replyMenu setBackgroundColor:[UIColor lightGrayColor]];
    [replyMenu setHidden:YES];
    
    CGRect buttonFrame = CGRectMake(((320 / 3) / 2) - 25, 25, 50, 50);
    
    //Reply Button
    UIButton *replyMenuButton = [[UIButton alloc] initWithFrame:buttonFrame];
    [replyMenuButton setBackgroundImage:[UIImage imageNamed:@"ico_repondreA_grand"] forState:UIControlStateNormal];
    [replyMenuButton addTarget:self action:@selector(replyMenuButtonClicked:) forControlEvents:UIControlEventTouchDown];
    replyMenuButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320 / 3, 150)];
    [replyMenuButtonView addSubview:replyMenuButton];
    [replyMenuButtonView addSubview:[self generateReplyMenuLabel:@"Répondre"]];
    [replyToAllMenuButtonView setUserInteractionEnabled:YES];
    
    
    //Reply To All Button
    UIButton *replyToAllMenuButton = [[UIButton alloc] initWithFrame:buttonFrame];
    [replyToAllMenuButton setBackgroundImage:[UIImage imageNamed:@"ico.repondreAtous@2x.png"] forState:UIControlStateNormal];
    [replyToAllMenuButton addTarget:self action:@selector(replyToAllMenuButtonClicked:) forControlEvents:UIControlEventTouchDown];
    replyToAllMenuButtonView = [[UIView alloc] initWithFrame:CGRectMake(320 / 3, 0, 320 / 3, 150)];
    [replyToAllMenuButtonView addSubview:replyToAllMenuButton];
    [replyToAllMenuButtonView addSubview:[self generateReplyMenuLabel:@"Répondre à tous"]];
    [replyToAllMenuButtonView setUserInteractionEnabled:YES];
    
    //Forward Button
    UIButton *forwardMenuButton = [[UIButton alloc] initWithFrame:buttonFrame];
    
    [forwardMenuButton setBackgroundImage:[UIImage imageNamed:@"ico_transfere"] forState:UIControlStateNormal];
    [forwardMenuButton addTarget:self action:@selector(forwardMenuButtonClicked:) forControlEvents:UIControlEventTouchDown];
    forwardMenuButtonView = [[UIView alloc] initWithFrame:CGRectMake(2 * 320 / 3, 0, 320 / 3, 150)];
    [forwardMenuButtonView addSubview:forwardMenuButton];
    [forwardMenuButtonView addSubview:[self generateReplyMenuLabel:@"Transférer"]];
    [forwardMenuButtonView setUserInteractionEnabled:YES];
    
    [replyMenu addSubview:replyMenuButtonView];
    [replyMenu addSubview:replyToAllMenuButtonView];
    [replyMenu addSubview:forwardMenuButtonView];
    [replyMenu setUserInteractionEnabled:YES];
    [self.view addSubview:replyMenu];
}

- (void)generateMessageOptionsMenu {
    if (messageOptionsMenu == nil) {
        messageOptionsMenu = [[UIView alloc] initWithFrame:messageOptionsMenuFrame];
        [messageOptionsMenu setBackgroundColor:[UIColor colorWithRed:0.1294117647 green:0.36862745098 blue:0.44705882352 alpha:1]];
        [messageOptionsMenu setHidden:YES];
    } else {
        [messageOptionsMenu setFrame:messageOptionsMenuFrame];
        for (UIView *subview in messageOptionsMenu.subviews) {
            [subview removeFromSuperview];
        }
    }
    
    if(!message && self.detailItem){
    message = [MessageDAO findMessageByMessageId:self.detailItem];
    }
    
    CGRect buttonViewFrame = CGRectMake(messageOptionsMenuFrame.size.width - 60, 0, 50, 60);
    CGRect buttonFrame = CGRectMake(buttonViewFrame.size.width / 2 - 25 /2 , 10, 25 , 25);
    
    if (message.folderId.intValue == CORBEILLE_ID_FOLDER) {
        //Restore button
        if (restoreView == nil) {
            restoreView = [[UIView alloc] initWithFrame:buttonViewFrame];
            UIButton *restoreButton = [[UIButton alloc] initWithFrame:buttonFrame];
            UITapGestureRecognizer *restoreButtonGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(restoreMessage:)];
            [restoreButton setBackgroundImage:[UIImage imageNamed:@"ico_restaurer"] forState:UIControlStateNormal];
            [restoreButton setUserInteractionEnabled:NO];
            [restoreView addSubview:restoreButton];
            [restoreView addSubview:[self generateOptionsMenuLabel:@"Restaurer"]];

            [restoreView setUserInteractionEnabled:YES];
            [restoreView addGestureRecognizer:restoreButtonGesture];
        } else {
            [restoreView setFrame:buttonViewFrame];
        }
        
        //Delete button
        buttonViewFrame.origin.x -= 50;
        if (deleteView == nil) {
            deleteView = [[UIView alloc] initWithFrame:buttonViewFrame];
            UIButton *deleteButton = [[UIButton alloc] initWithFrame:buttonFrame];
            UITapGestureRecognizer *deleteButtonGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteMessage:)];
            [deleteButton setUserInteractionEnabled:NO];
            [deleteButton setBackgroundImage:[UIImage imageNamed:@"ico_supprimer"] forState:UIControlStateNormal];
            [deleteView addSubview:deleteButton];
            [deleteView addSubview:[self generateOptionsMenuLabel:@"Supprimer"]];
            [deleteView addGestureRecognizer:deleteButtonGesture];
            [deleteView setUserInteractionEnabled:YES];
        } else {
            [deleteView setFrame:buttonViewFrame];
        }
        
        [messageOptionsMenu addSubview:restoreView];
        [messageOptionsMenu addSubview:deleteView];
        
    } else if (message.folderId.intValue == BOITE_D_ENVOI_ID_FOLDER) {
        //Delete button
        if (deleteView == nil) {
            deleteView = [[UIView alloc] initWithFrame:buttonViewFrame];
            UIButton *deleteButton = [[UIButton alloc] initWithFrame:buttonFrame];
            UITapGestureRecognizer *deleteButtonGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteMessage:)];
            [deleteButton setUserInteractionEnabled:NO];
            [deleteButton setBackgroundImage:[UIImage imageNamed:@"ico_supprimer"] forState:UIControlStateNormal];
            [deleteView addSubview:deleteButton];
            [deleteView addSubview:[self generateOptionsMenuLabel:@"Supprimer"]];
            [deleteView addGestureRecognizer:deleteButtonGesture];
            [deleteView setUserInteractionEnabled:YES];
            
        } else {
            [deleteView setFrame:buttonViewFrame];
        }
        
        [messageOptionsMenu addSubview:deleteView];
    } else {
        //Trash button
        if (trashView == nil) {
            trashView = [[UIView alloc] initWithFrame:buttonViewFrame];
            UIButton *trashButton = [[UIButton alloc] initWithFrame:buttonFrame];
            UITapGestureRecognizer *trashButtonGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(trashMessage:)];
            [trashButton setBackgroundImage:[UIImage imageNamed:@"ico_corbeille_grand"] forState:UIControlStateNormal];
            [trashButton setUserInteractionEnabled:NO];
            [trashView addSubview:trashButton];
            [trashView addSubview:[self generateOptionsMenuLabel:@"Corbeille"]];
            [trashView setUserInteractionEnabled:NO];
            [trashView setUserInteractionEnabled:YES];
            [trashView addGestureRecognizer:trashButtonGesture];
        } else {
            [trashView setFrame:buttonViewFrame];
        }
        
        
        //Unread button
        buttonViewFrame.origin.x -= 50;
        buttonFrame.size.height = 15;
        buttonFrame.origin.y = 15;
        
        if (unreadView == nil) {
            unreadView = [[UIView alloc] initWithFrame:buttonViewFrame];
            UIButton *unreadButton = [[UIButton alloc] initWithFrame:buttonFrame];
            UITapGestureRecognizer *unreadButtonGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(unreadMessage:)];
            [unreadButton setUserInteractionEnabled:NO];
            [unreadButton setBackgroundImage:[UIImage imageNamed:@"ico_nonlus_grand"] forState:UIControlStateNormal];
            [unreadView addSubview:unreadButton];
            [unreadView addSubview:[self generateOptionsMenuLabel:@"Non lus"]];
            [unreadView addGestureRecognizer:unreadButtonGesture];
            [unreadView setUserInteractionEnabled:YES];
        } else {
            [unreadView setFrame:buttonViewFrame];
        }
        
        
        
        //Move button
        buttonViewFrame = CGRectMake(buttonViewFrame.origin.x -70, 0, 70, 60);
        buttonFrame = CGRectMake(buttonViewFrame.size.width / 2 - 25 /2 , 15, 25 , 15);
        
        if (moveView == nil) {
            moveView = [[UIView alloc] initWithFrame:buttonViewFrame];
            UIButton *moveButton = [[UIButton alloc] initWithFrame:buttonFrame];
            UILabel *moveLabel = [self generateOptionsMenuLabel:@"Déplacer vers"];
            UITapGestureRecognizer *moveButtonGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moveMessage:)];
            CGRect moveLabelFrame = moveLabel.frame;
            moveLabelFrame.size.width = 70;
            [moveButton setUserInteractionEnabled:NO];
            [moveButton setBackgroundImage:[UIImage imageNamed:@"ico_dossier"] forState:UIControlStateNormal];
            [moveLabel setFrame:moveLabelFrame];
            [moveView addSubview:moveButton];
            [moveView addSubview:moveLabel];
            [moveView addGestureRecognizer:moveButtonGesture];
            [moveView setUserInteractionEnabled:YES];
        } else {
            [moveView setFrame:buttonViewFrame];
        }
        
        
        //Flag button
        buttonViewFrame.origin.x -= 50;
        buttonFrame.size.height = 25;
        buttonFrame.size.width = 28;
        buttonFrame.origin.x = 12;
        buttonFrame.origin.y = 10;
        if (flagView == nil) {
            flagView = [[UIView alloc] initWithFrame:buttonViewFrame];
            UIButton *flagButton = [[UIButton alloc] initWithFrame:buttonFrame];
            UITapGestureRecognizer *favoriteButtonGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(flagMessage:)];
            [flagButton setUserInteractionEnabled:NO];
            [flagButton setBackgroundImage:[UIImage imageNamed:@"ico_msgsuivi"] forState:UIControlStateNormal];
            [flagView addSubview:flagButton];
            [flagView addSubview:[self generateOptionsMenuLabel:@"Suivre"]];
            [flagView addGestureRecognizer:favoriteButtonGesture];
            [flagView setUserInteractionEnabled:YES];
        } else {
            [flagView setFrame:buttonViewFrame];
        }
        
        [messageOptionsMenu addSubview:trashView];
        [messageOptionsMenu addSubview:unreadView];
        [messageOptionsMenu addSubview:moveView];
        [messageOptionsMenu addSubview:flagView];
    }
    
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    replyMenuFrame.origin.y = screenHeight - 150 + contentOffsetY;
    [replyMenu setFrame:replyMenuFrame];
    
    CGRect loadingFrame = loadingView.frame;
    
    loadingFrame.origin.y = contentOffsetY;
    [loadingView setFrame:loadingFrame];
    
    [_noEmailsLabel setFrame:loadingFrame];
    
    messageOptionsMenuFrame.origin.y = contentOffsetY;
    [messageOptionsMenu setFrame:messageOptionsMenuFrame];
}

- (UILabel*)generateReplyMenuLabel:(NSString*)text {
    CGRect labelFrame = CGRectMake(((320 / 3) / 2) - 105/2, 90, 105, 20);
    UIFont *labelFont = [UIFont fontWithName:@"Helvetica" size:14];
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    [label setText:text];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:labelFont];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor whiteColor]];
    return label;
}

- (UILabel*)generateOptionsMenuLabel:(NSString*)text {
    CGRect labelFrame = CGRectMake(0 , 25, 50 , 40);
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    UIFont *labelFont = [UIFont fontWithName:@"Helvetica" size:10];
    UIColor *labelColor = [UIColor whiteColor];
    [label setText:text];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:labelFont];
    [label setTextColor:labelColor];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setNumberOfLines:0];
    return label;
}





-(NSAttributedString*)generateLabel:(NSString*)title content:(NSString*)content {
    
    NSString *completeString = @"";
    completeString = [NSString stringWithFormat:@"%@ : %@", title, content];
    
    cellFont = [UIFont fontWithName:@"Helvetica" size:17];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping ;
    } else {
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:paragraphStyle, NSParagraphStyleAttributeName,nil];
    
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:completeString attributes:attributes];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0,[title length]+2)];
    [string addAttribute:NSFontAttributeName value:cellFont range:NSMakeRange(0,completeString.length)];
    
    return string;
}


-(void)updateMasterController:(NSString*)method{
    DLog(@"update detail method %@", method);
    [messageOptionsMenu setHidden:YES];
    if ([self delegate] != nil) {
        [[self delegate] updateListMessage:message forMethod:method];
    }
    
    if ([method isEqualToString:TRASH_MESSAGE_DELEGATE]) {
        [_noEmailsLabel setHidden:NO];
    }
    else if ([method isEqualToString:DELETE_MESSAGE_DELEGATE]) {
        [_noEmailsLabel setHidden:NO];
    }
    else if ([method isEqualToString:RESTORE_MESSAGE_DELEGATE]) {
        [_noEmailsLabel setHidden:NO];
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if ([method isEqualToString:MOVE_TO_FOLDER_DELEGATE]) {
            NSMutableArray *selectedMessages = [[NSMutableArray alloc] initWithObjects:npMessage, nil];
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:selectedMessages forKey:SELECTED_MESSAGE];
            DLog(@"message.folderId : %@", message.folderId);
            [dict setObject:npMessage.folderId forKey:MASTER_FOLDER_ID];
            [dict setObject:npMessage.folderId forKey:CURRENT_FOLDER_ID];
            [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_MOVE_MSG_VIEW_NOTIF object:dict];
        }
        
        if (![method isEqualToString:FOLLOW_DELEGATE] && ![method isEqualToString:UNREAD_DELEGATE]) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}



- (void)restoreMessage:(id)sender {
    DLog(@"restoreMessage");
    
    NSMutableArray *arrayIdsMessage = [[NSMutableArray alloc] init];
    [arrayIdsMessage addObject:npMessage.messageId];
    
    MoveMessagesInput *moveMessages = [[MoveMessagesInput alloc] init];
    [moveMessages setMessageIds:arrayIdsMessage];
    [moveMessages setDestinationFolderId:[NSNumber numberWithInt:RECEPTION_ID_FOLDER]];
    message.folderId = [NSNumber numberWithInt:RECEPTION_ID_FOLDER];
    [self runRequestService:S_ITEM_MOVE_MESSAGES withParams:[moveMessages generate] header:nil andMethod:HTTP_POST];
    [self updateMasterController : RESTORE_MESSAGE_DELEGATE];
    [self saveDB];
}

- (void)deleteMessage:(id)sender {
    DLog(@"deleteMessage");
    if (npMessage.folderId.intValue == CORBEILLE_ID_FOLDER) {
        [self deleteForEver:YES];
    } else if (message.folderId.intValue == BOITE_D_ENVOI_ID_FOLDER) {
        [self deleteForEver:NO];
    }
    
}

-(void)deleteForEver:(BOOL)sync{
    MessageDAO *messageDAO = (MessageDAO*)[[DAOFactory factory] newDAO:MessageDAO.class];
    if (message.attachments.count > 0) {
        for (Attachment *attachment in message.attachments) {
            NSString *filePath = [Tools getAttachmentFilePath:attachment.fileName];
            if (filePath) {
                BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
                if (fileExists) {
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    NSError *error;
                    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
                    if (!success) DLog(@"Error Deleting Attachment: %@", [error localizedDescription]);
                }
            }
        }
    }
    
    if ([message.folderId isEqualToNumber:[NSNumber numberWithInt:BOITE_D_ENVOI_ID_FOLDER]]) {
        ModificationDAO *modifDAO = (ModificationDAO*)[[DAOFactory factory] newDAO:ModificationDAO.class];
        NSMutableArray *listModification = [modifDAO findModificationByMessageId:message.messageId];
        if (listModification.count > 0){
            for (Modification *modif in listModification){
                if ([SEND isEqualToString:modif.operation ]){
                    [modifDAO deleteObject:modif];
                }
            }
        }
    }
    
    [messageDAO deleteObject:message];
    
    if (sync) {
        NSMutableArray *arrayIdsMessage = [[NSMutableArray alloc] init];
        [arrayIdsMessage addObject:message.messageId];
        if ([arrayIdsMessage count] >0){
            UpdateMessagesInput* updateInput = [[UpdateMessagesInput alloc] init];
            [updateInput setMessageIds:arrayIdsMessage];
            [updateInput setOperation:O_DELETE];
            [self runRequestService:S_ITEM_UPDATE_MESSAGES withParams:[updateInput generate] header:nil andMethod:HTTP_POST];
        }
    }
    
    [self saveDB];
    [self updateMasterController : DELETE_MESSAGE_DELEGATE];
}

- (void)trashMessage:(id)sender {
    DLog(@"trashMessage");
    
    if(!message.messageId) {
        message = [MessageDAO findMessageByMessageId:npMessage.messageId];
    }
    
    NSMutableArray *arrayIdsMessage = [[NSMutableArray alloc] init];
    if ([message.folderId intValue] == BOITE_D_ENVOI_ID_FOLDER){
        ModificationDAO *modifDAO = (ModificationDAO*)[[DAOFactory factory] newDAO:ModificationDAO.class];
        NSMutableArray *listModification = [modifDAO findModificationByMessageId:message.messageId];
        if (listModification.count > 0){
            for (Modification *modif in listModification){
                if ([SEND isEqualToString:modif.operation ]){
                    [modifDAO deleteObject:modif];
                    [self saveDB];
                }
            }
        }
    }

    [arrayIdsMessage addObject:message.messageId];
    
    UpdateMessagesInput* updateInput = [[UpdateMessagesInput alloc] init];
    message.folderId = [NSNumber numberWithInt:CORBEILLE_ID_FOLDER];
    
    [updateInput setOperation:O_TRASH];
    [updateInput setMessageIds:arrayIdsMessage];
    
    [self runRequestService:S_ITEM_UPDATE_MESSAGES withParams:[updateInput generate] header:nil andMethod:HTTP_POST];
    [self updateMasterController:TRASH_MESSAGE_DELEGATE];
    [self saveDB];
}

- (void)unreadMessage:(id)sender {
    DLog(@"unreadMessage");
    
    if(!message.messageId){
        message = [MessageDAO findMessageByMessageId:npMessage.messageId];
    }
    
    NSMutableArray *arrayIdsMessage = [[NSMutableArray alloc] init];
    UpdateMessagesInput* updateInput = [[UpdateMessagesInput alloc] init];
    
    if ([message.isRead boolValue]){
        [updateInput setOperation:O_UNREAD];
        [message setIsRead:[NSNumber numberWithBool:NO]];
    } else {
        [updateInput setOperation:O_READ];
        [message setIsRead:[NSNumber numberWithBool:YES]];
    }
    
    if (message.messageId) {
        [arrayIdsMessage addObject:message.messageId];
        [updateInput setMessageIds:arrayIdsMessage];
        
        [self runRequestService:S_ITEM_UPDATE_MESSAGES withParams:[updateInput generate] header:nil andMethod:HTTP_POST];
        [self saveDB];
        [self updateMasterController:UNREAD_DELEGATE];
    }
}

- (void)moveMessage:(id)sender {
    DLog(@"moveMessage");
    
    if(!message.messageId) {
        message = [MessageDAO findMessageByMessageId:npMessage.messageId];
    }
    
    if (message.folderId.intValue != 0 && message.folderId.intValue != BOITE_D_ENVOI_ID_FOLDER && message.folderId.intValue != CORBEILLE_ID_FOLDER) {
        [self updateMasterController : MOVE_TO_FOLDER_DELEGATE];
    }
}

- (void)flagMessage:(id)sender {
    DLog(@"flagMessage");
    
    if(!message.messageId) {
        message = [MessageDAO findMessageByMessageId:npMessage.messageId];
    }
    
    NSMutableArray *arrayIdsMessage = [[NSMutableArray alloc] init];
    [arrayIdsMessage addObject:message.messageId];
    
    UpdateMessagesInput* updateInput = [[UpdateMessagesInput alloc] init];
    [updateInput setMessageIds:arrayIdsMessage];
    
    if ([message.isFavor boolValue]) {
        message.isFavor = [NSNumber numberWithBool:NO];
        [updateInput setOperation:O_UNFLAGGED];
    } else {
        message.isFavor = [NSNumber numberWithBool:YES];
        [updateInput setOperation:O_FLAGGED];
    }
    
    [self runRequestService:S_ITEM_UPDATE_MESSAGES withParams:[updateInput generate] header:nil andMethod:HTTP_POST];
    [self saveDB];
    [self updateMasterController:FOLLOW_DELEGATE];
}


- (IBAction)openBarMenu:(id)sender {
    DLog(@"openBarMenu");
    [messageOptionsMenu setHidden:!messageOptionsMenu.isHidden];
}

- (void)toggleDetails:(id)sender {
    DLog(@"toggleDetails");
    showDetails = !showDetails;
    [self.tableView reloadData];
}

- (void)toggleReplyMenu:(id)sender {
    DLog(@"toggleReplyMenu");
    showReplyMenu = !showReplyMenu;
    
    UIScrollView *myTableView;
    if([self.tableView.superview isKindOfClass:[UIScrollView class]]) {
        myTableView = (UIScrollView *)self.tableView.superview;
    } else {
        myTableView = self.tableView;
    }
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    if (replyMenu.isHidden) {
        [replyMenu setHidden:NO];
        contentInsets = UIEdgeInsetsMake(0, 0, 150, 0);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:HIDE_KEYBOARD object:nil];
        [self.view endEditing:YES];
    } else {
        [replyMenu setHidden:YES];
    }
    
    myTableView.contentInset = contentInsets;
    myTableView.scrollIndicatorInsets = contentInsets;
}

- (void)toggleAttachments:(id)sender {
    DLog(@"toggleAttachments");
    showAttachments = !showAttachments;
    
    [self.tableView reloadData];
    [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
}

- (BOOL)emailExists:(Email*)searchEmail inList:(NSMutableArray*)emails {
    for (Email *email in emails) {
        if ([email.address isEqualToString:searchEmail.address]) {
            return YES;

        }
    }
    return NO;
}

- (void)replyMenuButtonClicked:(id)sender {
    [replyMenu setHidden:YES];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:[NPConverter switchToRespondMessage:npMessage] forKey:MESSAGE];
    [params setObject:REPLIED forKey:REPLY_TYPE];
    [params setObject:MSG_DETAIL forKey:MSG_DETAIL];
    [params setObject:self.navigationController forKey:CURRENT_NAV_CONTROLLER];
 
    [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_NEW_MSG_VIEW_NOTIF object:params];
}

- (void)replyToAllMenuButtonClicked:(id)sender {
    [replyMenu setHidden:YES];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:[NPConverter switchToRespondToAllMessage:npMessage] forKey:MESSAGE];
    [params setObject:MSG_DETAIL forKey:MSG_DETAIL];
    [params setObject:self.navigationController forKey:CURRENT_NAV_CONTROLLER];
    [params setObject:REPLIED forKey:REPLY_TYPE];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_NEW_MSG_VIEW_NOTIF object:params];
}


- (void)forwardMenuButtonClicked:(id)sender {
    [replyMenu setHidden:YES];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:[NPConverter switchToTransferMessage:npMessage] forKey:MESSAGE];
    
    if (hasAttachments) {
        [params setObject:[attachments copy] forKey:ATTACHMENTS];
    }
    
    [params setObject:FORWARDED forKey:REPLY_TYPE];
    [params setObject:MSG_DETAIL forKey:MSG_DETAIL];
    [params setObject:self.navigationController forKey:CURRENT_NAV_CONTROLLER];
  
    [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_NEW_MSG_VIEW_NOTIF object:params];
}


-(void)viewAttachment:(NSData*)data filePath:(NSString*)filePath attachment:(Attachment*)attachment {
    
     DLog(@"filePath %@",filePath);
    if ([EmailTool attachmentIsImage:attachment]) {
        
//        [Tools copyAttachmentToTempFolder:data fileName:attachment.fileName];
//        
//        documentController =[UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:[Tools getAttachmentTempFilePath:attachment.fileName]]];
//        documentController.delegate = self;
////        documentController.UTI = @"com.apple.photo";
//        BOOL open = [documentController presentOpenInMenuFromRect:CGRectZero
//                                                           inView:self.view
//                                                         animated:YES];
//        if (open) {
//            [documentController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
//        } else {
//            UIImage *image = [[UIImage alloc] initWithData:data];
//            if (image) {
//                [self performSegueWithIdentifier:@"segueToImageViewer" sender:image];
//            } else {
//                //TODO Wrong Format
//            }
//
//        }
        
        UIImage *image = [[UIImage alloc] initWithData:data];
        if (image) {
            [self performSegueWithIdentifier:@"segueToImageViewer" sender:image];
        } else {
            //TODO Wrong Format
        }
        
    } else if ([EmailTool attachmentIsViewable:attachment]) {
        [self performSegueWithIdentifier:@"segueToWebViewer" sender:filePath];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"segueToImageViewer"]) {
        UIImage *image = (UIImage*)sender;
        ImageViewerController *imageViewController = segue.destinationViewController;
        [imageViewController setImage:image];
    } else if ([segue.identifier isEqualToString:@"segueToWebViewer"]) {
        //        NSURL *path = (NSURL*)sender;
        NSString *path = (NSString*)sender;
        WebViewController *webViewController = segue.destinationViewController;
        //        [webViewController setUrl:path];
        [webViewController setFilePath:path];
        
    }
    
    
    
}

- (void)hideImageViewer:(NSNotification *)pNotification{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)runRequestService:(NSString*)_servivce withParams:(NSDictionary*)_params header:(NSMutableDictionary*)_header andMethod:(NSString*)_method {
    Request *request = [[Request alloc] initWithService:_servivce method:_method headers:_header params:_params];
    request.delegate = self;
    [request execute];
}

-(void)httpError:(Error *)_error{
    [loadingView setHidden:YES];
    //    [currentCell setAccessoryView:nil];
}

-(void)httpResponse:(id)_responseObject{
    [loadingView setHidden:YES];
    if ([_responseObject isKindOfClass:[DownloadAttachmentResponse class]]) {
        DownloadAttachmentResponse *response = (DownloadAttachmentResponse*) _responseObject;
        
        NSString *filename = currentAttachment.fileName;
        NSString *filePath = [Tools getAttachmentFilePath:filename];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
        if (fileExists) {
            NSDate *date = [NSDate date];
            NSTimeInterval timestamp = [date timeIntervalSince1970];
            NSString *currentFileName = [filename stringByDeletingPathExtension];
            NSString *ext = [filename pathExtension];
            filename = [NSString stringWithFormat:@"%@%d.%@",currentFileName,(int)timestamp,ext];
            filePath = [Tools getAttachmentFilePath:filename];
        }
        
        [currentAttachment setLocalFileName:filename];
        
        [self saveDB];
        
        NSData* data = [Tools base64DataFromString:response.file];
        
        NSData* encryptedData = [data AES256EncryptWithKey:[[PasswordStore getInstance] getDbEncryptionKey]];
        
        if (encryptedData) {
            [encryptedData writeToFile:filePath atomically:YES];
        }
        
        //        [currentCell setAccessoryView:nil];
        
        [self viewAttachment:data filePath:filePath attachment:currentAttachment];
    }
    else if ([_responseObject isKindOfClass:[NSString class]] && [_responseObject isEqualToString:@"S_ITEM_UPDATE_MESSAGES"]){
        
    }
}

-(void)saveDB{
    NSError *error;
    if (![[DAOFactory factory] save:&error]) {
        DLog(@"error save %@", [error userInfo]);
    }
}

//DANGEROUS     A confirmer avec Loïc
-(void)setDefaultParamsDetail{
    //message = nil;
    npMessage = nil;
    [_noEmailsLabel setHidden:NO];
}

- (void)reloadDetailsView {
    [self configureView];
}

-(void)reloadData {
    
    bodyHeight = 0;
    showAttachments = NO;
    showDetails = NO;
    showReplyMenu = NO;
    [messageOptionsMenu setHidden:YES];
    
    if ([npMessage.folderId intValue] == BOITE_D_ENVOI_ID_FOLDER){
        [replyButton setHidden:YES];
    } else {
        [replyButton setHidden:NO];
    }
    
    [self.tableView reloadData];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self updateOrientation];
    }
    
    if (npMessage.messageId) {
        [_noEmailsLabel setHidden:YES];
    } else {
        [_noEmailsLabel setHidden:NO];
    }

    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

@end
