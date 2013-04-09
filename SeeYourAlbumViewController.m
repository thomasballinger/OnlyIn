//
//  SeeYourAlbumViewController.m
//  OnlyIn
//
//  Created by Jennifer Clark on 3/26/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import "SeeYourAlbumViewController.h"

@interface SeeYourAlbumViewController () <UITabBarDelegate, UICollectionViewDelegate,UICollectionViewDataSource, SMContactsSelectorDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic)  UIImagePickerController *picker;
@property (strong, nonatomic) NSMutableArray *pictures;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) SharedDatabaseDocument *sharedDocument;
@property (strong, nonatomic) UIImage *currentPhoto;
@property (strong, nonatomic) NSMutableArray *indexPaths;
@property (strong, nonatomic) UIImage *image;

@end

@implementation SeeYourAlbumViewController

#define MAX_PHOTO_SIZE_FOR_SMALL_PHOTO 75  //based on size of image view in collection view cell
#define SMALL_PHOTO @"small"
#define LARGE_PHOTO @"large"

- (UIActivityIndicatorView *)makeSpinner
{
    UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    view.hidesWhenStopped = YES;
    return view;
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (item.tag == 0) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.spinner];
        [self.spinner startAnimating];
        [self takePhoto];
    }   else if (item.tag == 1) {
        [self showContacts];
        [self.spinner startAnimating];
        }   else if (item.tag == 2) {
            [self performSegueWithIdentifier:@"seeAlbumFriends" sender:self];
            }
}

-(void)prepareToolBarItems
{
    UITabBarItem *seeAlbumFriendsItem = [[UITabBarItem alloc]initWithTitle:@"See Album Friends" image:nil tag:2];
    UITabBarItem *photoItem = [[UITabBarItem alloc]initWithTitle:@"Add Photos" image:nil tag:0];
    UITabBarItem *inviteFriendsItem = [[UITabBarItem alloc]initWithTitle:@"Invite Friends" image:nil tag:1];
    NSArray *toolBarItems = [[NSArray alloc]initWithObjects:photoItem, inviteFriendsItem, seeAlbumFriendsItem, nil];
    self.tabBar.items = toolBarItems;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pictures = [[NSMutableArray alloc]initWithArray:self.photosSmall];
    self.sharedDocument = [[SharedDatabaseDocument alloc]init];
    self.tabBar.delegate = self;
    self.collectionView.backgroundColor = [UIColor blackColor];
    self.spinner = [self makeSpinner];
    [self prepareToolBarItems];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (![segue.identifier isEqualToString:@"seeAlbumFriends"]) {
    ImageViewController *ivc = segue.destinationViewController;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
    self.currentPhoto = [self.photosLarge objectAtIndex:indexPath.row];
    ivc.photo = self.currentPhoto;
    }
}

+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)saveChangesToCoreData:(ImageViewWithPhotoTag *)thisPhoto forAlbum:(Album *)album
{
    NSSet *photosInThisAlbum = album.photos;
    for (Photo *photo in photosInThisAlbum) {
        
        if (photo.photoID == thisPhoto.photoID) {
            
            album.photoCounter -- ;
            NSNumber *photoCounter = [NSNumber numberWithInt:album.photoCounter];
            NSNumber *albumID = [NSNumber numberWithInt:album.id];
            NSDictionary *albumDictionaryWithUpdate = [[NSDictionary alloc]initWithObjectsAndKeys:photoCounter, PHOTO_COUNTER, albumID, ALBUM_ID, album.title, ALBUM_TITLE, album.location, LOCATION, nil];
            [[DataController dc].database.managedObjectContext deleteObject:photo];
            NSError *error = nil;
            [[DataController dc].database.managedObjectContext save:&error];
            [[DataController dc].database saveToURL:[DataController dc].database.fileURL
                                   forSaveOperation:UIDocumentSaveForOverwriting
                                  completionHandler:^(BOOL success) {
                                      if (success) {
                                          NSLog(@"saved"); //if photo is deleted, then update album with new photo count
                                          [self.sharedDocument prepareDatabaseDocument:nil withUnsavedAlbumDictionary:albumDictionaryWithUpdate];

                                      } else {
                                          //handle error
                                      }
                                  }];
        
        
        }
    }
}

