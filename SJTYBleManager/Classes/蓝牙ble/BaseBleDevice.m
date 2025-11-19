//
//  BaseBleDevice.m
//  KangNengWear
//
//  Created by liangss on 2017/10/12.
//  Copyright © 2017年 sjty. All rights reserved.
//

#import "BaseBleDevice.h"
#import "NSQueue.h"
#import "BabyBluetooth.h"
#import "SJTYBLESecret.h"
#import <SJTYLogManager/SJTYLogManager.h>
///通知 -- 设备非法 即非四聚通用开发的设备,此时需要断开蓝牙并通知非法设备
#define BLE_DEVICE_ERROR  @"BLE_DEVICE_ERROR"

@interface BaseBleDevice()
@property (nonatomic,retain) NSQueue *queue;
@property(nonatomic,strong)BabyBluetooth *babyBlutooth;



@property (nonatomic,strong) CBCharacteristic * writeCharacteristic;

@property (nonatomic,strong) CBCharacteristic * notifyCharacteristic;

@property (nonatomic,strong) NSMutableArray<NSString*>* spiltDataArray;

@property (nonatomic,strong) CBService * cbService;

@property (nonatomic, copy) ReturnNotifyValueToViewBlock blockReturnNotifyValueToView;
@property (nonatomic,copy)  FilterNotifyValueBlock blockFilterNotifyValue;

@property (nonatomic,assign) BOOL iSpiltData;


@property(assign,nonatomic)Boolean isChecked;

///发送数据数组--->用于防止发送数据过快导致无法发送成功
@property(nonatomic,strong)NSMutableArray *sendDataArray;

///已经准备好了可以发送数据了
@property(assign,nonatomic)Boolean isReadyToSend;


@end

@implementation BaseBleDevice


- (instancetype) initWithBluetooth{
    self = [super init];
    if (self) {
        self.babyBlutooth = [BabyBluetooth shareBabyBluetooth];
        self.characteristicWriteType=CBCharacteristicWriteWithoutResponse;
        //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifcationValue:) name:BabyNotificationAtDidUpdateValueForCharacteristic object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDisconnectPeripheralNotifcationValue:) name:BabyNotificationAtDidDisconnectPeripheral object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peripheralIsReadyToSendWriteWithoutResponse:) name:BabyNotificationAtPeripheralIsReadyToSendWriteWithoutResponse object:nil];
        
        self.queue = [[NSQueue alloc] init];
        
        self.isReadyToSend = true;
    }
    return self;
}




-(NSMutableArray*)spiltDataArray {
    if (_spiltDataArray == nil) {
        _spiltDataArray =[NSMutableArray array];
    }
    return _spiltDataArray;
}

/**
 获取服务UUID 子类需覆盖次方法

 @return serviceUUID
 */
-(NSArray <NSString*> *)getServiceUUID{
    return @[];
}


/**
 
 获取写数据UUID 子类需覆盖次方法
 
 @return writeUUID
 */
-(NSArray <NSString*> *)getWriteUUID{
    return @[];
}


/**
 
 获取通知数据UUID 子类需覆盖次方法
 
 @return writeUUID
 */
-(NSArray <NSString*> *)getNotifiUUID{
    return @[];
}

/**
 
 获取广播数据UUID 子类需覆盖次方法
 
 @return writeUUID
 */
-(NSArray <NSString*> *)getBroadcastServiceUUID{
    return @[];
}

-(NSArray*)deviceName{
    return @[];
}


-(void)startTimer{
    if(self.isVerify){
        if(!self.isChecked){
            NSLog(@"=======此设备为非法设备");
            if (self.activityCBPeripheral!=nil) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"BLE_DEVICE_ERROR" object:@{@"peripheral":self.activityCBPeripheral}];
            }
        }
    }
}

