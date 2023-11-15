//
//  BleManager.m
//  TPFLight
//
//  Created by sjty on 2019/12/30.
//  Copyright © 2019 sjty. All rights reserved.
//

#import "BleManager.h"
#import "BaseBleDevice.h"
#import "BabyBluetooth.h"
@interface BleManager()

@property(assign,nonatomic)Boolean autoDisConnected;//是否为自动断开

@property(nonatomic,strong)NSMutableArray *reconnectUUIDArray;

///为了防止信号刷新过快导致页面卡顿,接收到20次后刷新一次页面
@property(assign,nonatomic)Boolean rssiRefresh;



@property(nonatomic,strong)CBPeripheral *currentConnectPeripheral;

///是否正在连接
@property(assign,nonatomic)Boolean isConnecting;

@property(assign,nonatomic)Boolean filterName;

///定时刷新信号值
@property(nonatomic,strong)NSTimer *rssiTimer;


@property(assign,nonatomic)Boolean isReLoad;

@property(nonatomic,strong)NSMutableArray *connectingArray;


@end


@implementation BleManager

static BleManager *_instance;

//单例模式
+ (instancetype)shareManager {
    static BleManager *share = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        share = [[BleManager alloc]init];
        [share babyDelegate];
        share.isVerify =true;
        share.characteristicWriteType=CBCharacteristicWriteWithoutResponse;
        [share.reconnectUUIDArray addObjectsFromArray:[share autoReconnectUUIDS]];
        share.rssiTimer=[NSTimer timerWithTimeInterval:1 target:share selector:@selector(updateRssiRefresh) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:share.rssiTimer forMode:NSRunLoopCommonModes];
    });
   return share;
}


- (BabyBluetooth*)babyBluetooth {
    return  [BabyBluetooth shareBabyBluetooth];
}


-(void)updateRssiRefresh{
        
        
    self.rssiRefresh=YES;
}


-(void)setFilterByName:(Boolean)filter{
    _filterName=filter;
    
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    //连接设备->
    [self.babyBluetooth setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil scanForPeripheralsWithServices:nil  discoverWithServices:nil  discoverWithCharacteristics:nil];
    
    if (filter) {
        [self.babyBluetooth setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
            if ([advertisementData objectForKey:@"kCBAdvDataLocalName"]) {
                peripheralName = [NSString stringWithFormat:@"%@",[advertisementData objectForKey:@"kCBAdvDataLocalName"]];
            }
            NSArray* array = [self.baseBleDevice deviceName];
            for (NSString *peripheral_name in array) {
                if ([peripheralName containsString:peripheral_name]) {
                    return YES;
                }
            }
            
            return NO;
        }];
    }
}

-(void)setFilterByUUID:(BOOL)filter{
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
      if (filter) {
          //连接设备->
          [self.babyBluetooth setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:[self.baseBleDevice  getBroadcastServiceUUID]]]  discoverWithServices:nil  discoverWithCharacteristics:nil];
      }else{
          //连接设备->
          [self.babyBluetooth setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil scanForPeripheralsWithServices:nil  discoverWithServices:nil  discoverWithCharacteristics:nil];
      }
    
}

-(void)stopScan{
   [self.babyBluetooth cancelScan];
}

- (void)scanDevice {
    self.isReLoad=NO;
    self.babyBluetooth.scanForPeripherals().begin();
}

-(void)disConnectAllPeripheral{
   
    self.autoDisConnected=NO;
    [self.babyBluetooth cancelAllPeripheralsConnection];
    [self.peripheralDataArray removeAllObjects];
    [self.reconnectUUIDArray removeAllObjects];
    [self saveAutoReconnectUUID:self.reconnectUUIDArray];
}


