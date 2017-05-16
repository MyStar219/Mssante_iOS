//
//  RequestFinishedDelegate.h
//  httpClient
//
//  Created by Work on 6/20/13.
//  Copyright (c) 2013 Work. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Error.h"

@protocol RequestFinishedDelegate <NSObject>

-(void)httpResponse:(id)_responseObject;

-(void)httpError:(Error*)_error;

@end
