//
//  LLAppDelegate.m
//  ExampleProject
//
//  Created by Mats Melke on 2014-02-28.
//  Copyright (c) 2014 Mats Melke. All rights reserved.
//

#import "LLAppDelegate.h"
#import "LogglyLogger.h"
#import "LogglyFormatter.h"
#import "DDTTYLogger.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation LLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    LogglyLogger *logglyLogger = [[LogglyLogger alloc] init];
    [logglyLogger setLogFormatter:[[LogglyFormatter alloc] init]];
    logglyLogger.logglyKey = @"c5e3fb00-c446-4039-a498-4881dab69d38";
    // Set saving every 15 seconds, to speed up the example project, but the default value of 10 minutes is better in apps
    // that normally don't access the network very often.
    logglyLogger.saveInterval = 15;

    [DDLog addLogger:logglyLogger];

    DDLogVerbose(@"Verbose no JSON in log message");
    DDLogVerbose(@"{\"a_json_key\":\"some verbose json value\"}");
    DDLogVerbose(@"{badjson:\"This json is invalid (no quotes around key)\"}");
    DDLogInfo(@"Info no JSON in log message");
    DDLogInfo(@"{\"another_json_key\":\"some info json value\"}");


    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
