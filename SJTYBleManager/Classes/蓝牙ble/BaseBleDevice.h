//
//  BaseBleDevice.h
//  KangNengWear
//
//  Created by liangss on 2017/10/12.
//  Copyright © 2017年 sjty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import <SJTYBleManager/BaseUtils.h>

//#import <SJTYBleManager/NSQueue.h>


#define sendLog @"sendCommand"
#define receiveLog @"receiveCommand"

typedef void(^ReturnNotifyValueToViewBlock)(NSData* data,NSString* stringData);
typedef NSString*(^FilterNotifyValueBlock)(void);

@interface BaseBleDevice : NSObject

@property (nonatomic,strong) CBPeripheral * activityCBPeripheral;

@property(assign,nonatomic)CBCharacteristicWriteType characteristicWriteType;

///是否需要进行四聚通用产品产品校验
@property(assign,nonatomic)Boolean isVerify; 

/**
 初始化
 @return 返回设备对象
 */
- (instancetype) initWithBluetooth;

/**
 获取服务UUID 子类需覆盖次方法

 @return serviceUUID
 */
-(NSString*)getServiceUUID;


/**
 
 获取写数据UUID 子类需覆盖次方法
 
 @return writeUUID
 */
-(NSString*)getWriteUUID;


/**
 
 获取通知数据UUID 子类需覆盖次方法
 
 @return writeUUID
 */
-(NSString*)getNotifiUUID;

/**
 
 获取广播数据UUID 子类需覆盖次方法
 
 @return writeUUID
 */
-(NSString *)getBroadcastServiceUUID;

/**
 设备名字 子类需覆盖次方法

 @return 设备的名字
 */

-(NSArray*)deviceName;

/**
 设置通知
 */
-(void)setNotify;

/**
 *清除数据缓存
 */
- (void)cleanDataBuffer;

/**
 发送数据

 @param cmd 指令
 */
-(void)sendCommand:(NSData*)cmd
       notifyBlock:(ReturnNotifyValueToViewBlock) notifyBlock
       filterBlock:(FilterNotifyValueBlock) filterBlock;



- (void)sendCommand:(NSData*)cmd
       notifyBlock:(ReturnNotifyValueToViewBlock) notifyBlock
filterBlock:(FilterNotifyValueBlock) filterBlock iSpiltData:(Boolean)isPiltData;


//获取同步时间指令  hexYear + hexMonth + hexDay + hexHour + hexMin + hexSecond;
-(NSString*)getAnsyTimeCmd;

-(void)cleanObject;

/**
 
 */
- (void)receiveData:(NSData*)data;

@end
