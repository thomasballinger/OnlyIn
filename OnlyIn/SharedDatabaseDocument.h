//
//  SharedDatabaseDocument.h
//  OnlyIn
//
//  Created by Jennifer Clark on 4/1/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Photo+Create.h"
#import "Album+Create.h"
#import <CoreData/CoreData.h>

@class SharedDatabaseDocument;

@protocol DataSaved <NSObject>
- (void)showAlertView:(SharedDatabaseDocument *)sender;
@end

@interface SharedDatabaseDocument : NSObject

- (void)prepareDatabaseDocument:(NSDictionary *)unsavedPhotoDictionary withUnsavedAlbumDictionary:(NSDictionary *)unsavedAlbumDictionary;

@property (weak, nonatomic) id <DataSaved> delegate;

@end
