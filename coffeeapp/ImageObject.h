//
//  ImageObject.h
//  GastronautBase
//
//  Created by Leonel Roberto Perea Trejo on 9/5/14.
//  Copyright (c) 2014 CrowdInt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageObject : NSObject

@property (nonatomic, strong) NSString * attachment_file_name;
@property (nonatomic, assign) int image_id;
@property (nonatomic, strong) NSString * large_url;
@property (nonatomic, strong) NSString * mini_url;
@property (nonatomic, strong) NSString * product_url;
@property (nonatomic, strong) NSString * small_url;

@end
