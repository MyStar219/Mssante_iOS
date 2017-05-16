//
//  DownloadAttachmentInput.m
//  MSSante
//
//  Created by Labinnovation on 13/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "DownloadAttachmentInput.h"

@implementation DownloadAttachmentInput

@synthesize messageId, part;

- (id)init {
    self = [super init];
    return self;
}

- (NSDictionary*)generate {
    if (messageId) {[input setObject:messageId forKey:MESSAGE_ID];}
    if (part) {[input setObject:part forKey:A_PART];}
    return [NSDictionary dictionaryWithObject:input forKey:DOWNLOAD_ATTACHMENT_INPUT];
}


@end