-(void)setActivityCBPeripheral:(CBPeripheral *)activityCBPeripheral {
    _cbService=nil;
    _writeCharacteristic=nil;
    _notifyCharacteristic=nil;
    _activityCBPeripheral = activityCBPeripheral;
    _isChecked =NO;
    if (activityCBPeripheral!=nil) {
        [self performSelector:@selector(setNotify) withObject:self afterDelay:3];
    }
}


-(void)returnValue {
    
    NSMutableString * strData = [NSMutableString string];
    if(self.spiltDataArray.count > 0){
        for (NSString * str in self.spiltDataArray) {
            [strData appendString:str];
        }
    }
    if([self blockFilterNotifyValue]) {
        NSString * filterString = self.blockFilterNotifyValue();
        NSString * headString = [strData substringWithRange:NSMakeRange(0, filterString.length)];
        if ([filterString caseInsensitiveCompare:headString] == NSOrderedSame) {
            
            if ([self blockReturnNotifyValueToView]) {
                [self blockReturnNotifyValueToView](nil,strData);
            }
            //移除所有
        }
    }
    self.iSpiltData = NO;
    [self.spiltDataArray removeAllObjects];
}

-(void)setNotify{
    if (self.activityCBPeripheral) {
        if (self.notifyCharacteristic) {
            __weak typeof(self) weekSelf = self;
//            [self startTimer];
            [self  performSelector:@selector(startTimer) withObject:nil afterDelay:10];
            [self.babyBlutooth notify:weekSelf.activityCBPeripheral characteristic:weekSelf.notifyCharacteristic block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                
            }];
            
        }
    }
}


- (void)sendCommand:(NSData*)cmd
       notifyBlock:(ReturnNotifyValueToViewBlock) notifyBlock
       filterBlock:(FilterNotifyValueBlock) filterBlock{
    self.blockReturnNotifyValueToView = notifyBlock;
    self.blockFilterNotifyValue = filterBlock;
    
    
    if (cmd) {
        if (self.activityCBPeripheral && self.activityCBPeripheral.state == CBPeripheralStateConnected &&self.writeCharacteristic!=nil&&self.isReadyToSend) {
            [self.activityCBPeripheral writeValue:cmd forCharacteristic:self.writeCharacteristic type:self.characteristicWriteType];
//            BabyLog(@"发送的数据为:%@",[BaseUtils stringConvertForData:cmd]);
            SJTYLog(LogLevelInfo, [NSString stringWithFormat:@"发送的数据为:%@",[BaseUtils stringConvertForData:cmd]]);
            if (self.writeCharacteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) {
                self.isReadyToSend=NO;
                [self performSelector:@selector(checkReadToSend) withObject:nil afterDelay:0.1];
            }
        }else{
            if (self.writeCharacteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) {
                [self.sendDataArray addObject:cmd];
            }
        }
    }
    
}

- (void)sendCommand:(NSData*)cmd
       notifyBlock:(ReturnNotifyValueToViewBlock) notifyBlock
        filterBlock:(FilterNotifyValueBlock) filterBlock iSpiltData:(Boolean)isPiltData{
    self.blockReturnNotifyValueToView = notifyBlock;
    self.blockFilterNotifyValue = filterBlock;
    self.iSpiltData=isPiltData;
    if (cmd) {
        if (self.activityCBPeripheral && self.activityCBPeripheral.state == CBPeripheralStateConnected &&self.writeCharacteristic!=nil&&self.isReadyToSend) {
            [self.activityCBPeripheral writeValue:cmd forCharacteristic:self.writeCharacteristic type:self.characteristicWriteType];
            SJTYLog(LogLevelInfo, [NSString stringWithFormat:@"发送的数据为:%@",[BaseUtils stringConvertForData:cmd]]);
            if (self.writeCharacteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) {
                self.isReadyToSend=NO;
                [self performSelector:@selector(checkReadToSend) withObject:nil afterDelay:0.1];
            }
            
        }else{
            if (self.writeCharacteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) {
                [self.sendDataArray addObject:cmd];
            }
        }
    }
    
}

