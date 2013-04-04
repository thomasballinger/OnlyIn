//
//  Photo+Create.h
//  OnlyIn
//
//  Created by Jennifer Clark on 4/1/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import "Photo.h"
#import "SeeYourAlbumViewController.h"

@interface Photo (Create)

#define PHOTO_ID @"photoID"
#define ALBUM_ID_ON_PHOTO @"albumID"

+ (Photo *)photoWithInfo:(NSDictionary *)PhotoInfo andAlbumInfo: (NSDictionary *)AlbumInfo inManagedObjectContext:(NSManagedObjectContext *)context;

@end
