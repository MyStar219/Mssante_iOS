//
//  Password.m
//  MSSante
//
//  Created by Labinnovation on 23/09/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "PasswordStore.h"
#import "Constant.h"
#import "AccesToUserDefaults.h"
#import "NSData+AES256.h"
#import "FDKeychain.h"
#import "Base64.h"
#import "Tools.h"
#import "Authentification.h"
#import "DAOFactory.h"

#define SALT_LENGTH                 32
#define SALT_A_LENGTH               32
#define SALT_B_LENGTH               32
#define DB_ENCRYPTION_KEY_LENGTH    64
#define DERIVED_PASSWORD_LENGTH     32

@interface PasswordStore ()
@property(nonatomic, strong) NSString *plainPassword;
@property(nonatomic, strong) NSData *derivedPassword;//KD
@property(nonatomic, strong) NSString *plainDbEncryptionKey;//KC
@property(nonatomic, strong) NSString *dbEncryptionKey;//KC Chiffré
@property(nonatomic, strong) NSData *saltedPassword;// Hash du mdp mobilité

@end

@implementation PasswordStore

@synthesize firstConnection;

static PasswordStore *instance = nil;

+(void)storeNotFirstConnexion:(BOOL)isFirstConnexion{
    [[NSUserDefaults standardUserDefaults] setBool:isFirstConnexion forKey:IS_FIRST_CONNEXION];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(BOOL)getIsNotFirstConnexion{
    return [[NSUserDefaults standardUserDefaults] boolForKey:IS_FIRST_CONNEXION];
}

-(void)initialize:(NSString *)plainPassword{
    // on sauvegarde plainpassword en mémoire
    _plainPassword = plainPassword;
    BOOL notFirstConnexion = [PasswordStore getIsNotFirstConnexion];
    // si premiere connexion

    if(!notFirstConnexion){
        [PasswordStore storeNotFirstConnexion:YES];
        // on initialise la KC
        [self initalizeFirstConnexion];
    }
    else {
        // on genere la derivé du passaword
        [self initalizeNotFirstConnexion:_plainPassword];
    }
    
    //Block generation du hash salé
    [self generateSaltedPassword:_plainPassword];
}

-(void)initalizeFirstConnexion{
    //Genere un sel pour la derivation du mot de passe (SAlt A) et un sel pour KC (SALT B)
    [self calculateSalts];
    
    //block génération du derived password
    [self generateDerivedPassword:_plainPassword];
    
    NSString *plainDbEncryptionKey = [self generatePlainDbEncryptionKey];
    [DAOFactory setKey:plainDbEncryptionKey];
    
    // on genere KC Chiffré
    _dbEncryptionKey = [self encryptItem:plainDbEncryptionKey withKey:_derivedPassword];
    
    //on persiste
    [self persistEncryptionKey:_dbEncryptionKey];
}


-(void)initalizeNotFirstConnexion:(NSString*)plainPassword {
    [self generateDerivedPassword:plainPassword];
    _dbEncryptionKey = [self getDbEncryptionKey];
}


 //Block génération du derived password
-(void)generateDerivedPassword:(NSString*)plainPassword{
    NSString *saltA = [PasswordStore getSaltA];
    
    // on calcul KD le derive de password
    _derivedPassword = [self calculateDerivedPassword:plainPassword salt:saltA];
}

//Block generation du hash salé
-(void)generateSaltedPassword:(NSString*)plainPassword{
    
    NSString *saltB = [PasswordStore getSaltB];

    // On calcul le hash salé du plain PASSWORD
    _saltedPassword = [PasswordStore calculSaltedPassword:plainPassword salt:saltB];
    
    //on persiste
    [self persisteSaltedPassword:_saltedPassword];

}
    //    NSData *saltedPassword = [self getPersistedSaltedPassword];
    //        NSLog(@"PasswordStore initialise getPersistedSaltedPassword %@",saltedPassword);
    //    if (saltedPassword.length > 0) {
    //        DLog(@"PasswordStore : initalize : saltedPassword : %@",saltedPassword);
    //        _saltedPassword = saltedPassword;
    //    }
    //
    ////    NSString *salt = [self getPersistedItem:SALT];
    ////    if (salt.length > 0) {
    ////        DLog(@"PasswordStore : initalize : salt : %@",salt);
    ////        _salt = salt;
    ////    }
    //
    //    NSString *saltAOne = [self getPersistedItem:SALT_A_ONE];
    //    NSString *saltATwo = [self getPersistedItem:SALT_A_TWO];
    //    NSString *saltAThree = [self getPersistedItem:SALT_A_THREE];
    //    DLog(@"saltAOne : %@ , saltATwo : %@ , saltAThree : %@",saltAOne, saltATwo, saltAThree);
    //    NSLog(@"saltAOne : %@ , saltATwo : %@ , saltAThree : %@",saltAOne, saltATwo, saltAThree);
    //    if (saltAOne.length > 0 && saltATwo.length > 0 && saltAThree.length > 0) {
    //        _saltAOne = saltAOne;
    //        _saltATwo = saltATwo;
    //        _saltAThree = saltAThree;
    //        _saltA = [NSString stringWithFormat:@"%@%@%@",saltAOne, saltATwo, saltAThree];
    //        DLog(@"PasswordStore : initalize : saltA : %@",_saltA);
    //        NSLog(@"PasswordStore : initalize : saltA : %@",_saltA);
    //    }
    //
    ////    NSString *saltA = [self getPersistedItem:SALT_A];
    ////    if (saltA.length > 0) {
    ////        DLog(@"PasswordStore : initalize : saltA : %@",saltA);
    ////        _saltA = saltA;
    ////    }
    //
    //
    //    NSString *saltBOne = [self getPersistedItem:SALT_B_ONE];
    //    NSString *saltBTwo = [self getPersistedItem:SALT_B_TWO];
    //    NSString *saltBThree = [self getPersistedItem:SALT_B_THREE];
    //
    //    DLog(@"saltBOne : %@ , saltBTwo : %@ , saltBThree : %@",saltBOne, saltBTwo, saltBThree);
    //    NSLog(@"saltBOne : %@ , saltBTwo : %@ , saltBThree : %@",saltBOne, saltBTwo, saltBThree);
    //    if (saltBOne.length > 0 && saltBTwo.length > 0 && saltBThree.length > 0) {
    //        _saltBOne = saltBOne;
    //        _saltBTwo = saltBTwo;
    //        _saltBThree = saltBThree;
    //        _saltB = [NSString stringWithFormat:@"%@%@%@",saltBOne, saltBTwo, saltBThree];
    //        DLog(@"PasswordStore : initalize : saltB : %@",_saltB);
    //        NSLog(@"PasswordStore : initalize : saltB : %@",_saltB);
    //    }
    //
    //
    ////    NSString *saltB = [self getPersistedItem:SALT_B];
    ////    if (saltB.length > 0) {
    ////        DLog(@"PasswordStore : initalize : saltB : %@",saltB);
    ////        _saltB = saltB;
    ////    }
    //
    //    NSString* dbEncryptionKey = [self getPersistedItem:ENCRYPTION_KEY];
    //    NSLog(@"PasswordStore : initalize : dbEncryptionKey : %@",dbEncryptionKey);
    ////    DLog(@"PasswordStore : initalize : dbEncryptionKey : %@",dbEncryptionKey);
    //    if (dbEncryptionKey.length > 0) {
    //        DLog(@"PasswordStore : initalize : dbEncryptionKey : %@",dbEncryptionKey);
    //        _dbEncryptionKey = dbEncryptionKey;
    //    }
    //
    //    NSString* plainPassword = [self getPersistedItem:PLAIN_PASSWORD];
    //    NSLog(@"PasswordStore : initalize : palinPasswd : %@",plainPassword);
    //
    ////    DLog(@"PasswordStore : initalize : plainPassword : %@",plainPassword);
    //    if (plainPassword.length > 0) {
    //        _plainPassword = plainPassword;
    //        if (_saltA.length > 0) {
    //            _derivedPassword = [self calculateDerivedPassword:_plainPassword];
    //              NSLog(@"PasswordStore : _derivedPassword : %@",_derivedPassword);
    //            if (_derivedPassword.length == DERIVED_PASSWORD_LENGTH && _dbEncryptionKey.length > 0)  {
    //                _plainDbEncryptionKey = [self decryptItem:_dbEncryptionKey withKey:_derivedPassword];
    //                  NSLog(@"PasswordStore : _plainDbEncryptionKey : %@",_plainDbEncryptionKey);
    //            }
    //        }
    //    }
    // }


+(NSString *)getSaltA {
    NSString *saltAOne = [PasswordStore getPersistedItem:SALT_A_ONE];
    NSString *saltATwo = [PasswordStore getPersistedItem:SALT_A_TWO];
    NSString *saltAThree = [PasswordStore getPersistedItem:SALT_A_THREE];
    NSString *saltA = [NSString stringWithFormat:@"%@%@%@",saltAOne, saltATwo, saltAThree];
    
    return saltA;
}

+(NSString *)getSaltB {
    NSString *saltBOne = [PasswordStore getPersistedItem:SALT_B_ONE];
    NSString *saltBTwo = [PasswordStore getPersistedItem:SALT_B_TWO];
    NSString *saltBThree = [PasswordStore getPersistedItem:SALT_B_THREE];
    NSString *saltB = [NSString stringWithFormat:@"%@%@%@",saltBOne, saltBTwo, saltBThree];
    
    return saltB;
}

+(NSData*) calculSaltedPassword:(NSString*)plainPassword salt:(NSString*)saltB{
    NSData* data =[Tools PBKDF2:plainPassword withSalt:saltB];
    return data;
}
+(PasswordStore*)getInstanceWithPlainPasswordForEnrollment:(NSString *)plainPassword {
    DLog(@"PasswordStore : initialising instatce");
    NSLog(@"PasswordStore : initialising instance");
    instance = [[PasswordStore allocWithZone:NULL] init];
    [instance initialize:plainPassword];
    return instance;
}


+(PasswordStore*)getInstanceWithPlainPassword:(NSString *)plainPassword{
    if (!instance){
        DLog(@"PasswordStore : initialising instatce");
        NSLog(@"PasswordStore : initialising instance");
        instance = [[PasswordStore allocWithZone:NULL] init];
        [instance initialize:plainPassword];
    }
    return instance;
}

+(PasswordStore*)getInstance{
    return instance;
}

+(BOOL)verifyPassword:(NSString*)tmpPassword {
    
    NSData* tmpSaltedPassword = [PasswordStore calculSaltedPassword:tmpPassword salt:[PasswordStore getSaltB]];
    return [[PasswordStore getPersistedSaltedPassword] isEqualToData:tmpSaltedPassword];
}


-(NSData*)calculateDerivedPassword:(NSString*)tmpPassword salt:(NSString *)salt{
    NSLog(@"PasswordStore : calculateDerivedPassword");
    
    if (tmpPassword.length > 0 && salt.length > 0) {
        DLog(@"PasswordStore : Calculating Derived Password");
        return [Tools PBKDF2:tmpPassword withSalt:salt];
    }
    return nil;
}

-(NSData*)calculateSaltedPassword:(NSString*)tmpPassword {
    NSLog(@"PasswordStore : calculateSaltedPassword");
        NSData* data =[Tools PBKDF2:tmpPassword withSalt:[PasswordStore getSaltB]];
        return data;
 
}

-(void)calculateSalts {
    
    NSString *saltA = [Tools generateSalt:SALT_A_LENGTH];
    int stringSize = floor(saltA.length/3);
    
    int diff = saltA.length - 3*stringSize;
    
    
    NSString *Aone = [saltA substringWithRange:NSMakeRange(0,stringSize)];
    NSString *ATwo = [saltA substringWithRange:NSMakeRange(stringSize,stringSize)];
    NSString *AThree = [saltA substringWithRange:NSMakeRange(2*stringSize,stringSize+diff)];
    
    DLog(@"Salt A One : %@",Aone);
    DLog(@"Salt A Two : %@",ATwo);
    DLog(@"Salt A Three : %@",AThree);
    
    if ([PasswordStore getPersistedItem:SALT_A_ONE].length > 0) {
        [FDKeychain deleteItemForKey:SALT_A_ONE forService:MSSANTE];
    }
    [PasswordStore persisteItem:Aone forKey:SALT_A_ONE];
    
    if ([PasswordStore getPersistedItem:SALT_A_TWO].length > 0) {
        [FDKeychain deleteItemForKey:SALT_A_TWO forService:MSSANTE];
    }
    [PasswordStore persisteItem:ATwo forKey:SALT_A_TWO];
    
    if ([PasswordStore getPersistedItem:SALT_A_THREE].length > 0) {
        [FDKeychain deleteItemForKey:SALT_A_THREE forService:MSSANTE];
    }
    [PasswordStore persisteItem:AThree forKey:SALT_A_THREE];
    
    
    NSString *saltB = [Tools generateSalt:SALT_B_LENGTH];
    stringSize = floor(saltB.length/3);
    
    diff = saltB.length - 3*stringSize;
    
    DLog(@"Salt B : %@",saltB);

    
    NSString *Bone = [saltB substringWithRange:NSMakeRange(0,stringSize)];
    NSString *BTwo = [saltB substringWithRange:NSMakeRange(stringSize,stringSize)];
    NSString *BThree = [saltB substringWithRange:NSMakeRange(2*stringSize,stringSize+diff)];
    
    DLog(@"Salt B One : %@",Bone);
    DLog(@"Salt B Two : %@",BTwo);
    DLog(@"Salt B Three : %@",BThree);

    
    if ([PasswordStore getPersistedItem:SALT_B_ONE].length > 0) {
        [FDKeychain deleteItemForKey:SALT_B_ONE forService:MSSANTE];
    }
    [PasswordStore persisteItem:Bone forKey:SALT_B_ONE];
    
    if ([PasswordStore getPersistedItem:SALT_B_TWO].length > 0) {
        [FDKeychain deleteItemForKey:SALT_B_TWO forService:MSSANTE];
    }
    [PasswordStore persisteItem:BTwo forKey:SALT_B_TWO];
    
    if ([PasswordStore getPersistedItem:SALT_B_THREE].length > 0) {
        [FDKeychain deleteItemForKey:SALT_B_THREE forService:MSSANTE];
    }
    [PasswordStore persisteItem:BThree forKey:SALT_B_THREE];
    
}

-(NSString*)getPlainPassword {
    if (_plainPassword.length > 0) {
        return _plainPassword;
    }
    return nil;
}

-(void)setPlainPasswordValue:(NSString*) plainPassword{
    _plainPassword=plainPassword;
    
}

//-(void)setPlainPasswordValue:(NSString*)plainPassword {
//    DLog(@"PasswordStore : setPlainPassword %@",plainPassword);
//    //Save Plain Password in Memory
//    _plainPassword = plainPassword;
//    if (_derivedPassword.length != DERIVED_PASSWORD_LENGTH || _derivedPassword.length == 0) {
//        _derivedPassword = [self calculateDerivedPassword:plainPassword];
//    }
//    
//    _plainDbEncryptionKey = [self getDbEncryptionKey];
//    DLog(@"PasswordStore : plainDbKey %@", _plainDbEncryptionKey);
//    
//    if (firstConnection) {
//        DLog(@"PasswordStore : firstConnection");
//        NSLog(@"PasswordStore firstConnection !");
//        [self updatePasswordsAndDbEncryptionKey];
//    }
//}

-(void)changePassword:(NSString*)newPassword {
    
    
  [[Authentification sharedInstance] setUserPassword:newPassword];
    NSString * plainDbEncryptionKey = [self decryptItem:[PasswordStore getPersistedItem:ENCRYPTION_KEY] withKey:_derivedPassword];
    
    _plainPassword=newPassword;
    //block génération du derived password
    [self generateDerivedPassword:_plainPassword];
    // on genere KC Chiffré
    _dbEncryptionKey = [self encryptItem:plainDbEncryptionKey withKey:_derivedPassword];
    //on persiste
    [self persistEncryptionKey:_dbEncryptionKey];
    [self generateSaltedPassword:_plainPassword];
}

//-(void)updatePasswordsAndDbEncryptionKey {
//    NSLog(@"PasswdPersistence updatePasswordsAndDbEncryptionKey");
//    //Calculate Salted Password
//    _saltedPassword = [self calculateSaltedPassword:_plainPassword];
//    
//    //Persiste Salted Password
//    [self persisteSaltedPassword:_saltedPassword];
//    
//    
//    DLog(@"PasswordStore : Calculate And Persiste Salted Password %@", _saltedPassword);
//    
//    //Reset Derived Password
//    _derivedPassword = [self calculateDerivedPassword:_plainPassword];
//    DLog(@"PasswordStore : Calculate Derived Password : %@",_derivedPassword);
//    
//    //Encrypted Kc with new DerivedPassword
//    _dbEncryptionKey = [self encryptItem:_plainDbEncryptionKey withKey:_derivedPassword];
//    
//    //persist EncryptionKey
//    [self persistEncryptionKey:_dbEncryptionKey];
//    DLog(@"PasswordStore : Calculate and Persiste encryptedDbKey : %@",_dbEncryptionKey);
//    
//    DLog(@"_dbEncryptionKey.length %d",_dbEncryptionKey.length);
//    
//    DLog(@"PasswordStore : DecryptedDbKey %@", [self decryptItem:_dbEncryptionKey withKey:_derivedPassword]);
//    NSLog(@"PasswdPersistence updatePasswordsAndDbEncryptionKey dbEncryptionKey : %@",_dbEncryptionKey);
//}


-(void) persistEncryptionKey: (NSString *) dbEncryptionKey{
    if ([PasswordStore getPersistedItem:ENCRYPTION_KEY].length > 0) {
        [FDKeychain deleteItemForKey:ENCRYPTION_KEY forService:MSSANTE];
    }
    [PasswordStore persisteItem:dbEncryptionKey forKey:ENCRYPTION_KEY];
    
}

-(NSString*)getPlainDbEncryptionKey {
    if ([PasswordStore getPersistedItem:ENCRYPTION_KEY].length > 0 && _derivedPassword.length == DERIVED_PASSWORD_LENGTH) {
        return [self decryptItem:[PasswordStore getPersistedItem:ENCRYPTION_KEY] withKey:_derivedPassword];
    }
    return nil;
}


-(NSString*)getDbEncryptionKey {

//    if (_dbEncryptionKey.length > 0 && _derivedPassword.length == DERIVED_PASSWORD_LENGTH) {
//        NSLog(@"_plainDbEncryptionKey has length more than 0");
//        NSLog(@"And _derivedPassword has length equal to  %d",DERIVED_PASSWORD_LENGTH);
//        NSLog(@"decryptItem %@ withKey:%@",_dbEncryptionKey, _derivedPassword);
//        NSLog(@"Result Decrypt: %@",[self decryptItem:_dbEncryptionKey withKey:_derivedPassword] );
//        return [self decryptItem:_dbEncryptionKey withKey:_derivedPassword];
//    }
    return [PasswordStore getPersistedItem:ENCRYPTION_KEY];
    // return [self];
    @throw [NSException exceptionWithName:@"NoDBENcryption" reason:@"The DB Encryption is not set " userInfo:@{}];
}

-(NSString*)generatePlainDbEncryptionKey {
    NSString *plainDbEncryptionKey = [Tools generateSalt:DB_ENCRYPTION_KEY_LENGTH];
    return plainDbEncryptionKey;
}

-(NSString*)decryptItem:(NSString*)item withKey:(NSData*)key {
    NSData *itemData = [[NSData dataWithBase64EncodedString:item] AES256DecryptWithDataKey:key];
    return [itemData base64EncodedString];
}

-(NSString*)encryptItem:(NSString*)item withKey:(NSData*)key {
    NSData *itemData = [[NSData dataWithBase64EncodedString:item] AES256EncryptWithDataKey:key];
    return [itemData base64EncodedString];
}


+(void)persisteItem:(NSString*)item forKey:(NSString*)key {
    [FDKeychain saveItem:item forKey:key forService:MSSANTE];
}

+(NSString*)getPersistedItem:(NSString*)key {
    return [FDKeychain itemForKey:key forService:MSSANTE];
}

-(void)persisteSaltedPassword:(NSData*)saltedPassword{
    if ([PasswordStore getPersistedItem:SALTED_PASSWORD].length > 0) {
        [FDKeychain deleteItemForKey:SALTED_PASSWORD forService:MSSANTE];
    }
    [FDKeychain saveItem:saltedPassword forKey:SALTED_PASSWORD forService:MSSANTE];
}

+(NSData*)getPersistedSaltedPassword {
    return [FDKeychain itemForKey:SALTED_PASSWORD forService:MSSANTE];
}

+(void)resetKeyChain {
    PasswordStore *instance = [PasswordStore getInstance];

    if ([PasswordStore getPersistedItem:SALT_B].length > 0) {
        [FDKeychain deleteItemForKey:SALT_B forService:MSSANTE];
    }
    
    if ([PasswordStore getPersistedItem:SALT_A].length > 0) {
        [FDKeychain deleteItemForKey:SALT_A forService:MSSANTE];
    }
    
    if ([PasswordStore getPersistedItem:SALT_B_ONE].length > 0) {
        [FDKeychain deleteItemForKey:SALT_B_ONE forService:MSSANTE];
    }
    
    if ([PasswordStore getPersistedItem:SALT_B_TWO].length > 0) {
        [FDKeychain deleteItemForKey:SALT_B_TWO forService:MSSANTE];
    }
    
    if ([PasswordStore getPersistedItem:SALT_B_THREE].length > 0) {
        [FDKeychain deleteItemForKey:SALT_B_THREE forService:MSSANTE];
    }
    
    if ([PasswordStore getPersistedItem:SALT_A_ONE].length > 0) {
        [FDKeychain deleteItemForKey:SALT_A_ONE forService:MSSANTE];
    }
    
    if ([PasswordStore getPersistedItem:SALT_A_TWO].length > 0) {
        [FDKeychain deleteItemForKey:SALT_A_TWO forService:MSSANTE];
    }
    
    if ([PasswordStore getPersistedItem:SALT_A_THREE].length > 0) {
        [FDKeychain deleteItemForKey:SALT_A_THREE forService:MSSANTE];
    }
    
//    instance.saltA = nil;
//    instance.saltAOne = nil;
//    instance.saltATwo = nil;
//    instance.saltAThree = nil;
//    instance.saltB = nil;
//    instance.saltBOne = nil;
//    instance.saltBOne = nil;
//    instance.saltBTwo = nil;
//    instance.saltBThree = nil;
    
    [instance resetPasswordsInKeychain];
    
    DLog(@"End Resetting Keychain");
}

+(void)deletePlainPassword {
    if ([[FDKeychain itemForKey:PLAIN_PASSWORD forService:MSSANTE] length] > 0) {
        [FDKeychain deleteItemForKey:PLAIN_PASSWORD forService:MSSANTE];
        NSLog(@"PasswordStore : DELETE PLAIN PASSWD");
    }
}

-(void)resetPasswordsInKeychain {
    NSLog(@"resetPasswordsInKeychain");
    //NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!\nPasswordStore : Resetting Plain Password, Salted Password, DB Encryption Key");
    if ([PasswordStore getPersistedItem:PLAIN_PASSWORD].length > 0) {
        [FDKeychain deleteItemForKey:PLAIN_PASSWORD forService:MSSANTE];
    }
    
    if ([PasswordStore getPersistedItem:SALTED_PASSWORD].length > 0) {
        [FDKeychain deleteItemForKey:SALTED_PASSWORD forService:MSSANTE];
    }
    
    if ([PasswordStore getPersistedItem:ENCRYPTION_KEY].length > 0) {
        [FDKeychain deleteItemForKey:ENCRYPTION_KEY forService:MSSANTE];
    }
    
    instance.plainPassword = nil;
    instance.saltedPassword = nil;
    instance.dbEncryptionKey = nil;
    instance.plainDbEncryptionKey = nil;
}

+(BOOL)plainPasswordIsSet {
    return [[[PasswordStore getInstance] getPlainPassword] length] > 0;
}

+(void)resetPasswords {
    NSLog(@"resetAllPasswd");
    [PasswordStore storeNotFirstConnexion:NO];
    [[PasswordStore getInstance] resetPasswordsInKeychain];
    [[PasswordStore getInstance] setPlainPassword:nil];
    [[PasswordStore getInstance] setSaltedPassword:nil];
    [[PasswordStore getInstance] setDbEncryptionKey:nil];
    [[PasswordStore getInstance] setPlainDbEncryptionKey:nil];
}

@end
