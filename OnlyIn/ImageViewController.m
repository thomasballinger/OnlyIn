//
//  ImageViewController.m
//  OnlyIn
//
//  Created by Jennifer Clark on 4/3/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageView.image = self.photo;
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
