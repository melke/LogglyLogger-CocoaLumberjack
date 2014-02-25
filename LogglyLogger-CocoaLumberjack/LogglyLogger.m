//
// Created by Mats Melke on 2014-02-20.
// Copyright (c) 2014 Expressen. All rights reserved.
//

#import "LogglyLogger.h"
#import "AFHTTPRequestOperation.h"


@implementation LogglyLogger {
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

    if (!_logglyURL) {
        _logglyURL = [NSURL URLWithString:[NSString stringWithFormat:self.logglyUrlTemplate, self.logglyKey, self.logglyTags]];
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_logglyURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[messagesString dataUsingEncoding:NSUTF8StringEncoding]];

    DDLogMelke(@"Posting %@", messagesString);
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *response = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        DDLogMelke(@"response = %@",response);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"Loggly post Error: %@", error);
    }];

    [operation start];


}

@end
