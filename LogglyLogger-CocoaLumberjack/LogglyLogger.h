//
// Created by Mats Melke on 2014-02-20.
// Copyright (c) 2014 Expressen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDLog.h"
#import "DDAbstractDatabaseLogger.h"


@interface LogglyLogger : DDAbstractDatabaseLogger

@property (assign, readwrite) NSUInteger maxLogMessagesInBuffer;
/// NSString used in stringWithFormat when creating the loggly bulk post url. Must contain placeholders for Loggly API key and Loggly tags
@property (nonatomic, strong) NSString *logglyUrlTemplate;
/// NSString with comma-separated tags (no whitespace, no special chars)
@property (nonatomic, strong) NSString *logglyTags;
/// The Loggly API key
@property (nonatomic, strong) NSString *logglyKey;

@end