-(void)disConnectPeripheral:(CBPeripheral *)peripheral{
    self.autoDisConnected=NO;
    
    [self.babyBluetooth cancelPeripheralConnection:peripheral];
    NSInteger index= [[self.peripheralDataArray valueForKey:@"peripheral"] indexOfObject:peripheral];
    if (index>=0&&index<self.peripheralDataArray.count ) {
        [self.peripheralDataArray removeObjectAtIndex:index];
    }
    if ([self.reconnectUUIDArray containsObject:peripheral.identifier.UUIDString]) {
        [self.reconnectUUIDArray removeObject:peripheral.identifier.UUIDString];
        [self saveAutoReconnectUUID:self.reconnectUUIDArray];
    }
    
    
}

-(void)refresh{
    
    NSMutableArray *peripherDataArray=[NSMutableArray array];
    
    for (NSDictionary * item in self.peripheralDataArray) {
        CBPeripheral *peripheral=  [item valueForKey:@"peripheral"];
        if (peripheral.state==CBPeripheralStateConnected) {
            [peripherDataArray addObject:item];
        }
    }
    [self.peripheralDataArray removeAllObjects];
    [self.peripheralDataArray addObjectsFromArray:peripherDataArray];
    
    [self scanDevice];
    
}

- (void)babyDelegate {
    
    __weak typeof(self) weakSelf = self;
    
    //设置扫描到设备的委托
    [self.babyBluetooth setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        if (self.filterName) {
            NSString *peripheralName;
            if ([advertisementData objectForKey:@"kCBAdvDataLocalName"]) {
                peripheralName = [NSString stringWithFormat:@"%@",[advertisementData objectForKey:@"kCBAdvDataLocalName"]];
            }else{
                peripheralName=peripheral.name;
            }
            
            for (NSString * deviceName in self.baseBleDevice.deviceName) {
                if ([peripheralName containsString:deviceName]) {
                    [weakSelf filterScanDevice:peripheral advertisementData:advertisementData RSSI:RSSI];
                }
            }
        }else{
            [weakSelf filterScanDevice:peripheral advertisementData:advertisementData RSSI:RSSI];
        }
        
        
    }];
    
    
    [self.babyBluetooth setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        NSLog(@"---连接成功---");
        [weakSelf setPeripheral:peripheral];
        
    }];
    
    //设置发现设service的Characteristics的委托
    [self.babyBluetooth setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        //发现特性 设置通知
        NSLog(@"--- 发现特性 ---");
        weakSelf.currentConnectPeripheral=peripheral;
    }];
    
    
    [self.babyBluetooth setBlockOnDidUpdateNotificationStateForCharacteristic:^(CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"设置通知");
        weakSelf.isConnected=YES;
        [weakSelf onNotifyFinish];
        Boolean isconnected = NO;
        for (CBPeripheral *peripheral in weakSelf.peripheralArray) {
            for (CBService *sevice in peripheral.services) {
                if ([sevice.characteristics containsObject:characteristic]) {
                    isconnected=YES;
                    [weakSelf.reconnectUUIDArray addObject:peripheral.identifier.UUIDString];
                    [weakSelf saveAutoReconnectUUID:weakSelf.reconnectUUIDArray];
                    [self.connectingArray removeObject:peripheral];
                    break;
                }
            }
            if (isconnected) {
                break;
            }
            
        }
        if (weakSelf.ConnectedBlock&&weakSelf.currentConnectPeripheral!=nil) {
            weakSelf.ConnectedBlock(weakSelf.currentConnectPeripheral.identifier.UUIDString);
        }
        
    }];
    
    
    [self.babyBluetooth setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        [weakSelf onDisconnect:peripheral];
    }];
    
    
    [self.babyBluetooth setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        [weakSelf onUpdateState:central];
    }];
    
}



