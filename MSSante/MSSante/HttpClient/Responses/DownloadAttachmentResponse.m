//
//  DownloadAttachmentResponse.m
//  MSSante
//
//  Created by Labinnovation on 14/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "DownloadAttachmentResponse.h"

@implementation DownloadAttachmentResponse

@synthesize file;
@synthesize responseObject;

- (id)parseJSONObject {
    [self setFile:nil];
    if(!jsonError &&
       [[jsonObject objectForKey:DOWNLOAD_ATTACHMENT_OUTPUT] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *output = [jsonObject objectForKey:DOWNLOAD_ATTACHMENT_OUTPUT];

        /* @WX - Amélioration Sonar
         * [output objectForKey:A_FILE] <=> output[A_FILE]
         */
        if (output[A_FILE]) {
            [self setFile:output[A_FILE]];
        }
    }

    [self setResponseObject:file];
    return responseObject;
}

@end
