//
//  ViewAlbumsTableViewController.m
//  OnlyIn
//
//  Created by Jennifer Clark on 3/26/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import "ViewAlbumsTableViewController.h"

@interface ViewAlbumsTableViewController () <UIAlertViewDelegate>

@property (nonatomic) BOOL openAlbumsWasSelected;
@property (strong, nonatomic) NSDictionary *sections;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@end

@implementation ViewAlbumsTableViewController 

#pragma mark - core data query and saving
#define LOCKED_ALBUMS @"locked albums"
#define UNLOCKED_ALBUMS @"unlocked albums"
#define ALBUM @"Album"
#define TITLE @"title"

- (void)setUpFetchedResultsController
{
    NSArray *results;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:ALBUM];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:TITLE ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:[DataController dc].database.managedObjectContext sectionNameKeyPath:nil cacheName:nil];

    NSError *error = nil;
    results = [[DataController dc].database.managedObjectContext
               executeFetchRequest:request error:&error];
    
    if (results) {
        NSMutableArray *unlockedAlbums = [[NSMutableArray alloc]init];
        NSMutableArray *lockedAlbums = [[NSMutableArray alloc]init];
        
        for (Album *album in results) {
            if ([album.location isEqualToString:self.currentLocation]) {
                [unlockedAlbums addObject:album];
            } else {
                [lockedAlbums addObject:album];
            }
        }
        
        self.sections = [[NSDictionary alloc]initWithObjectsAndKeys:lockedAlbums, LOCKED_ALBUMS, unlockedAlbums, UNLOCKED_ALBUMS, nil];
      
          [self.spinner stopAnimating];
          [self.tableView reloadData];
    }
}

- (void)useDocument
{
    __weak ViewAlbumsTableViewController *zelf = self;
    if (![[NSFileManager defaultManager] fileExistsAtPath:[[DataController dc].database.fileURL path]]) {
        __weak ViewAlbumsTableViewController *zelf = self;
        [[DataController dc].database saveToURL:[DataController dc].database.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success)  {
            [zelf setUpFetchedResultsController];
        }];
    }   else if ([DataController dc].database.documentState == UIDocumentStateClosed) {
        [[DataController dc].database openWithCompletionHandler:^(BOOL success) {
            [zelf setUpFetchedResultsController];
        }];
    }   else if ([DataController dc].database.documentState == UIDocumentStateNormal) {
        [zelf setUpFetchedResultsController];
    }
}

- (void)prepareDatabaseDocument
{
    if (![DataController dc].database) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]lastObject];
        url = [url URLByAppendingPathComponent:@"Default Database"];
        [DataController dc].database = [[UIManagedDocument alloc]initWithFileURL:url];
    }
    
    [self useDocument];
}

#define SMALL_PHOTOS @"small photos"
#define LARGE_PHOTOS @"large photos"

+ (NSDictionary *)preparePhotoSet:(Album *)album {

    NSSet *photos = album.photos;
    NSMutableArray *smallPhotos = [[NSMutableArray alloc]initWithCapacity:[photos count]];
    NSMutableArray *largePhotos = [[NSMutableArray alloc]initWithCapacity:[photos count]];
    
    for (Photo *photo in photos) {
        if (photo) {
            
            NSData *smallPhotoData = photo.photoDataSmall;
            NSData *largePhotoData = photo.photoDataLarge;
            
            UIImage *smallPhoto = [UIImage imageWithData:smallPhotoData];
            UIImage *largePhoto = [UIImage imageWithData:largePhotoData];
            
            ImageViewWithPhotoTag *imageViewForSmallPhoto = [[ImageViewWithPhotoTag alloc]initWithImage:smallPhoto];
            imageViewForSmallPhoto.photoID = photo.photoID;
    
            [smallPhotos addObject:imageViewForSmallPhoto];
            [largePhotos addObject:largePhoto];
        }
    }
    
    NSDictionary *dictionary = [[NSDictionary alloc]initWithObjectsAndKeys:smallPhotos, SMALL_PHOTOS, largePhotos, LARGE_PHOTOS, nil];
    return dictionary;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    SeeYourAlbumViewController *detailsVC = [[SeeYourAlbumViewController alloc]init];
    detailsVC = segue.destinationViewController;

    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    Album *album = [[self.sections objectForKey:UNLOCKED_ALBUMS]objectAtIndex:indexPath.row];
    detailsVC.title = album.title;
    detailsVC.albumID = [NSNumber numberWithInt:album.id];
    detailsVC.photoCounter = [NSNumber numberWithInt:album.photoCounter];
    detailsVC.albumLocation = album.location;
    detailsVC.album = album;
    
    NSDictionary *dictionary = [ViewAlbumsTableViewController preparePhotoSet:album];
    detailsVC.photosSmall = [dictionary objectForKey:SMALL_PHOTOS];
    detailsVC.photosLarge = [dictionary objectForKey:LARGE_PHOTOS];
}

- (UIActivityIndicatorView *)makeSpinner
{
    UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    view.hidesWhenStopped = YES;
    return view;
}

- (IBAction)exitButton:(UIBarButtonItem *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.spinner = [self makeSpinner];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.spinner];
    [self.spinner startAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sections count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch(section){
        case 0:
            return [[self.sections objectForKey:UNLOCKED_ALBUMS] count];
            break;
        case 1:
            return [[self.sections objectForKey:LOCKED_ALBUMS] count];
            break;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(section == 0) {
        return UNLOCKED_ALBUMS;
    }
    if(section == 1) {
        return LOCKED_ALBUMS;
    }
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"newCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
       
    if (indexPath.section == 0) {
        Album *album = [[self.sections objectForKey:UNLOCKED_ALBUMS]objectAtIndex:indexPath.row];
        cell.textLabel.text = album.title;
        cell.detailTextLabel.text = album.location;
        
        
    } else if (indexPath.section == 1) {
        Album *album = [[self.sections objectForKey:LOCKED_ALBUMS]objectAtIndex:indexPath.row];
        cell.textLabel.text = album.title;
        cell.detailTextLabel.text = album.location;
        cell.imageView.image = [UIImage imageNamed:@"lock"];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [self performSegueWithIdentifier:@"seeAlbum" sender:self];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Album Locked!" message:@"You are only to view albums that were created in the same location as your current location." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //__weak ViewAlbumsTableViewController *zelf = self;
    
    Album *album;
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        if (indexPath.section == 0) {
            album = [[self.sections objectForKey:UNLOCKED_ALBUMS]objectAtIndex:indexPath.row];
            [[self.sections objectForKey:UNLOCKED_ALBUMS]removeObjectAtIndex:indexPath.row];
        } else if (indexPath.section == 1) {
            album = [[self.sections objectForKey:UNLOCKED_ALBUMS]objectAtIndex:indexPath.row];
            [[self.sections objectForKey:LOCKED_ALBUMS]removeObjectAtIndex:indexPath.row];
          }
}
    
    NSArray *indexPaths = [[NSArray alloc]initWithObjects:indexPath, nil];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [[DataController dc].database.managedObjectContext deleteObject:album];
    NSError *error = nil;
    [[DataController dc].database.managedObjectContext save:&error];

    [[DataController dc].database saveToURL:[DataController dc].database.fileURL
                           forSaveOperation:UIDocumentSaveForOverwriting
                          completionHandler:^(BOOL success) {
                              if (success) {
                                  NSLog(@"saved");
                              } else {
                                  //handle error
                              }
                          }];
    

    [self.tableView reloadData];
}

@end
