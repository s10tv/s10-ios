//
//  Utils.m
//  Taylr
//
//  Created by Tony Xiao on 11/27/15.
//  Copyright © 2015 S10. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Taylr-Bridging.h"

NSString *formatLogMessageTimestamp(NSDate *timestamp) {
    int len;
    char ts[24] = "";
    size_t tsLen = 0;
    
    // Calculate timestamp.
    // The technique below is faster than using NSDateFormatter.
    NSUInteger _calendarUnitFlags = (NSCalendarUnitYear     |
                          NSCalendarUnitMonth    |
                          NSCalendarUnitDay      |
                          NSCalendarUnitHour     |
                          NSCalendarUnitMinute   |
                          NSCalendarUnitSecond);
    NSDateComponents *components = [[NSCalendar autoupdatingCurrentCalendar] components:_calendarUnitFlags fromDate:timestamp];
    
    NSTimeInterval epoch = [timestamp timeIntervalSinceReferenceDate];
    int milliseconds = (int)((epoch - floor(epoch)) * 1000);
    
    len = snprintf(ts, 24, "%04ld-%02ld-%02ld %02ld:%02ld:%02ld.%03d", // yyyy-MM-dd HH:mm:ss:SSS
                   (long)components.year,
                   (long)components.month,
                   (long)components.day,
                   (long)components.hour,
                   (long)components.minute,
                   (long)components.second, milliseconds);
    
    tsLen = (NSUInteger)MAX(MIN(24 - 1, len), 0);
    
    NSString *tsStr = [NSString stringWithCString:ts encoding:NSUTF8StringEncoding];
    
    NSTimeZone *timeZone = components.timeZone ?: [NSTimeZone systemTimeZone];
    NSString *tzStr = [timeZone abbreviationForDate:timestamp] ?: timeZone.name;
    
    if (tzStr != nil) {
        return [NSString stringWithFormat:@"%@ %@", tsStr, tzStr];
    }
    return tsStr;
}