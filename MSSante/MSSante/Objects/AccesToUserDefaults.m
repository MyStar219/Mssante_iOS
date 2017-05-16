//
//  AccesToUserDefaults.m
//  MSSante
//
//  Classe de gestion de NSUserDefault
//
//  Created by Labinnovation on 17/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "AccesToUserDefaults.h"
#import "Constant.h"

static NSUserDefaults *defaults = nil;

@implementation AccesToUserDefaults

//Synchronise
+(void)synchronize{
    [[self getUserDefaults] synchronize];
}

//Get UserDefaults
+(NSUserDefaults*)getUserDefaults{
    if (!defaults){
        defaults = [NSUserDefaults standardUserDefaults];
    }
    return defaults;
}
+(NSString*)getIdPush{
    return [[self getUserDefaults] objectForKey:ID_PUSH];
}

+(NSString*)getIdPushEnrolement {
    return [[self getUserDefaults] objectForKey:ID_PUSH_ENROLEMENT];
}

//Set UserDefaults
+(void)setIdPush : (NSString*) idPush{
    [[self getUserDefaults] setObject:idPush forKey:ID_PUSH];
    [self synchronize];
}

+(void)setIdPushEnrolement : (NSString*) idPush{
    [[self getUserDefaults] setObject:idPush forKey:ID_PUSH_ENROLEMENT];
    [self synchronize];
}

//Get info
+(NSMutableDictionary*)getUserInfo{
    if ([[self getUserDefaults] objectForKey:USER]){
        return [[[self getUserDefaults] objectForKey:USER] mutableCopy];
    }
    else {
        return nil;
    }
}
+(NSString*)getUserInfoCode{
    if ([self getUserInfo]){
        return [[self getUserInfo] objectForKey:QR_CODE];
    }
    else {
        return nil;
    }
}
+(NSString*)getUserInfoNom{
    if ([self getUserInfo]){
        return [[self getUserInfo] objectForKey:QR_NOM];
    }
    else {
        return @"";
    }
}
+(NSString*)getUserInfoPrenom{
    if ([self getUserInfo]){
        return [[self getUserInfo] objectForKey:QR_PRENOM];
    }
    else {
        return @"";
    }
}
+(NSString*)getUserInfoIdCanal{
    if ([self getUserInfo]){
        return [[self getUserInfo] objectForKey:ID_CANAL];
    }
    else {
        return nil;
    }
}
+(NSString*)getUserInfoPassword{
    if ([self getUserInfo]){
        return [[self getUserInfo] objectForKey:PASSWORD];
    }
    else {
        return nil;
    }
}

+(NSString*)getUserInfoSaltedPassword{
    if ([self getUserInfo]){
        return [[self getUserInfo] objectForKey:SALTED_PASSWORD];
    }
    else {
        return nil;
    }
}
+(NSString*)getUserInfoChoiceMail{
    if ([self getUserInfo]){
        return [[self getUserInfo] objectForKey:CHOICE_MAIL];
    }
    else {
        return nil;
    }
}
+(NSString*)getUserInfoIdNat{
    if ([self getUserInfo]){
        return [[self getUserInfo] objectForKey:QR_IDNAT];
    }
    else {
        return nil;
    }
}
+(NSString*)getUserInfoIdEnv{
    if ([self getUserInfo]){
        return [[self getUserInfo] objectForKey:QR_IDENV];
    }
    else {
        return nil;
    }
}

+(BOOL)getUserInfoEnrollement{
    return [self getUserInfo] != nil && [[[self getUserInfo] objectForKey:ENROLLEMENT] boolValue];
}
//+(BOOL)getUserInfoRememberMe{
//    return [self getUserInfo] != nil && [[[self getUserInfo] objectForKey:REMEMBER_ME] boolValue];
//}

+(NSNumber*)getUserInfoSyncToken{
    if ([self getUserInfo]){
        return [[self getUserInfo] objectForKey:SYNC_TOKEN];
    }
    else {
        return nil;
    }
}

+(NSNumber*)getUserInfoLoginCounter{
    if ([self getUserInfo]){
        return [[self getUserInfo] objectForKey:LOGIN_COUNTER];
    }
    else {
        return nil;
    }
}

