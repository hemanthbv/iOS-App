//
//  TouchIDHandler.m
//  SmartAppTouchID
//
//  Created by InQuest Technologies India
//  Copyright © 2016 InQuest Technologies. All rights reserved.
//
//


#import "TouchIDHandler.h"
#import <LocalAuthentication/LocalAuthentication.h>

static TouchIDHandler *sharedInstance = Nil;

@interface TouchIDHandler()

@property (nonatomic, strong) NSError *authError;
@property (nonatomic, strong) LAContext *laContext;
@property (nonatomic, readwrite) BOOL fLocalAuthentication;

@property (nonatomic, strong) id<TouchIdDelegate> tDelegate;

@end

@implementation TouchIDHandler

+(id)sharedInstance
{
    static dispatch_once_t dispatchOnce;
    
    dispatch_once (&dispatchOnce, ^{
        sharedInstance = [[self alloc] initLocalAuthentication];
    });
    
    return sharedInstance;
}

-(id)initLocalAuthentication
{
    self = [super init];
    if(self != nil)
    {
        self.laContext = [[LAContext alloc] init];
    }
    return self;
}

-(void)setTouchIdDelegate:(id)delegate {
    self.tDelegate = delegate;
}


-(BOOL)checkForLocalAuthentication {
    
    NSError *err = Nil;
    if ( self.laContext ) {
        [self.laContext invalidate];
    }
    
    self.laContext = Nil;
    self.laContext = [[LAContext alloc] init];
    self.fLocalAuthentication = [self.laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error: &err];
    
    self.authError = Nil;
    self.authError = err;
    return self.fLocalAuthentication;
    
}

-(NSError *)disableTouchIDWithMessage:(NSDictionary *)touchIDObj {
    
    NSString *message = touchIDObj[TOUCHID_MESSAGE];
    NSString *identifier = touchIDObj[TOUCHID_IDENTIFIER];
    
    NSMutableDictionary *failedObj = [[NSMutableDictionary alloc] init];
    [failedObj setObject:[NSNumber numberWithInt:TOUCHID_FAILED] forKey:TOUCHID_STATUS];
    [failedObj setObject:[NSNumber numberWithInt:RESPONSE_DISABLE] forKey:TOUCHID_RESPONSETYPE];
    
    if ( [self checkForLocalAuthentication] ) {
        [self removeUserInfo:message withIdentifier:identifier];
    }
    else {
        [failedObj setObject:self.authError forKey:TOUCHID_ERROR];
        if ( [self.tDelegate respondsToSelector:@selector(handleTouchIDFailureCallback:)]) {
            [self.tDelegate handleTouchIDFailureCallback:failedObj];
        }
        return self.authError;
    }

    return self.authError;
}

-(NSError *)enableTouchIDWithMessage:(NSDictionary *)touchIDObj {
    
    NSMutableDictionary *failedObj = [[NSMutableDictionary alloc] init];
    [failedObj setObject:[NSNumber numberWithInt:TOUCHID_FAILED] forKey:TOUCHID_STATUS];
    [failedObj setObject:[NSNumber numberWithInt:RESPONSE_ENABLE] forKey:TOUCHID_RESPONSETYPE];

    NSString *message = touchIDObj[TOUCHID_MESSAGE];
    NSString *saveInfo = touchIDObj[TOUCHID_CREDENTIALS];
    NSString *identifier = touchIDObj[TOUCHID_IDENTIFIER];
    
    if ( [self checkForLocalAuthentication] ) {
        [self.laContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                       localizedReason:message
                                 reply:^(BOOL success, NSError *error) {
                                     if (success) {
                                         [self saveUserInfoForFutureValidation:saveInfo withIdentifier:identifier];
                                     } else {
                                         if ( [self.tDelegate respondsToSelector:@selector(handleTouchIDFailureCallback:)]) {
                                             [self.tDelegate handleTouchIDFailureCallback:failedObj];
                                         }
                                     }
                                 }];
    }
    else {
        [failedObj setObject:self.authError forKey:TOUCHID_ERROR];
        if ( [self.tDelegate respondsToSelector:@selector(handleTouchIDFailureCallback:)]) {
            [self.tDelegate handleTouchIDFailureCallback:failedObj];
        }
        return self.authError;
    }
    
    return self.authError;
}

