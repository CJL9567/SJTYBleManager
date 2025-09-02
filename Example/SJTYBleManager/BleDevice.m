//
//  BleDevice.m
//  TestApp
//
//  Created by sjty on 2023/7/6.
//

#import "BleDevice.h"

@implementation BleDevice


//-(NSString *)getServiceUUID{
//    return @"FFF0";
//
//}
//
//-(NSString *)getWriteUUID{
//    return @"FFF6";
//}
//
//
//-(NSString *)getNotifiUUID{
//    return @"FFF6";
//}
//
//-(NSString *)getBroadcastServiceUUID{
//    return @"";
//}
//
//-(NSArray *)deviceName{
//    return @[@"FSRKB"];
//}

////
///**
// 获取服务UUID 子类需覆盖次方法
// @return serviceUUID
// */
//-(NSArray<NSString *> *)getServiceUUID {
//    return @[@"FFB0",@"6E400001-B5A3-F393-E0A9-E50E24DCCA9E"];
//}
//
//
///**
//
// 获取写数据UUID 子类需覆盖次方法
//
// @return writeUUID
// */
//-(NSArray<NSString *> *)getWriteUUID {
//    return @[@"FFB1",@"6E400002-B5A3-F393-E0A9-E50E24DCCA9E"];
//}
//
///**
// 获取通知数据UUID 子类需覆盖次方法
//
// @return writeUUID
// */
//-(NSArray<NSString *> *)getNotifiUUID {
//
//    return @[@"FFB2",@"6E400003-B5A3-F393-E0A9-E50E24DCCA9E"];
//}
//
//
//-(NSArray *)deviceName{
//    return @[@"YDSC",@"EMS"];
//}



-(NSArray<NSString *> *)getServiceUUID{
    
    return @[@"AE00"];
}

-(NSArray<NSString *> *)getWriteUUID{
    return @[@"AE01"];
}

-(NSArray<NSString *> *)getNotifiUUID{
    return @[@"AE02"];
}


-(NSArray *)deviceName{
    return @[@"Ani"];
    
}

-(void)sendModeToBigDataDevice:(NSInteger)value{
    //    NSString *string=@"AAAE1501160D";
    // 计算需要生成的字节数
    NSUInteger targetSize = 512;
    
//    // 创建数据缓冲区
    NSMutableData *data = [NSMutableData dataWithCapacity:targetSize];
    
    
    [data appendData:[NSData dataWithBytes:&value length:1]];
    
    // 填充数据直到达到目标大小
    uint8_t byte = 0x55; // 使用0x55作为填充字节，可以根据需要修改
    for (NSUInteger i = 0; i < targetSize-1; i++) {
        [data appendBytes:&byte length:1];
        // 简单的字节变化，使文件内容不完全相同
        byte = (byte + 1) % 0xFF;
    }
    
    [self sendCommand:data notifyBlock:^(NSData *data, NSString *stringData) {
        
    } filterBlock:^NSString *{
        return @"";
    }];
    
}



-(void)lightDeviceHue:(NSInteger)hue saturation:(NSInteger)saturation{
    NSMutableString *sendDataString =[NSMutableString string];
//    NSLog(@"========%d =======%d",hue,saturation);
    [sendDataString appendString:@"FFA4"];
    [sendDataString appendString:@"03"];
    [sendDataString appendString:[BaseUtils stringConvertForShort:hue]];
    [sendDataString appendString:[BaseUtils stringConvertForByte:saturation]];
    [sendDataString appendString:[self checkString:[sendDataString substringFromIndex:6]]];
    [sendDataString appendString:@"AA"];
    NSData *sendData=[BaseUtils stringToBytes:sendDataString];
    [self sendCommand:sendData notifyBlock:^(NSData *data, NSString *stringData) {
        
    } filterBlock:^NSString *{
        return @"";
    }];
}

-(void)lightDeviceMode:(NSInteger)lightMode{
    
    NSMutableString *sendDataString =[NSMutableString string];
    
    [sendDataString appendString:@"FFA1"];
    [sendDataString appendString:@"01"];
    [sendDataString appendString:[BaseUtils stringConvertForByte:lightMode]];
    [sendDataString appendString:[self checkString:[sendDataString substringFromIndex:6]]];
    [sendDataString appendString:@"AA"];
    NSData *sendData=[BaseUtils stringToBytes:sendDataString];
    [self sendCommand:sendData notifyBlock:^(NSData *data, NSString *stringData) {
        
    } filterBlock:^NSString *{
        return @"";
    }];
}

-(NSString *)checkString:(NSString *)dataString{
    NSInteger checkValue=0;
    for (int i=0; i<dataString.length/2; i++) {
        NSString *string=[dataString substringWithRange:NSMakeRange(i*2, 2)];
        checkValue+= [BaseUtils intConvertForHexString:string];
    }
    return [BaseUtils stringConvertForByte:checkValue];
}

