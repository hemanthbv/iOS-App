//
//  TouchIDViewController.m
//  SmartAppTouchID
//
//  Created by Hemanth kumar on 08/12/16.
//  Copyright © 2016 InQuest Technologies. All rights reserved.
//

#import "TouchIDViewController.h"
#import "TouchIDHandler.h"
#import "MultipleTouchIDTestViewController.h"
#import "AppDelegate.h"

@interface TouchIDViewController ()<TouchIdDelegate>

@property (nonatomic, weak)IBOutlet UITextField *txtUserName;
@property (nonatomic, weak)IBOutlet UITextField *txtPassword;

@end

@implementation TouchIDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)actionDisableTouchID:(id)sender {
    
    NSMutableDictionary *touchIDObj = [[NSMutableDictionary alloc] init];
    [touchIDObj setObject:@"Testing...." forKey:TOUCHID_MESSAGE];
    [touchIDObj setObject:@"Login Page" forKey:TOUCHID_IDENTIFIER];
    
    [[TouchIDHandler sharedInstance] setTouchIdDelegate:self];
    
    NSError *errMsg = [[TouchIDHandler sharedInstance] disableTouchIDWithMessage:touchIDObj];
    
    if ( errMsg ) {
        //[self showAlertMessage:errMsg.localizedDescription withTitle:@"Error"];
    }
    
}

-(IBAction)actionEnableTouchID:(id)sender {

    if ( ([self.txtPassword.text length] <= 0) || ([self.txtUserName.text length] <= 0)) {
        
        [self showAlertMessage:@"Please enter username and password to enable Touch ID" withTitle:@"Credentials Alert"];
        
        return;
    }
    
    NSString *creditials = [NSString stringWithFormat:@"%@,%@", self.txtUserName.text, self.txtPassword.text];
    
    NSMutableDictionary *touchIDObj = [[NSMutableDictionary alloc] init];
    [touchIDObj setObject:@"Testing...." forKey:TOUCHID_MESSAGE];
    [touchIDObj setObject:creditials forKey:TOUCHID_CREDENTIALS];
    [touchIDObj setObject:@"Login Page" forKey:TOUCHID_IDENTIFIER];
    
    [[TouchIDHandler sharedInstance] setTouchIdDelegate:self];
    
    NSError *errMsg = [[TouchIDHandler sharedInstance] enableTouchIDWithMessage:touchIDObj];
    
    if ( errMsg ) {
        //[self showAlertMessage:errMsg.localizedDescription withTitle:@"Error"];
    }
    
}

-(IBAction)actionTestTouchID:(id)sender {
    
    NSMutableDictionary *touchIDObj = [[NSMutableDictionary alloc] init];
    [touchIDObj setObject:@"Testing...." forKey:TOUCHID_MESSAGE];
    [touchIDObj setObject:@"Login Page" forKey:TOUCHID_IDENTIFIER];
    
    [[TouchIDHandler sharedInstance] setTouchIdDelegate:self];
    NSError *errMsg = [[TouchIDHandler sharedInstance] showTouchIDValidateForMessage:touchIDObj];
    
    if ( errMsg ) {
        //[self showAlertMessage:errMsg.localizedDescription withTitle:@"Error"];
    }
    
}

-(IBAction)actionPasswordTouchID:(id)sender {
    
    if ( ([self.txtPassword.text length] <= 0) || ([self.txtUserName.text length] <= 0)) {
        
        [self showAlertMessage:@"Please enter username and password to enable Touch ID" withTitle:@"Credentials Alert"];
        
        return;
    }
    
    NSString *creditials = [NSString stringWithFormat:@"%@,%@", self.txtUserName.text, self.txtPassword.text];
    
    NSMutableDictionary *touchIDObj = [[NSMutableDictionary alloc] init];
    [touchIDObj setObject:@"Testing...." forKey:TOUCHID_MESSAGE];
    [touchIDObj setObject:creditials forKey:TOUCHID_CREDENTIALS];
    [touchIDObj setObject:@"Login Page" forKey:TOUCHID_IDENTIFIER];
    
    [[TouchIDHandler sharedInstance] setTouchIdDelegate:self];
    
    NSError *errMsg = [[TouchIDHandler sharedInstance] enableTouchIDWithPasswordPrompt:touchIDObj];
    
    if ( errMsg ) {
        //[self showAlertMessage:errMsg.localizedDescription withTitle:@"Error"];
    }
    
}

-(void)showAlertMessage:(NSString *)alertMsg withTitle:(NSString *)titleMsg
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:titleMsg
                                                            message:alertMsg
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        
    });
}

#pragma mark - TouchIDHandler Delegate
-(void)handleTouchIDSuccessCallback:(id)responseObj {
    
    AppDelegate *appDel = (AppDelegate *) [UIApplication sharedApplication].delegate;
    
    int responseType = [[responseObj objectForKey:TOUCHID_RESPONSETYPE] intValue];
    int status = [[responseObj objectForKey:TOUCHID_STATUS] intValue];
    
    switch (responseType) {
        case RESPONSE_VALIDATE:
        case RESPONSE_ENABLE:
        case RESPONSE_ENABLE_PWD:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *credentials = [responseObj objectForKey:TOUCHID_CREDENTIALS];
                NSArray *userInfo = [credentials componentsSeparatedByString:@","];
                self.txtUserName.text = userInfo[0];
                self.txtPassword.text = userInfo[1];
                
                appDel.userName = self.txtUserName.text;
                appDel.passWord = self.txtPassword.text;
                
                MultipleTouchIDTestViewController *viewCtrl = [[MultipleTouchIDTestViewController alloc]initWithNibName:@"MultipleTouchIDTestViewController" bundle:Nil];
                [appDel.navCtrl pushViewController:viewCtrl animated:YES];
                
                [[TouchIDHandler sharedInstance] saveData:[NSString stringWithFormat:@"[Login-%@-%@]", appDel.userName, appDel.passWord]];
            });
            
        }
            break;
        case RESPONSE_DISABLE:
        {
            NSLog(@"Touch ID disabled");
        }
            break;
        default:
            break;
    }
}

-(void)handleTouchIDFailureCallback:(id)responseObj {
    
    int responseType = [[responseObj objectForKey:TOUCHID_RESPONSETYPE] intValue];
    id errObj = [responseObj objectForKey:TOUCHID_ERROR];
    NSString *statusMsg = [responseObj objectForKey:TOUCHID_STATUS_MSG];
    NSError *errMsg = Nil;
    
    if ( [errObj isKindOfClass:[NSError class]]) {
        errMsg = (NSError *)errObj;
        statusMsg = errMsg.localizedDescription;
    }
    
    switch (responseType) {
        case RESPONSE_ENABLE:
        {
            NSLog(@"TouchID enable failed");
            [self showAlertMessage:statusMsg withTitle:@"Error"];
        }
            break;
        case RESPONSE_VALIDATE:
        {
            NSLog(@"TouchID validate failed");
            [self showAlertMessage:statusMsg withTitle:@"Error"];
        }
            break;
        case RESPONSE_DISABLE:
        {
            NSLog(@"TouchID disable failed");
            [self showAlertMessage:statusMsg withTitle:@"Error"];
        }
            break;
        default:
            break;
    }
}

#pragma mark - UITextfield delegates
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