-(NSError *)showTouchIDValidateForMessage:(NSDictionary *)touchIDObj {
    
    NSString *message = touchIDObj[TOUCHID_MESSAGE];
    NSString *identifier = touchIDObj[TOUCHID_IDENTIFIER];

    NSMutableDictionary *failedObj = [[NSMutableDictionary alloc] init];
    [failedObj setObject:[NSNumber numberWithInt:TOUCHID_FAILED] forKey:TOUCHID_STATUS];
    [failedObj setObject:[NSNumber numberWithInt:RESPONSE_VALIDATE] forKey:TOUCHID_RESPONSETYPE];

    if ( [self checkForLocalAuthentication] ) {
        [self validateUserInfo:message withIdentifier:identifier];
    }
    else {
        [failedObj setObject:self.authError forKey:TOUCHID_ERROR];
        if ( [self.tDelegate respondsToSelector:@selector(handleTouchIDFailureCallback:)]) {
            [self.tDelegate handleTouchIDFailureCallback:failedObj];
        }
        return self.authError;
    }
    
    return self.authError;
}

// enable touch with password
-(NSError *)enableTouchIDWithPasswordPrompt:(NSDictionary *)touchIDObj
{
    NSMutableDictionary *failedObj = [[NSMutableDictionary alloc] init];
    [failedObj setObject:[NSNumber numberWithInt:TOUCHID_FAILED] forKey:TOUCHID_STATUS];
    [failedObj setObject:[NSNumber numberWithInt:RESPONSE_ENABLE] forKey:TOUCHID_RESPONSETYPE];
    
    NSString *message = touchIDObj[TOUCHID_MESSAGE];
    NSString *saveInfo = touchIDObj[TOUCHID_CREDENTIALS];
    NSString *identifier = touchIDObj[TOUCHID_IDENTIFIER];
    
    if ( [self checkForLocalAuthentication] ) {
        [self.laContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                       localizedReason:message
                                 reply:^(BOOL success, NSError *error) {
                                     if (success) {
                                         [self savePasswordAccessWithTouchIDForFutureValidation:saveInfo withIdentifier:identifier];
                                     } else {
                                         if ( [self.tDelegate respondsToSelector:@selector(handleTouchIDFailureCallback:)]) {
                                             [self.tDelegate handleTouchIDFailureCallback:failedObj];
                                         }
                                     }
                                 }];
    }
    else {
        [failedObj setObject:self.authError forKey:TOUCHID_ERROR];
        if ( [self.tDelegate respondsToSelector:@selector(handleTouchIDFailureCallback:)]) {
            [self.tDelegate handleTouchIDFailureCallback:failedObj];
        }
        return self.authError;
    }
    
    return self.authError;
}


