//
//  TokenTableViewController.m
//  TokenFieldExample
//
//  Created by jac on 9/5/12.
//
//

#import "TITokenTableViewController.h"
#import "Names.h"
#import "Constant.h"
#import "DAOFactory.h"
#import "EmailDAO.h"
#import "Email.h"
#define IS_IOS_7_OR_EARLIER    ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
@class NouveauMessageViewController2;
@implementation TITokenTableViewController

@synthesize showAlreadyTokenized, sourceArray, heightView, widthView, messageView, numberOfShownCells, attachmentsTable;
@synthesize hideCiField;
@synthesize activeCellIndexPath;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // init screen size
        screenBounds = [[UIScreen mainScreen] bounds];
        screenSize = screenBounds.size;
        hideCiField = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
  //  [self setup];
}

//update height and width depending on orientation
- (void)updateOrientation {
    screenBounds = [[UIScreen mainScreen] bounds];
    screenSize = screenBounds.size;
    orientation = [UIApplication sharedApplication].statusBarOrientation;
    if(IS_IOS_7_OR_EARLIER){
        //portrait
        if(orientation == 0 || orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
            heightView = screenSize.height - 64;
            widthView = screenSize.width;
            
        } //landscape
        else if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
            heightView = screenSize.width - 64;
            widthView = screenSize.height;
        }
    }else {
        heightView = screenSize.height - 64;
        widthView = screenSize.width;
        
    }

}

- (void)setup {
    
    _tokenFields = [NSMutableArray array];
    for(NSUInteger i = 0; i < self.tokenDataSource.numberOfTokenRows; i++) {
        NSString *tokenPromptText = [self.tokenDataSource tokenFieldPromptAtRow:i];
        
        TITokenField *tokenField = [[TITokenField alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 42)];//42 size of cell
        [tokenField addTarget:self action:@selector(tokenFieldDidBeginEditing:) forControlEvents:UIControlEventEditingDidBegin];
        [tokenField addTarget:self action:@selector(tokenFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
        [tokenField addTarget:self action:@selector(tokenFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
        [tokenField addTarget:self action:@selector(tokenFieldFrameWillChange:) forControlEvents:(UIControlEvents)TITokenFieldControlEventFrameWillChange];
        [tokenField addTarget:self action:@selector(tokenFieldFrameDidChange:) forControlEvents:(UIControlEvents)TITokenFieldControlEventFrameDidChange];
        
        [tokenField addTarget:self action:@selector(tokenFieldChangedEditing:) forControlEvents:UIControlEventEditingDidBegin];
        [tokenField addTarget:self action:@selector(tokenFieldChangedEditing:) forControlEvents:UIControlEventEditingDidEnd];
        
        [tokenField setDelegate:self];
        [tokenField setPromptText:tokenPromptText];
        
        UIView *accessoryView = [self.tokenDataSource accessoryViewForField:tokenField];
        if(accessoryView) {
            [tokenField setRightView:accessoryView];
        }
        
        [_tokenFields addObject:tokenField];
    }
    
    showAlreadyTokenized = NO;
    resultsArray = [[NSMutableArray alloc] init];
    
    //TODO
    EmailDAO *emailDAO = (EmailDAO*)[[DAOFactory factory] newDAO:EmailDAO.class];
    NSMutableArray *listEmails = [[emailDAO findAllEmailsOnce] mutableCopy];
    [self setSourceArray:listEmails];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        
   		UITableViewController * tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
   		[tableViewController.tableView setDelegate:self];
   		[tableViewController.tableView setDataSource:self];
        
        if(IS_IOS_7_OR_EARLIER){
            [tableViewController setContentSizeForViewInPopover:CGSizeMake(400, 400)];

        }else{
            [tableViewController setPreferredContentSize:CGSizeMake(400, 400)];

        }

   		resultsTable = tableViewController.tableView;
   		popoverController = [[UIPopoverController alloc] initWithContentViewController:tableViewController];
   	} else {
   		resultsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0 + 1, self.view.bounds.size.width, self.view.bounds.size.height)];
   		[resultsTable setSeparatorColor:[UIColor colorWithWhite:0.85 alpha:1]];
   		[resultsTable setBackgroundColor:[UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1]];
   		[resultsTable setDelegate:self];
   		[resultsTable setDataSource:self];
   		[resultsTable setHidden:YES];
   		[self.view addSubview:resultsTable];
        [self.view  bringSubviewToFront:resultsTable];
   		popoverController = nil;
   	}
    
    self.tableView.allowsSelection = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
   	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
//    attachmentsArray = [NSMutableArray array];
    attachmentsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, numberOfShownCells * 42 + 1, widthView, 60)];
    [attachmentsTable setSeparatorColor:[UIColor colorWithWhite:0.85 alpha:1]];
    [attachmentsTable setBackgroundColor:[UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1]];
    [attachmentsTable setDelegate:self];
    [attachmentsTable setDataSource:self];
