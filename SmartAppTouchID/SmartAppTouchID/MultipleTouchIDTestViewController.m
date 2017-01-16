//
//  MultipleTouchIDTestViewController.m
//  SmartAppTouchID
//
//  Created by Hemanth kumar on 08/12/16.
//  Copyright © 2016 InQuest Technologies. All rights reserved.
//

#import "MultipleTouchIDTestViewController.h"
#import "TouchIDHandler.h"
#import "AppDelegate.h"

@interface MultipleTouchIDTestViewController ()<TouchIdDelegate>

@property (nonatomic, weak) IBOutlet UIButton *btnThumb;
@property (nonatomic, weak) IBOutlet UIButton *btnIndex;
@property (nonatomic, weak) IBOutlet UIButton *btnMiddle;
@property (nonatomic, weak) IBOutlet UIButton *btnRing;
@property (nonatomic, weak) IBOutlet UIButton *btnLittle;

@property (nonatomic, strong) UIButton *btnValidating;
@property (nonatomic, strong) NSString *strIdentifier;

@end

@implementation MultipleTouchIDTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)actionThumbTouchID:(id)sender {
    AppDelegate *appDel = (AppDelegate *) [UIApplication sharedApplication].delegate;
    NSString *identifier = [NSString stringWithFormat:@"Thumb-%@,%@", appDel.passWord, appDel.userName];
    self.strIdentifier = @"Thumb";
    
    self.btnValidating = self.btnThumb;
    
    [self checkForValidationOREnable];
    
    if(self.btnThumb.tag == 0) {
        [self enableTouchID:identifier];
    } else {
        [self validateTouchID:identifier];
    }
}

-(IBAction)actionIndexTouchID:(id)sender {
    AppDelegate *appDel = (AppDelegate *) [UIApplication sharedApplication].delegate;
    NSString *identifier = [NSString stringWithFormat:@"Index-%@,%@", appDel.passWord, appDel.userName];
    self.strIdentifier = @"Index";
    
    self.btnValidating = self.btnIndex;
    
    [self checkForValidationOREnable];
    
    if(self.btnIndex.tag == 0) {
        [self enableTouchID:identifier];
    } else {
        [self validateTouchID:identifier];
    }
    
}

-(IBAction)actionMiddleTouchID:(id)sender {
    AppDelegate *appDel = (AppDelegate *) [UIApplication sharedApplication].delegate;
    NSString *identifier = [NSString stringWithFormat:@"Middle-%@,%@", appDel.passWord, appDel.userName];
    self.strIdentifier = @"Middle";
    
    self.btnValidating = self.btnMiddle;
    
    [self checkForValidationOREnable];
    
    if(self.btnMiddle.tag == 0) {
        [self enableTouchID:identifier];
    } else {
        [self validateTouchID:identifier];
    }
}

-(IBAction)actionRingTouchID:(id)sender {
    AppDelegate *appDel = (AppDelegate *) [UIApplication sharedApplication].delegate;
    NSString *identifier = [NSString stringWithFormat:@"Ring-%@,%@", appDel.passWord, appDel.userName];
    self.strIdentifier = @"Ring";
    
    self.btnValidating = self.btnRing;
    
    [self checkForValidationOREnable];
    
    if(self.btnRing.tag == 0) {
        [self enableTouchID:identifier];
    } else {
        [self validateTouchID:identifier];
    }
}

-(IBAction)actionBabyTouchID:(id)sender {
    AppDelegate *appDel = (AppDelegate *) [UIApplication sharedApplication].delegate;
    NSString *identifier = [NSString stringWithFormat:@"Baby-%@,%@", appDel.passWord, appDel.userName];
    self.strIdentifier = @"Baby";
    
    self.btnValidating = self.btnLittle;
    
    [self checkForValidationOREnable];
    
    if(self.btnLittle.tag == 0) {
        [self enableTouchID:identifier];
    } else {
        [self validateTouchID:identifier];
    }
}

