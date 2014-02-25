//
// Created by Mats Melke on 2014-02-18.
// Copyright (c) 2014 Expressen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LogglyFields;


@interface LogglyFormatter : NSObject <DDLogFormatter>

- (id)initWithLogglyFields:(LogglyFields *)logglyFields;

@end