//    [attachmentsTable setHidden:YES];
    [attachmentsTable flashScrollIndicators];

    attachmentsTable.allowsSelection = YES;
    
    
   // [self.view addSubview:attachmentsTable];
   // [self.view bringSubviewToFront:attachmentsTable];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        NSUInteger rows = self.tokenDataSource.numberOfTokenRows;
        // another cell that is not a TIToken (e.g. subject, body)
        if ([self.tokenDataSource respondsToSelector:@selector(tokenTableView:numberOfRowsInSection:)]) {
            rows += [self.tokenDataSource tokenTableView:self numberOfRowsInSection:section];
        }
        DLog(@"rows %d",rows);
        return rows;
    }
    
    if (tableView == resultsTable) {
        return resultsArray.count;
    }
    
    if (tableView == attachmentsTable) {
        if ([self.tokenDataSource respondsToSelector:@selector(numberOfAttachmentsRows)]) {
            int nbAttachments = [self.tokenDataSource numberOfAttachmentsRows] ;
            int height = nbAttachments * 60;     
            DLog(@"heightView %f",heightView);
        
        
            if (nbAttachments > 2) {
                height = 150;
            }
            
            CGRect frame = attachmentsTable.frame;
            frame.size.height = height;
            frame.size.width = widthView;
            [attachmentsTable setFrame:frame];
            return nbAttachments;
        }
    }
    
    return 0;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.tableView) {
        if(indexPath.row < self.tokenDataSource.numberOfTokenRows) {
            TITokenField *tokenField = _tokenFields[indexPath.row];
            CGFloat height = tokenField.frame.size.height;
            // si on cache CCI la taille doit être 0;
            if (indexPath.row == kCellCCI && hideCiField) {
               // NSLog(@"hide CCI" );
                height = 0;
            }
            //NSLog(@"height %f",height );
            return height;

        } else {
            // a row that is not a token field: delegate
            if ([self.tokenDataSource respondsToSelector:@selector(tokenTableView:heightForRowAtIndexPath:)]) {
                NSIndexPath * idx = [NSIndexPath indexPathForRow:indexPath.row - self.tokenDataSource.numberOfTokenRows inSection:indexPath.section];
                
                if (idx.row == kOtherCellBody) {
                    float height = 0;
                    
//                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
//                        [self updateOrientation];
//                        height = heightView - 4 * 42;
//                    } else {
//                        height = self.tableView.frame.size.height - 4 * 42;
//                    }
                    
                    [self updateOrientation];
//                    DLog(@"numberOfShownCells %d",numberOfShownCells);
                    height = heightView - numberOfShownCells * 42;

                    if ([self.tokenDataSource tokenTableView: self heightForRowAtIndexPath:idx] > 0) {
                        height = [self.tokenDataSource tokenTableView: self heightForRowAtIndexPath:idx];
                    }
                    
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                        if(orientation == 0 || orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
                            height += 264;
                        } else {
                            height += 352;
                        }
                    } else {
                        height += 216;
                    }
                    
                    return height;
                }//if idx.row == CCCell do
                else {
                    return [self.tokenDataSource tokenTableView: self heightForRowAtIndexPath:idx];
                }
            }
        }
        
    }
    if (tableView == resultsTable) {
        //todo ???
//                if (tokenField && [tokenField.delegate respondsToSelector:@selector(tokenField:resultsTableView:heightForRowAtIndexPath:)]){
//               		return [TITokenField.delegate tokenField:tokenField resultsTableView:tableView heightForRowAtIndexPath:indexPath];
//               	}
//        
        	return 44;
       // return 0;
    }
    
    if (tableView == attachmentsTable) {
        
        return 60;
    }

    
    
    return 0;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    // DISPLAYING THE TOKEN TABLE
    if (tableView == self.tableView) {
        static NSString *CellIdentifiert = @"Cellttilopkl";
        // any TokenCell
        if (indexPath.row < self.tokenDataSource.numberOfTokenRows) {
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifiert];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifiert];
                // get the token field from dictionary using the delegated title text as key
                cell.backgroundColor = [UIColor whiteColor];
            }
            
            TITokenField *tokenField = _tokenFields[indexPath.row];
            
            BOOL addSubview = YES;
            for (UIView * subView in [cell.contentView subviews]) {
                if(subView == tokenField) {
                    addSubview = NO;
                    break;
                }
            }
            
            if(addSubview) {
                [cell.contentView addSubview:tokenField];
            }
            
            if (indexPath.row == kCellCCI && hideCiField) {
                for (UIView * subView in [cell.contentView subviews]) {
                    [subView removeFromSuperview];
                }
                
            }
            
        } else {
            // another cell that is not a TIToken (e.g. subject, body)
            if ([self.tokenDataSource respondsToSelector:@selector(tokenTableView:cellForRowAtIndexPath:)]) {
                NSIndexPath *idx = [NSIndexPath indexPathForRow:indexPath.row - self.tokenDataSource.numberOfTokenRows inSection:indexPath.section];
                cell = [self.tokenDataSource tokenTableView:self cellForRowAtIndexPath:idx];
            }
        }
        
    }
    
    
    // DISPLAYING THE SEARCH RESULT
    if (tableView == resultsTable) {
        Email* email = [resultsArray objectAtIndex:(NSUInteger) indexPath.row];
        
        
        //todo, shall the delegate be able to give a result cell ?
        if ([_currentSelectedTokenField.delegate respondsToSelector:@selector(tokenField:resultsTableView:cellForRepresentedObject:)]) {
           return
        [_currentSelectedTokenField.delegate tokenField:_currentSelectedTokenField resultsTableView:tableView cellForRepresentedObject:email.name];
        }
        
        static NSString *CellIdentifier = @"ResultsCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
//        NSString *subtitle = [self searchResultSubtitleForRepresentedObject:representedObject.name inTokenField:_currentSelectedTokenField];
        NSString* subtitle = email.address;
        if (!cell) {
            NSInteger style = UITableViewCellStyleDefault;
            if (subtitle) {
                  style = UITableViewCellStyleSubtitle;
            }
            cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:CellIdentifier];
        }
        
        cell.detailTextLabel.text = subtitle;
        [cell.textLabel setTextColor:[UIColor colorWithRed:0.1294 green:0.3686 blue:0.4470 alpha:1]];
        [cell.textLabel setFont:[UIFont boldSystemFontOfSize:16]];
        //[cell.textLabel setText:[self searchResultStringForRepresentedObject:email.name]];
        [cell.textLabel setText:[self searchResultStringForRepresentedObject:email.address]];
    }
    
    if (tableView == attachmentsTable) {
        return [self.tokenDataSource attachmentsTableView:tableView cellForRowAtIndexPath:indexPath];
    }

    
    // Configure the cell...
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
     if (tableView == resultsTable) {
         return HEIGHT_FOOTER_BACK_MENU;
     }
     else{
         return 0;
     }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (tableView == resultsTable) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, resultsTable.frame.size.width, HEIGHT_FOOTER_BACK_MENU)];
        [view setBackgroundColor:[UIColor darkGrayColor]];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, resultsTable.frame.size.width, HEIGHT_FOOTER_BACK_MENU)];
        label.text = @"Elargir la recherche";
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setTextColor:[UIColor whiteColor]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setUserInteractionEnabled:YES];
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(callAnnuaire:)];
        [tapGestureRecognizer setNumberOfTapsRequired:1];
        [label addGestureRecognizer:tapGestureRecognizer];
        
        [view addSubview:label];
        
        return view;
    }
    else{
        return nil;
    }
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (tableView == self.tableView) {
        activeCellIndexPath = indexPath;
        DLog(@"didSelectRowAtIndexPath activeCellIndexPath %@",indexPath);
        if ([self.delegate respondsToSelector:@selector(tokenTableViewController:didSelectRowAtIndex:)]) {
            NSInteger row = indexPath.row - self.tokenDataSource.numberOfTokenRows;
            [self.delegate tokenTableViewController:self didSelectRowAtIndex:row];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    if (tableView == resultsTable) {
        
        TITokenField *tokenField = _currentSelectedTokenField;
        if (tokenField) {
            Email* representedObject = [resultsArray objectAtIndex:(NSUInteger) indexPath.row];
            TIToken *token = [[TIToken alloc] initWithTitle:[self displayStringForRepresentedObject:representedObject.address] representedObject:representedObject];
            [tokenField addToken:token];

            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self setSearchResultsVisible:NO forTokenField:tokenField];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didAddToken" object:tokenField];            
            
        }
    }
    
    if (tableView == attachmentsTable) {
        DLog(@"didSelectRowAtIndexPath activeCellIndexPath %@",indexPath);
        [self.tokenDataSource attachmentsTableView:attachmentsTable didSelectRowAtIndex:indexPath];
    }
    
}