-(BOOL)savePasswordAccessWithTouchIDForFutureValidation:(NSString *)userCredentials withIdentifier:(NSString *)identifier {
    
    NSMutableDictionary *failedObj = [[NSMutableDictionary alloc] init];
    [failedObj setObject:[NSNumber numberWithInt:TOUCHID_FAILED] forKey:TOUCHID_STATUS];
    [failedObj setObject:[NSNumber numberWithInt:RESPONSE_ENABLE_PWD] forKey:TOUCHID_RESPONSETYPE];
    
    // The identifier and service name together will uniquely identify the keychain entry.
    NSString * keychainItemIdentifier = identifier;
    NSString * keychainItemServiceName = @"www.smartapp.com";
    
    // The content of the user credentials
    NSData * pwData = [userCredentials dataUsingEncoding:NSUTF8StringEncoding];
    
    // Create the keychain entry attributes.
    NSMutableDictionary	* attributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        (__bridge id)(kSecClassGenericPassword), kSecClass,
                                        keychainItemIdentifier, kSecAttrAccount,
                                        keychainItemServiceName, kSecAttrService,
                                        kSecUseAuthenticationUIAllow, kSecUseAuthenticationUI,nil];
    
    // Require a fingerprint scan or passcode validation when the keychain entry is read.
    // Apple also offers an option to destroy the keychain entry if the user ever removes the
    // passcode from his iPhone, but we don't need that option here.
    CFErrorRef accessControlError = NULL;
    SecAccessControlRef accessControlRef = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                                                           kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                                                                           kSecAccessControlTouchIDAny | kSecAccessControlApplicationPassword, &accessControlError);
    
    if (accessControlRef == NULL || accessControlError != NULL)
    {
        NSLog(@"Cannot create SecAccessControlRef to store a password with identifier “%@” in the key chain: %@.", keychainItemIdentifier, accessControlError);
        
        [failedObj setObject:(__bridge id)(accessControlError) forKey:TOUCHID_ERROR];
        
        if ( [self.tDelegate respondsToSelector:@selector(handleTouchIDFailureCallback:)]) {
            [self.tDelegate handleTouchIDFailureCallback:failedObj];
        }
        
        return FALSE;
    }
    
    attributes[(__bridge id)kSecAttrAccessControl] = (__bridge id)accessControlRef;
    // In case this code is executed again and the keychain item already exists we want an error code instead of a fingerprint scan.
    attributes[(__bridge id)kSecUseAuthenticationUI] = @YES;
    attributes[(__bridge id)kSecValueData] = pwData;
    CFTypeRef result;
    OSStatus osStatus = SecItemAdd((__bridge CFDictionaryRef)attributes, &result);
    if (osStatus != noErr)
    {
        NSError * error = [[NSError alloc] initWithDomain:NSOSStatusErrorDomain code:osStatus userInfo:nil];
        NSLog(@"Adding generic password with identifier “%@” to keychain failed with OSError %d: %@.", keychainItemIdentifier, (int)osStatus, error);
        
        [failedObj setObject:error forKey:TOUCHID_ERROR];
        
        if ( [self.tDelegate respondsToSelector:@selector(handleTouchIDFailureCallback:)]) {
            [self.tDelegate handleTouchIDFailureCallback:failedObj];
        }
        
        CFRelease(accessControlRef);
        return FALSE;
    }
    
    NSMutableDictionary *successObj = [[NSMutableDictionary alloc] init];
    [successObj setObject:[NSNumber numberWithInt:TOUCHID_SUCCESS] forKey:TOUCHID_STATUS];
    [successObj setObject:[NSNumber numberWithInt:RESPONSE_ENABLE_PWD] forKey:TOUCHID_RESPONSETYPE];
    [successObj setObject:userCredentials forKey:TOUCHID_CREDENTIALS];
    
    if ( [self.tDelegate respondsToSelector:@selector(handleTouchIDSuccessCallback:)]) {
        [self.tDelegate handleTouchIDSuccessCallback:successObj];
    }
    
    CFRelease(accessControlRef);
    return TRUE;
}


-(BOOL)saveUserInfoForFutureValidation:(NSString *)userCredentials withIdentifier:(NSString *)identifier {
    
    NSMutableDictionary *failedObj = [[NSMutableDictionary alloc] init];
    [failedObj setObject:[NSNumber numberWithInt:TOUCHID_FAILED] forKey:TOUCHID_STATUS];
    [failedObj setObject:[NSNumber numberWithInt:RESPONSE_ENABLE] forKey:TOUCHID_RESPONSETYPE];

    // The identifier and service name together will uniquely identify the keychain entry.
    NSString * keychainItemIdentifier = identifier;
    NSString * keychainItemServiceName = @"www.smartapp.com";
    
    // The content of the user credentials
    NSData * pwData = [userCredentials dataUsingEncoding:NSUTF8StringEncoding];
    
    // Create the keychain entry attributes.
    NSMutableDictionary	* attributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        (__bridge id)(kSecClassGenericPassword), kSecClass,
                                        keychainItemIdentifier, kSecAttrAccount,
                                        keychainItemServiceName, kSecAttrService, nil];
    
    // Require a fingerprint scan or passcode validation when the keychain entry is read.
    // Apple also offers an option to destroy the keychain entry if the user ever removes the
    // passcode from his iPhone, but we don't need that option here.
    CFErrorRef accessControlError = NULL;
    SecAccessControlRef accessControlRef = SecAccessControlCreateWithFlags(
                                                                           kCFAllocatorDefault,
                                                                           kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                                                           kSecAccessControlUserPresence,
                                                                           &accessControlError);
    if (accessControlRef == NULL || accessControlError != NULL)
    {
        NSLog(@"Cannot create SecAccessControlRef to store a password with identifier “%@” in the key chain: %@.", keychainItemIdentifier, accessControlError);
        
        [failedObj setObject:(__bridge id)(accessControlError) forKey:TOUCHID_ERROR];
        
        if ( [self.tDelegate respondsToSelector:@selector(handleTouchIDFailureCallback:)]) {
            [self.tDelegate handleTouchIDFailureCallback:failedObj];
        }
        
        return FALSE;
    }
    
    attributes[(__bridge id)kSecAttrAccessControl] = (__bridge id)accessControlRef;
    // In case this code is executed again and the keychain item already exists we want an error code instead of a fingerprint scan.
    attributes[(__bridge id)kSecUseAuthenticationUI] = @NO;
    attributes[(__bridge id)kSecValueData] = pwData;
    CFTypeRef result;
    OSStatus osStatus = SecItemAdd((__bridge CFDictionaryRef)attributes, &result);
    if (osStatus != noErr)
    {
        NSError * error = [[NSError alloc] initWithDomain:NSOSStatusErrorDomain code:osStatus userInfo:nil];
        NSLog(@"Adding generic password with identifier “%@” to keychain failed with OSError %d: %@.", keychainItemIdentifier, (int)osStatus, error);
        
        [failedObj setObject:error forKey:TOUCHID_ERROR];
        
        if ( [self.tDelegate respondsToSelector:@selector(handleTouchIDFailureCallback:)]) {
            [self.tDelegate handleTouchIDFailureCallback:failedObj];
        }
        
        CFRelease(accessControlRef);
        return FALSE;
    }
    
    NSMutableDictionary *successObj = [[NSMutableDictionary alloc] init];
    [successObj setObject:[NSNumber numberWithInt:TOUCHID_SUCCESS] forKey:TOUCHID_STATUS];
    [successObj setObject:[NSNumber numberWithInt:RESPONSE_ENABLE] forKey:TOUCHID_RESPONSETYPE];
    [successObj setObject:userCredentials forKey:TOUCHID_CREDENTIALS];

    if ( [self.tDelegate respondsToSelector:@selector(handleTouchIDSuccessCallback:)]) {
        [self.tDelegate handleTouchIDSuccessCallback:successObj];
    }
    
    CFRelease(accessControlRef);
    return TRUE;
}

