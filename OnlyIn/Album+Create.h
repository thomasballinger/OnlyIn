//
//  Album+Create.h
//  OnlyIn
//
//  Created by Jennifer Clark on 4/1/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import "Album.h"

@interface Album (Create)

#define LOCATION @"location"
#define ALBUM_TITLE @"title"
#define ALBUM_ID @"id"
#define PHOTO_COUNTER @"photo counter"

+ (Album *)albumWithInfo:(NSDictionary *)albumInfo inManagedObjectContext:(NSManagedObjectContext *)context;

@end
