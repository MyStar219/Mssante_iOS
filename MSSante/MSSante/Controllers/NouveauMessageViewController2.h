//
// Created by Labinnovation on 04/11/14.
// Copyright (c) 2014 Capgemini. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TITokenTableViewController.h"
#import "Email.h"
#import "SendMessageInput.h"
#import "Request.h"
#import "RequestFinishedDelegate.h"
#import "SendMessageResponse.h"
#import "PieceJointeMenu.h"
#import "Attachment.h"
#import "DAOFactory.h"
#import "MessageDAO.h"
#import "AnnuaireDelegate.h"
#import "SyncAndSendModifDelegate.h"
#import "NSData+AES256.h"
#import "Tools.h"
#import "UIImage+Resize.h"
#import "DraftMessageResponse.h"
#import "NPMessage.h"
#import "NouveauMessageDrawer.h"

@class PieceJointeMenu;

@protocol NouveauMessageProtocol

@required
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)sendMessage:(id)sender;
- (IBAction)togglePjMenuView:(id)sender;
- (void)updateWithMessage:(NPMessage *)message;
- (void)updateWithAttachments:(NSMutableArray *)attachments;
- (void)scrollViewToTextField:(TITokenField *)tokenFieldCc;
@end

@interface NouveauMessageViewController2 : TITokenTableViewController <TITokenTableViewDataSource, TITokenTableViewControllerDelegate,RequestFinishedDelegate, AnnuaireDelegate, NouveauMessageProtocol, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic, retain) IBOutlet UIView *attachmentsView;
@property (nonatomic, retain) IBOutlet UILabel *attachmentsCountLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *addingAttachmentSpinner;
@property (nonatomic, retain) IBOutlet UIButton *toggleAttachments;

@property (nonatomic,retain) UIView *spinnerView;
@property (nonatomic, strong) UIPopoverController * popoverControllerCamera;
@property (nonatomic, retain) NSDictionary *sendInputGenerate;
@property (nonatomic, retain) NSMutableArray *emailAddresses;
@property (nonatomic, retain) NSString *operationType;
@property (nonatomic, assign) int saveInfolderId;
@property (nonatomic, retain) NSString *tokenField;
@property (nonatomic, assign, getter=isDismissFromImagePicker) BOOL dismissFromImagePicker;
@property (nonatomic, assign, getter=isViewAttachment) BOOL viewAttachment;
@property (nonatomic, assign, getter=isDontDismiss) BOOL dontDismiss;
@property (nonatomic, assign) CGPoint point;

- (void)setStateUrgent;
- (void)initFirstResponder;
- (void)reset;
- (void)displayDraftActionSheet;
- (void)saveDraft:(NSNotification *)notification;

@end