#pragma mark TextField Methods

#pragma mark TextField Methods

- (void)tokenFieldDidBeginEditing:(TITokenField *)field {
    
    if([self.delegate respondsToSelector:@selector(tokenTableViewController:didSelectTokenField:)]) {
        [self.delegate tokenTableViewController:self didSelectTokenField:field];
    }
    
    _currentSelectedTokenField = field;
    
    UIView * cell = field.superview;
    while (cell && ![cell isKindOfClass:[UITableViewCell class]]) {
        cell = cell.superview;
    }
    
	[resultsArray removeAllObjects];
	[resultsTable reloadData];
}

- (void)tokenFieldDidEndEditing:(TITokenField *)field {
	[self tokenFieldDidBeginEditing:field];
    [self setSearchResultsVisible:NO forTokenField:field];
    
    _currentSelectedTokenField = nil;
    
    if([self.delegate respondsToSelector:@selector(tokenTableViewController:didSelectTokenField:)]) {
        [self.delegate tokenTableViewController:self didSelectTokenField:field];
    }
}

- (void)tokenFieldTextDidChange:(TITokenField *)field {
	[self resultsForSearchString:[field.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
}

- (void)tokenFieldFrameWillChange:(TITokenField *)field {
    
    // this resizes the table cells animated
    [self updateContentSize];
    
}

- (void)tokenFieldFrameDidChange:(TITokenField *)field {
    //[self.tableView endUpdates];
    //	[self updateContentSize];
}

#pragma mark Results Methods
- (NSString *)displayStringForRepresentedObject:(id)object {
    
    TITokenField *tokenField = _currentSelectedTokenField;
    
	if ([tokenField.delegate respondsToSelector:@selector(tokenField:displayStringForRepresentedObject:)]){
		return [tokenField.delegate tokenField:tokenField displayStringForRepresentedObject:object];
	}
    
	if ([object isKindOfClass:[NSString class]]){
		return (NSString *)object;
	}
    
	return [NSString stringWithFormat:@"%@", object];
}

- (NSString *)searchResultStringForRepresentedObject:(id)object   {
    TITokenField *tokenField = _currentSelectedTokenField;
    
	if ([tokenField.delegate respondsToSelector:@selector(tokenField:searchResultStringForRepresentedObject:)]){
		return [tokenField.delegate tokenField:tokenField searchResultStringForRepresentedObject:object];
	}
    
	return [self displayStringForRepresentedObject:object];
}

- (NSString *)searchResultSubtitleForRepresentedObject:(id)object inTokenField:(TITokenField *)tokenField {
    
	if ([tokenField.delegate respondsToSelector:@selector(tokenField:searchResultSubtitleForRepresentedObject:)]){
		return [tokenField.delegate tokenField:tokenField searchResultSubtitleForRepresentedObject:object];
	}
    
	return nil;
}

- (void)setSearchResultsVisible:(BOOL)visible forTokenField:(TITokenField *)tokenField {
//    DLog(@"setSearchResultsVisible");
    // dont set it twice
    if (_searchResultIsVisible == visible) {
        return;
    }
    
    _searchResultIsVisible = visible;
    
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        
		if (visible) [self presentpopoverAtTokenFieldCaretAnimated:YES inTokenField:tokenField];
		else [popoverController dismissPopoverAnimated:YES];
	}
	else
	{
        //CGPoint tableOrigin = [tokenField convertPoint:tokenField.frame.origin toView:self.view];
        
        //CGPoint newOrigin = [self.tableView convertPoint:self.tableView.bounds.origin toView:tokenField];
        //CGRect newFrame = ((CGRect) {newOrigin, tokenField.frame.size});
        
        //CGFloat tokenFieldBottom = CGRectGetMaxY([tokenField convertRect:newFrame toView:self.view]);
        
        CGFloat tokenFieldBottom = CGRectGetMaxY([tokenField convertRect:tokenField.frame toView:self.view]);
        
        DLog(@"tokenFieldBottom %f", tokenFieldBottom);
        NSInteger scrollToRow = 0;
        
        if (visible) {
            // showing the search result table: scroll the current cell to top
            NSInteger count = self.tokenDataSource.numberOfTokenRows;
            for (NSUInteger row = 0; row < count; row++) {
                NSString *rowPrompt = [self.tokenDataSource tokenFieldPromptAtRow:row];
                if([rowPrompt isEqualToString:@"Cc/Cci :"]){
                    rowPrompt = @"Cc :";
                }
                if ([rowPrompt isEqualToString:tokenField.promptText]) {
                    scrollToRow = row;
                    break;
                }
            }
            
            CGFloat heightMax = 40;
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                if (heightView == 504.0f) {
                    heightMax = 120;
                }
            }
            
            // size is from the token till the beginning of the keyboard
            CGFloat tableHeight = self.view.bounds.size.height - tokenField.frame.size.height;
            if (tokenField.frame.size.height > heightMax) {
//                tableHeight -= (tokenField.frame.size.height - 150);
                tableHeight += tokenField.frame.size.height - 42;
//                tokenFieldBottom = 41;
                
            }
         
            //on fixe la frame que prendra la scrollable view des adresses de l'annuaire
            //TODO ecran iphone 5 ,6 et Ipad mini
            tableHeight = MAX([[UIScreen mainScreen]bounds].size.height -20 - 50 - tokenField.frame.size.height - 216 +5,44);
            
            
            NSLog(@"self.view.bounds.size.height  %f", self.view.bounds.size.height);
            NSLog(@"fieldHeight %f", tokenField.frame.size.height);
            NSLog(@"tableHeight %f", tableHeight);
            resultsTable.frame = CGRectMake(0, tokenFieldBottom + 1, self.view.bounds.size.width, tableHeight);
            [self.view bringSubviewToFront:resultsTable];
            
            
            _contentOffsetBeforeResultTable = self.tableView.contentOffset;
            
            // find the containing cell to bring it to front
            UIView *cell = tokenField.superview;
            while (cell && ![cell isKindOfClass:[UITableViewCell class]]) {
                cell = cell.superview;
            }
            
            if (cell) {
                [self.tableView bringSubviewToFront:cell];
            }
            
            NSIndexPath * idx = [NSIndexPath indexPathForRow:scrollToRow inSection:0];
            //[self.tableView scrollRectToVisible: animated:YES];
            //[self.tableView scrollViewToTextField:tokenField];
            [self.tableView scrollToRowAtIndexPath:idx atScrollPosition:UITableViewScrollPositionNone animated:NO];
            
            //CGFloat height = tokenField.frame.size.height;
            UIScrollView *myTableView;
            
            if([self.tableView.superview isKindOfClass:[UIScrollView class]]) {
                myTableView = (UIScrollView *)self.tableView.superview;
            } else {
                myTableView = self.tableView;
            }
            
           /*
            if (height > heightMax) {
                UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 40, 0.0);
                myTableView.contentInset = contentInsets;
                myTableView.scrollIndicatorInsets = contentInsets;
                
                CGPoint scrollPoint = CGPointMake(0.0, tokenField.frame.size.height-40);
                if ([[tokenField promptText] isEqual:CC]) {
                    scrollPoint.y += 41;
                }
                if ([[tokenField promptText] isEqual:CI]) {
                    scrollPoint.y += 82;
                }
                [myTableView setContentOffset:scrollPoint animated:NO];

            } else {
                UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
                myTableView.contentInset = contentInsets;
                myTableView.scrollIndicatorInsets = contentInsets;
                
                CGPoint scrollPoint = CGPointMake(0.0, tokenField.frame.origin.y);
                if ([[tokenField promptText] isEqual:CC]) {
                    scrollPoint.y += 42;
                }
                if ([[tokenField promptText] isEqual:CI]) {
                    scrollPoint.y += 84;
                }
                
                [myTableView setContentOffset:scrollPoint animated:NO];

            }*/
        } else {
            // hiding result table, scroll back to where we were,
            [self.tableView setContentOffset:_contentOffsetBeforeResultTable];
        }
        
        
        [resultsTable setHidden:!visible];
        [tokenField setResultsModeEnabled:visible];
        
        
        
        
        self.tableView.scrollEnabled = !visible;
        
        
    }
}

