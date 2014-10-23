//
//  ProductCellTableViewCell.m
//  GastronautBase
//
//  Created by Crowd on 9/8/14.
//  Copyright (c) 2014 CrowdInt. All rights reserved.
//

#import "ProductCellTableViewCell.h"

@implementation ProductCellTableViewCell
@synthesize lblPrice, lblDescription, imgProduct, loader, btnAdd, lblName, btnMinus, lblQuantity;

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
