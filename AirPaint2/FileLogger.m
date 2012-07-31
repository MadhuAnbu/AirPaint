//
//  FileLogger.m
//  AirPaint2
//
//  Created by Philipp Sessler on 25.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
// http://cocoaforbreakfast.wordpress.com/2011/02/25/logging-into-files-for-ios/



#import "FileLogger.h"

@implementation FileLogger

- (id) init {
    if (self == [super init]) {

        appDelegate = [[UIApplication sharedApplication] delegate];

        // timestamp
        
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm:ss"];
        
        // logfile
        [self setupLogFile];
    }
    
    return self;
}

- (void)setupLogFile
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *logFileName = [NSString stringWithFormat:@"%@_%@.log", appDelegate.configurationsViewController.studyID, appDelegate.configurationsViewController.additionalInfo];
    
    NSLog(@"file name: %@", logFileName);
    
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:logFileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath])
        [fileManager createFileAtPath:filePath
                             contents:nil
                           attributes:nil];
    logFile = [NSFileHandle fileHandleForWritingAtPath:filePath];
    [logFile seekToEndOfFile];
}

- (void)log:(NSString *)format, ...  {
    va_list ap;
    va_start(ap, format);
    
    
    timeString = [formatter stringFromDate:[NSDate date]];
    
    NSString *message = [[NSString alloc] initWithFormat:format arguments:ap];
    message = [NSString stringWithFormat:@"%@ >> %@\n", timeString,message];
    
    [logFile writeData:[message dataUsingEncoding:NSUTF8StringEncoding]];
    [logFile synchronizeFile];
}

+ (FileLogger *)sharedInstance {
    static FileLogger *instance = nil;
    if (instance == nil) instance = [[FileLogger alloc] init];
    return instance;
}

@end
