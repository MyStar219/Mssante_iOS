//
//  AccesToUserDefaults.h
//  MSSante
//
//  Created by Labinnovation on 17/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccesToUserDefaults : NSObject

//Synchronize
+(void)synchronize;

//Set Defaults
+(void)setIdPush:(NSString*) idPush;
+(void)setIdPushEnrolement : (NSString*) idPush;

//Get Defaults
+(NSString*)getIdPush;
+(NSString*)getIdPushEnrolement;

//Set UserInfos
+(void)setUserInfo:(NSMutableDictionary*) userInfo;
+(void)setUserInfoEnrollement:(BOOL)isEnrolled;
+(void)setUserInfoIdNat:(NSString*)idNat;
+(void)setUserInfoIdEnv:(NSString*)idEnv;
+(void)setUserInfoChoiceMail:(NSString*)choiceMail;
+(void)setUserInfoPassword:(NSString*)password;
+(void)setUserInfoSaltedPassword:(NSString*)password;
+(void)setUserInfoIdCanal:(NSString*)idCanal;
+(void)setUserInfoPrenom:(NSString*)prenom;
+(void)setUserInfoNom:(NSString*)nom;
+(void)setUserInfoCode:(NSString*)code;
+(void)setUserInfoSyncToken:(NSNumber*)syncToken;
+(void)deleteSyncToken;
+(void)setUserInfoLoginCounter:(NSNumber*)loginCounter;
+(void)setUserInfoLoginTimestamp:(NSNumber*)loginTimestamp;
+(void)setUserInfoWrongFolderInitDictionary:(NSMutableDictionary*)wrongFolderInitDictionary;
+(void)setUserInfoLastSyncDate:(NSString*)syncDate;
+(void)setUserInfoEmailNotification:(BOOL)notificationStatus;
+(void)setUserInfoEmailNotificationInitailized:(BOOL)notificationStatus;
+(void)setUserInfoLastActivityTime:(NSTimeInterval)time;

//+(void)setUserInfoRememberMe:(BOOL)isRemember;
//Get UserInfos
+(NSMutableDictionary*)getUserInfo;
//+(BOOL)getUserInfoRememberMe;
+(BOOL)getUserInfoEnrollement;
+(NSString*)getUserInfoIdNat;
+(NSString*)getUserInfoIdEnv;
+(NSString*)getUserInfoChoiceMail;
+(NSString*)getUserInfoPassword;
+(NSString*)getUserInfoSaltedPassword;
+(NSString*)getUserInfoIdCanal;
+(NSString*)getUserInfoPrenom;
+(NSString*)getUserInfoNom;
+(NSString*)getUserInfoCode;
+(NSNumber*)getUserInfoSyncToken;
+(NSNumber*)getUserInfoLoginCounter;
+(NSNumber*)getUserInfoLoginTimestamp;
+(NSMutableDictionary*)getUserInfoWrongFolderInitDictionary;
+(NSString*)getUserInfoLastSyncDate;
+(BOOL)getUserInfoEmailNotification;
+(BOOL)getUserInfoEmailNotificationInitalized;
+(NSTimeInterval)getUserInfoLastActivityTime;
//Reset UserInfo
+(void)resetUserInfo;

@end
