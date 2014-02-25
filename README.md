# Don't use this yet. It is not completed in any way!

# LogglyLogger-CocoaLumberjack

LogglyLogger-CocoaLumberjack is a custom logger for [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack) that logs to [Loggly](https://www.loggly.com/).

##Requirements

A Loggly account.

LogglyLogger-CocoaLumberjack includes uses ARC. If your project doesn't use ARC, you can enable it per file using the `-fobjc-arc` compiler flag under "Build Phases" and "Compile Sources" on your project's target in Xcode.

##Installation

There are two ways to add LogglyLogger-CocoaLumberjack to your project:

Using [Cocoapods](cocoapods.org):

    pod "LogglyLogger-CocoaLumberjack"

Or manually:

    git clone https://github.com/melke/LogglyLogger-CocoaLumberjack.git
    cd LogglyLogger-CocoaLumberjack

Now add LogglyLogger-CocoaLumberjack to your project by dragging the everything in the `LogglyLogger-CocoaLumberjack` directory into your project.

##Usage

First, set an API key:

    [[];


##Copyrights

* Copyright (c) 2010-2014 Mats Melke. Please see LICENSE.txt for details.