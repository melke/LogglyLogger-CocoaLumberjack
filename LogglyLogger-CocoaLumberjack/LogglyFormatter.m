//
// Created by Mats Melke on 2014-02-18.
//

#import "LogglyFormatter.h"
#import "LogglyFields.h"
#define kLogglyFormatStringWhenLogMsgIsNotJson @"{\"loglevel\":\"%@\",\"timestamp\":\"%@\",\"file\":\"%@\",\"fileandlinenumber\":\"%@:%d\",\"jsonerror\":\"JSON Output Error when trying to create Loggly JSON\",\"rawlogmessage\":\"%@\"}"

#pragma mark NSMutableDictionary category.
// Defined here so it doesn't spill over to the client projects.
@interface NSMutableDictionary (NilSafe)
- (void)setObjectNilSafe:(id)obj forKey:(id)aKey;
@end

@implementation NSMutableDictionary (NilSafe)
- (void)setObjectNilSafe:(id)obj forKey:(id)aKey {
    // skip nils and NSNull
    if(obj == nil || obj == [NSNull null]) {
        return;
    }
    // skip empty string
    if([obj isKindOfClass: NSString.class] && [obj length]==0) {
        return;
    }
    // The object is fine, insert it
    [self setObject:obj forKey:aKey];
}
@end



@implementation LogglyFormatter {
    id<LogglyFieldsDelegate> logglyFieldsDelegate;
}

- (id)init {
    if((self = [super init]))
    {
        // Use standard LogglyFields Delegate
        logglyFieldsDelegate = [[LogglyFields alloc] init];
    }
    return self;
}

- (id)initWithLogglyFieldsDelegate:(id<LogglyFieldsDelegate>)delegate {
    if((self = [super init]))
    {
        logglyFieldsDelegate = delegate;
    }
    return self;
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    // Get the fields that should be included in every log entry.
    NSMutableDictionary *logfields = [NSMutableDictionary dictionaryWithDictionary:[logglyFieldsDelegate logglyFieldsToIncludeInEveryLogStatement]];

    NSString *logLevel;
    switch (logMessage->logFlag)
    {
        case LOG_FLAG_ERROR : logLevel = @"error"; break;
        case LOG_FLAG_WARN  : logLevel = @"warning"; break;
        case LOG_FLAG_INFO  : logLevel = @"info"; break;
        case LOG_FLAG_DEBUG : logLevel = @"debug"; break;
        default             : logLevel = @"verbose"; break;
    }
    [logfields setObjectNilSafe:logLevel forKey:@"loglevel"];

    NSString *iso8601DateString = [self iso8601StringFromDate:(logMessage->timestamp)];
    [logfields setObjectNilSafe:iso8601DateString forKey:@"timestamp"];

    NSString *filestring = [self lastPartOfFullFilePath:[NSString stringWithFormat:@"%s", logMessage->file]];
    [logfields setObjectNilSafe:filestring forKey:@"file"];
    [logfields setObjectNilSafe:[NSString stringWithFormat:@"%@:%d", filestring, logMessage->lineNumber] forKey:@"fileandlinenumber"];

    // newlines are not allowed in POSTS to Loggly
    NSString *logMsg = [logMessage->logMsg stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    [logfields setObjectNilSafe:logMsg forKey:@"rawlogmessage"];

    NSData *jsondata = [logMsg dataUsingEncoding:NSUTF8StringEncoding];
    NSError *inputJsonError;
    id mostOftenADict = [NSJSONSerialization JSONObjectWithData:jsondata options:NSJSONReadingAllowFragments error:&inputJsonError];
    if ([mostOftenADict isKindOfClass:[NSDictionary class]]) {
        NSDictionary *jsondictForLogMsg = (NSDictionary *)mostOftenADict;
        if (!inputJsonError && [jsondictForLogMsg count] > 0) {
            [logfields addEntriesFromDictionary:jsondictForLogMsg];
        }
    }

    NSError *outputJsonError;
    NSData *outputJson = [NSJSONSerialization dataWithJSONObject:logfields options:0 error:&outputJsonError];
    if (outputJsonError) {
        return [NSString stringWithFormat:kLogglyFormatStringWhenLogMsgIsNotJson, logLevel, iso8601DateString, filestring, filestring, logMessage->lineNumber, logMsg];
    }
    NSString *jsonString = [[NSString alloc] initWithData:outputJson encoding:NSUTF8StringEncoding];
    if (jsonString) {
        return jsonString;
    } else {
        return [NSString stringWithFormat:kLogglyFormatStringWhenLogMsgIsNotJson, logLevel, iso8601DateString, filestring, filestring, logMessage->lineNumber, logMsg];
    }
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