+(NSNumber*)getUserInfoLoginTimestamp{
    if ([self getUserInfo]){
        return [[self getUserInfo] objectForKey:LOGIN_TIMESTAMP];
    }
    else {
        return nil;
    }
}
+(NSMutableDictionary*)getUserInfoWrongFolderInitDictionary{
    if ([[self getUserDefaults] objectForKey:WRONG_FOLDER_INIT_DICT]){
        return [[[self getUserDefaults] objectForKey:WRONG_FOLDER_INIT_DICT] mutableCopy];
    }
    else {
        return nil;
    }
}

+(NSString*)getUserInfoLastSyncDate {
    if ([self getUserInfo]){
        return [[self getUserInfo] objectForKey:LAST_SYNC_DATE];
    }
    else {
        return nil;
    }
}

+(BOOL)getUserInfoEmailNotification {

    return [self getUserInfo] != nil && [[[self getUserInfo] objectForKey:EMAIL_NOTIFICATION_STATUS] boolValue];
}

+(BOOL)getUserInfoEmailNotificationInitalized {
    return [self getUserInfo] != nil && [[[self getUserInfo] objectForKey:EMAIL_NOTIFICATION_STATUS_INIT] boolValue];
}

+(NSTimeInterval)getUserInfoLastActivityTime {
    if ([self getUserInfo]){
        return [[[self getUserInfo] objectForKey:LAST_ACTIVITY_TIME] doubleValue];
    }
    else {
        return 0;
    }
}

//Set info
+(void)setUserInfo : (NSMutableDictionary*) userInfo{
    [[self getUserDefaults] setObject:userInfo forKey:USER];
    [self synchronize];
}
+(void)setUserInfoCode:(NSString*)code{
    NSMutableDictionary *userInfo = [self getUserInfo];
    if (!userInfo){
        userInfo = [[NSMutableDictionary alloc] init];
    }
    [userInfo setObject:code forKey:QR_CODE];
    [self setUserInfo:userInfo];
}
+(void)setUserInfoNom:(NSString*)nom{
    NSMutableDictionary *userInfo = [self getUserInfo];
    if (!userInfo){
        userInfo = [[NSMutableDictionary alloc] init];
    }
    [userInfo setObject:nom forKey:QR_NOM];
    [self setUserInfo:userInfo];
}
+(void)setUserInfoPrenom:(NSString*)prenom{
    NSMutableDictionary *userInfo = [self getUserInfo];
    if (!userInfo){
        userInfo = [[NSMutableDictionary alloc] init];
    }
    [userInfo setObject:prenom forKey:QR_PRENOM];
    [self setUserInfo:userInfo];
}
+(void)setUserInfoIdCanal:(NSString*)idCanal{
    NSMutableDictionary *userInfo = [self getUserInfo];
    if (!userInfo){
        userInfo = [[NSMutableDictionary alloc] init];
    }
    [userInfo setObject:idCanal forKey:ID_CANAL];
    [self setUserInfo:userInfo];
}
+(void)setUserInfoPassword:(NSString*)password{
    NSMutableDictionary *userInfo = [self getUserInfo];
    if (!userInfo){
        userInfo = [[NSMutableDictionary alloc] init];
    }
    [userInfo setObject:password forKey:PASSWORD];
    [self setUserInfo:userInfo];
}

+(void)setUserInfoSaltedPassword:(NSString*)password{
    NSMutableDictionary *userInfo = [self getUserInfo];
    if (!userInfo){
        userInfo = [[NSMutableDictionary alloc] init];
    }
    [userInfo setObject:password forKey:SALTED_PASSWORD];
    [self setUserInfo:userInfo];
}

