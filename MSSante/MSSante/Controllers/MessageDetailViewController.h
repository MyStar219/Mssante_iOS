//
//  MessageDetailViewController.h
//  MSSante
//
//  Created by Labinnovation on 14/10/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"
#import "Email.h"
#import "Constant.h"
#import "RequestFinishedDelegate.h"
#import "MasterViewController.h"
#import "CurrentMessage.h"
#import "Message.h"


@interface MessageDetailViewController : UITableViewController <RequestFinishedDelegate, UIDocumentInteractionControllerDelegate> {
    Message *message;
    BOOL hasAttachments;
    BOOL hasCC;
    BOOL hasCCi;
    NSUInteger numberOfAttachments;
    id<DetailDelegate> __unsafe_unretained delegate;
    UIDocumentInteractionController *documentController;
}
@property (unsafe_unretained) id delegate;

@property (strong, nonatomic) MasterViewController *masterViewController;
@property (strong, nonatomic) NSNumber *detailItem;
@property (strong, nonatomic) Message *message;
@property (assign, nonatomic) BOOL showCci;
@property (strong, nonatomic) UILabel *noEmailsLabel;
-(void)setDefaultParamsDetail;
- (void)reloadDetailsView;
-(void)reloadData;
- (void)setBlankView:(NSNumber *)msgId;

@end
