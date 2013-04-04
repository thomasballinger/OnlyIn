//
//  ViewAlbumsTableViewController.h
//  OnlyIn
//
//  Created by Jennifer Clark on 3/26/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@interface ViewAlbumsTableViewController : CoreDataTableViewController

- (void)prepareDatabaseDocument;

@property (strong, nonatomic) NSString *currentLocation;

@end
