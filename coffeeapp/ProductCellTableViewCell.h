//
//  ProductCellTableViewCell.h
//  GastronautBase
//
//  Created by Crowd on 9/8/14.
//  Copyright (c) 2014 CrowdInt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductCellTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *lblPrice;
@property (nonatomic, strong) IBOutlet UILabel *lblDescription;
@property (nonatomic, strong) IBOutlet UIImageView * imgProduct;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *loader;
@property (nonatomic, strong) IBOutlet UIButton *btnAdd;
@property (nonatomic, strong) IBOutlet UILabel *lblName;
@property (nonatomic, strong) IBOutlet UIButton *btnMinus;
@property (nonatomic, strong) IBOutlet UILabel *lblQuantity;
@end
