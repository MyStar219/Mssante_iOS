//
//  ListEmailsResponse.m
//  MSSante
//
//  Created by Labinnovation on 03/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "ListEmailsResponse.h"

@implementation ListEmailsResponse

@synthesize emails, responseObject;

- (id)parseJSONObject {
    emails = [[NSMutableArray alloc] init];
    if(!jsonError) {
        if([[jsonObject objectForKey:LIST_EMAILS_OUTPUT] isKindOfClass:[NSDictionary class]]) {
            id _emails = [jsonObject objectForKey:LIST_EMAILS_OUTPUT];
            if ([[_emails objectForKey:EMAILS] isKindOfClass:[NSArray class]]) {
                emails = [_emails objectForKey:EMAILS];
            } else if ([[_emails objectForKey:EMAILS] isKindOfClass:[NSString class]] && [[_emails objectForKey:EMAILS] length] > 0) {
                [emails addObject:[_emails objectForKey:EMAILS]];
            } else {
                DLog(@"email object is invalid");
            }
        }
        else {
            DLog(@"listEmailsInput object is invalid");
        }
        
    } else {
        DLog(@"Error parsing json : %@", jsonError);
    }
    responseObject = emails;
    return responseObject;
}

@end
