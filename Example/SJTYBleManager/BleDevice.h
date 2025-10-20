//
//  BleDevice.h
//  TestApp
//
//  Created by sjty on 2023/7/6.
//

#import <SJTYBleManager/SJTYBleManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface BleDevice : BaseBleDevice

-(void)sendModeToBigDataDevice:(NSInteger)value;

//-(void)sendFileName:(NSString *)fileName;
-(void)lightDeviceHue:(NSInteger)hue saturation:(NSInteger)saturation;
-(void)lightDeviceMode:(NSInteger)lightMode;
-(void)sendFileData:(NSString *)filePath progress:(void(^)(float progress)) block;
-(void)sendFinish;
-(void)sendFileData1:(NSString *)filePath progress:(void(^)(float progress)) block;

-(void)sendStartToDevice:(void(^)(Boolean sucess))block;
@end

NS_ASSUME_NONNULL_END