-(void)checkReadToSend{
    if (!self.isReadyToSend) {
        self.isReadyToSend=YES;
    }
}

-(CBCharacteristic*)writeCharacteristic{
    if (_writeCharacteristic == nil) {
        for (CBCharacteristic *characteristic in self.cbService.characteristics ) {
           // NSLog(@"characteristic.UUID==%@",characteristic.UUID.UUIDString);
            for (NSString *uuid in [self getWriteUUID]) {
                if ([characteristic.UUID.UUIDString isEqualToString:[uuid uppercaseString]])
                    {
                        _writeCharacteristic = characteristic;
                        return _writeCharacteristic;
                    }
                }
            }
            
        
        }
    return _writeCharacteristic;
}

-(CBCharacteristic*)notifyCharacteristic{
    if (_notifyCharacteristic == nil) {
        
        
        for (CBCharacteristic *characteristic in self.cbService.characteristics ) {
            // NSLog(@"notifiUUID==%@",characteristic.UUID.UUIDString);
            for (NSString *uuid in [self getNotifiUUID]) {
                if ([characteristic.UUID.UUIDString isEqualToString:[uuid uppercaseString]])
                {
                    _notifyCharacteristic = characteristic;
                    return _notifyCharacteristic;
                }
            }
            
        }
    }
    return _notifyCharacteristic;
}

-(CBService*)cbService{
    if (_cbService == nil) {
        for ( CBService *service in self.activityCBPeripheral.services ) {
            for (NSString *uuid in [self getServiceUUID]) {
                if ([service.UUID.UUIDString isEqualToString:[uuid uppercaseString]]) {
                    _cbService = service;
                    return _cbService;
                }
            }
            
        }
    }
    return _cbService;
}

-(NSString*)getAnsyTimeCmd{
    NSMutableString * string = [NSMutableString string];
    
    NSDate *date = [NSDate date];//这个是NSDate类型的日期，所要获取的年月日都放在这里；
    NSCalendar *cal = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSCalendarUnitYear|NSCalendarUnitMonth|
    NSCalendarUnitDay|NSCalendarUnitWeekday |NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;//这句是说你要获取日期的元素有哪些。获取年就要写NSYearCalendarUnit，获取小时就要写NSHourCalendarUnit，中间用|隔开；
    NSDateComponents *d = [cal components:unitFlags fromDate:date];//把要从date中获取的unitFlags标示的日期元素存放在NSDateComponents类型的d里面；
    //然后就可以从d中获取具体的年月日了；
    //aa e0 07 e2 08 28 02 18 12 30 ff e4
    //aa e0 07 e2 08 1c 12 10 0c 00 ff 26
    NSInteger year = [d year];
    NSInteger month = [d month];
    NSInteger day  =  [d day];
    NSInteger hour = [d hour];
    NSInteger min = [d minute];
    NSInteger second = [d second];
    NSInteger w=[d weekday];
    NSInteger week = w;
    
    // hexYear + hexMonth + hexDay + hexHour + hexMin + hexSecond;
    
    if (week==1) {
        week=6;
    }else{
        week=week-2;
    }
    
    [string appendString:[BaseUtils stringConvertForShort:year]];
    [string appendString:[BaseUtils stringConvertForByte:month]];
    [string appendString:[BaseUtils stringConvertForByte:day]];
    [string appendString:[BaseUtils stringConvertForByte:hour]];
    [string appendString:[BaseUtils stringConvertForByte:min]];
    [string appendString:[BaseUtils stringConvertForByte:second]];
    
    return string;
}



-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BabyNotificationAtDidUpdateValueForCharacteristic object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BabyNotificationAtDidDisconnectPeripheral object:nil];
}