-(void)deleteCollectionViewCell:(CollectionViewCellButton *)sender
{
    [self.collectionView performBatchUpdates:^{
        NSArray *selectedIndexPath = [[NSArray alloc]initWithObjects:sender.indexPath, nil];
        //remove from core data
        ImageViewWithPhotoTag *thisPhoto = [self.pictures objectAtIndex:sender.indexPath.row];
        Album *thisAlbum = self.album;
        [self saveChangesToCoreData:thisPhoto forAlbum:thisAlbum];
        
        //remove from vc data source and collection view
        [self.pictures removeObjectAtIndex:sender.indexPath.row];
        [self.collectionView deleteItemsAtIndexPaths:selectedIndexPath];
    } completion:^(BOOL finished) {
        if (finished) {
            [self.collectionView reloadData];
        }
        
    }];
    
}
-(CollectionViewCellButton *)makeDeleteButtonForCell:(UICollectionViewCell *)cell
{
    CollectionViewCellButton *button = [CollectionViewCellButton buttonWithType:UIButtonTypeCustom];
    
    if (!self.image) {
    CGSize newImageSize = CGSizeMake(cell.frame.size.width/2.5, cell.frame.size.height/2.5);
    self.image = [SeeYourAlbumViewController imageWithImage:[UIImage imageNamed:@"delete"] scaledToSize:newImageSize];
    }
        
    CGFloat width = self.image.size.width;
    CGFloat height = self.image.size.height;
    CGFloat X = cell.frame.size.width - width;
    CGFloat Y = cell.bounds.origin.y;

    button.frame = CGRectMake(X, Y, width, height);
    [button setImage:self.image forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(deleteCollectionViewCell:)
     forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    return [self.pictures count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView
                                  dequeueReusableCellWithReuseIdentifier:@"newCell"
                                  forIndexPath:indexPath];
    
    CollectionViewCellButton *cellButton = [self makeDeleteButtonForCell:cell];
    cellButton.indexPath = indexPath;
    
    [cell addSubview:[self.pictures objectAtIndex:indexPath.row]];
    [cell addSubview:cellButton];
    
    return cell;
}


-(void)takePhoto
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"We could not locate a camera on your device." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        //check source type, see if camera is available on this device
        NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        
        if ([mediaTypes containsObject:(NSString *)kUTTypeImage]) {
            //see if image is an available media type
            self.picker = [[UIImagePickerController alloc]init];
            self.picker.delegate = self;
            self.picker.sourceType = UIImagePickerControllerSourceTypeCamera; //choose source type
            self.picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage]; //choose media type
            self.picker.allowsEditing = NO;
            [self presentViewController:self.picker animated:YES completion:^{
                [self.spinner stopAnimating];
            }];
        } else {
            [alert show];
        }
    } else {
        [alert show];
    }
}