- (void)resultsForSearchString:(NSString *)searchString {
    
    TITokenField *tokenField = _currentSelectedTokenField;
	// The brute force searching method.
	// Takes the input string and compares it against everything in the source array.
	// If the source is massive, this could take some time.
	// You could always subclass and override this if needed or do it on a background thread.
	// GCD would be great for that.
    
	[resultsArray removeAllObjects];
	[resultsTable reloadData];
    
	[sourceArray enumerateObjectsUsingBlock:^(id sourceObject, NSUInteger idx, BOOL *stop){
        Email* email = sourceObject;
		NSString * queryName = [self searchResultStringForRepresentedObject:email.name];
		NSString * queryAddress = [self searchResultStringForRepresentedObject:email.address];
//        NSString * querySubtitle = [self searchResultSubtitleForRepresentedObject:email.name inTokenField:tokenField];
		if ([queryName rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound){
            
			__block BOOL shouldAdd = ![resultsArray containsObject:email];
			if (shouldAdd && !showAlreadyTokenized){
                
				[tokenField.tokens enumerateObjectsUsingBlock:^(TIToken * token, NSUInteger idx, BOOL *secondStop){
					if ([token.representedObject isEqual:email]){
						shouldAdd = NO;
						*secondStop = YES;
					}
				}];
			}
            
			if (shouldAdd) [resultsArray addObject:email];
		}
        
        if ([queryAddress rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound){
            
			__block BOOL shouldAdd = ![resultsArray containsObject:email];
			if (shouldAdd && !showAlreadyTokenized){
                
				[tokenField.tokens enumerateObjectsUsingBlock:^(TIToken * token, NSUInteger idx, BOOL *secondStop){
					if ([token.representedObject isEqual:email]){
						shouldAdd = NO;
						*secondStop = YES;
					}
				}];
			}
            
			if (shouldAdd) [resultsArray addObject:email];
		}
	}];
    
	[resultsArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		return [[self searchResultStringForRepresentedObject:obj1 ] localizedCaseInsensitiveCompare:[self searchResultStringForRepresentedObject:obj2]];
	}];
	[resultsTable reloadData];
    if (self.isViewLoaded && self.view.window) {
        [self setSearchResultsVisible:([searchString length] > 0) forTokenField:tokenField];
    }
}

- (void)presentpopoverAtTokenFieldCaretAnimated:(BOOL)animated inTokenField:(TITokenField *)tokenField {
    
    UITextPosition * position = [tokenField positionFromPosition:tokenField.beginningOfDocument offset:2];
    
	[popoverController presentPopoverFromRect:[tokenField caretRectForPosition:position] inView:tokenField
					 permittedArrowDirections:UIPopoverArrowDirectionUp animated:animated];
}



- (void)tokenFieldChangedEditing:(TITokenField *)tokenField {
	// There's some kind of annoying bug where UITextFieldViewModeWhile/UnlessEditing doesn't do anything.
	[tokenField setRightViewMode:(tokenField.editing ? UITextFieldViewModeAlways : UITextFieldViewModeNever)];
}



-(void) updateContentSize {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}


- (void)keyboardWillShow:(NSNotification *)notification {
    
	CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	_keyboardHeight = keyboardRect.size.height > keyboardRect.size.width ? keyboardRect.size.width : keyboardRect.size.height;
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
	_keyboardHeight = 0;
}

-(void)keyboardDidHide:(NSNotification *)notification{
    //    [self updateContentSize];
    
}

- (void)dealloc {
	[self setDelegate:nil];
}




@end
