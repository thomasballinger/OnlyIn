//
//  SharedDatabaseDocument.m
//  OnlyIn
//
//  Created by Jennifer Clark on 4/1/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import "SharedDatabaseDocument.h"

@interface SharedDatabaseDocument()

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSDictionary *unsavedPhoto;
@property (strong, nonatomic) NSDictionary *unsavedAlbum;

@end

@implementation SharedDatabaseDocument

- (void)fetchDataIntoDocument:(UIManagedDocument *)document
{
    if ((self.unsavedPhoto != nil) || (self.unsavedAlbum !=nil))  {
        
        dispatch_queue_t fetchQ = dispatch_queue_create("get results data", NULL);
        dispatch_async(fetchQ, ^{
            
            [document.managedObjectContext performBlock:^{
                
                if (self.unsavedPhoto != nil && self.unsavedAlbum != nil) {
                    [Photo photoWithInfo:self.unsavedPhoto andAlbumInfo:self.unsavedAlbum inManagedObjectContext:document.managedObjectContext];
                }
            
                if (self.unsavedAlbum != nil) {
                   [Album albumWithInfo:self.unsavedAlbum inManagedObjectContext:document.managedObjectContext];
                }
                
                NSError *error = nil;
                [[DataController dc].database.managedObjectContext save:&error];
                [[DataController dc].database saveToURL:[DataController dc].database.fileURL
                                       forSaveOperation:UIDocumentSaveForOverwriting
                                      completionHandler:^(BOOL success) {
                                          
                                          if (success) {
                                              NSLog(@"saved");
                                              [self.delegate showAlertView:self];
                                              self.unsavedPhoto = nil;
                                              self.unsavedAlbum = nil;
                                              
                                          } else {
                                              //handle error
                                          }
                                      
                                      }];
                                }];
            
                            });
    
                        }


}


- (void)useDocument
{
    __weak SharedDatabaseDocument *zelf = self;
    if (![[NSFileManager defaultManager] fileExistsAtPath:[[DataController dc].database.fileURL path]]) {
        [[DataController dc].database saveToURL:[DataController dc].database.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success)  {
            [zelf fetchDataIntoDocument:[DataController dc].database];
        }];
    }   else if ([DataController dc].database.documentState == UIDocumentStateClosed) {
        [[DataController dc].database openWithCompletionHandler:^(BOOL success) {
            [zelf fetchDataIntoDocument:[DataController dc].database];
        }];
    }   else if ([DataController dc].database.documentState == UIDocumentStateNormal) {
        [self fetchDataIntoDocument:[DataController dc].database];
    }
}


//- (void)prepareDatabaseDocument
- (void)prepareDatabaseDocument:(NSDictionary *)unsavedPhotoDictionary withUnsavedAlbumDictionary:(NSDictionary *)unsavedAlbumDictionary;
{
    if (![DataController dc].database) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]lastObject];
        url = [url URLByAppendingPathComponent:@"Default Database"];
        [DataController dc].database = [[UIManagedDocument alloc]initWithFileURL:url];
    }
    
    self.unsavedPhoto = unsavedPhotoDictionary;
    self.unsavedAlbum = unsavedAlbumDictionary;
    
    [self useDocument];
}

@end
