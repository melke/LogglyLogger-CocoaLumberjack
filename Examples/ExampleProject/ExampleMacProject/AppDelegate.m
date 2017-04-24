//
//  AppDelegate.m
//  ExampleMacProject
//
//  Created by Brian Gerstle on 8/30/16.
//  Copyright © 2016 Loggly. All rights reserved.
//

#import "AppDelegate.h"
@import CocoaLumberjack;
@import LogglyLogger_CocoaLumberjack;

static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    LogglyLogger *logglyLogger = [[LogglyLogger alloc] init];
    [logglyLogger setLogFormatter:[[LogglyFormatter alloc] init]];
    logglyLogger.logglyKey = @"your-loggly-api-key";
    
    logglyLogger.saveInterval = 15;
    
    [DDLog addLogger:logglyLogger];
    
    // Do some logging
    DDLogVerbose(@"{\"myJsonKey\":\"some verbose json value\"}");
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
