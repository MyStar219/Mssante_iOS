//
//  TokenTableViewController.h
//  TokenFieldExample
//
//  Created by jac on 9/5/12.
//
//

#import <UIKit/UIKit.h>
#import "TITokenField.h"


@class TITokenTableViewController;

@protocol TITokenTableViewDataSource <NSObject>
@required



/**
* Provide a list of token filed prompt texts: "To:" "Cc:" ..
*/
-(NSString *)tokenFieldPromptAtRow:(NSUInteger) row;
-(NSUInteger) numberOfTokenRows;
-(NSUInteger) numberOfAttachmentsRows;


/**
* E.g. a browse address book button.
*/
-(UIView *) accessoryViewForField:(TITokenField*) tokenField;


/**
* Other cells that ore not TITokenFields
**/

- (UITableViewCell *)tokenTableView:(TITokenTableViewController *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (UITableViewCell *)attachmentsTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)tokenTableView:(TITokenTableViewController *)tableView numberOfRowsInSection:(NSInteger)section;

- (CGFloat)tokenTableView:(TITokenTableViewController *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)attachmentsTableView:(UITableView *)tableView didSelectRowAtIndex:(NSIndexPath *)indexPath;

@end




@protocol TITokenTableViewControllerDelegate <NSObject>

@optional
/**
* Called when a token field is selected
*/
-(void) tokenTableViewController:(TITokenTableViewController *) tokenTableViewController  didSelectTokenField:(TITokenField*) tokenField;

/**
* Called when a cell that is NOT a TIToken cell is selected
*/
- (void)tokenTableViewController:(TITokenTableViewController *)tableView didSelectRowAtIndex:(NSInteger)row;



@end



@interface TITokenTableViewController : UITableViewController <TITokenFieldDelegate> {

    NSMutableArray * resultsArray;
    UITableView * resultsTable;
    UIPopoverController * popoverController;

    NSMutableArray * _tokenFields;


    TITokenField *_currentSelectedTokenField;


    CGFloat _keyboardHeight;

    BOOL _searchResultIsVisible;

    CGPoint _contentOffsetBeforeResultTable;

    UINavigationBar *naviBarObj;
    
    UIInterfaceOrientation orientation;
    CGRect screenBounds;
    CGSize screenSize;
    
    UITableView *attachmentsTable;
    
    BOOL hideCiField;
    
    NSIndexPath *activeCellIndexPath;
@public
    float heightView;
    UITextView * messageView;
    int numberOfShownCells;
    float widthView;
}
@property(nonatomic, assign) int numberOfShownCells;
@property(nonatomic, assign) float heightView;
@property(nonatomic, assign) float widthView;
@property(nonatomic, assign) BOOL showAlreadyTokenized;
@property(nonatomic, copy) NSArray * sourceArray;
@property(nonatomic, strong) UITextView * messageView;
@property(nonatomic, strong) UITableView *attachmentsTable;
@property(nonatomic, assign) BOOL hideCiField;
@property(nonatomic, strong) NSIndexPath *activeCellIndexPath;

@property (nonatomic, weak) id<TITokenTableViewDataSource> tokenDataSource;
@property (nonatomic, weak) id<TITokenTableViewControllerDelegate> delegate;

- (void)setup;
- (void)updateContentSize;

- (void)keyboardWillShow:(NSNotification *)notification;

- (void)keyboardWillHide:(NSNotification *)notification;

- (void)updateOrientation;

@end
