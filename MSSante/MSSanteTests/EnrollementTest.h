//
//  EnrollementTest.h
//  MSSante
//
//  Created by Labinnovation on 16/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "EnrollementBController.h"
#import "EnrollementCController.h"

@interface EnrollementTest : SenTestCase
{
    
    UIWindow *window;
    EnrollementBController *controllerEnrolB;
    EnrollementCController *controllerEnrolC;
}

@end
