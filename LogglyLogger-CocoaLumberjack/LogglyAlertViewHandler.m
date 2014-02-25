//
// Created by Mats Melke on 2014-02-21.
// Copyright (c) 2014 Expressen. All rights reserved.
//

#import "LogglyAlertViewHandler.h"
#import "AppSingleton.h"
#import "LogglyFields.h"


@implementation LogglyAlertViewHandler {

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    UITextField *textfield = [alertView textFieldAtIndex:0];
    if (textfield && [textfield.text length] > 0) {
        [AppSingleton sharedInstance].logglyFields.debugidentifier = textfield.text;
    }
}

@end
