//
//  HomeViewController.m
//  OnlyIn
//
//  Created by Jennifer Clark on 3/25/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController () <setCurrentLocation>

@property (strong, nonatomic) GetMapLocation *getMapLocation;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) UILabel *locationLabel;
@property (strong, nonatomic) NSString *currentLocation;

@property (weak, nonatomic) IBOutlet UIButton *viewAlbumsButton;
@property (weak, nonatomic) IBOutlet UIButton *createNewAlbumButton;
@property (strong, nonatomic) NSDate *mostRecentDate;

@end

@implementation HomeViewController

-(void)hideButtons
{
    if (!self.viewAlbumsButton.isHidden)  self.viewAlbumsButton.hidden = YES;
    if (!self.createNewAlbumButton.isHidden)  self.createNewAlbumButton.hidden = YES;
}

-(void)showButtons
{
    if (self.viewAlbumsButton.isHidden)  self.viewAlbumsButton.hidden = NO;
    if (self.createNewAlbumButton.isHidden)  self.createNewAlbumButton.hidden = NO;
}

//delegate method 
- (void)updateLocationLabel:(GetMapLocation *)sender currentLocation:(NSString *)locationInfo
{
    [self.spinner stopAnimating];
    [self.view addSubview:self.locationLabel];
    self.currentLocation = locationInfo;
    self.locationLabel.text = locationInfo;
    [self showButtons];
}

//set up the view elements
- (UIActivityIndicatorView *)createSpinner
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = self.locationLabel.center;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    spinner.hidesWhenStopped = YES;
    return spinner;
}

#define label_x_origin 60
#define label_y_origin 50
#define label_width 200
#define label_height 50
- (UILabel *)createLabel
{
    if (self.locationLabel.text) self.locationLabel.text = nil;
    CGRect frame = CGRectMake(label_x_origin, label_y_origin, label_width, label_height);
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    label.textColor = [UIColor grayColor];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

-(void)checkLocation
{
    self.getMapLocation = [[GetMapLocation alloc]init];
    self.getMapLocation.delegate = self;
    [self.getMapLocation startLocationManagerUpdates];
    self.locationLabel = [self createLabel];
    self.spinner = [self createSpinner];
}

-(void)appEnteredForeground
{
  [self hideButtons];
  [self checkLocation];
}

- (void)getCurrentDateAndTime
{
    if (!self.mostRecentDate) {
        self.mostRecentDate = [NSDate date];
        [self hideButtons];
        [self checkLocation];
    } else {
        NSDate *timeNow = [NSDate date];
        NSTimeInterval elapsed = [timeNow timeIntervalSinceDate:self.mostRecentDate];
        self.mostRecentDate = timeNow;
        float timeElapsedInMinutes = elapsed/60;
        if (timeElapsedInMinutes > 5) {
            [self hideButtons];
            [self checkLocation];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnteredForeground) name:@"AppDidEnterForegroundNotification" object:nil];
    [self getCurrentDateAndTime];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"createNewAlbum"]) {
        [segue.destinationViewController setCurrentLocation:self.currentLocation];
    } else if ([segue.identifier isEqualToString:@"viewAlbums"]) {
        ViewAlbumsTableViewController *vatvc = segue.destinationViewController;
        vatvc.currentLocation = self.currentLocation;
        [vatvc prepareDatabaseDocument];
    }
    
}

@end
