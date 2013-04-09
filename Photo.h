//
//  Photo.h
//  OnlyIn
//
//  Created by Jennifer Clark on 4/3/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Album;

@interface Photo : NSManagedObject

@property (nonatomic) int64_t albumID;
@property (strong, nonatomic) NSData * photoDataLarge;
@property (nonatomic) int64_t photoID;
@property (strong, nonatomic) NSData * photoDataSmall;
@property (strong, nonatomic) Album *whichAlbum;

@end