-(void)receiveNotifcationValue:(NSNotification*)notification {
    NSDictionary*dic = notification.object;
    CBPeripheral* peripheral = dic[@"peripheral"];
    CBCharacteristic* characteristics = dic[@"characteristic"];
  
    if ([peripheral.identifier.UUIDString isEqualToString:self.activityCBPeripheral.identifier.UUIDString] ) {//接收的peripheral 要与当前的activityCBPeripheral 为同一个。
        NSData * data = characteristics.value;
        NSString * strData =  [BaseUtils stringConvertForData:characteristics.value];
        if (data.length==0) {
            return;
        }
//        BabyLog(@"接受的数据为:%@",strData);
        SJTYLog(LogLevelInfo, [NSString stringWithFormat:@"接受的数据为:%@",strData]);
        Byte *byte= (Byte *)[data bytes];
        if(byte[0]==0xBB&&byte[1]==0xB6){
            self.isChecked =YES;
            if(self.isVerify){
                if(data.length>3){
                    [self sendVerifyData:[SJTYBLESecret secrect:[data subdataWithRange:NSMakeRange(2, data.length-3)]]];
                    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startTimer) object:nil];
                }
            }
        }
        if ([self iSpiltData]) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(returnValue) object:nil];
            [self.spiltDataArray addObject:strData];
            [self performSelector:@selector(returnValue) withObject:nil afterDelay:0.5];
            
        } else {
            
            if([self blockFilterNotifyValue]) {
                
                NSString * filterString = self.blockFilterNotifyValue();
                if (strData.length>=filterString.length) {
                    NSString * headString = [strData substringWithRange:NSMakeRange(0, filterString.length)];
                    if ([filterString caseInsensitiveCompare:headString] == NSOrderedSame) {
                        if ([self blockReturnNotifyValueToView]) {
                            [self blockReturnNotifyValueToView](data,strData);
                        }
                    }
                }
                
            }
        }
        [self receiveData:data];
    }
}



-(void)didDisconnectPeripheralNotifcationValue:(NSNotification*)notification{
    NSDictionary*dic = notification.object;
    CBPeripheral* peripheral = dic[@"peripheral"];
    if (self.activityCBPeripheral==peripheral) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startTimer) object:nil];
    }
    
}

-(void)peripheralIsReadyToSendWriteWithoutResponse:(NSNotification*)notification{
    NSDictionary*dic = notification.object;
    CBPeripheral* peripheral = dic[@"peripheral"];
    if (self.activityCBPeripheral==peripheral) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkReadToSend) object:nil];
        self.isReadyToSend=YES;
        if (self.sendDataArray.count>0) {
            NSData * data = [self.sendDataArray firstObject];
            if (data!=nil) {
                [self.activityCBPeripheral writeValue:data forCharacteristic:self.writeCharacteristic type:self.characteristicWriteType];
                SJTYLog(LogLevelInfo, [NSString stringWithFormat:@"准备好重新发送的数据为:%@",[BaseUtils stringConvertForData:data]]);
                [self.sendDataArray removeObjectAtIndex:0];
                self.isReadyToSend=NO;
            }
        }
        
    }
}

-(void)sendVerifyData:(NSData *)data {
    NSMutableString *sendDataString =[NSMutableString string];
    
    [sendDataString appendString:@"AAAA"];
    [sendDataString appendString:[BaseUtils stringConvertForData:data]];
    [sendDataString appendString:@"FF"];
    
    NSData *sendData=[BaseUtils stringToBytes:sendDataString];
    [self sendCommand:sendData notifyBlock:^(NSData *data, NSString *stringData) {
        
    } filterBlock:^NSString *{
        return @"";
    }];
    
}

- (void)receiveData:(NSData*)data {
    
}

/**
 *清除数据缓存
 */
- (void)cleanDataBuffer {
    if (self.queue) {
        [self.queue clearQueue];
    }
}

-(void)cleanObject {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BabyNotificationAtDidUpdateValueForCharacteristic object:nil];
    if (self.queue) {
        [self.queue clearQueue];
    }
}

-(NSMutableArray *)sendDataArray{
    if (_sendDataArray==nil) {
        _sendDataArray = [NSMutableArray array];
    }
    return _sendDataArray;
}

@end
