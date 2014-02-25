//
// Created by Mats Melke on 2014-02-18.
// Copyright (c) 2014 Expressen. All rights reserved.
//

#import "LogglyFormatter.h"
#import "LogglyFields.h"
#import "NSMutableDictionary+NilSafe.h"

@implementation LogglyFormatter {
    int _loggerCount;
    LogglyFields *_logglyFields;
}

- (id)init
{

    NSAssert(false,@"Init without params is unavailable, use initWithLogglyFields:(LogglyFields *) instead");
    return nil;
}

- (id)initWithLogglyFields:(LogglyFields *)logglyFields
{
    if((self = [super init]))
    {
        _logglyFields = logglyFields;
    }
    return self;
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    NSString *logLevel;
    switch (logMessage->logFlag)
    {
        case LOG_FLAG_ERROR : logLevel = @"error"; break;
        case LOG_FLAG_WARN  : logLevel = @"warning"; break;
        case LOG_FLAG_INFO  : logLevel = @"info"; break;
        case LOG_FLAG_DEBUG : logLevel = @"debug"; break;
        default             : logLevel = @"verbose"; break;
    }

    NSString *iso8601DateString = [self iso8601StringFromDate:(logMessage->timestamp)];
    NSMutableDictionary *logfields = [NSMutableDictionary dictionaryWithCapacity:0];
    [logfields setObjectNilSafe:logLevel forKey:@"loglevel"];
    [logfields setObjectNilSafe:iso8601DateString forKey:@"timestamp"];

    NSString *filestring = [self lastPartOfFullFilePath:[NSString stringWithFormat:@"%s", logMessage->file]];

    [logfields setObjectNilSafe:filestring forKey:@"file"];
    [logfields setObjectNilSafe:[NSString stringWithFormat:@"%d", logMessage->lineNumber] forKey:@"linenumber"];
    [logfields setObjectNilSafe:[NSString stringWithFormat:@"%@:%d", filestring, logMessage->lineNumber] forKey:@"fileandlinenumber"];
    [logfields setObjectNilSafe:_logglyFields.appname forKey:@"appname"];
    [logfields setObjectNilSafe:_logglyFields.appversion forKey:@"appversion"];
    [logfields setObjectNilSafe:_logglyFields.debugidentifier forKey:@"debugidentifier"];
    [logfields setObjectNilSafe:_logglyFields.devicemodel forKey:@"devicemodel"];
    [logfields setObjectNilSafe:_logglyFields.devicename forKey:@"devicename"];
    [logfields setObjectNilSafe:_logglyFields.lang forKey:@"lang"];
    [logfields setObjectNilSafe:_logglyFields.osversion forKey:@"osversion"];
    [logfields setObjectNilSafe:_logglyFields.platform forKey:@"platform"];
    [logfields setObjectNilSafe:logMessage->logMsg forKey:@"rawlogmessage"];
    NSData *jsondata = [logMessage->logMsg dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsondictForLogMsg = [NSJSONSerialization JSONObjectWithData:jsondata options:NSJSONReadingAllowFragments error:nil];
    if ([jsondictForLogMsg count] > 0) {
        [logfields addEntriesFromDictionary:jsondictForLogMsg];
    }

    NSError *outputJsonError;
    NSData *outputJson = [NSJSONSerialization dataWithJSONObject:logfields options:nil error:&outputJsonError];
    if (outputJsonError) {
        return [NSString stringWithFormat:@"{\"loglevel\":\"warning\",\"timestamp\":\"%@\",\"file\":\"%@\",\"linenumber\":\"%d\",\"jsonerror\":\"Could not serialize JSON string\",\"logmessage\":\"%@\"}", iso8601DateString, filestring, logMessage->lineNumber, logMessage->logMsg];
    }
    NSString *jsonString = [[NSString alloc] initWithData:outputJson encoding:NSUTF8StringEncoding];
    if (jsonString) {
        return jsonString;
    } else {
        return [NSString stringWithFormat:@"{\"loglevel\":\"warning\",\"timestamp\":\"%@\",\"file\":\"%@\",\"linenumber\":\"%d\",\"jsonerror\":\"Could not serialize JSON string\",\"logmessage\":\"%@\"}", iso8601DateString, filestring, logMessage->lineNumber, logMessage->logMsg];
    }
}

- (void)didAddToLogger:(id <DDLogger>)logger
{
    _loggerCount++;
    NSAssert(_loggerCount <= 1, @"This logger uses date formatting, so it isn't thread-safe. Create a new instance of this class if you need to use it in multiple loggers");
}
- (void)willRemoveFromLogger:(id <DDLogger>)logger
{
    _loggerCount--;
}

#pragma mark Private methods

- (NSString *)iso8601StringFromDate:(NSDate *)date {
    struct tm *timeinfo;
    char buffer[80];

    time_t rawtime = (time_t)[date timeIntervalSince1970];
    timeinfo = gmtime(&rawtime);

    strftime(buffer, 80, "%Y-%m-%dT%H:%M:%SZ", timeinfo);

    return [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
}

- (NSString *)lastPartOfFullFilePath:(NSString *)fullfilepath {
    NSString *retvalue;
    NSArray *parts = [fullfilepath componentsSeparatedByString:@"/"];
    if ([parts count] > 0) {
        retvalue = [parts lastObject];
    }
    if ([retvalue length] == 0) {
        retvalue = @"No file";
    }
    return retvalue;
}

@end
