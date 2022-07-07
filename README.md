# SJTYBleManager

[![CI Status](https://img.shields.io/travis/caijialiang/SJTYBleManager.svg?style=flat)](https://travis-ci.org/caijialiang/SJTYBleManager)
[![Version](https://img.shields.io/cocoapods/v/SJTYBleManager.svg?style=flat)](https://cocoapods.org/pods/SJTYBleManager)
[![License](https://img.shields.io/cocoapods/l/SJTYBleManager.svg?style=flat)](https://cocoapods.org/pods/SJTYBleManager)
[![Platform](https://img.shields.io/cocoapods/p/SJTYBleManager.svg?style=flat)](https://cocoapods.org/pods/SJTYBleManager)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
    1、创建继承 BaseBleDevice 的设备对象,例如TreeBleDevice,并赋值给[BleManager shareManager].baseBleDevice
    
    [BleManager shareManager].baseBleDevice=[[TreeBleDevice alloc] initWithBluetooth];
    [BleManager shareManager].isMultiple=NO;
    [[BleManager shareManager] setFilterByName:YES];
    [BleManager shareManager].mutipleClass=@"TreeBleDevice";
    [BleManager shareManager].autoConnected=YES;
    [[BleManager shareManager] scanDevice];
    2、实现BleManager 相对应回调
    例如 [BleManager shareManager].setReloadBlock:^(CBPeripheral * _Nonnull peripheral) {}];
    
    详情查看示例代码Example

## Installation

SJTYBleManager is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SJTYBleManager'
```

## Author



## License

SJTYBleManager is available under the MIT license. See the LICENSE file for more info.
