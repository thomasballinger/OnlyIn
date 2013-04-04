//
//  SeeYourAlbumViewController.h
//  OnlyIn
//
//  Created by Jennifer Clark on 3/26/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Album+Create.h"

@interface SeeYourAlbumViewController : UIViewController

@property (strong, nonatomic) NSNumber *albumID;
@property (strong, nonatomic) NSNumber *photoCounter;
@property (strong, nonatomic) NSString *albumLocation;
@property (strong, nonatomic) NSArray *photosSmall;
@property (strong, nonatomic) NSArray *photosLarge;

@property (strong,nonatomic) Album *album;

#define SMALL_PHOTO @"small"
#define LARGE_PHOTO @"large"

@end
