//
//  EnregistrerCanal.m
//  MSSante
//
//  Created by Ismail on 7/3/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "EnregistrerCanalResponse.h"

@implementation EnregistrerCanalResponse

@synthesize idCanal, responseObject;

- (id)parseJSONObject {
    idCanal = nil;
    if(!jsonError) {
        if([[jsonObject objectForKey:ENREGIST_CANAL_OUTPUT] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *enregistrerCanalOutput = [jsonObject objectForKey:ENREGIST_CANAL_OUTPUT];
            if([[enregistrerCanalOutput objectForKey:ID_CANAL] isKindOfClass:[NSNumber class]] || [[enregistrerCanalOutput objectForKey:ID_CANAL] isKindOfClass:[NSString class]]) {
                idCanal = [enregistrerCanalOutput objectForKey:ID_CANAL];
            }
        }
    } else {
        // JSON parsing error
        DLog(@"Error parsing json : %@", jsonError);
    }
    responseObject = idCanal;
    return responseObject;
} 

@end
