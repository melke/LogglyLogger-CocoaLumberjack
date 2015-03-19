//
// Created by Mats Melke on 2014-02-20.
//

#import "LogglyLogger.h"
#import "AFHTTPRequestOperation.h"


@implementation LogglyLogger {
    // Some private iVars
    NSMutableArray *_logMessagesArray;
    NSURL *_logglyURL;
    BOOL _hasLoggedFirstLogglyPost;
}

- (id)init {
    self = [super init];
    if (self) {

        self.deleteInterval = 0;
        self.maxAge = 0;
        self.deleteOnEverySave = NO;
        self.saveInterval = 600;
        self.saveThreshold = 1000;

        // Make sure we POST the logs when the application is suspended
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(saveOnSuspend)
                                                     name:@"UIApplicationWillResignActiveNotification"
                                                   object:nil];

        // No NSLOG of first Loggly request at all if not DEBUG
        _hasLoggedFirstLogglyPost = YES;
#ifdef DEBUG
        _hasLoggedFirstLogglyPost = NO;
#endif
    }

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Overridden methods from DDAbstractDatabaseLogger

- (BOOL)db_log:(DDLogMessage *)logMessage
{
    // Return YES if an item was added to the buffer.
    // Return NO if the logMessage was ignored.
    if (!self->_logFormatter) {
        // No formatter set, don't log
#ifdef DEBUG
        NSLog(@"No formatter set in LogglyLogger. Will not log anything.");
#endif
        return NO;
    }
    
    // Initialize the log messages array if we havn't already (or its recently been cleared by saving to loggly).
    if ( ! _logMessagesArray) {
        _logMessagesArray = [NSMutableArray arrayWithCapacity:1000];
    }

    if ([_logMessagesArray count] > 2000) {
        // Too much logging is coming in too fast. Let's not put this message in the array
        // However, we want the abstract logger to retry at some time later, so
        // let's return YES, so the log message counters in the abstract logger keeps getting incremented.
        return YES;
    }

    [_logMessagesArray addObject:[self->_logFormatter formatLogMessage:logMessage]];
    return YES;
}

- (void)db_save
{
    [self db_saveAndDelete];
}

- (void)db_delete
{
    // We don't ever want to delete log messages on Loggly
}

- (void)db_saveAndDelete
{
    if ( ! [self isOnInternalLoggerQueue]) {
        NSAssert(NO, @"db_saveAndDelete should only be executed on the internalLoggerQueue thread, if you're seeing this, your doing it wrong.");
    }
    
    // If no log messages in array, just return
    if ([_logMessagesArray count] == 0) {
        return;
    }

    // Get reference to log messages
    NSArray *oldLogMessagesArray = [_logMessagesArray copy];

    // reset array
    _logMessagesArray = [NSMutableArray arrayWithCapacity:0];

    // Create string with all log messages
    NSString *logMessagesString = [oldLogMessagesArray componentsJoinedByString:@"\n"];

    // Post string to Loggly
    [self doPostToLoggly:logMessagesString];

}

- (void)doPostToLoggly:(NSString *)messagesString {

    if ([messagesString length] == 0) {
        return;
    }

    if (!self.logglyKey) {
        NSAssert(false, @"You MUST set a loggly api key in the logglyKey property of this logger");
    }

    if (!_logglyURL) {
        _logglyURL = [NSURL URLWithString:[NSString stringWithFormat:self.logglyUrlTemplate, self.logglyKey, self.logglyTags]];
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_logglyURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[messagesString dataUsingEncoding:NSUTF8StringEncoding]];

    if (!_hasLoggedFirstLogglyPost) {
        NSLog(@"Posting to Loggly: %@", messagesString);
    }
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    // Make sure the post request can finish in background
#ifndef AF_APP_EXTENSIONS
    [operation setShouldExecuteAsBackgroundTaskWithExpirationHandler:^{
        // Handle what to do when the background time has been consumed and iOS will shut us down
        // So, let's do... nothing at all
    }];
#endif

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *response = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        if (!_hasLoggedFirstLogglyPost) {
            NSLog(@"Loggly post response = %@. This was the last NSLog statement you will see from LogglyLogger. The rest of the posts to Loggly will be done silently",response);
            _hasLoggedFirstLogglyPost = YES;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (!_hasLoggedFirstLogglyPost) {
            NSLog(@"Loggly post Error: %@", error);
            _hasLoggedFirstLogglyPost = YES;
        }
    }];

    [operation start];

}

#pragma mark Property getters

- (NSString *)logglyUrlTemplate {
    if (!_logglyUrlTemplate) {
        // As of writing this code, this is the correct url for bulk posting log entries in Loggly
        _logglyUrlTemplate = @"https://logs-01.loggly.com/bulk/%@/tag/%@/";
    }
    return _logglyUrlTemplate;
}

- (NSString *)logglyTags {
    if (!_logglyTags) {
        // Default to bundle id
        _logglyTags = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    }
    return _logglyTags;
}

- (void) saveOnSuspend {
#ifdef DEBUG
    NSLog(@"Suspending, posting logs to Loggly");
#endif
    
    dispatch_async(_loggerQueue, ^{
        [self db_save];
    });
}

@end
