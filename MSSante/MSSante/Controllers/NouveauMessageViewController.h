//
//  Created by jac on 9/14/12.
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


@class PieceJointeMenu;
@interface NouveauMessageViewController : TITokenTableViewController <TITokenTableViewDataSource, TITokenTableViewControllerDelegate, RequestFinishedDelegate, AnnuaireDelegate, UITextViewDelegate, UIImagePickerControllerDelegate , UINavigationControllerDelegate, UIAlertViewDelegate, UIActionSheetDelegate> {
    NSArray *_tokenFieldTitles;
    UITextField *textFieldSubject;
    CGFloat _oldHeight;
    CGSize popupSize;
    CGRect tableBounds;
    TITokenField *tokenFieldTo;
    TITokenField *tokenFieldCc;
    TITokenField *tokenFieldCi;
    NSString* subject;
    NSString* body;
    NSArray *toEmails;
    NSArray *ccEmails;
    NSArray *fromEmails;
    NSArray *ciEmails;
    NSMutableArray *toEmailsStrings;
    NSMutableArray *ccEmailsStrings;
    NSMutableArray *fromEmailsStrings;
    NSMutableArray *ciEmailsStrings;
    NSNumber *messageId;
    NSNumber *messageTransferedId;
    UIButton *pjButton;
    UIButton *urgentButton;
    UIView *pjMenuView;
    NSString *replyType;
    PieceJointeMenu *pjMenu;
    Message* message;
    
    IBOutlet UIImageView *imageSelect;
    SendMessageInput *sendInput;
    
    NSDictionary *sendInputGenerate;
    TITokenField *setFirstResponder;
    NSMutableArray *emailAddresses;
    NSString *operationType;
    int saveInfolderId;
    NSString *annuaireSearchString;

    BOOL isDraft;
    UIActionSheet *sheet;
    BOOL isActive;


    BOOL urgent;
    BOOL hasAttachments;
    BOOL isAddingAttachment;
    //int numberOfAttachments;
    UIView *attachmentsView;
    UILabel *attachmentsCountLabel;
    UIActivityIndicatorView *addingAttachmentSpinner;
    UIButton *toggleAttachments;
    Attachment *selectedAttachment;
    NSMutableDictionary *attachmentsBytes;
    int currentIndex;
    BOOL keyboardShown;
    CGFloat keyboardOverlap;
    int returnClickCount;
    int toLastTokensCount;
    int ccLastTokensCount;
    int ciLastTokensCount;
    BOOL startedEditCcField;
    UITextField *lastField;
    CGPoint currentScrollPoint;
    BOOL dismissFromImagePicker;
    BOOL dismissFromAnnuaire;

    UIView *spinnerView;
    Attachment *currentAttachment;
    BOOL viewAttachment;
    BOOL dontDismiss;

    long totalAttachmentsSize;

    BOOL msgSavedToOutboxError;
}

@property(nonatomic, strong) TITokenTableViewController *tokenTableViewController;
@property(nonatomic, strong) NSString* replyType;
@property(nonatomic, strong) NSArray *toEmails;
@property(nonatomic, strong) NSArray *ccEmails;
@property(nonatomic, strong) NSArray *fromEmails;
@property(nonatomic, strong) NSArray *ciEmails;
@property(nonatomic, strong) NSNumber *messageId;
@property(nonatomic, strong) NSNumber *messageTransferedId;
@property(nonatomic, strong) Message* message;
@property(nonatomic, strong) TITokenField *tokenFieldTo;
@property(nonatomic, strong) TITokenField *tokenFieldCc;
@property(nonatomic, strong) TITokenField *tokenFieldCi;
@property(nonatomic, strong) TITokenField* setFirstResponder;
@property(nonatomic, retain) UIImageView *imageSelect;
@property(nonatomic, strong) UIPopoverController * popoverControllerCamera;
@property(nonatomic, strong) UIImagePickerController *imagePicker;
@property(nonatomic, weak) id<SyncAndSendModifDelegate>sendDelegate;
@property(nonatomic, strong)SendMessageInput *sendInput;
@property(nonatomic, strong) NSMutableArray *emailAddresses;
@property(nonatomic, strong) NSString *annuaireSearchString;
@property(assign) BOOL isDraft;
@property(assign) BOOL isActive;
@property(assign) BOOL isComingFromMessageDetail;
@property(assign) BOOL isComingFromAnnuaire;
@property (assign, nonatomic) UIEdgeInsets scrollViewInitialContentInset;
@property(nonatomic, strong) UIViewController *previousViewController;

- (void)addAttachment:(Attachment*)attachment;
- (void)initFirstResponder;
-(void)addAttachmentToSendInput:(Attachment*)attachment;
- (IBAction)cancelButtonPressed:(id)sender;
-(BOOL)needToSaveDraft;
-(void)reset;
-(void)saveDraft:(NSNotification *)aNotification;
-(void)saveDraftInBackground;
@end