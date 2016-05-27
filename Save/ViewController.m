//
//  ViewController.m
//  Save
//
//  Created by Jonathan Schober on 1/23/16.
//  Copyright © 2016 Jonathan Schober. All rights reserved.
//

#import "ViewController.h"
#define EMAIL @"saver@solomonway.com"
@interface ViewController () <MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *invest;

@end

@implementation ViewController
NSArray *values;
NSInteger cents = 0;
NSUserDefaults *defaults;
NSNumber *dollars = 0;
- (void)viewDidLoad{
    values = @[@5,@6,@7,@8,@9,@10,@11,@12,@13,@14,@15,@25,@50,@75,@100];
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"email"] == nil || [defaults objectForKey:@"name"] == nil || [defaults objectForKey:@"phone"] == nil) {
        [self showOnboarding];
    }
}
- (IBAction)clearDefaults:(id)sender {
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void)showOnboarding{
    __block OnboardingViewController *onboardingVC;
    OnboardingContentViewController *namePage = [OnboardingContentViewController contentWithTitle:@"Welcome" body:@"Thanks for installing \"The Solomon Saver.\"\n\nTo get started, we need a few things.\n\nLet's start with a name" image:[UIImage imageNamed:@"Solomongroup.png"] buttonText:@"Enter Full Name" action:^{
        [self onboardingNameAlertWithVC:onboardingVC];
    }];
    OnboardingContentViewController *emailPage = [OnboardingContentViewController contentWithTitle:@"Thanks so much" body:@"You're almost done.\n\nNow we need your email address" image:[UIImage imageNamed:@"Solomongroup.png"] buttonText:@"Enter E-mail" action:^{
        [self onboardingEmailAlertWithVC:onboardingVC];
    }];
    OnboardingContentViewController *phonePage = [OnboardingContentViewController contentWithTitle:@"Perfect!" body:@"Last step!\n\nNow we need your phone number" image:[UIImage imageNamed:@"Solomongroup.png"] buttonText:@"Enter Phone Number" action:^{
        [self onboardingPhoneAlertWithVC:onboardingVC];
    }];
    onboardingVC = [OnboardingViewController onboardWithBackgroundImage:[UIImage imageNamed:@"cash.jpg"] contents:@[namePage,emailPage,phonePage]];
    if ([[UIScreen mainScreen].currentMode size].height < 1000){
        onboardingVC.topPadding = 10;
        onboardingVC.underIconPadding = 5;
        onboardingVC.titleFontSize = 22;
        onboardingVC.bodyFontSize = 18;
    }else if ([[UIScreen mainScreen].currentMode size].height < 1200){
        onboardingVC.topPadding = 15;
        onboardingVC.underIconPadding = 5;
        onboardingVC.titleFontSize = 25;
        onboardingVC.bodyFontSize = 20;
    }
    //    onboardingVC.shouldBlurBackground = YES;
    namePage.movesToNextViewController = YES;
    emailPage.movesToNextViewController = YES;
    phonePage.movesToNextViewController = YES;
    onboardingVC.swipingEnabled = NO;
    onboardingVC.hidePageControl = YES;
    UIAlertController *legalText = [UIAlertController alertControllerWithTitle:@"The Solomon Saver" message:@"This product is a service item for existing clients of The Solomon Group Financial Services, LLC. If you are not currently a client, contact The Solomon Group Financial Services at "EMAIL preferredStyle:UIAlertControllerStyleAlert];
    [legalText addAction:[UIAlertAction actionWithTitle:@"Contact" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        MFMailComposeViewController* composeVC = [[MFMailComposeViewController alloc] init];
        composeVC.mailComposeDelegate = self;
        [composeVC setToRecipients:@[EMAIL]];
        NSLog(EMAIL);
        [self presentViewController:composeVC animated:YES completion:nil];
    }]];
    [legalText addAction:[UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self presentViewController:onboardingVC animated:YES completion:nil];
    }]];
    [self presentViewController:legalText animated:YES completion:nil];
    
}
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    // Check the result or perform other tasks.
    
    // Dismiss the mail compose view controller.
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [values count];
}
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSInteger selectedRow = [pickerView selectedRowInComponent:0];
    [self updateLabelWithRow:selectedRow];
    return [NSString stringWithFormat:@"$%@",values[row]];
    
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    [self updateLabelWithRow:row];
}
-(void)updateLabelWithRow:(NSInteger)row{
    dollars = values[row];
    [UIView setAnimationsEnabled:NO];
    [self.invest setTitle:[self amountString] forState:UIControlStateNormal];
    [self.invest layoutIfNeeded];
    [UIView setAnimationsEnabled:YES];
}
-(NSString*)amountString{
    return [NSString stringWithFormat:@"Reward yourself: $%@",dollars];
}
-(float)amountFloat{
    return [dollars floatValue];
}
-(IBAction)sendEmail{
    [AppDelegate sendEmailWithAmount:[self amountFloat]];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Solomon's Saver" message:@"Long Journeys are traveled in small steps.\n\nCongratulations on investing in yourself!\n\nRequests sent after 3pm Central (M-F) will be processed the following business day." preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController: alert
                       animated: YES
                     completion:^{
                         alert.view.superview.userInteractionEnabled = YES;
                         [alert.view.superview addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(alertControllerBackgroundTapped)]];
                     }];
    
    
}
- (void)alertControllerBackgroundTapped
{
    [self dismissViewControllerAnimated: YES
                             completion: nil];
}


