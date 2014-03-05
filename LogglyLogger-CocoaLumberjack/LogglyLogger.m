//
// Created by Mats Melke on 2014-02-20.
// Copyright (c) 2014 Expressen. All rights reserved.
//

#import "LogglyLogger.h"
#import "AFHTTPRequestOperation.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation LogglyLogger {
    // Some private iVars
    NSMutableArray *_logMessagesArray;
    NSURL *_logglyURL;
}

- (id)init {
    self = [super init];
    if (self) {
        _logMessagesArray = [NSMutableArray arrayWithCapacity:0];
        _maxLogMessagesInBuffer = 1000;
    }

    return self;
}


#pragma mark Overridden methods from DDAbstractDatabaseLogger

- (BOOL)db_log:(DDLogMessage *)logMessage
{
    // Return YES if an item was added to the buffer.
    // Return NO if the logMessage was ignored.
    if (!self->formatter) {
        // No formatter set, just don't log
        return NO;
    }

    if ([_logMessagesArray count] > _maxLogMessagesInBuffer) {
        // Somehow the log messages are not written fast enough, skip messages until next successful save.
        return NO;
    }

    [_logMessagesArray addObject:[self->formatter formatLogMessage:logMessage]];
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
    // If no log messages in array, just return
    if ([_logMessagesArray count] == 0) {
        return;
    }

    // Get reference to log messages
    NSArray *oldLogMessagesArray = _logMessagesArray;

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

    DDLogVerbose(@"Posting to Loggly: %@", messagesString);
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *response = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        DDLogVerbose(@"Loggly post response = %@",response);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogVerbose(@"Loggly post Error: %@", error);
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
    return _logglyUrlTemplate;
}

@end
