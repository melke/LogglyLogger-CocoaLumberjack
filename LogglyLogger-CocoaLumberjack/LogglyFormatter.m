//
// Created by Mats Melke on 2014-02-18.
//

#import "LogglyFormatter.h"
#import "LogglyFields.h"
#define kLogglyFormatStringWhenLogMsgIsNotJson @"{\"loglevel\":\"%@\",\"timestamp\":\"%@\",\"file\":\"%@\",\"fileandlinenumber\":\"%@:%d\",\"appname\":\"%@\",\"appversion\":\"%@\",\"devicemodel\":\"%@\",\"devicename\":\"%@\",\"lang\":\"%@\",\"osversion\":\"%@\",\"sessionid\":\"%@\",\"userid\":\"%@\",\"rawlogmessage\":\"%@\"}"

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
    LogglyFields *_logglyFields;
}

- (id)init
{
    if((self = [super init]))
    {
        _logglyFields = [[LogglyFields alloc] init];
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
    [logfields setObjectNilSafe:[NSString stringWithFormat:@"%@:%d", filestring, logMessage->lineNumber] forKey:@"fileandlinenumber"];
    [logfields setObjectNilSafe:_logglyFields.appname forKey:@"appname"];
    [logfields setObjectNilSafe:_logglyFields.appversion forKey:@"appversion"];
    [logfields setObjectNilSafe:_logglyFields.devicemodel forKey:@"devicemodel"];
    [logfields setObjectNilSafe:_logglyFields.devicename forKey:@"devicename"];
    [logfields setObjectNilSafe:_logglyFields.lang forKey:@"lang"];
    [logfields setObjectNilSafe:_logglyFields.osversion forKey:@"osversion"];
    [logfields setObjectNilSafe:self.sessionid forKey:@"sessionid"];
    [logfields setObjectNilSafe:self.userid forKey:@"userid"];
    // newlines are not allowed in POSTS to Loggly
    NSString *logMsg = [logMessage->logMsg stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    [logfields setObjectNilSafe:logMsg forKey:@"rawlogmessage"];
    NSData *jsondata = [logMsg dataUsingEncoding:NSUTF8StringEncoding];
    NSError *inputJsonError;
    NSDictionary *jsondictForLogMsg = [NSJSONSerialization JSONObjectWithData:jsondata options:NSJSONReadingAllowFragments error:&inputJsonError];
    if (inputJsonError) {
        return [self formattedNonJsonLogMsgWithLogLevel:logLevel andIso8601DateString:iso8601DateString andFileString:filestring andLineNumber:logMessage->lineNumber andLogMsg:logMsg];
    }
    if ([jsondictForLogMsg count] > 0) {
        [logfields addEntriesFromDictionary:jsondictForLogMsg];
    }

    NSError *outputJsonError;
    NSData *outputJson = [NSJSONSerialization dataWithJSONObject:logfields options:0 error:&outputJsonError];
    if (outputJsonError) {
        return [self formattedNonJsonLogMsgWithLogLevel:logLevel andIso8601DateString:iso8601DateString andFileString:filestring andLineNumber:logMessage->lineNumber andLogMsg:logMsg];
    }
    NSString *jsonString = [[NSString alloc] initWithData:outputJson encoding:NSUTF8StringEncoding];
    if (jsonString) {
        return jsonString;
    } else {
        return [self formattedNonJsonLogMsgWithLogLevel:logLevel andIso8601DateString:iso8601DateString andFileString:filestring andLineNumber:logMessage->lineNumber andLogMsg:logMsg];
    }
}

#pragma mark property getters

- (NSString *)sessionid {
    if (!_sessionid) {
        // generate session id, 10 chars should be enough, we don't want to clutter the log
        _sessionid = [self generateRandomStringWithSize:10];
    }
    return _sessionid;
}

#pragma mark Private methods

- (NSString *) formattedNonJsonLogMsgWithLogLevel:(NSString *)logLevel andIso8601DateString:(NSString *)iso8601DateString andFileString:(NSString *)filestring andLineNumber:(int)lineNumber andLogMsg:(NSString *)logMsg {
    return [NSString stringWithFormat:kLogglyFormatStringWhenLogMsgIsNotJson, logLevel, iso8601DateString, filestring, filestring, lineNumber,
                                      _logglyFields.appname, _logglyFields.appversion, _logglyFields.devicemodel, _logglyFields.devicename, _logglyFields.lang,
                                      _logglyFields.osversion, self.sessionid, self.userid, logMsg];
}

- (NSString*)generateRandomStringWithSize:(int)num {
    NSMutableString* string = [NSMutableString stringWithCapacity:num];
    for (int i = 0; i < num; i++) {
        [string appendFormat:@"%C", (unichar)('a' + arc4random_uniform(25))];
    }
    return string;
}

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
