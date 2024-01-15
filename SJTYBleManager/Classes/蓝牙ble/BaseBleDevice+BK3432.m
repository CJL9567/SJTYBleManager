//
//  BaseBleDevice+BK3432.m
//  SJTYBleManager
//
//  Created by sjty on 2024/1/15.
//

#import "BaseBleDevice+BK3432.h"
#import "BKOTAManager.h"
#import "BabyBluetooth.h"
@implementation BaseBleDevice (BK3432)


-(NSString *)getOTA_SEVICE_UUID{
    return @"f000ffc0-0451-4000-b000-000000000000";
}

-(NSString *)getOTA_IDENTFY_UUID{
    return @"f000ffc1-0451-4000-b000-000000000000";
}

-(NSString *)getOTA_BLOCK_UUID{
    return @"f000ffc2-0451-4000-b000-000000000000";
}

-(void)setupOTA{
    [self setNotifyWithOTA:NOTIFY_IDENTFY];
    [self setNotifyWithOTA:NOTIFY_BLOCK];
}


-(void)stopVerify{
    
    NSData * newData = [BaseUtils stringToBytes:@"09"];
    
    [self sendOTAIdentfyCommand:newData notifyBlock:^(NSData * _Nonnull data, NSString * _Nonnull stringData, BOOL canUpdate) {
        
    } filterBlock:^NSString *{
        return @"";
    }];
}

-(void)startOTAWithFile:(NSString *)filePah progress:(OTABlock)otaBlock{
    
    BKOTAManager *otaManager=  [[BKOTAManager alloc] initWithOTAFilePath:filePah];

    if (self.identfyCharacteristic==nil||self.blockCharacteristic==nil) {
        NSLog(@"====此设备不支持OTA升级");
        if (otaBlock) {
            otaBlock(ERROR_DEVICE_NOTSUPPORT_UPDATE,0);
        }
    }
    if (otaManager.getType==0) {
        if (otaBlock) {
            otaBlock(ERROR_FILEERROR,0);
        }
        return;
    }
    [self otaQueryVersion:^(NSInteger version, NSInteger romVersion) {
        Byte *byte= [otaManager getBytes];
        NSData *data=[NSData dataWithBytes:byte length:16];
        if (otaManager.getType==1) {
            if (otaManager.getRomVersion!=romVersion) {
                if (otaBlock) {
                    otaBlock(ERROR_ROMVERION_ERROR,0);
                }
                NSLog(@"====ROM版本号不相同");
                return;
            }
            if (otaManager.getVersion==version) {
                if (otaBlock) {
                    otaBlock(ERROR_VERION_SAME,0);
                }
                NSLog(@"====版本号相同");
                return;
            }
        }else{
            if (otaManager.getRomVersion==romVersion) {
                NSLog(@"====ROM版本号相同");
                if (otaBlock) {
                    otaBlock(ERROR_ROMVERION_SAME,0);
                }
                return;
            }
        }
        __weak typeof(self)weakSelf=self;
        [self otaVersionCheck:data Block:^(NSString * _Nonnull result, Boolean canUpdate) {
            
            NSString *sendString=  [BaseUtils stringConvertForData:[otaManager getData]];
            
            dispatch_group_t group = dispatch_group_create();
            dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
           
            dispatch_group_async(group, serialQueue, ^{
                dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
                for (NSInteger i=0; i<otaManager.getBlockCount; i++) {
                    
                    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.03 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            
                            if(self.activityCBPeripheral.state==CBPeripheralStateConnected){
                                otaManager.index++;
                                if (otaBlock) {
                                    otaBlock(ERROR_NONE,otaManager.index*1.0f/otaManager.getBlockCount);
                                }
                                [weakSelf sendData:i sendString:sendString];
                            }else{
                                return;
                            }
                            
                            dispatch_semaphore_signal(semaphore);
                        });
                    });
                    
                }
                
            });
            
            
            dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"=====完成");
                    
                });
            });
            
        }];
        
    }];
    
    
}

-(void)sendData:(NSInteger )index sendString:(NSString *)sendString{
    NSString *updateString=[BaseUtils stringConvertForShort:[BaseUtils highAndLowToChanage:index]];
    
    NSString *dataString=[NSString stringWithFormat:@"%@%@",updateString,[sendString substringWithRange:NSMakeRange(index*32, 32)]];
    NSData *sendData=  [BaseUtils stringToBytes:dataString];
    [self otaUpdate:sendData Block:^(NSString * _Nonnull result, Boolean canUpdate) {
        
    }];
}



/// 查询设备版本号
/// @param block 回调
-(void)otaQueryVersion:(void(^)(NSInteger version,NSInteger romVersion))block{
    NSData * newData = [BaseUtils stringToBytes:@"00"];

    [self sendOTAIdentfyCommand:newData notifyBlock:^(NSData *data, NSString *stringData, BOOL canUpdate) {
        Byte *byte=(Byte *)[data bytes];
        NSInteger version=(byte[1]<<8)|byte[0];
        NSInteger romVersion=(byte[9]<<8)|byte[8];
        
        NSLog(@"version===%ld  romVersion == %ld",(long)version,(long)romVersion);
        
        if (block) {
            block(version,romVersion);
        }
    } filterBlock:^NSString *{
        return @"";
    }];
}


