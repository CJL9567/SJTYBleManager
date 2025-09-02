//
//  TreeBleDevice.h
//  M8001
//
//  Created by sjty on 2022/6/9.
//

#import "BaseBleDevice.h"

NS_ASSUME_NONNULL_BEGIN

@interface TreeBleDevice : BaseBleDevice

-(void)sendPowerToDevice:(Boolean)power;

-(void)sendRGBToDevice:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue;
-(void)sendModeToBigDataDevice:(NSInteger)value;

@end

NS_ASSUME_NONNULL_END
