//
//  Photo+Create.m
//  OnlyIn
//
//  Created by Jennifer Clark on 4/1/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import "Photo+Create.h"
#import "Album+Create.h"

@implementation Photo (Create)

+ (Photo *)photoWithInfo:(NSDictionary *)PhotoInfo andAlbumInfo: (NSDictionary *)AlbumInfo inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    
    //before creating a new Photo, check the database to see if that Photo already exists
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"photoID = %i", [[PhotoInfo objectForKey:PHOTO_ID]intValue]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:PHOTO_ID ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    //execute the request
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error]; //array of all the photos that match the predicate
    
    //if matches is nil, that qualifies as an error
    if (!matches || [matches count] > 1) {
        return nil;
        
    } else if ([matches count] == 0) { //if there are no matches then add it to the database
        
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        
        UIImageView *imageViewSmallPhoto = [PhotoInfo objectForKey:SMALL_PHOTO];
        UIImageView *imageViewLargePhoto = [PhotoInfo objectForKey:LARGE_PHOTO];
        
        NSData *smallPhotoData = UIImagePNGRepresentation(imageViewSmallPhoto.image);
        NSData *largePhotoData = UIImagePNGRepresentation(imageViewLargePhoto.image);
        
        photo.photoDataSmall = smallPhotoData;
        photo.photoDataLarge = largePhotoData;
        
        int intForPhotoID = [[PhotoInfo objectForKey:PHOTO_ID]intValue];
        photo.photoID = intForPhotoID;
        
        int intForAlbumID = [[PhotoInfo objectForKey:ALBUM_ID_ON_PHOTO]intValue];
        photo.albumID = intForAlbumID;
        
        Album *album = [Album albumWithInfo:AlbumInfo inManagedObjectContext:context];
        photo.whichAlbum = album;
        
       // NSLog(@"the album I am accessing: album title = %@, album id = %lli, album photos count = %i, album location = %@, photo counter = %i", album.title, album.id, [album.photos count], album.location, album.photoCounter);
        
        
    } else { //if matches is 1
        
        photo = [matches lastObject];
    }
    
    //NSLog(@"The photo was saved: id = %lli, albumID = %lli", photo.photoID, photo.albumID);
    //NSLog(@"The photo whichAlbum is %@", photo.whichAlbum);
    
    return photo;
}

@end
