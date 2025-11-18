//
//  SJTYLogManager.h
//  Evolluxor
//
//  Created by sjty on 2025/9/11.
//

#import <Foundation/Foundation.h>


#define SJTYLog(level,fmt...) [SJTYLogManager logLevel:level format:fmt];

//#define SJTYInfoLog(format,...) [SJTYLogManager logLevel:LogLevelInfo format:format];

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, LogLevel) {
    LogLevelDebug,
    LogLevelInfo,
    LogLevelWarning,
    LogLevelError
};

@interface SJTYLogManager : NSObject



/// 设置是否打印日志
/// - Parameter enable: 是否打印
+(void)setLog:(BOOL)enable;


/// 设置是否自动保存到文件
/// - Parameter isSave: 是否自动保存
+(void)saveLogAsFile:(BOOL)isSave;


/// 打印内容
/// - Parameters:
///   - level: 日志等级
///   - format:日志内容
+ (void)logLevel:(LogLevel)level format:(NSString *)format,...;


// 获取所有日志文件名称
+ (NSArray<NSString *> *)getAllLogFileNames;

// 获取所有日志文件完整路径
+ (NSArray<NSString *> *)getAllLogFilePaths;


/// 获取日志文件路径
/// - Parameter date: 日志时间 yyyy-MM-dd
+(NSString*)logFilePathByDate:(NSString *)date;


@end

NS_ASSUME_NONNULL_END
