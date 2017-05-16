
//
//  AttachementManager.m
//  MSSante
//
//  Created by Labinnovation on 09/12/2014.
//  Copyright (c) 2014 Capgemini. All rights reserved.
//

#import "AttachmentManager.h"
#import "Tools.h"
#import "UIImage+Resize.h"
#import "Attachment.h"
#import "DAOFactory.h"
#import "AttachmentDAO.h"
#import "Constant.h"
#import "PasswordStore.h"
#import "NSData+AES256.h"
#import "NPConverter.h"
#import "NPAttachment.h"
#import "NouveauMessageViewController2.h"

@interface AttachmentManager()

@property (weak, nonatomic) NouveauMessageViewController2* master;
@property (retain, nonatomic) NSMutableDictionary* attachments;

@end

@implementation AttachmentManager

@synthesize attachments;
@synthesize master;

- (id) initWithMaster:(NouveauMessageViewController2 *)theMaster {
    self = [super init];
    if (self){
        self.master = theMaster;
        self.attachments = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void) addAttachmentFromPickingMediaWithInfo : (NSDictionary *)info{
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    
    CGSize newSize = chosenImage.size;
    
    newSize.width /= 3;
    newSize.height /= 3;
    
    NSString *imageName = nil;
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    NSString* filePath;
    
    if ([info objectForKey:UIImagePickerControllerReferenceURL]) {
        NSURL *imageFileURL = [info objectForKey:UIImagePickerControllerReferenceURL];
        imageName = [imageFileURL lastPathComponent];
        filePath = [Tools getAttachmentFilePath:imageName];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
        // on change le nom si l'image prise existe deja
        if ([attachments objectForKey:imageName] || fileExists) {
            NSString *filename = [[imageFileURL lastPathComponent] stringByDeletingPathExtension];
            NSString *ext = [imageFileURL pathExtension];
            imageName = [NSString stringWithFormat:@"%@%d.%@",filename,(int)timestamp,ext];
        }
    } else {
        chosenImage = [chosenImage resizedImage:newSize interpolationQuality:0.5];
    }
    
    if (imageName.length == 0) {
        imageName = [NSString stringWithFormat:@"IMG%d.jpeg",(int)timestamp];
    }
    
    filePath = [Tools getAttachmentFilePath:imageName];
    
    DLog(@"filePath %@",filePath);
    
    __block NSData *imgData;
    __block NSData* encryptedData;
    
    Attachment *attachment= [NSEntityDescription insertNewObjectForEntityForName: @"Attachment" inManagedObjectContext: [[DAOFactory factory] managedObjectContext]];
    
    
    //TODO: rewriteAddAttachment
    
    
    NSBlockOperation* saveOp = [NSBlockOperation blockOperationWithBlock: ^{
        DLog(@"Start Saving");
        
        imgData = UIImageJPEGRepresentation(chosenImage, 1);
        int size = ceil(imgData.length/1024);
        
        [attachment setFileName:imageName];
        [attachment setContentType:IMAGE_JPEG];
        [attachment setSize:[NSNumber numberWithInt:size]];
        
        
        NPAttachment *npAttachment = [NPConverter convertAttachment:attachment];
        
        if (filePath) {
            encryptedData = [imgData AES256EncryptWithKey:[[PasswordStore getInstance] getDbEncryptionKey]];
            NSLog(@"PasswordStore getInstance : getDBEncroptionkey for attachments");
            
            if (encryptedData) {
                [encryptedData writeToFile:filePath atomically:YES];
                DLog(@"Save Image");
            }
            NSString *imageString = [imgData base64Encoding];
            [npAttachment setDatas:imageString];
            // [attachments setValue:npAttachment forKey:imageName];
            
            [self.attachments setValue:npAttachment forKey:imageName];
            
            //TODO: rewriteAddAttachment to input
            //[self addAttachmentToSendInput:attachment];
        }
    }];
    
    // Use the completion block to update our UI from the main queue
    [saveOp setCompletionBlock:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            DLog(@"Finish Saving");
            //TODO:ReloadAttachlent Table
            
            [self.master.tableView reloadData];
            [self.master.attachmentsTable reloadData];
            [self.master.tableView reloadData];
        }];
    }];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:saveOp];//TODO: Dismiss the picker
    /*
     dismissFromImagePicker = YES;
     
     if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && imagePicker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
     [popoverControllerCamera dismissPopoverAnimated:YES];
     } else {
     [picker dismissViewControllerAnimated:YES completion:^{
     [self showPjMenuView];
     }];
     }
     */
}

