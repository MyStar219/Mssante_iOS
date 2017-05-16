//
//  urls.h
//  MSSante
//
//  Created by Labinnovation on 08/11/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//
#import "defaultUrl.h"
#import <UIKit/UIKit.h>
#ifndef MSSante_urls_h
#define MSSante_urls_h


NSString * getIdEnv () {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    NSString * idEnv=[preferences objectForKey:@"DefaultEnv"];
    if(!idEnv||[idEnv isEqualToString:@""]){
        idEnv=DEFAULT_ENV;
    }
    return idEnv;
}

#ifndef SERVER_IDP
NSString * getServerIdp(){
    NSDictionary *datas = [NSDictionary dictionaryWithContentsOfFile: ([[NSBundle mainBundle] pathForResource:@"urls" ofType:@"plist" inDirectory:getIdEnv () ])];
    return [datas objectForKey:@"SERVER_IDP"];
}
#define SERVER_IDP getServerIdp()
#endif
#ifndef SERVER_MSS
NSString * getServerMss(){
    NSDictionary *datas = [NSDictionary dictionaryWithContentsOfFile: ([[NSBundle mainBundle] pathForResource:@"urls" ofType:@"plist" inDirectory:getIdEnv () ])];
    return [datas objectForKey:@"SERVER_MSS"];
}
#define SERVER_MSS getServerMss()
#endif
#ifndef SERVER_ENROLLEMENT
NSString * getServerEnrollement(){
    NSDictionary *datas = [NSDictionary dictionaryWithContentsOfFile: ([[NSBundle mainBundle] pathForResource:@"urls" ofType:@"plist" inDirectory:getIdEnv () ])];
    return [datas objectForKey:@"SERVER_ENROLLEMENT"];
}
#define SERVER_ENROLLEMENT getServerEnrollement()
#endif
#ifndef ID_PROVIDER_DOMAIN
NSString * getServerDomain(){
    NSDictionary *datas = [NSDictionary dictionaryWithContentsOfFile: ([[NSBundle mainBundle] pathForResource:@"urls" ofType:@"plist" inDirectory:getIdEnv () ])];
    return [datas objectForKey:@"ID_PROVIDER_DOMAIN"];
}
#define ID_PROVIDER_DOMAIN getServerDomain()
//#define ConnectionLog(...)
//#define DLog(...)
#endif
#endif