-(BOOL)validateUserInfo:(NSString *)userMessage withIdentifier:(NSString *)identifier {
    
    NSMutableDictionary *failedObj = [[NSMutableDictionary alloc] init];
    [failedObj setObject:[NSNumber numberWithInt:TOUCHID_FAILED] forKey:TOUCHID_STATUS];
    [failedObj setObject:[NSNumber numberWithInt:RESPONSE_VALIDATE] forKey:TOUCHID_RESPONSETYPE];

    // The identifier and service name together will uniquely identify the keychain entry.
    NSString * keychainItemIdentifier = identifier;
    NSString * keychainItemServiceName = @"www.smartapp.com";
    
    // The keychain operation shall be performed by the global queue. Otherwise it might just nothing happen.
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        // Create the keychain query attributes using the values from the first part of the code.
        NSMutableDictionary * query = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       (__bridge id)(kSecClassGenericPassword), kSecClass,
                                       keychainItemIdentifier, kSecAttrAccount,
                                       keychainItemServiceName, kSecAttrService,
                                       userMessage, kSecUseOperationPrompt,
                                       kCFBooleanTrue, kSecReturnData,
                                       nil];
        
        // Start the query and the fingerprint scan and/or device passcode validation
        CFTypeRef result = nil;
        OSStatus userPresenceStatus = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
        // Ignore the found content of the key chain entry (the dummy password) and only evaluate the return code.
        if (noErr == userPresenceStatus)
        {
            NSData *data = (__bridge NSData *)result;
            NSString *credentials =  [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            
            
            NSLog(@"Fingerprint or device passcode validated.");
            
            NSMutableDictionary *successObj = [[NSMutableDictionary alloc] init];
            [successObj setObject:[NSNumber numberWithInt:TOUCHID_SUCCESS] forKey:TOUCHID_STATUS];
            [successObj setObject:[NSNumber numberWithInt:RESPONSE_VALIDATE] forKey:TOUCHID_RESPONSETYPE];
            [successObj setObject:credentials forKey:TOUCHID_CREDENTIALS];
            
            if ( [self.tDelegate respondsToSelector:@selector(handleTouchIDSuccessCallback:)]) {
                [self.tDelegate handleTouchIDSuccessCallback:successObj];
            }
        }
        else
        {
            NSString *errMessage = [NSString stringWithFormat:@"Fingerprint or device passcode could not be validated. Status %d.", (int) userPresenceStatus];
            
            NSLog(@"%@", errMessage);
            
            [failedObj setObject:errMessage forKey:TOUCHID_STATUS_MSG];
            
            if ( [self.tDelegate respondsToSelector:@selector(handleTouchIDFailureCallback:)]) {
                [self.tDelegate handleTouchIDFailureCallback:failedObj];
            }
        }

    });
    
    
    return TRUE;
}

