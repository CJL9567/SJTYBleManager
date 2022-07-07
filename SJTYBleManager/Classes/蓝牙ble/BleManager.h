//
//  BleManager.h
//  TPFLight
//
//  Created by sjty on 2019/12/30.
//  Copyright © 2019 sjty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseBleDevice.h"
NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, AuthorizationState) {
    AuthorizationNotDetermined = 0,
    AuthorizationRestricted,
    AuthorizationDenied,
    AuthorizationAllowedAlways
};

@interface BleManager : NSObject


+(instancetype)shareManager;

@property(nonatomic,strong)BaseBleDevice *baseBleDevice;

@property (nonatomic,strong) NSMutableArray * peripheralDataArray;

@property (nonatomic,strong) NSArray * peripheralArray;

///是否为多连接
@property(assign,nonatomic)Boolean isMultiple;
///已连接的设备
@property(nonatomic,strong)NSMutableArray *multipleArray;

///多连接时的设备对象-->
@property(nonatomic,strong)NSString *mutipleClass;

///是否已连接--->仅限单连接时使用
@property(assign,nonatomic)Boolean isConnected;

///是否需要自动回连
@property(assign,nonatomic)Boolean autoConnected;

@property(assign,nonatomic)CBCharacteristicWriteType characteristicWriteType;


-(void)setFilterByName:(Boolean)filter;

-(void)setFilterByUUID:(BOOL)filter;


/// 开始扫描
- (void)scanDevice;


/// 停止扫描
-(void)stopScan;

/// 连接设备
/// @param peripheral 指定设备
- (void)connectedCBPeripheral:(CBPeripheral*)peripheral;

/// 断开指定设备
/// @param peripheral 指定设备
-(void)disConnectPeripheral:(CBPeripheral *)peripheral;

/// 断开所有的设备
-(void)disConnectAllPeripheral;

/// 刷新设备
-(void)refresh;

/// 搜索到新的设备
@property(nonatomic,copy)void(^ReloadBlock)(CBPeripheral * peripheral);

/// 连接成功
@property(nonatomic,copy)void(^ConnecttingBlock)(CBPeripheral * peripheral);

/// 连接成功
@property(nonatomic,copy)void(^ConnectedBlock)(NSString *UUID);

///设备断开
@property(nonatomic,copy)void(^AutoDisConnectedBlock)(CBPeripheral * peripheral);


///设备断开
@property(nonatomic,copy)void(^DisConnectedBlock)(CBPeripheral * peripheral);

/// 连接超时
@property(nonatomic,copy)void(^ConnectTimeOutBlock)(void);

@property(nonatomic,copy)void(^ReloadRSSIBlock)(void);

@property(nonatomic,copy)void(^UpdateStateBlock)(CBManagerState  state);


@property(nonatomic,copy)void(^UpdateAuthorizationBlock)(AuthorizationState  authorization);

///多连接时将要连接的设备回调
@property(nonatomic,copy)void(^MutipleSetPeripheralBlock)(CBPeripheral * peripheral);


@end

NS_ASSUME_NONNULL_END
