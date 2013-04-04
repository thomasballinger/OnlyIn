//
//  Album+Create.m
//  OnlyIn
//
//  Created by Jennifer Clark on 4/1/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import "Album+Create.h"

@implementation Album (Create)

+ (Album *)albumWithInfo:(NSDictionary *)albumInfo inManagedObjectContext:(NSManagedObjectContext *)context

{
    Album *album = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Album"];
    request.predicate = [NSPredicate predicateWithFormat:@"id = %i", [[albumInfo objectForKey:ALBUM_ID]intValue]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:ALBUM_TITLE ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *albums = [context executeFetchRequest:request error:&error];
    
    if (!albums || ([albums count] > 1)) {
        // handle error
    } else if (![albums count]) {
        album = [NSEntityDescription insertNewObjectForEntityForName:@"Album"
                                                     inManagedObjectContext:context];
        
        NSString *albumTitle = [albumInfo objectForKey:ALBUM_TITLE];
        int albumID = [[albumInfo objectForKey:ALBUM_ID]intValue];
        NSString *location = [albumInfo objectForKey:LOCATION];
        int photoCounter = [[albumInfo objectForKey:PHOTO_COUNTER]intValue];
        
        album.title = albumTitle;
        album.id = albumID;
        album.location = location;
        album.photoCounter = photoCounter;
                        
    } else {
        album = [albums lastObject];
        int photoCounter = [[albumInfo objectForKey:PHOTO_COUNTER]intValue];
        album.photoCounter = photoCounter;
        
    }
    
    //NSLog(@"The album was saved: title = %@, location = %@, id = %lli, photocounter = %i, photos = %@", album.title, album.location, album.id, album.photoCounter, album.photos);
    
    return album;
}

@end