-(BOOL)removeUserInfo:(NSString *)userMessage withIdentifier:(NSString *)identifier {
    
    NSMutableDictionary *failedObj = [[NSMutableDictionary alloc] init];
    [failedObj setObject:[NSNumber numberWithInt:TOUCHID_FAILED] forKey:TOUCHID_STATUS];
    [failedObj setObject:[NSNumber numberWithInt:RESPONSE_DISABLE] forKey:TOUCHID_RESPONSETYPE];
    
    // The identifier and service name together will uniquely identify the keychain entry.
    NSString * keychainItemIdentifier = identifier;
    NSString * keychainItemServiceName = @"www.smartapp.com";
    
    // The keychain operation shall be performed by the global queue. Otherwise it might just nothing happen.
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        // Create the keychain query attributes using the values from the first part of the code.
        NSMutableDictionary * query = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       (__bridge id)(kSecClassGenericPassword), kSecClass,
                                       keychainItemIdentifier, kSecAttrAccount,
                                       keychainItemServiceName, kSecAttrService,
                                       userMessage, kSecUseOperationPrompt,
                                       kCFBooleanTrue, kSecReturnData,
                                       nil];
        
        // Start the query and the fingerprint scan and/or device passcode validation
        CFTypeRef result = nil;
        OSStatus userPresenceStatus = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
        // Ignore the found content of the key chain entry (the dummy password) and only evaluate the return code.
        if (noErr == userPresenceStatus)
        {
            OSStatus osStatus = SecItemDelete((__bridge CFDictionaryRef)query);
            if (osStatus != noErr)
            {
                NSError * error = [[NSError alloc] initWithDomain:NSOSStatusErrorDomain code:osStatus userInfo:nil];
                NSLog(@"Deleting generic password with identifier “%@” to keychain failed with OSError %d: %@.", keychainItemIdentifier, (int)osStatus, error);
                
                [failedObj setObject:error forKey:TOUCHID_ERROR];
                
                if ( [self.tDelegate respondsToSelector:@selector(handleTouchIDFailureCallback:)]) {
                    [self.tDelegate handleTouchIDFailureCallback:failedObj];
                }
                
                return ;
            }
            
            NSMutableDictionary *successObj = [[NSMutableDictionary alloc] init];
            [successObj setObject:[NSNumber numberWithInt:TOUCHID_SUCCESS] forKey:TOUCHID_STATUS];
            [successObj setObject:[NSNumber numberWithInt:RESPONSE_DISABLE] forKey:TOUCHID_RESPONSETYPE];
            
            if ( [self.tDelegate respondsToSelector:@selector(handleTouchIDSuccessCallback:)]) {
                [self.tDelegate handleTouchIDSuccessCallback:successObj];
            }
        }
        else
        {
            NSString *errMessage = [NSString stringWithFormat:@"Fingerprint or device passcode could not be validated. Status %d.", (int) userPresenceStatus];
            
            NSLog(@"%@", errMessage);
            
            [failedObj setObject:errMessage forKey:TOUCHID_STATUS_MSG];
            
            if ( [self.tDelegate respondsToSelector:@selector(handleTouchIDFailureCallback:)]) {
                [self.tDelegate handleTouchIDFailureCallback:failedObj];
            }
        }
        
    });
    
    
    return TRUE;
}


-(NSString*)saveData:(NSString *)data
{
    NSString* fileContents = nil;
    @try {
        
        NSFileManager* fm = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *pathToFile = [documentsDirectory stringByAppendingPathComponent:@"fileName"];
        NSData* fileData = [data dataUsingEncoding:NSUTF8StringEncoding];
        
        if([fm fileExistsAtPath:pathToFile]) {
            // append
            NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:pathToFile];
            [handle truncateFileAtOffset:[handle seekToEndOfFile]];
            [handle writeData:fileData];
            [handle closeFile];
        }
        else { 
            [fm createFileAtPath:pathToFile contents:fileData attributes:Nil];
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"ERROR:Exception from readFile  - %@", exception.reason);
    }
    @finally {
        
    }
    
    return fileContents;
}

-(NSString*)readFile
{
    NSString* fileContents = nil;
    @try {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *pathToFile = [documentsDirectory stringByAppendingPathComponent:@"fileName"];
        
        fileContents = [NSString stringWithContentsOfFile:pathToFile
                                                 encoding:NSUTF8StringEncoding
                                                    error:NULL];
    }
    @catch (NSException *exception) {
        NSLog(@"ERROR:Exception from readFile  - %@", exception.reason);
    }
    @finally {
        
    }
    
    return fileContents;
}

@end

