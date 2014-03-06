//
// Created by Mats Melke on 2014-02-20.
//

#import "LogglyFields.h"


@implementation LogglyFields {

}

- (NSString *)lang {
    if (!_lang) {
        _lang = [[NSLocale preferredLanguages] objectAtIndex:0];
    }
    return _lang;
}

- (NSString *)appname {
    if (!_appname) {
       _appname = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
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

@end
