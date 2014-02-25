//
// Created by Mats Melke on 2014-02-20.
// Copyright (c) 2014 Expressen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDAbstractDatabaseLogger.h"


@interface LogglyLogger : DDAbstractDatabaseLogger

@property (assign, readwrite) NSUInteger maxLogMessagesInBuffer;
@property (nonatomic, strong) NSString *logglyUrlTemplate;
@property (nonatomic, strong) NSString *logglyTags;
@property (nonatomic, strong) NSString *logglyKey;

@end
