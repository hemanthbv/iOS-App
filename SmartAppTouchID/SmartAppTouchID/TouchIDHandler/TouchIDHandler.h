//
//  TouchIDHandler.h
//  SmartAppTouchID
//
//  Created by InQuest Technologies India
//  Copyright © 2016 InQuest Technologies. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import "TouchIDConstants.h"

@protocol TouchIdDelegate <NSObject>

@required
-(void)handleTouchIDSuccessCallback:(id)responseObj;
-(void)handleTouchIDFailureCallback:(id)responseObj;

@optional

@end

@interface TouchIDHandler : NSObject

// Shared instance method
+(id)sharedInstance;

// delegate to get back required info
-(void)setTouchIdDelegate:(id)delegate;

// check for local authentication availability
-(BOOL)checkForLocalAuthentication;

// disable touch id
-(NSError *)disableTouchIDWithMessage:(NSDictionary *)touchIDObj;

// enable touch id
-(NSError *)enableTouchIDWithMessage:(NSDictionary *)touchIDObj;

// validate touch id
-(NSError *)showTouchIDValidateForMessage:(NSDictionary *)touchIDObj;

// enable touch with password
-(NSError *)enableTouchIDWithPasswordPrompt:(NSDictionary *)touchIDObj;

// Temp methods
-(NSString*)readFile;
-(NSString*)saveData:(NSString *)data;

@end
