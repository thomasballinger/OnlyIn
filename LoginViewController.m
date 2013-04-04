//
//  LoginViewController.m
//  OnlyIn
//
//  Created by Jennifer Clark on 3/25/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import "LoginViewController.h"

NSString *const userIdPrompt = @"userId";
NSString *const passwordPrompt = @"password";

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *userPasswordTextField;

@end

@implementation LoginViewController

- (IBAction)loginButton:(UIButton *)sender {
    
    [self performSegueWithIdentifier:@"loginSuccess" sender:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.userNameTextField.text = userIdPrompt;
    self.userPasswordTextField.text = passwordPrompt;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