/// OTA 版本号校验
/// @param otaData ota文件数据
/// @param block 回调
-(void)otaVersionCheck:(NSData *)otaData Block:(void(^)(NSString *result,Boolean canUpdate))block{
   
   
    [self sendOTAIdentfyCommand:otaData notifyBlock:^(NSData *data, NSString *stringData, BOOL canUpdate) {
        if (block) {
            NSLog(@"OTA 版本号校验====%@",stringData);
            block(stringData,canUpdate);
        }
    } filterBlock:^NSString *{
        return @"0000";
    }];
    
}



/// 发送OTA文件数据
/// @param data 数据
/// @param block 回调
-(void)otaUpdate:(NSData *)data Block:(void(^)(NSString *result,Boolean canUpdate))block{
    [self sendOTABlockCommand:data notifyBlock:^(NSData *data, NSString *stringData, BOOL canUpdate) {
        if (block) {
            block(stringData,canUpdate);
        }
    } filterBlock:^NSString *{
        return @"";
    }];
    
}



- (void)sendOTABlockCommand:(NSData*)cmd
       notifyBlock:(OTAReturnNotifyValueToViewBlock) notifyBlock
       filterBlock:(FilterNotifyValueBlock) filterBlock{

//    BabyLog(@"发送的数据为:%@",[BaseUtils stringConvertForData:cmd]);
    NSString * sendDataStr = [BaseUtils stringConvertForData:cmd];
    
   
    if (cmd) {
        if (self.activityCBPeripheral && self.activityCBPeripheral.state == CBPeripheralStateConnected &&self.identfyCharacteristic!=nil) {
            [self.activityCBPeripheral writeValue:cmd forCharacteristic:self.blockCharacteristic type:CBCharacteristicWriteWithoutResponse];
        }
    }
}

- (void)sendOTAIdentfyCommand:(NSData*)cmd
       notifyBlock:(OTAReturnNotifyValueToViewBlock) notifyBlock
       filterBlock:(FilterNotifyValueBlock) filterBlock{
    
    if(self.identfyCharacteristic){
        [[BabyBluetooth shareBabyBluetooth] notify:self.activityCBPeripheral characteristic:self.identfyCharacteristic block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
            if(filterBlock) {
                NSString * strData =  [BaseUtils stringConvertForData:characteristics.value];
                
                NSString * filterString = filterBlock();
                NSString * headString = [strData substringWithRange:NSMakeRange(0, filterString.length)];
                if ([filterString caseInsensitiveCompare:headString] == NSOrderedSame) {
                    if (notifyBlock) {
                        notifyBlock(characteristics.value,strData,YES);
                    }
                }
            }
        }];
    }
    if(self.blockCharacteristic){
        [[BabyBluetooth shareBabyBluetooth] notify:self.activityCBPeripheral characteristic:self.blockCharacteristic block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
            if(filterBlock) {
                NSString * strData =  [BaseUtils stringConvertForData:characteristics.value];
                
                NSString * filterString = filterBlock();
                NSString * headString = [strData substringWithRange:NSMakeRange(0, filterString.length)];
                if ([filterString caseInsensitiveCompare:headString] == NSOrderedSame) {
                    if (notifyBlock) {
                        notifyBlock(characteristics.value,strData,YES);
                    }
                }
            }
        }];
    }
    
   
    if (cmd) {
        if (self.activityCBPeripheral && self.activityCBPeripheral.state == CBPeripheralStateConnected &&self.identfyCharacteristic!=nil) {
            [self.activityCBPeripheral writeValue:cmd forCharacteristic:self.identfyCharacteristic type:CBCharacteristicWriteWithoutResponse];
        }
    }
    
}




-(void)setNotifyWithOTA:(NOTIFY )notify{
    
    if (notify==NOTIFY_IDENTFY) {
        if (self.identfyCharacteristic) {
            
            [[BabyBluetooth shareBabyBluetooth] notify:self.activityCBPeripheral characteristic:self.identfyCharacteristic block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                
            }];
           
            
        }
    }else{
        if (self.blockCharacteristic) {
            [[BabyBluetooth shareBabyBluetooth] notify:self.activityCBPeripheral characteristic:self.blockCharacteristic block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                
            }];

        }
    }
    
}


-(CBService *)otaSevice{
    
    for ( CBService *service in self.activityCBPeripheral.services ) {
        if ([service.UUID.UUIDString isEqualToString:[[self getOTA_SEVICE_UUID] uppercaseString]]) {
            return  service;
        }
    }
    return nil;
}

-(CBCharacteristic*)identfyCharacteristic{
    for (CBCharacteristic *characteristic in self.otaSevice.characteristics ) {
        if ([characteristic.UUID.UUIDString  isEqualToString:[[self getOTA_IDENTFY_UUID] uppercaseString]])
        {
            return  characteristic;
        }
    }
    return nil;
}


-(CBCharacteristic*)blockCharacteristic{
    
    for (CBCharacteristic *characteristic in self.otaSevice.characteristics ) {
        if ([characteristic.UUID.UUIDString isEqualToString:[[self getOTA_BLOCK_UUID] uppercaseString]])
            {
                return  characteristic;
            }
        }
    return nil;
}

@end