//搜索过滤
- (void)filterScanDevice:(CBPeripheral*)peripheral
      advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSArray *peripherals = [self.peripheralDataArray valueForKey:@"peripheral"];
    if (!self.isReLoad) {
        self.isReLoad=YES;
        return;
    }
    NSLog(@"===搜索到设备 %@",peripheral.name);
    if (![peripherals containsObject:peripheral]) {
        
        NSString *peripheralName;
        if ([advertisementData objectForKey:@"kCBAdvDataLocalName"]) {
            peripheralName = [NSString stringWithFormat:@"%@",[advertisementData objectForKey:@"kCBAdvDataLocalName"]];
        }else if(!([peripheral.name isEqualToString:@""] || peripheral.name == nil)){
            peripheralName = peripheral.name;
        }
        
        NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
        [item setValue:peripheral forKey:@"peripheral"];
        [item setValue:RSSI forKey:@"RSSI"];
        [item setValue:advertisementData forKey:@"advertisementData"];
        [item setValue:peripheralName forKey:@"peripheralName"];
        
//        NSDictionary *advertisementDataDict= (NSDictionary *)[advertisementData valueForKey:@"advertisementData"];
        NSData *advDataManufacturerData;
        if ([advertisementData valueForKey:@"kCBAdvDataManufacturerData"]!=nil) {
            
            advDataManufacturerData=[advertisementData valueForKey:@"kCBAdvDataManufacturerData"];
            
        }
        if (self.needContainsAdvData) {
            if(advDataManufacturerData==nil){
                return;
            }
        }
        [self.peripheralDataArray addObject:item];
        [self reload:peripheral peripheralName:peripheralName advDataManufacturerData:advDataManufacturerData];
        if (self.autoConnected) {
            //自动连接
            if (!self.isMultiple) {
                if (!self.isConnected) {
                    if ([self.reconnectUUIDArray containsObject:peripheral.identifier.UUIDString]) {
                        if (!self.isConnecting) {
                            self.isConnecting=YES;
                            [self connectedCBPeripheral:peripheral];
                            if (self.ConnecttingBlock) {
                                self.ConnecttingBlock(peripheral);
                            }
                        }
                    }
                }
            }else{
                
                if ([self.reconnectUUIDArray containsObject:peripheral.identifier.UUIDString]) {
                    if (!self.isConnecting) {
                        self.isConnecting=YES;
                        [self connectedCBPeripheral:peripheral];
                        if (self.ConnecttingBlock) {
                            self.ConnecttingBlock(peripheral);
                        }
                    }
                }
            }
        }
    }else{
        for (int i=0; i<self.peripheralDataArray.count; i++) {
            NSDictionary *dict=self.peripheralDataArray[i];
            
            CBPeripheral *peri=dict[@"peripheral"];
            if (peri==peripheral) {
                [dict setValue:RSSI forKey:@"RSSI"];
                [dict setValue:advertisementData forKey:@"advertisementData"];
            }
        }
        //防止多设备时过度刷新
        if (self.rssiRefresh) {
            self.rssiRefresh=NO;
            if (self.ReloadRSSIBlock) {
                self.ReloadRSSIBlock();
            }
        }
        
    }
    
    if(self.ReloadAdvDataBlock){
        NSString *peripheralName;
        if ([advertisementData objectForKey:@"kCBAdvDataLocalName"]) {
            peripheralName = [NSString stringWithFormat:@"%@",[advertisementData objectForKey:@"kCBAdvDataLocalName"]];
        }else if(!([peripheral.name isEqualToString:@""] || peripheral.name == nil)){
            peripheralName = peripheral.name;
        }
        
        NSData *advDataManufacturerData;
        if ([advertisementData valueForKey:@"kCBAdvDataManufacturerData"]!=nil) {
             advDataManufacturerData=[advertisementData valueForKey:@"kCBAdvDataManufacturerData"];
            self.ReloadAdvDataBlock(peripheral, peripheralName, advDataManufacturerData);
        }
        
    }
}



