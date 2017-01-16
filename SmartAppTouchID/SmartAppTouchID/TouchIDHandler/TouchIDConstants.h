//
//  TouchIDConstants.h
//  SmartAppTouchID
//
//  Created by InQuest Technologies India
//  Copyright © 2016 InQuest Technologies. All rights reserved.
//
//

#define TOUCHID_MESSAGE         @"Message"
#define TOUCHID_CREDENTIALS     @"Credentials"
#define TOUCHID_IDENTIFIER      @"Identifier"

#define TOUCHID_RESPONSETYPE            @"ResponseType"
#define TOUCHID_STATUS                  @"Status"
#define TOUCHID_STATUS_MSG              @"StatusMessage"
#define TOUCHID_ERROR                   @"Error"
#define TOUCHID_CREDENTIALS             @"Credentials"

#define TOUCHID_FAILED          0
#define TOUCHID_SUCCESS         1

typedef enum TouchResponseType{
    RESPONSE_DISABLE = 0,
    RESPONSE_ENABLE = 1,
    RESPONSE_ENABLE_PWD = 2,
    RESPONSE_VALIDATE = 3
} touchResponseType;
