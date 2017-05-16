//
//  DetailViewController.h
//  MSSante
//
//  Created by labinnovation on 10/06/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Email.h"
#import "Message.h"
#import "Attachment.h"
#import "AccesToUserDefaults.h"
#import "RequestFinishedDelegate.h"
#import "DownloadAttachmentInput.h"
#import "ImageViewerController.h"
#import "DownloadAttachmentResponse.h"
#import "Tools.h"
#import "WebViewController.h"
#import "ModificationDAO.h"
#import "Modification.h"
#import "NSData+AES256.h"
#import "NPMessage.h"

@protocol DetailDelegate <NSObject>
@required
- (void)updateListMessage:(Message*)messageModify forMethod:(NSString*)method;
@end

@interface DetailViewController : UIViewController <RequestFinishedDelegate, UITableViewDelegate, UITableViewDataSource, UIDocumentInteractionControllerDelegate> {
    Message *message;
    NSArray *messages;
    Message *lastMessage;
    NSArray *emailsTo;
    Email *emailFrom;
    Email *emailTo;
    NSArray *attachments;
    BOOL pjIsHide;
    NSMutableArray *toEmails;
    NSMutableArray *ccEmails;
    NSMutableArray *fromEmails;
    NSMutableArray *bccmEmails;
    NSMutableArray *toEmailsStrings;
    NSMutableArray *ccEmailsStrings;
    NSMutableArray *fromEmailsStrings;
    NSMutableArray *bccEmailsStrings;
    NSMutableArray *listAttachments;
    id<DetailDelegate> __unsafe_unretained delegate;
    NSMutableDictionary *attachmentsData;
}
@property (weak, nonatomic) IBOutlet UITableView *attachmentsTableView;

@property (unsafe_unretained) id delegate;

- (IBAction)transferer:(id)sender;
- (IBAction)repondreATous:(id)sender;
- (IBAction)repondreAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *repondreView;
@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UIView *mailInfoView;
@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;
@property (weak, nonatomic) IBOutlet UILabel *ccLabel;
@property (weak, nonatomic) IBOutlet UILabel *objectLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *hidePJButton;
@property (weak, nonatomic) IBOutlet UILabel *nbPjLabel;
@property (weak, nonatomic) IBOutlet UIView *viewNoMail;
@property (weak, nonatomic) IBOutlet UIView *followView;
@property (weak, nonatomic) IBOutlet UIView *moveFolderView;
@property (weak, nonatomic) IBOutlet UIView *deleteView;
@property (weak, nonatomic) IBOutlet UIView *bodyView;
@property (weak, nonatomic) IBOutlet UITextView *mailLabel;
@property (strong, nonatomic) IBOutlet Message *message;
@property (weak, nonatomic) IBOutlet UIButton *repondreMenuButton;
@property (strong,nonatomic) NSMutableArray *tableArray;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) NSMutableDictionary *attachmentsData;
@property (nonatomic, strong) UIDocumentInteractionController *docController;

@property (weak, nonatomic) IBOutlet UIView *unreadView;

- (IBAction)reply:(id)sender;
- (IBAction)hidePJInfo:(id)sender;


- (void)reloadDetailsView;
-(void)setDefaultParamsDetail;

@end
