//
//  SJTYLogManager.m
//  Evolluxor
//
//  Created by sjty on 2025/9/11.
//

#import "SJTYLogManager.h"


@interface SJTYLogManager ()

@property(assign,nonatomic)BOOL enable;

@property(assign,nonatomic)BOOL isSave;

@end

@implementation SJTYLogManager


static SJTYLogManager *sharedInstance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SJTYLogManager alloc] init];
        [SJTYLogManager ensureLogDirectoryExists];
        sharedInstance.enable=false;
        sharedInstance.isSave=true;
        
    });
    return sharedInstance;
}



/// 设置是否打印日志
/// - Parameter enable: 是否打印
+(void)setLog:(BOOL)enable{
    [SJTYLogManager sharedInstance].enable =enable;
}


/// 设置是否自动保存到文件
/// - Parameter isSave: 是否自动保存
+(void)saveLogAsFile:(BOOL)isSave{
    [SJTYLogManager sharedInstance].isSave =isSave;
}


// 获取Log文件夹路径
+ (NSString *)logDirectoryPath {
    // 获取Documents目录
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    
    // 拼接Log文件夹路径
    return [documentsDirectory stringByAppendingPathComponent:@"Log"];
}

// 确保Log文件夹存在
+ (void)ensureLogDirectoryExists {
    NSString *logDirPath = [self logDirectoryPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory;
    
    // 检查文件夹是否存在
    if (![fileManager fileExistsAtPath:logDirPath isDirectory:&isDirectory] || !isDirectory) {
        // 创建文件夹(包括可能需要的中间目录)
        NSError *error = nil;
        BOOL success = [fileManager createDirectoryAtPath:logDirPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        if (!success) {
            NSLog(@"创建Log文件夹失败: %@", error.localizedDescription);
        }
    }
}

+(NSString *)logFilePath {
    // 获取Log文件夹路径
    NSString *logDirPath = [self logDirectoryPath];
    
    // 获取当前日期作为文件名
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    
    // 拼接日志文件路径
    NSString *fileName = [NSString stringWithFormat:@"log_%@.txt", dateString];
    return [logDirPath stringByAppendingPathComponent:fileName];
}


+ (NSString *)levelStringForLevel:(LogLevel)level {
    switch (level) {
        case LogLevelDebug: return @"DEBUG";
        case LogLevelInfo: return @"INFO";
        case LogLevelWarning: return @"WARNING";
        case LogLevelError: return @"ERROR";
        default: return @"UNKNOWN";
    }
}

+ (void)logLevel:(LogLevel)level format:(NSString *)format,...{
    if (!format) return;
    if (![SJTYLogManager sharedInstance].enable) {
        NSLog(@"%@",format);
        return;
    }
    
    // 获取当前时间
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    timeFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    NSString *timeString = [timeFormatter stringFromDate:[NSDate date]];
    NSString *levelString = [self levelStringForLevel:level];
    
    // 格式化日志内容
    NSString *logString = [NSString stringWithFormat:@"[%@] [%@] %@\n", timeString, levelString, format];
    
    // 同时在控制台打印
    NSLog(@"%@", [logString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]);
    
    if (![SJTYLogManager sharedInstance].isSave) {
        return;
    }
    
    // 获取日志文件路径
    NSString *filePath = [self logFilePath];
    
    // 将日志写入文件（追加模式）
    @synchronized(self) {
        // 先读取已有内容
        NSMutableString *fileContent = [NSMutableString stringWithContentsOfFile:filePath
                                                                       encoding:NSUTF8StringEncoding
                                                                          error:nil];
        if (!fileContent) {
            fileContent = [NSMutableString string];
        }
        
        // 追加新内容
        [fileContent appendString:logString];
        
        // 写入文件
        NSError *error = nil;
        BOOL success = [fileContent writeToFile:filePath
                                    atomically:YES
                                      encoding:NSUTF8StringEncoding
                                         error:&error];
        
        if (!success) {
            NSLog(@"日志写入失败: %@", error.localizedDescription);
        }
    }
}

// 获取所有日志文件名称
+ (NSArray<NSString *> *)getAllLogFileNames {
    NSArray<NSString *> *filePaths = [self getAllLogFilePaths];
    NSMutableArray<NSString *> *fileNames = [NSMutableArray array];
    
    for (NSString *path in filePaths) {
        [fileNames addObject:[path lastPathComponent]];
    }
    
    return [fileNames copy];
}

// 获取所有日志文件完整路径
+ (NSArray<NSString *> *)getAllLogFilePaths {
    NSString *logDirPath = [self logDirectoryPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    // 获取目录下所有文件
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:logDirPath error:&error];
    if (error) {
        NSLog(@"获取日志文件列表失败: %@", error.localizedDescription);
        return @[];
    }
    
    NSMutableArray *logFilePaths = [NSMutableArray array];
    
    // 筛选出日志文件
    for (NSString *item in contents) {
        NSString *fullPath = [logDirPath stringByAppendingPathComponent:item];
        BOOL isDirectory;
        
        // 检查是否为文件且文件名符合日志文件格式
        if ([fileManager fileExistsAtPath:fullPath isDirectory:&isDirectory] && !isDirectory) {
            if ([item hasPrefix:@"log_"] && [item hasSuffix:@".txt"]) {
                [logFilePaths addObject:fullPath];
            }
        }
    }
    
    // 按日期排序（最新的在后面）
    [logFilePaths sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
    }];
    
    return [logFilePaths copy];
}
                  

/// 获取日志文件路径
/// - Parameter date: 日志时间
+(NSString*)logFilePathByDate:(NSString *)date{
    
    NSString *logDirPath = [self logDirectoryPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    // 获取目录下所有文件
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:logDirPath error:&error];
    if (error) {
        NSLog(@"获取日志文件列表失败: %@", error.localizedDescription);
        return nil;
    }
    
    for (NSString *item in contents) {
        NSString *fullPath = [logDirPath stringByAppendingPathComponent:item];
        BOOL isDirectory;
        
        // 检查是否为文件且文件名符合日志文件格式
        if ([fileManager fileExistsAtPath:fullPath isDirectory:&isDirectory] && !isDirectory) {
            if ([item containsString:date] && [item hasSuffix:@".txt"]) {
                return fullPath;
            }
        }
    }
    
    return nil;
    
}
                  
@end
