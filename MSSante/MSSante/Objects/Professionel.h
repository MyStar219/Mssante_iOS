//
//  Professionel.h
//  MSSante
//
//  Created by Labinnovation on 28/08/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Professionel : NSObject{
    NSString* nom;
    NSString* prenom;
    NSString* profession;
    NSString* specialite;
    NSMutableArray* numTel;
    NSMutableArray* listMails;
    NSMutableArray* listAdresse;
}

@property (nonatomic, retain) NSString* nom;
@property (nonatomic, retain) NSString* prenom;
@property (nonatomic, retain) NSString* profession;
@property (nonatomic, retain) NSString* specialite;
@property (nonatomic, retain) NSMutableArray* numTel;
@property (nonatomic, retain) NSMutableArray* listMails;
@property (nonatomic, retain) NSMutableArray* listAdresse;

@end