///将需要自动回连的UDID进行保存
-(void)saveAutoReconnectUUID:(NSArray *)udidArrray{
    
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:@"Muti_UUIDS.archiver"];
    //将对象归档到指定路径
    [NSKeyedArchiver archiveRootObject:udidArrray toFile:path];
    
}

-(void)setCharacteristicWriteType:(CBCharacteristicWriteType)characteristicWriteType{
    _characteristicWriteType=characteristicWriteType;
    
}


-(NSArray *)autoReconnectUUIDS{
    
    
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:@"Muti_UUIDS.archiver"];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
    return  array;
}




-(void)reload:(CBPeripheral *)peripheral peripheralName:(NSString *)peripheralName advDataManufacturerData:(NSData *)advDataManufacturerData{
    if (self.ReloadBlock) {
        self.ReloadBlock(peripheral,peripheralName,advDataManufacturerData);
    }
}




#pragma mark 连接成功
- (void)setPeripheral:(CBPeripheral *) peripheral{
    if (!self.isMultiple) {
        //单连接
        self.baseBleDevice.isVerify = self.isVerify;
        self.baseBleDevice.activityCBPeripheral = peripheral;
        self.baseBleDevice.characteristicWriteType=self.characteristicWriteType;
    }else{
        Boolean isExist=NO;
        
        for (BaseBleDevice *baseBleDevice in self.multipleArray) {
            if ( [baseBleDevice.activityCBPeripheral.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
                isExist=YES;
                baseBleDevice.activityCBPeripheral=peripheral;
                break;
            }
        }
        ///判断启动app后是否已经连接过此设备
        if (!isExist) {
            if (self.mutipleClass!=nil) {
                BaseBleDevice *baseBleDevice = [[NSClassFromString(self.mutipleClass) alloc] initWithBluetooth];
                baseBleDevice.isVerify = self.isVerify;
                baseBleDevice.activityCBPeripheral=peripheral;
                baseBleDevice.characteristicWriteType=self.characteristicWriteType;
                [self.multipleArray addObject:baseBleDevice];
            }else{
                NSLog(@"⚠️⚠️⚠️⚠️=====请给 self.mutipleClass 赋值,否则将无法进行控制设备");
            }
        }
        
    }
    
}

#pragma mark 断开连接
- (void)onDisconnect:(CBPeripheral*)peripheral {
    if (!self.isMultiple) {
        self.isConnected=NO;
        self.baseBleDevice.activityCBPeripheral=nil;
    }
    
    NSInteger index= [[self.peripheralDataArray valueForKey:@"peripheral"] indexOfObject:peripheral];
    if (index>=0&&index<self.peripheralDataArray.count ) {
        [self.peripheralDataArray removeObjectAtIndex:index];
    }
    
    if(self.isMultiple){
        ///如果是多连接状态下,断开蓝牙时清除设备
        index = -1 ;
        for (BaseBleDevice *baseBleDevice in self.multipleArray) {
            if(baseBleDevice.activityCBPeripheral == peripheral){
                index = [self.multipleArray indexOfObject:baseBleDevice];
                break;
            }
        }
        if(index>=0 && index <self.multipleArray.count){
            [self.multipleArray removeObjectAtIndex:index];
        }
    }
    
   
    
    [self scanDevice];
    if (self.autoDisConnected) {
        if (self.AutoDisConnectedBlock) {
            self.AutoDisConnectedBlock(peripheral);
        }
    }else{
        if (self.DisConnectedBlock) {
            self.DisConnectedBlock(peripheral);
        }
    }
}
 
#pragma mark 蓝牙状态更新
-(void)onUpdateState:(CBCentralManager *)manager{
    self.isConnected=NO;
    [self.peripheralDataArray removeAllObjects];
    if (@available(iOS 13.0, *)) {
        
        if (manager.authorization==CBManagerAuthorizationAllowedAlways) {
            self.authorizationState=AuthorizationAllowedAlways;
            
            if (self.UpdateAuthorizationBlock) {
                self.UpdateAuthorizationBlock(AuthorizationAllowedAlways);
            }
        }else if (manager.authorization==CBManagerAuthorizationDenied){
            self.authorizationState=AuthorizationDenied;
             if (self.UpdateAuthorizationBlock) {
                 self.UpdateAuthorizationBlock(AuthorizationDenied);
             }
        }else if (manager.authorization==CBManagerAuthorizationRestricted){
            self.authorizationState=AuthorizationRestricted;
             if (self.UpdateAuthorizationBlock) {
                 self.UpdateAuthorizationBlock(AuthorizationRestricted);
             }
        }else if (manager.authorization==CBManagerAuthorizationNotDetermined){
            self.authorizationState=AuthorizationNotDetermined;
             if (self.UpdateAuthorizationBlock) {
                 self.UpdateAuthorizationBlock(AuthorizationNotDetermined);
             }
        }
        self.state=manager.state;
        if (self.UpdateStateBlock) {
            self.UpdateStateBlock(manager.state);
        }
        
    } else {
        self.state=manager.state;
        if(manager.state==CBManagerStatePoweredOff){
            if(self.isMultiple){
                [self.multipleArray removeAllObjects];
            }
        }
       if (self.UpdateStateBlock) {
           self.UpdateStateBlock(manager.state);
       }
        
    }
}

#pragma mark 连接设备
- (void)connectedCBPeripheral:(CBPeripheral*)peripheral {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.babyBluetooth cancelScan];
    [self.connectingArray addObject:peripheral];
    self.babyBluetooth.having(peripheral).connectToPeripherals().discoverServices().discoverCharacteristics().begin();
    [self performSelector:@selector(onConnecTimeOut) withObject:nil afterDelay:5];
    
}

