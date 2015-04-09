//
// Created by Mats Melke on 2014-02-20.
//

#import "LogglyFields.h"



@implementation LogglyFields {
    dispatch_queue_t _queue;
    NSDictionary *_fieldsDictionary;
}

- (id)init {
    if((self = [super init])) {
        _queue = dispatch_queue_create("se.baresi.logglylogger.logglyfields.queue", NULL);
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
        [dict setObject:[[NSLocale preferredLanguages] objectAtIndex:0] forKey:@"lang"];
        id bundleDisplayName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        if (bundleDisplayName != nil) {
            [dict setObject:bundleDisplayName forKey:@"appname"];
        } else {
            [dict setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"] forKey:@"appname"];
        }
        [dict setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"appversion"];
        [dict setObject:[UIDevice currentDevice].name forKey:@"devicename"];
        [dict setObject:[UIDevice currentDevice].model forKey:@"devicemodel"];
        [dict setObject:[UIDevice currentDevice].systemVersion forKey:@"osversion"];
        [dict setObject:[self generateRandomStringWithSize:10] forKey:@"sessionid"];
        _fieldsDictionary = [NSDictionary dictionaryWithDictionary:dict];
    }
    return self;
}

#pragma mark implementation of LogglyFieldsDelegate protocol

- (NSDictionary *)logglyFieldsToIncludeInEveryLogStatement {
    // The dict may be altered by one of the setters, so lets use a queue for thread safety
    __block NSDictionary *dict;
    dispatch_sync(_queue, ^{
        dict = [_fieldsDictionary copy];
    });
    return dict;
}

#pragma mark Property setters

- (void)setSessionid:(NSString *)sessionid {
    dispatch_barrier_async(_queue, ^{
        NSMutableDictionary *dict = [_fieldsDictionary mutableCopy];
        [dict setObject:sessionid forKey:@"sessionid"];
        _fieldsDictionary = [NSDictionary dictionaryWithDictionary:dict];
    });
}

- (void)setUserid:(NSString *)userid {
    dispatch_barrier_async(_queue, ^{
        NSMutableDictionary *dict = [_fieldsDictionary mutableCopy];
        [dict setObject:userid forKey:@"userid"];
        _fieldsDictionary = [NSDictionary dictionaryWithDictionary:dict];
    });
}

#pragma mark Private methods

- (NSString*)generateRandomStringWithSize:(int)num {
    NSMutableString* string = [NSMutableString stringWithCapacity:num];
    for (int i = 0; i < num; i++) {
        [string appendFormat:@"%C", (unichar)('a' + arc4random_uniform(25))];
    }
    return string;
}

@end
