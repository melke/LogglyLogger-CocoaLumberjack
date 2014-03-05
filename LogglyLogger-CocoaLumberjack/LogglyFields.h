//
// Created by Mats Melke on 2014-02-20.
// Copyright (c) 2014 Expressen. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LogglyFields : NSObject
@property (strong, nonatomic) NSString *lang;
@property (strong, nonatomic) NSString *appname;
@property (strong, nonatomic) NSString *appversion;
@property (strong, nonatomic) NSString *devicename;
@property (strong, nonatomic) NSString *devicemodel;
@property (strong, nonatomic) NSString *osversion;

@end
