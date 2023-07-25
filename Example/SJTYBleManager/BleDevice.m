//
//  BleDevice.m
//  TestApp
//
//  Created by sjty on 2023/7/6.
//

#import "BleDevice.h"

@implementation BleDevice


-(NSString *)getWriteUUID{
    return @"AE01";
}

-(NSString *)getNotifiUUID{
    return @"AE02";
}

-(NSString *)getServiceUUID{
    return @"AE00";
}


-(NSArray *)deviceName{
    return @[@"JL"];
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
