//
//  FileLogger.h
//  AirPaint2
//
//  Created by Philipp Sessler on 25.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
// 
// http://cocoaforbreakfast.wordpress.com/2011/02/25/logging-into-files-for-ios/

#import "AppDelegate.h"


@interface FileLogger : NSObject {
    NSFileHandle *logFile;
    AppDelegate *appDelegate;
    NSDateFormatter *formatter;
    NSString *timeString;
}
+ (FileLogger *)sharedInstance;
- (void)log:(NSString *)format, ...;
- (void)setupLogFile;

@end

#define FLog(fmt, ...) [appDelegate.logger log:fmt, ##__VA_ARGS__]