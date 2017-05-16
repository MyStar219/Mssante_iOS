//
//  ContainerViewController.h
//  MSSante
//
//  Created by Labinnovation on 29/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MasterViewController.h"
#import "MessageDetailViewController.h"

@interface ContainerViewController : UIViewController

- (void)launchControllerWithSegue:(NSString*)segue;
- (MasterViewController*)getMasterViewController;
- (MessageDetailViewController*)getDetailViewController;

@end