+(void)setUserInfoChoiceMail:(NSString*)choiceMail{
    NSMutableDictionary *userInfo = [self getUserInfo];
    if (!userInfo){
        userInfo = [[NSMutableDictionary alloc] init];
    }
    [userInfo setObject:choiceMail forKey:CHOICE_MAIL];
    [self setUserInfo:userInfo];
}
+(void)setUserInfoIdNat:(NSString*)idNat{
    NSMutableDictionary *userInfo = [self getUserInfo];
    if (!userInfo){
        userInfo = [[NSMutableDictionary alloc] init];
    }
    [userInfo setObject:idNat forKey:QR_IDNAT];
    [self setUserInfo:userInfo];
}
+(void)setUserInfoIdEnv:(NSString*)idEnv{
    NSMutableDictionary *userInfo = [self getUserInfo];
    if (!userInfo){
        userInfo = [[NSMutableDictionary alloc] init];
    }
    [userInfo setObject:idEnv forKey:QR_IDENV];
    [self setUserInfo:userInfo];
}
+(void)setUserInfoEnrollement:(BOOL)isEnrolled{
    NSMutableDictionary *userInfo = [self getUserInfo];
    if (!userInfo){
        userInfo = [[NSMutableDictionary alloc] init];
    }
    NSNumber* enrolledNumber = [NSNumber numberWithBool:isEnrolled];
    [userInfo setObject:enrolledNumber forKey:ENROLLEMENT];
    [self setUserInfo:userInfo];
}
//+(void)setUserInfoRememberMe:(BOOL)isRemember{
//    NSMutableDictionary *userInfo = [self getUserInfo];
//    if (!userInfo){
//        userInfo = [[NSMutableDictionary alloc] init];
//    }
//    NSNumber* rememberNumber = [NSNumber numberWithBool:isRemember];
//    [userInfo setObject:rememberNumber forKey:REMEMBER_ME];
//    [self setUserInfo:userInfo];
//}
+(void)setUserInfoSyncToken:(NSNumber*)syncToken{
    NSMutableDictionary *userInfo = [self getUserInfo];
    if (!userInfo){
        userInfo = [[NSMutableDictionary alloc] init];
    }
    [userInfo setObject:syncToken forKey:SYNC_TOKEN];
    [self setUserInfo:userInfo];
}

+(void)deleteSyncToken {
    NSMutableDictionary *userInfo = [self getUserInfo];
    if (!userInfo){
        userInfo = [[NSMutableDictionary alloc] init];
    }
    
    if ([userInfo objectForKey:SYNC_TOKEN]) {
        [userInfo removeObjectForKey:SYNC_TOKEN];
    }
    
    [self setUserInfo:userInfo];
}

+(void)setUserInfoLoginCounter:(NSNumber*)loginCounter{
    NSMutableDictionary *userInfo = [self getUserInfo];
    if (!userInfo){
        userInfo = [[NSMutableDictionary alloc] init];
    }
    [userInfo setObject:loginCounter forKey:LOGIN_COUNTER];
    [self setUserInfo:userInfo];
}
+(void)setUserInfoLoginTimestamp:(NSNumber*)loginTimestamp{
    NSMutableDictionary *userInfo = [self getUserInfo];
    if (!userInfo){
        userInfo = [[NSMutableDictionary alloc] init];
    }
    [userInfo setObject:loginTimestamp forKey:LOGIN_TIMESTAMP];
    [self setUserInfo:userInfo];
}
+(void)setUserInfoWrongFolderInitDictionary:(NSMutableDictionary *)wrongFolderInitDictionary{
    [[self getUserDefaults] setObject:wrongFolderInitDictionary forKey:WRONG_FOLDER_INIT_DICT];
    [self synchronize];
}

+(void)setUserInfoEmailNotification:(BOOL)notificationStatus {
    NSMutableDictionary *userInfo = [self getUserInfo];
    if (!userInfo){
        userInfo = [[NSMutableDictionary alloc] init];
    }
    [userInfo setObject:[NSNumber numberWithBool:notificationStatus] forKey:EMAIL_NOTIFICATION_STATUS];
    [self setUserInfo:userInfo];
}

+(void)setUserInfoEmailNotificationInitailized:(BOOL)notificationStatus {
    NSMutableDictionary *userInfo = [self getUserInfo];
    if (!userInfo){
        userInfo = [[NSMutableDictionary alloc] init];
    }
    [userInfo setObject:[NSNumber numberWithBool:notificationStatus] forKey:EMAIL_NOTIFICATION_STATUS_INIT];
    [self setUserInfo:userInfo];
}

+(void)setUserInfoLastActivityTime:(NSTimeInterval)time {
    NSMutableDictionary *userInfo = [self getUserInfo];
    if (!userInfo){
        userInfo = [[NSMutableDictionary alloc] init];
    }
    [userInfo setObject:[NSNumber numberWithDouble:time] forKey:LAST_ACTIVITY_TIME];
    [self setUserInfo:userInfo];
}

+(void)resetUserInfo{
    [self setUserInfo:nil];
    [self setUserInfoWrongFolderInitDictionary:nil];
}

+(void)setUserInfoLastSyncDate:(NSString*)syncDate {
    NSMutableDictionary *userInfo = [self getUserInfo];
    if (!userInfo){
        userInfo = [[NSMutableDictionary alloc] init];
    }
    [userInfo setObject:syncDate forKey:LAST_SYNC_DATE];
    [self setUserInfo:userInfo];
}

@end
