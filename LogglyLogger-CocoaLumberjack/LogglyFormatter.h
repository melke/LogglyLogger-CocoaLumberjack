//
// Created by Mats Melke on 2014-02-18.
//

#import <Foundation/Foundation.h>
#import "DDLog.h"

@protocol LogglyFieldsDelegate
- (NSDictionary *)logglyFieldsToIncludeInEveryLogStatement;
@end

@interface LogglyFormatter : NSObject <DDLogFormatter>
- (id)initWithLogglyFieldsDelegate:(id<LogglyFieldsDelegate>)delegate;
@end
