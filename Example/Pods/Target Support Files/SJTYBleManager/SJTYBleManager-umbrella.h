#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "BabyBluetooth.h"
#import "BabyCallback.h"
#import "BabyCentralManager.h"
#import "BabyDefine.h"
#import "BabyOptions.h"
#import "BabyPeripheralManager.h"
#import "BabyRhythm.h"
#import "BabySpeaker.h"
#import "BabyToy.h"
#import "SJTYBleManager.h"
#import "BaseUtils.h"
#import "BaseBleDevice+BK3432.h"
#import "BaseBleDevice.h"
#import "BKOTAManager.h"
#import "BleManager.h"
#import "NSQueue.h"
#import "SJTYBLESecret.h"

FOUNDATION_EXPORT double SJTYBleManagerVersionNumber;
FOUNDATION_EXPORT const unsigned char SJTYBleManagerVersionString[];

