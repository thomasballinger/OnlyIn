//
//  SignUpViewController.m
//  OnlyIn
//
//  Created by Jennifer Clark on 3/25/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (IBAction)submitInformation:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"signUpSuccess" sender:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