-(IBAction)actionExit:(id)sender {
    AppDelegate *appDel = (AppDelegate *) [UIApplication sharedApplication].delegate;
    
    [appDel.navCtrl popViewControllerAnimated:YES];
}


-(void)enableTouchID:(NSString *)identifierValue {

    NSMutableDictionary *touchIDObj = [[NSMutableDictionary alloc] init];
    [touchIDObj setObject:@"Different Touch IDs...." forKey:TOUCHID_MESSAGE];
    [touchIDObj setObject:@"" forKey:TOUCHID_CREDENTIALS];
    [touchIDObj setObject:identifierValue forKey:TOUCHID_IDENTIFIER];
    
    [[TouchIDHandler sharedInstance] setTouchIdDelegate:self];
    
    NSError *errMsg = [[TouchIDHandler sharedInstance] enableTouchIDWithMessage:touchIDObj];
    
    if ( errMsg ) {
        ;
    }
    
}

-(void)validateTouchID:(NSString *)identifierValue {
    
    NSMutableDictionary *touchIDObj = [[NSMutableDictionary alloc] init];
    [touchIDObj setObject:@"Different Touch IDs...." forKey:TOUCHID_MESSAGE];
    [touchIDObj setObject:@"" forKey:TOUCHID_CREDENTIALS];
    [touchIDObj setObject:identifierValue forKey:TOUCHID_IDENTIFIER];
    
    [[TouchIDHandler sharedInstance] setTouchIdDelegate:self];
    NSError *errMsg = [[TouchIDHandler sharedInstance] showTouchIDValidateForMessage:touchIDObj];
    
    if ( errMsg ) {
        ;
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
    
    int responseType = [[responseObj objectForKey:TOUCHID_RESPONSETYPE] intValue];
    int status = [[responseObj objectForKey:TOUCHID_STATUS] intValue];
    
    switch (responseType) {
        case RESPONSE_VALIDATE:
        case RESPONSE_ENABLE:
        {
            self.btnValidating.tag = 1;
            [self showAlertMessage:@"Enabled Touch ID" withTitle:@"Success"];
        
            if (responseType != RESPONSE_VALIDATE) {
                [self saveValidationInfo];
            }
            
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
    NSInteger errorCode = 0;
    
    if ( [errObj isKindOfClass:[NSError class]]) {
        errMsg = (NSError *)errObj;
        statusMsg = errMsg.localizedDescription;
        errorCode = errMsg.code;
    }
    
    switch (responseType) {
        case RESPONSE_ENABLE:
        {
            self.btnValidating.tag = 0;
            NSLog(@"TouchID enable failed");
            [self showAlertMessage:statusMsg withTitle:@"Error"];
            if(errorCode == -25299) {
                self.btnValidating.tag = 1;
                [self saveValidationInfo];
            }
        }
            break;
        case RESPONSE_VALIDATE:
        {
            self.btnValidating.tag = 0;
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

-(void)checkForValidationOREnable {
    AppDelegate *appDel = (AppDelegate *) [UIApplication sharedApplication].delegate;
    NSString *fileData = [[TouchIDHandler sharedInstance] readFile];
    NSString *findIdentifier = [NSString stringWithFormat:@"<%@-%@,%@>",self.strIdentifier, appDel.passWord, appDel.userName];
    
    NSRange range = [fileData rangeOfString:findIdentifier];
    
    if (range.location == NSNotFound) {
        self.btnValidating.tag = 0;
    } else {
        self.btnValidating.tag = 1;
    }
}

-(void)saveValidationInfo {
    AppDelegate *appDel = (AppDelegate *) [UIApplication sharedApplication].delegate;
    NSString *findIdentifier = [NSString stringWithFormat:@"<%@-%@,%@>",self.strIdentifier, appDel.passWord, appDel.userName];
    
    [[TouchIDHandler sharedInstance] saveData:findIdentifier];
}
@end