/// 连接设备
/// @param peripheral 指定设备
/// @param timeOut 超时时长
- (void)connectedCBPeripheral:(CBPeripheral*)peripheral timeOut:(NSInteger)timeOut{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.babyBluetooth cancelScan];
    [self.connectingArray addObject:peripheral];
    self.babyBluetooth.having(peripheral).connectToPeripherals().discoverServices().discoverCharacteristics().begin();
    if(timeOut==0){
        timeOut=5;
    }
    [self performSelector:@selector(onConnecTimeOut) withObject:nil afterDelay:timeOut];
}


- (void)onConnecTimeOut {
    for (CBPeripheral *peripheral in self.connectingArray) {
        [[BabyBluetooth shareBabyBluetooth] cancelPeripheralConnection:peripheral];
        NSInteger index= [[self.peripheralDataArray valueForKey:@"peripheral"] indexOfObject:peripheral];
        if (index>=0&&index<self.peripheralDataArray.count ) {
            [self.peripheralDataArray removeObjectAtIndex:index];
        }
    }
    if (self.ConnectTimeOutBlock) {
        self.ConnectTimeOutBlock();
    }
}


- (void)onNotifyFinish {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    self.autoDisConnected=YES;
    self.isConnecting=NO;
    [self scanDevice];

    
}

- (NSMutableArray*)peripheralDataArray{
    if (_peripheralDataArray==nil) {
        _peripheralDataArray = [NSMutableArray array];
    }
    return _peripheralDataArray;
}

-(NSArray *)peripheralArray{
    return [self.peripheralDataArray valueForKey:@"peripheral"];
}


-(NSMutableArray *)multipleArray{
    if (!_multipleArray) {
        _multipleArray=[NSMutableArray array];
    }
    return _multipleArray;
}


-(NSMutableArray *)reconnectUUIDArray{
    if (!_reconnectUUIDArray) {
        _reconnectUUIDArray =[NSMutableArray array];
    }
    return _reconnectUUIDArray;
}


-(NSMutableArray *)connectingArray{
    if (!_connectingArray) {
        _connectingArray  =[NSMutableArray array];
    }
    return _connectingArray;
}

@end
