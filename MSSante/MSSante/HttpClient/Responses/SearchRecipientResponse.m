//
//  SearchRecipientResponse.m
//  MSSante
//
//  Created by Labinnovation on 28/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "SearchRecipientResponse.h"
#import "Professionel.h"

@implementation SearchRecipientResponse

@synthesize listProfessionels;

@synthesize responseObject;

- (id)parseJSONObject {
    listProfessionels = [[NSMutableArray alloc] init];
    if(!jsonError) {
        if ([[jsonObject objectForKey:SEARCH_RECIPIENT_OUTPUT] isKindOfClass: [NSDictionary class]]) {
            id searchOutput = [jsonObject objectForKey:SEARCH_RECIPIENT_OUTPUT];
            if([[searchOutput objectForKey:PROFESSIONELS] isKindOfClass:[NSArray class]]) {
                NSArray *_professionels = [searchOutput objectForKey:PROFESSIONELS];
                for(int i = 0 ; i < [_professionels count]; i++) {
                    if([[_professionels objectAtIndex:i] isKindOfClass: [NSDictionary class]]) {
                        NSDictionary *_professionelDictionary = [_professionels objectAtIndex:i];
                        Professionel *tmpProfessionel = [self parseProfessionel:_professionelDictionary];
                        [listProfessionels addObject:tmpProfessionel];
                    }
                }
            } else if ([[searchOutput objectForKey:PROFESSIONELS] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *_professionelDictionary = [searchOutput objectForKey:PROFESSIONELS];
                 Professionel *tmpProfessionel = [self parseProfessionel:_professionelDictionary];
                [listProfessionels addObject:tmpProfessionel];
            }
        } else {
            //Pas de message : searchOutput est un string : {searchOutput:""}
        }
    } else {
        DLog(@"Error parsing json : %@", jsonError);
    }
    responseObject = listProfessionels;
    return responseObject;

}

@end
