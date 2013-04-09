//
//  Album.h
//  OnlyIn
//
//  Created by Jennifer Clark on 4/3/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Photo.h"

@class Photo;

@interface Album : NSManagedObject

@property (nonatomic) int64_t id;
@property (strong, nonatomic) NSString * location;
@property (strong, nonatomic) NSString * title;
@property (nonatomic) int16_t photoCounter;
@property (strong, nonatomic) NSSet *photos;
@end

@interface Album (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

@end