-(void)onboardingPhoneAlertWithVC:(UIViewController*)vc{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Phone Number"
                                  message:[NSString stringWithFormat:@"Enter your %@",@"Phone Number"]
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   [defaults setObject:[[[alert textFields]firstObject]text] forKey:@"phone"];
                                                   [defaults synchronize];
                                                   
                                                   [self checkOnboardingFinishedLastVC:vc];
                                               }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    [alert addAction:cancel];
    [alert addAction:ok];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Phone Number";
        textField.keyboardType = UIKeyboardTypePhonePad;
    }];
    
    [vc presentViewController:alert animated:YES completion:nil];
}


-(void)onboardingEmailAlertWithVC:(OnboardingViewController*)vc{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Email Address"
                                  message:[NSString stringWithFormat:@"Enter your %@",@"E-Mail Address"]
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   [defaults setObject:[[[alert textFields]firstObject]text] forKey:@"email"];
                                                   [defaults synchronize];
                                                   [vc moveNextPage];
                                                   [self checkOnboardingFinished]; }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    
    [alert addAction:cancel];
    [alert addAction:ok];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"E-Mail Address";
        textField.keyboardType = UIKeyboardTypeEmailAddress;
    }];
    
    [vc presentViewController:alert animated:YES completion:nil];
}

-(void)onboardingNameAlertWithVC:(OnboardingViewController*)vc {
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Name"
                                  message:[NSString stringWithFormat:@"Enter your %@",@"Name"]
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   NSString *fullName = [NSString stringWithFormat:@"%@ %@",[[[alert textFields]firstObject]text],[[[alert textFields]lastObject]text]];
                                                   if ([[[alert textFields]firstObject]text] != nil){
                                                       [defaults setObject:fullName forKey:@"name"];
                                                       [defaults synchronize];
                                                   }
                                                   [vc moveNextPage];
                                                   [self checkOnboardingFinished];
                                               }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    
    [alert addAction:cancel];
    [alert addAction:ok];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"First Name";
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Last Name";
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    }];
    
    [vc presentViewController:alert animated:YES completion:nil];
}
-(void)checkOnboardingFinished{
    if ([defaults objectForKey:@"email"] != nil && [defaults objectForKey:@"name"] != nil && [defaults objectForKey:@"phone"] != nil) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
-(void)checkOnboardingFinishedLastVC: (UIViewController*)vc{
    if ([defaults objectForKey:@"email"] != nil && [defaults objectForKey:@"name"] != nil && [defaults objectForKey:@"phone"] != nil) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Something went wrong"
                                      message:@"Oh no!\nIt looks like all the information wasn't given."
                                      preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Start Over" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           [self dismissViewControllerAnimated:YES completion:nil];
                                                           [self showOnboarding];
                                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                                       }];
        [alert addAction:cancel];
        [vc presentViewController:alert animated:YES completion:nil];
    }
}

@end
