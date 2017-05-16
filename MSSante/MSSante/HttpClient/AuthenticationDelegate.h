//
//  AuthenticationDelegate.h
//  MSSante
//
//  Created by Work on 6/28/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AuthenticationDelegate <NSObject>

- (void)authResponse:(id)_samlAssertion;

- (void)authError:(id)_error;
@end