- (NSArray *) getAttachements {
    return [self.attachments allValues];
}
- (NSInteger) getAttachementsCount {
    return [self.attachments count];
}

- (NSInteger) getTotalSize {
    NSInteger size = 0;
    for (NPAttachment * attachment in [attachments allValues]){
        size += [attachment.size integerValue];
    }
    return size;
}

- (void) deleteAttachementsByFileName {
}

//Array de Attachments
- (NSMutableArray *) getAttachementsByIdMessage:(NSNumber*)idMessage {
    NSMutableArray *attachements =  [AttachmentManager  getAttachementsByIdMessage:idMessage];
    
    [self setAttachements:attachements];
    return attachements;
}

+ (NSMutableArray *) getAttachementsByIdMessage:(NSNumber*)idMessage {
    AttachmentDAO *attachmentDAO = (AttachmentDAO*)[[DAOFactory factory] newDAO:AttachmentDAO.class];
    NSMutableArray *attachements = [NSMutableArray array];
    
    for (Attachment * tmpAttachment in [attachmentDAO findAttachmentByIdMessage:idMessage]) {
        [attachements addObject:[NPConverter convertAttachment:tmpAttachment]];
    }
    
    return attachements;
}

- (void) setAttachements:(NSMutableArray*)newAttachments {
    self.attachments=[NSMutableDictionary dictionary];
    
    /* @WX - Anomalie 18022 (adaptée à partir de l'iOS 8)
     * Correction sur la "suppression des PJ" lors du transfert d'un mail
     */
    /*NSInteger compteur = 1;
     
     for (NPAttachment *att in newAttachments){
     if ([self.attachments objectForKey:att.fileName]) {
     NSString *extension = [att.fileName pathExtension];
     att.fileName = [NSString stringWithFormat:@"%@_copie_%d.%@", [att.fileName substringWithRange:NSMakeRange(0, att.fileName.length - 4)],
     compteur, extension];
     ++compteur;
     
     } else {
     compteur = 1;
     }
     [self.attachments setValue:att forKey:att.fileName];
     }*/
    /* @WX - Fin des modifications */
    
    /* @WX - Anomalie 18022 (adaptée à partir de l'iOS 7)
     * Correction sur la "suppression des PJ" lors du transfert d'un mail
     */
    NSMutableDictionary *compteurs = [[NSMutableDictionary alloc] init];
    
    for (NPAttachment *att in newAttachments) {
        if ([self.attachments objectForKey:att.fileName]) {
            NSString *extension = [att.fileName pathExtension];
            [compteurs setValue:[NSNumber numberWithInt:([[compteurs objectForKey:att.fileName] intValue] + 1)] forKey:att.fileName];
            att.fileName = [NSString stringWithFormat:@"%@_copie_%@.%@", [att.fileName substringWithRange:NSMakeRange(0, att.fileName.length - 4)],
                            [compteurs objectForKey:att.fileName], extension];
        } else {
            [compteurs setValue:[NSNumber numberWithInt:1] forKey:att.fileName];
        }
        [self.attachments setValue:att forKey:att.fileName];
    }
    /* @WX - Fin des modifications */
}

- (void) removeAttachment :(NSString*)fileName {
    [self.attachments removeObjectForKey: fileName];
}

@end
