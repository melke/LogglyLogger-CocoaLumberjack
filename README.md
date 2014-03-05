# Don't use this yet. It is not completed in any way!

# LogglyLogger-CocoaLumberjack

LogglyLogger-CocoaLumberjack is a custom logger for [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack) that logs to [Loggly](https://www.loggly.com/).

##Requirements

A Loggly account. (Note, that they charge for higher volumes of logging)

LogglyLogger-CocoaLumberjack includes uses ARC. If your project doesn't use ARC, you can enable it per file using the `-fobjc-arc` compiler flag under "Build Phases" and "Compile Sources" on your project's target in Xcode.

##Installation

There are two ways to add LogglyLogger-CocoaLumberjack to your project:

Using [Cocoapods](cocoapods.org):

    pod "LogglyLogger-CocoaLumberjack"

Or manually:

    git clone https://github.com/melke/LogglyLogger-CocoaLumberjack.git
    cd LogglyLogger-CocoaLumberjack

Now add LogglyLogger-CocoaLumberjack to your project by dragging the everything in the sub folder `LogglyLogger-CocoaLumberjack` directory into your project.

##Usage

First, make sure that you have created an API key in your Loggly account (they call this Customer Token, and can be created
in the Loggly Web UI under the tab "Source setup".

In your App Delegate:

    #import "LogglyLogger.h"
    #import "LogglyFormatter.h"
    static const int ddLogLevel = LOG_LEVEL_VERBOSE;

In didFinishLaunchingWithOptions

    LogglyLogger *logglyLogger = [[LogglyLogger alloc] init];
    [logglyLogger setLogFormatter:[[LogglyFormatter alloc] init]];
    logglyLogger.logglyKey = @"your-loggly-api-key";

    // Set posting interval every 15 seconds, just for testing this out, but the default value of 10 minutes is better in apps
    // that normally don't access the network very often. When the user suspends the app, the logs will always be posted.
    logglyLogger.saveInterval = 15;

    [DDLog addLogger:logglyLogger];

    // Do some logging
    DDLogVerbose(@"{\"myJsonKey\":\"some verbose json value\"}");

This is all there is to it. The log posts will include all your json fields in the log message plus some standard fields that the logger adds automatically:

  - loglevel - CocoaLumberjack Log level
  - timestamp - Timestamp in iso8601 format (required by Loggly)
  - file - The name of the source file that logged the message
  - fileandlinenumber - Source file and line number in that file (nice for doing facet searches in Loggly)
  - appname - The Display name of your app
  - appversion - The version of your app
  - devicemodel - The device model
  - devicename - The device name
  - lang - The primary lang the app user has selected in Settings on the device
  - osversion - the iOS version
  - rawlogmessage - The log message that you sent, unparsed. This is also where simple non-JSON log messages will show up.
  - sessionid - A generated random id, to let you search in loggly for log statements from the same session. You can override this random value by setting your own sessionid in the LogglyFormatter.
  - userid - A userid string. Note, you must set this userid yourself in the LogglyFormatter. No default value.

Note that you don't have to log statements in json format, but it is much easier to do facet searches in Loggly if you use JSON.
Word of warning, don't use too many json keys. It will mess up the Loggly UI. Figure out smart json keys that you can reuse
in many of your log statements.

##Advanced Usage

LogglyLogger will use the bundle id of your app as a Loggly tag. You can create a "source group" in Loggly
that contains all log statements that has a specific tag. This way, you can easily use the same Loggly
account for many apps.

There are some settings you can set on the LogglyLogger. Most of them are inherited from the abstract class and
they all have reasonable default values.

  - saveInterval - Number of seconds between posting log statements to Loggly. Default = 600. Note that the logs are always posted when the app is suspended. Setting this to a low value may turn your app into a battery hog.
  - saveThreshold - Number of log messages before forcing a post, regardless of how long time it has been since the last post. Default 1000.


Filter by

##Copyrights

* Copyright (c) 2010-2014 Mats Melke. Please see LICENSE.txt for details.