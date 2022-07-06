//
//  TreeBleDevice.m
//  M8001
//
//  Created by sjty on 2022/6/9.
//

#import "TreeBleDevice.h"

@implementation TreeBleDevice

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithBluetooth {
    self =  [super initWithBluetooth];
    if (self) {
       
    }
    return self;
}


/**
 获取服务UUID 子类需覆盖次方法

 @return serviceUUID
 */
-(NSString*)getServiceUUID {
    return @"AE30";
}


/**

 获取写数据UUID 子类需覆盖次方法

 @return writeUUID
 */
-(NSString*)getWriteUUID {
    return @"AE01";
}

/**
 获取通知数据UUID 子类需覆盖次方法

 @return writeUUID
 */
-(NSString*)getNotifiUUID {

    return @"AE02";
}


-(NSString *)getBroadcastServiceUUID{
    return @"AE30";
}

- (NSArray *)deviceName{
    return @[@"M8001-A",@"M8001-C",@"M8001-B"];
}


-(void)sendPowerToDevice:(Boolean)power{
    NSMutableString *sendDataString =[NSMutableString string];
    
    [sendDataString appendString:@"AAF1"];
    [sendDataString appendString:[BaseUtils stringConvertForByte:power]];
    [sendDataString appendString:[self appendZeroString:sendDataString]];
    [sendDataString appendString:@"FF"];
    NSData *sendData=[BaseUtils stringToBytes:sendDataString];
    [self sendCommand:sendData notifyBlock:^(NSData *data, NSString *stringData) {
        
    } filterBlock:^NSString *{
        return @"";
    }];
}

-(void)sendRGBToDevice:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue{
    NSMutableString *sendDataString =[NSMutableString string];
    
    [sendDataString appendString:@"AAF2"];
    [sendDataString appendString:[BaseUtils stringConvertForByte:red]];
    [sendDataString appendString:[BaseUtils stringConvertForByte:green]];
    [sendDataString appendString:[BaseUtils stringConvertForByte:blue]];
    [sendDataString appendString:[self appendZeroString:sendDataString]];
    [sendDataString appendString:@"FF"];
    NSData *sendData=[BaseUtils stringToBytes:sendDataString];
    [self sendCommand:sendData notifyBlock:^(NSData *data, NSString *stringData) {
        
    } filterBlock:^NSString *{
        return @"";
    }];
}

-(NSString *)appendZeroString:(NSString *)content{
    NSMutableString *string=[NSMutableString string];
    

    for (int i=0; i<20-content.length; i++) {
        [string appendString:@"0"];
    }
    return string;
}

@end