-(void)sendFileName:(NSInteger)fileSize  fileName:(NSString *)fileName block:(void(^)(void))block{
    
    NSInteger maxLenght=[self.activityCBPeripheral maximumWriteValueLengthForType:self.characteristicWriteType]-4;

    NSInteger maxCount = fileSize % maxLenght == 0 ?  fileSize / maxLenght  : fileSize / maxLenght +1;
    
    NSMutableString *dataString = [NSMutableString string];
    [dataString appendString:@"AA"];
    [dataString appendString:@"1B"];
    [dataString appendString:[BaseUtils stringConvertForInt:fileSize]];
    [dataString appendString:@"00"];
    [dataString appendString:@"00"];
    [dataString appendString:[BaseUtils stringConvertForShort:maxCount]];
    
    
    NSMutableString *mustring = [[NSMutableString alloc]init];
    const char *ch = [fileName cStringUsingEncoding:NSASCIIStringEncoding];
    for (int i = 0; i < strlen(ch); i++) {
        [mustring appendString:[NSString stringWithFormat:@"%x",ch[i]]];
    }
    [dataString appendString:mustring];
    NSData *cmdData =[BaseUtils stringToBytes:dataString];
    [self sendCommand:cmdData notifyBlock:^(NSData *data, NSString *stringData) {
        Byte *byte=(Byte *) [data bytes];
        if(byte[2]==0x00){
            if(block){
                block();
            }
        }
        
    } filterBlock:^NSString *{
        return @"BB1B";
    }];
}


-(void)sendFileData:(NSString *)filePath progress:(void(^)(float progress)) block{
    
    
    
    
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    NSInteger maxLenght=[self.activityCBPeripheral maximumWriteValueLengthForType:self.characteristicWriteType]-4;

    NSInteger maxCount = fileData.length % maxLenght == 0 ?  fileData.length / maxLenght  : fileData.length / maxLenght +1;
    __weak typeof(self)weakSelf= self;
    [self sendFileName:fileData.length fileName:@"water.mp3" block:^{
        
        dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
        
        dispatch_async(serialQueue, ^{
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
            for (int i=0 ; i<maxCount; i++) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    NSLog(@"发送====%d",i);
                   
                    NSMutableData *mutableData= [NSMutableData data];
                    Byte byte[]= {0xaa,0x1d};
                    [mutableData appendBytes:byte length:2];
                     
                    [mutableData appendData: [BaseUtils stringToBytes:[BaseUtils stringConvertForShort:i]]];
                    
                    if(i==maxCount-1){
                        [mutableData appendData:[fileData subdataWithRange:NSMakeRange(i*maxLenght, fileData.length-i*maxLenght)]];
                    }else{
                        [mutableData appendData:[fileData subdataWithRange:NSMakeRange(i*maxLenght, maxLenght)]];
                    }
                    
                    
                    NSData *cmdData =mutableData;
                    [weakSelf sendCommand:cmdData notifyBlock:^(NSData *data, NSString *stringData) {
                        
                    } filterBlock:^NSString *{
                        return @"";
                    }];
                    
                    if(block){
                        block((i+1*1.0f)/maxCount);
                    }
                    dispatch_semaphore_signal(semaphore);
                });
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            }
            
            
            
        });
    }];
    

    
    
}

-(void)sendFinish{
    NSMutableString *dataString = [NSMutableString string];
    [dataString appendString:@"AA"];
    [dataString appendString:@"1C00"];
    
    NSData *cmdData =[BaseUtils stringToBytes:dataString];
    [self sendCommand:cmdData notifyBlock:^(NSData *data, NSString *stringData) {
        
    } filterBlock:^NSString *{
        return @"";
    }];
}



-(void)sendFileData1:(NSString *)filePath progress:(void(^)(float progress)) block{
    
    
    
    
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    NSInteger maxLenght=182-4;

    NSInteger maxCount = fileData.length % maxLenght == 0 ?  fileData.length / maxLenght  : fileData.length / maxLenght +1;
    __weak typeof(self)weakSelf= self;
    dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(serialQueue, ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        for (int i=0 ; i<maxCount; i++) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSLog(@"发送====%d",i);
               
                NSMutableData *mutableData= [NSMutableData data];
                Byte byte[]= {0xaa,0x1d};
                [mutableData appendBytes:byte length:2];
                 
                [mutableData appendData: [BaseUtils stringToBytes:[BaseUtils stringConvertForShort:i]]];
                
                if(i==maxCount-1){
                    [mutableData appendData:[fileData subdataWithRange:NSMakeRange(i*maxLenght, fileData.length-i*maxLenght)]];
                }else{
                    [mutableData appendData:[fileData subdataWithRange:NSMakeRange(i*maxLenght, maxLenght)]];
                }
                
                
                NSData *cmdData =mutableData;
                [weakSelf sendCommand:cmdData notifyBlock:^(NSData *data, NSString *stringData) {
                    
                } filterBlock:^NSString *{
                    return @"";
                }];
                
                if(block){
                    block((i+1*1.0f)/maxCount);
                }
                dispatch_semaphore_signal(semaphore);
            });
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
        
        
        
    });
    

    
    
}



@end