- (NSMutableDictionary *) buildPhotoDictionary:(UIImage *) image {
    NSMutableDictionary *photoDictionary = [[NSMutableDictionary alloc]initWithCapacity:2];
    //crop image for image view in view image view controller
    CGSize maxPhotoSizeForFullPhotoView = CGSizeMake(self.view.frame.size.width *2, self.view.frame.size.height *2);
    //Why the magical times two here? is it for retina?
    UIImageView *imageViewLarge = [[UIImageView alloc]initWithImage:[SeeYourAlbumViewController imageWithImage:image scaledToSize:maxPhotoSizeForFullPhotoView]];
    
    photoDictionary[LARGE_PHOTO] = imageViewLarge;
    
    //crop image for this collection view
    CGSize maxPhotoSizeForCollectionView = CGSizeMake(MAX_PHOTO_SIZE_FOR_SMALL_PHOTO, MAX_PHOTO_SIZE_FOR_SMALL_PHOTO);
    ImageViewWithPhotoTag *imageViewSmall = [[ImageViewWithPhotoTag alloc] initWithImage:[SeeYourAlbumViewController imageWithImage:image scaledToSize:maxPhotoSizeForCollectionView]];
    photoDictionary[SMALL_PHOTO] = imageViewSmall;
    
    photoDictionary[ALBUM_ID_ON_PHOTO] = self.albumID;
    
    self.photoCounter = [NSNumber numberWithInt:[self.photoCounter intValue] + 1];
    
    NSString *completePhotoIDStringValue = [NSString stringWithFormat:@"%@%i",self.albumID, [self.photoCounter intValue]];
    
    photoDictionary[PHOTO_ID] = self.photoCounter;
    
    ((ImageViewWithPhotoTag *) photoDictionary[SMALL_PHOTO]).photoID = [completePhotoIDStringValue integerValue];
    return photoDictionary;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image =  info[UIImagePickerControllerOriginalImage];
    if (image) {
        
        NSMutableDictionary *photoDictionary = [self buildPhotoDictionary:image];

        NSMutableArray *array = [self.photosLarge mutableCopy];
        [array addObject:(UIImageView *)photoDictionary[LARGE_PHOTO]];
        self.photosLarge = array;
        
        //add picture to data source
        [self.pictures addObject:[photoDictionary objectForKey:SMALL_PHOTO]];
        
        [self.collectionView reloadData];
        


        //update album attribute photo count
        NSDictionary *updatedAlbumWithNewPhotoCount = [[NSDictionary alloc]initWithObjectsAndKeys:self.photoCounter, PHOTO_COUNTER, self.title, ALBUM_TITLE, self.albumID, ALBUM_ID, self.albumLocation, LOCATION,  nil];
        
        //save to core data
        [self.sharedDocument prepareDatabaseDocument:photoDictionary withUnsavedAlbumDictionary:updatedAlbumWithNewPhotoCount];
    
    } else {
       UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"We could not locate your photo. Please make sure your camera is working properly and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    
    [self dismissImagePicker];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissImagePicker];
}

- (void)dismissImagePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
   
}

#pragma mark - select contacts
-(void)showContacts
{
    SMContactsSelector *controller = [[SMContactsSelector alloc] initWithNibName:@"SMContactsSelector" bundle:nil];
    controller.delegate = self;
    controller.requestData = DATA_CONTACT_TELEPHONE; // DATA_CONTACT_ID DATA_CONTACT_EMAIL , DATA_CONTACT_TELEPHONE
    controller.showModal = YES; //Mandatory: YES or NO
    controller.showCheckButton = YES; //Mandatory: YES or NO
    // Set your contact list setting record ids (optional)
    //controller.recordIDs = [NSArray arrayWithObjects:@"1", @"2", nil];
    [self presentViewController:controller animated:YES completion:^ {
        [self.spinner stopAnimating];
    }];
}

#pragma mark - SMContactsSelectorDelegate Methods
- (void)numberOfRowsSelected:(NSInteger)numberRows withContactData:(NSArray *)data andContactName:(NSArray *)nameData andDataType:(DATA_CONTACT)type
{
    if (type == DATA_CONTACT_TELEPHONE)
    {
        for (int i = 0; i < [data count]; i++)
        {
            NSString *str = [data objectAtIndex:i];
            NSString *name = [nameData objectAtIndex:i];
            str = [str reformatTelephone];
            NSLog(@"Telephone: %@", str);
            NSLog(@"Name: %@", name);
        }
    }
    else if (type == DATA_CONTACT_EMAIL)
    {
        for (int i = 0; i < [data count]; i++)
        {
            NSString *str = [data objectAtIndex:i];
            NSLog(@"Emails: %@", str);
        }
    }
	else
    {
        for (int i = 0; i < [data count]; i++)
        {
            NSString *str = [data objectAtIndex:i];
            NSLog(@"IDs: %@", str);
        }
    }
}

@end
