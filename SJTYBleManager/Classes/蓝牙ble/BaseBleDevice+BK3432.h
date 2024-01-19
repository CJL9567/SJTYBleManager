//
//  BaseBleDevice+BK3432.h
//  SJTYBleManager
//
//  Created by sjty on 2024/1/15.
//

#import <SJTYBleManager/SJTYBleManager.h>

NS_ASSUME_NONNULL_BEGIN



typedef enum : NSUInteger {
    ///正常
    ERROR_NONE,
    ///不是升级文件
    ERROR_FILEERROR,
    ///部分升级文件,ROM版本号不相同
    ERROR_ROMVERION_ERROR,
    ///部分升级文件,版本号相同
    ERROR_VERION_SAME,
    ///全量升级文件,ROM版本号相同
    ERROR_ROMVERION_SAME,
    ///设备不支持OTA升级
    ERROR_DEVICE_NOTSUPPORT_UPDATE
} ERROR;

typedef void(^OTAReturnNotifyValueToViewBlock)(NSData* data,NSString* stringData,BOOL canUpdate);

typedef void(^OTABlock)(ERROR error,float progress);


typedef enum : NSUInteger {
    NOTIFY_IDENTFY,
    NOTIFY_BLOCK,
}NOTIFY;

@interface BaseBleDevice (BK3432)

//开始升级前需要先调用此函数,初始化通道
-(void)setupOTA;

/// 开始OTA升级
/// @param filePah 文件路径
/// @param otaBlock ota 回调
-(void)startOTAWithFile:(NSString *)filePah progress:(OTABlock)otaBlock;



///跳过校验
-(void)stopVerify;

@end

NS_ASSUME_NONNULL_END
