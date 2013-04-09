//
//  CreateNewAlbumViewController.m
//  OnlyIn
//
//  Created by Jennifer Clark on 3/25/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import "CreateNewAlbumViewController.h"

NSString *const albumTitlePrompt = @"album title";

@interface CreateNewAlbumViewController () <SMContactsSelectorDelegate, UIAlertViewDelegate, UITextFieldDelegate, DataSaved>

@property (weak, nonatomic) IBOutlet UILabel *albumLocationLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) SharedDatabaseDocument *sharedDocument;
@end

@implementation CreateNewAlbumViewController

- (IBAction)exitButton:(UIBarButtonItem *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self resetPostMessage];
   if ([segue.identifier isEqualToString:@"seeNewAlbum"]) {
        ViewAlbumsTableViewController *vatvc = segue.destinationViewController;
        vatvc.currentLocation = self.currentLocation;
         [segue.destinationViewController prepareDatabaseDocument];
      }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textField.text = albumTitlePrompt;
    self.albumLocationLabel.text = self.currentLocation;
    self.sharedDocument = [[SharedDatabaseDocument alloc]init];
    self.sharedDocument.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
    [self performSegueWithIdentifier:@"seeNewAlbum" sender:self];
    }
    else {
        [self resetPostMessage];
    }
}

#pragma mark - text view methods and delegate methods
- (void)resetPostMessage
{
    self.textField.text = albumTitlePrompt;
    self.textField.textColor = [UIColor lightGrayColor];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self.textField.text isEqualToString:albumTitlePrompt]) {
        self.textField.text = @"";
        self.textField.textColor = [UIColor blackColor];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.textField.text isEqualToString:@""]) {
        [self resetPostMessage];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *) event
{
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.textField isFirstResponder] &&
        (self.textField != touch.view))
    {
        [self.textField resignFirstResponder];
    }
}

#pragma mark - save album
- (IBAction)saveAlbum:(UIButton *)sender
{    
    if ([self.textField isFirstResponder]) {
        [self.textField resignFirstResponder];
    }
    
    if (![self.textField.text isEqualToString:albumTitlePrompt] && ![self.textField.text isEqualToString:@""]) {
        //create album ID - CHANGE
        int albumIDPart1 = arc4random_uniform(100);
        int albumIDPart2 = arc4random_uniform(100);
        int albumIDPart3 = arc4random_uniform(100);
        int photoCounterInt = 0;
        NSString *albumIDString = [NSString stringWithFormat:@"%i%i%i", albumIDPart1, albumIDPart2,albumIDPart3];
        
        //create album attributes
        NSString *location = self.albumLocationLabel.text;
        NSString *albumTitle = self.textField.text;
        NSNumber *albumID = [NSNumber numberWithInt:[albumIDString intValue]];
        NSNumber *photoCounter = [NSNumber numberWithInt:photoCounterInt];
        NSDictionary *album = [[NSDictionary alloc]initWithObjectsAndKeys:location, LOCATION, albumTitle, ALBUM_TITLE, albumID, ALBUM_ID,
                              photoCounter, PHOTO_COUNTER, nil];
        
        //save in parse or in core data or in disk cache
        [self.sharedDocument prepareDatabaseDocument:nil withUnsavedAlbumDictionary:album]; //core data save
        
    }   else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Nothing to Save!" message:@"To create a new album, you must specify an album title" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
        
}

#pragma mark - save delegate method
- (void)showAlertView:(SharedDatabaseDocument *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Saved!" message: @"You may now edit this album." delegate:self cancelButtonTitle:@"Done" otherButtonTitles:@"Go to Album", nil];
    alertView.cancelButtonIndex = 1;
    [alertView show];
}


#pragma mark  show contacts
- (IBAction)showContacts:(UIButton *)sender
{
    if ([self.textField isFirstResponder]) {
        [self.textField resignFirstResponder];
    }
    
    SMContactsSelector *controller = [[SMContactsSelector alloc] initWithNibName:@"SMContactsSelector" bundle:nil];
    controller.delegate = self;
    controller.requestData = DATA_CONTACT_TELEPHONE; // DATA_CONTACT_ID DATA_CONTACT_EMAIL , DATA_CONTACT_TELEPHONE
    controller.showModal = YES; //Mandatory: YES or NO
    controller.showCheckButton = YES; //Mandatory: YES or NO
    
    // Set your contact list setting record ids (optional)
    //controller.recordIDs = [NSArray arrayWithObjects:@"1", @"2", nil];
    
    [self presentViewController:controller animated:YES completion:nil];
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

