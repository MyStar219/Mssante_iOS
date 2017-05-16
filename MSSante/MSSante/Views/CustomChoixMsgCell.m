//
//  CustomChoixMsgCell.m
//  MSSante
//
//  Created by Labinnovation on 03/07/13.
//  Copyright (c) 2013 Capgemini. All rights reserved.
//

#import "CustomChoixMsgCell.h"

@implementation CustomChoixMsgCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    /* @WX - Amélioration Sonar
     * Décommenter le if pour l'initialisation
     */
    /*if (self) {
        // Custom initialization
     }*/
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
