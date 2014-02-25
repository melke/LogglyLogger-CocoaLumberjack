//
// Created by Mats Melke on 2014-02-20.
// Copyright (c) 2014 Expressen. All rights reserved.
//

#import "LogglyFields.h"


@implementation LogglyFields {

}

- (NSString *)lang {
    if (!_lang) {
        _lang = [[NSLocale preferredLanguages] objectAtIndex:0];
        if ([_lang length] > 2) {
            _lang = [_lang substringToIndex:2];
        }
    }
    return _lang;
}

- (NSString *)appname {
    if (!_appname) {
        _appname = @"Unknown-app";
#if IS_GT
        _appname = @"GT-iPhone";
#elif IS_RESSEN
        _appname = @"Expressen-iPhone";
#elif IS_KVP
        _appname = @"KvP-iPhone";
#endif
    }
    return _appname;
}

- (NSString *)appversion {
    if (!_appversion) {
        _appversion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    }
    return _appversion;
}

- (NSString *)devicename {
    if (!_devicename) {
        _devicename = [UIDevice currentDevice].name;
    }
    return _devicename;
}

- (NSString *)devicemodel {
    if (!_devicemodel) {
        _devicemodel = [UIDevice currentDevice].model;
    }
    return _devicemodel;
}

- (NSString *)osversion {
    if (!_osversion) {
        _osversion = [UIDevice currentDevice].systemVersion;
    }
    return _osversion;
}

- (NSString *)platform {
    if (!_platform) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            _platform = @"iPad";
        } else {
            _platform = @"iPhone";
        }
    }
    return _platform;
}

@end
