//
// Created by Mats Melke on 2014-02-18.
//

#import <Foundation/Foundation.h>
#import "DDLog.h"

@interface LogglyFormatter : NSObject <DDLogFormatter>
@property (strong, nonatomic) NSString *userid;
@property (strong, nonatomic) NSString *sessionid;
@end
