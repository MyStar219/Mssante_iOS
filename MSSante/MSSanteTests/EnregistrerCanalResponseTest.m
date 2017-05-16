//
//  EnregistrerCanalResponseTest.m
//  MSSante
//
//  Created by Labinnovation on 18/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "EnregistrerCanalResponseTest.h"
#import "Constant.h"
#import "EnregistrerCanalResponse.h"

@implementation EnregistrerCanalResponseTest {
    NSMutableDictionary *enregistrerCanalObj;
    NSMutableDictionary *enregistrerCanalOutput;
    NSString *idCanal;
    EnregistrerCanalResponse *enregistrerCanalResponse;
}

- (void)setUp {
    [super setUp];
    
    enregistrerCanalObj = [NSMutableDictionary dictionary];
    enregistrerCanalOutput = [NSMutableDictionary dictionary];
    
    enregistrerCanalResponse = [[EnregistrerCanalResponse alloc] initWithJsonObject:enregistrerCanalObj];
}

- (void)tearDown {
    // Tear-down code here.
    [super tearDown];
}

- (void)testParseJSONObject {
    idCanal = [enregistrerCanalResponse parseJSONObject];
    STAssertEquals(0, [idCanal intValue], @"Impossible de parser idCanal");
    
    [enregistrerCanalObj setValue:enregistrerCanalOutput forKey:ENREGIST_CANAL_OUTPUT];
    idCanal = [enregistrerCanalResponse parseJSONObject];
    STAssertEquals(0, [idCanal intValue], @"Impossible de parser null idCanal");
    
    [enregistrerCanalOutput setValue:nil forKey:ID_CANAL];
    idCanal = [enregistrerCanalResponse parseJSONObject];
    STAssertEquals(0, [idCanal intValue], @"Impossible de parser null idCanal");
    
    [enregistrerCanalOutput setValue:@"24785954" forKey:ID_CANAL];
    idCanal = [enregistrerCanalResponse parseJSONObject];
    STAssertEquals([@"24785954" intValue], [idCanal intValue], @"CImpossible de parser string number");
    
    NSNumber *idC = [NSNumber numberWithInt:124785954];
    [enregistrerCanalOutput setValue:idC forKey:ID_CANAL];
    idCanal = [enregistrerCanalResponse parseJSONObject];
    STAssertEquals([idC intValue], [idCanal intValue], @"Impossible de parser integer number");
}
@end
