//
//  CreateNewAlbumViewController.h
//  OnlyIn
//
//  Created by Jennifer Clark on 3/25/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Album+Create.h"
#import "SharedDatabaseDocument.h"
#import "SMContactsSelector.h"
#import "ViewAlbumsTableViewController.h"

@interface CreateNewAlbumViewController : UIViewController

@property (strong, nonatomic) NSString *currentLocation;

@end
