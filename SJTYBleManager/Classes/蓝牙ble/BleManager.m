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
@property(assign,nonatomic)NSInteger rssiRefreshCount;

///是否正在连接
@property(assign,nonatomic)Boolean isConnecting;

@property(assign,nonatomic)Boolean filterName;
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
        [share.reconnectUUIDArray addObjectsFromArray:[share autoReconnectUUIDS]];
    });
   return share;
}


- (BabyBluetooth*)babyBluetooth {
    return  [BabyBluetooth shareBabyBluetooth];
}

-(void)setFilterByName:(Boolean)filter{
    _filterName=filter;
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
    }];
    
    
    [self.babyBluetooth setBlockOnDidUpdateNotificationStateForCharacteristic:^(CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"设置通知");
        Boolean isconnected = NO;
        for (CBPeripheral *peripheral in weakSelf.peripheralArray) {
            for (CBService *sevice in peripheral.services) {
                if ([sevice.characteristics containsObject:characteristic]) {
                    isconnected=YES;
                    [weakSelf.reconnectUUIDArray addObject:peripheral.identifier.UUIDString];
                    [weakSelf saveAutoReconnectUUID:weakSelf.reconnectUUIDArray];
                    
                    if (weakSelf.ConnectedBlock) {
                        weakSelf.ConnectedBlock(peripheral.identifier.UUIDString);
                    }
                    break;
                }
            }
            if (isconnected) {
                break;
            }
            
        }
        
        [weakSelf onNotifyFinish];
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
        [self.peripheralDataArray addObject:item];
        [self reload:peripheral];
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
            }
        }
        //防止多设备时过度刷新
        self.rssiRefreshCount++;
        if (self.rssiRefreshCount==30) {
            if (self.ReloadRSSIBlock) {
                self.ReloadRSSIBlock();
            }
            self.rssiRefreshCount=0;
        }
        
        
    }
}



///将需要自动回连的UDID进行保存
-(void)saveAutoReconnectUUID:(NSArray *)udidArrray{
    
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:@"Muti_UUIDS.archiver"];
    //将对象归档到指定路径
    [NSKeyedArchiver archiveRootObject:udidArrray toFile:path];
    
}



-(NSArray *)autoReconnectUUIDS{
    
    
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:@"Muti_UUIDS.archiver"];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
    return  array;
}




-(void)reload:(CBPeripheral *)peripheral{
    if (self.ReloadBlock) {
        self.ReloadBlock(peripheral);
    }
}


#pragma mark 连接成功
- (void)setPeripheral:(CBPeripheral *) peripheral{
    if (!self.isMultiple) {
        //单连接
        self.baseBleDevice.activityCBPeripheral = peripheral;
        
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
                baseBleDevice.activityCBPeripheral=peripheral;
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
            if (self.UpdateAuthorizationBlock) {
                self.UpdateAuthorizationBlock(AuthorizationAllowedAlways);
            }
        }else if (manager.authorization==CBManagerAuthorizationDenied){
             if (self.UpdateAuthorizationBlock) {
                 self.UpdateAuthorizationBlock(AuthorizationDenied);
             }
        }else if (manager.authorization==CBManagerAuthorizationRestricted){
             if (self.UpdateAuthorizationBlock) {
                 self.UpdateAuthorizationBlock(AuthorizationRestricted);
             }
        }else if (manager.authorization==CBManagerAuthorizationNotDetermined){
             if (self.UpdateAuthorizationBlock) {
                 self.UpdateAuthorizationBlock(AuthorizationNotDetermined);
             }
        }
        if (self.UpdateStateBlock) {
            self.UpdateStateBlock(manager.state);
        }
    } else {
       if (self.UpdateStateBlock) {
           self.UpdateStateBlock(manager.state);
       }
    }
}

#pragma mark 连接设备
- (void)connectedCBPeripheral:(CBPeripheral*)peripheral {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.babyBluetooth cancelScan];
    self.babyBluetooth.having(peripheral).connectToPeripherals().discoverServices().discoverCharacteristics().begin();
    [self performSelector:@selector(onConnecTimeOut) withObject:nil afterDelay:5];
}



- (void)onConnecTimeOut {
    if (self.ConnectTimeOutBlock) {
        self.ConnectTimeOutBlock();
    }
    [self.peripheralDataArray removeAllObjects];
    [[BabyBluetooth shareBabyBluetooth] cancelAllPeripheralsConnection];
    [self scanDevice];
}


- (void)onNotifyFinish {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    self.isConnected=YES;
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

@end
