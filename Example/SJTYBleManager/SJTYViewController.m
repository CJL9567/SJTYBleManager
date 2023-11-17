//
//  SJTYViewController.m
//  SJTYBleManager
//
//  Created by caijialiang on 07/06/2022.
//  Copyright (c) 2022 caijialiang. All rights reserved.
//

#import "SJTYViewController.h"
#import <SJTYBleManager/SJTYBleManager.h>
#import "TreeBleDevice.h"
//#import "JLOTAManager.h"
#import "BleDevice.h"
@interface SJTYViewController ()
<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation SJTYViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self setupUI];
//    [BleManager shareManager].baseBleDevice=[[TreeBleDevice alloc] initWithBluetooth];
//    [BleManager shareManager].isMultiple=NO;
//    [[BleManager shareManager] setFilterByName:YES];
////    [[BleManager shareManager] setFilterByUUID:YES];
//    [BleManager shareManager].mutipleClass=@"TreeBleDevice";
////    [BleManager shareManager].autoConnected=YES;
//    [[BleManager shareManager] scanDevice];
//    [BleManager shareManager].isVerify = NO;
//    [self babyDelegate];
    

    [self babyDelegate];
    [self initBle];
}

-(void)initBle{
[BleManager shareManager].baseBleDevice = [[BleDevice alloc] initWithBluetooth];

[BleManager shareManager].isVerify =NO;
[BleManager shareManager].autoConnected=NO;
[[BleManager shareManager] setFilterByName:YES];
[[BleManager shareManager] scanDevice];

}

-(void)setupUI{
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
}


-(void)babyDelegate{
    
    __weak typeof(self)weakSelf=self;
    [[BleManager shareManager] setReloadAdvDataBlock:^(CBPeripheral * _Nonnull peripheral, NSString * _Nonnull peripheralName, NSData * _Nonnull advDataManufacturerData) {
        Byte *byte = (Byte *)[advDataManufacturerData bytes];
        if(advDataManufacturerData.length==15){
            
//            if(byte[0]==0xc0 && ((byte[6]<<8)|byte[7])==2){
//                NSInteger weight = (byte[2])<<8|byte[3];
//                NSInteger status= byte[8];
//                NSString *binary =   [BaseUtils binaryToHex:[BaseUtils stringConvertForByte:status]];
//                NSLog(@"=======%@",[binary substringWithRange:NSMakeRange(7, 1)]);
//            }
            
        }
        

    }];
    
    [[BleManager shareManager] setReloadBlock:^(CBPeripheral * _Nonnull peripheral, NSString * _Nonnull peripheralName, NSData * _Nonnull advDataManufacturerData) {
//        if ([peripheralName containsString:@"FSRKB"]) {
//            if(advDataManufacturerData!=nil){
//                NSLog(@"");
//            }
//        }
        
//        if(![BleManager shareManager].isConnected){
//            [[BleManager shareManager] connectedCBPeripheral:peripheral timeOut:10];
//        }
        [weakSelf.tableView reloadData];
//        if (weakSelf.connectIndex==0) {
//            [[BleManager shareManager] connectedCBPeripheral:peripheral];
//        }
//        if(![BleManager shareManager].isConnected){
//            [[BleManager shareManager] connectedCBPeripheral:peripheral];
//        }
    
    }];
    
    

    [[BleManager shareManager] setConnectedBlock:^(NSString * _Nonnull UUID) {
//        if (![BleManager shareManager].isMultiple) {
//            TreeBleDevice *treeBleDevice=(TreeBleDevice *)[BleManager shareManager].baseBleDevice;
////            [treeBleDevice sendRGBToDevice:255 green:0 blue:0];
//        }
//        else{
//            for (TreeBleDevice *treeBleDevice in [BleManager shareManager].multipleArray) {
//                
//                if ([treeBleDevice.activityCBPeripheral.identifier.UUIDString isEqualToString:UUID]) {
//                    [treeBleDevice sendRGBToDevice:255 green:0 blue:0];
//                    break;
//                }
//            }
//        }
        
        [weakSelf.tableView reloadData];

    }];

    [[BleManager shareManager] setDisConnectedBlock:^(CBPeripheral * _Nonnull peripheral) {

    }];
    

    [[BleManager shareManager] setAutoDisConnectedBlock:^(CBPeripheral * _Nonnull peripheral) {

    }];
    
    [[BleManager shareManager] setConnectTimeOutBlock:^{
        [weakSelf.tableView reloadData];
    }];

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [BleManager shareManager].peripheralArray.count;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];

    if (!cell) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }


    CBPeripheral *peripheral=[BleManager shareManager].peripheralArray[indexPath.row];

    if (peripheral.state==CBPeripheralStateConnected) {
        cell.detailTextLabel.text=@"已连接";
    }else{
        cell.detailTextLabel.text=@"";
    }
    NSDictionary *dict=[BleManager shareManager].peripheralDataArray[indexPath.row];
    cell.textLabel.text= [dict valueForKey:@"peripheralName"];
    cell.detailTextLabel.textColor=[UIColor darkGrayColor];

    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CBPeripheral *peripheral=[BleManager shareManager].peripheralArray[indexPath.row];

    
    if(peripheral.state!=CBPeripheralStateConnected){
        [[BleManager shareManager] connectedCBPeripheral:peripheral];
    }
}

- (IBAction)refreshAction:(id)sender {
    __weak typeof(self )weakSelf= self;
//    BleDevice *bleDevice =(BleDevice *) [BleManager shareManager].baseBleDevice;
//    [bleDevice sendFileData: [[NSBundle mainBundle] pathForResource:@"water" ofType:@"mp3"] progress:^(float progress) {
//        NSLog(@"====%f",progress);
//        if(progress==1){
//            [bleDevice sendFinish];
//        }
////        weakSelf.progressLabel.text = [NSString stringWithFormat:@"=====%f",progress];
//    }];
//    self.connectIndex=0;
//    [[BleManager shareManager] disConnectAllPeripheral];
    
    [[BleManager shareManager] refresh];
////    [[BleManager shareManager].peripheralDataArray removeAllObjects];
////    [[BleManager shareManager].multipleArray removeAllObjects];
//    [self.tableView reloadData];
    
}
- (IBAction)disconnect:(id)sender {
//    self.connectIndex=0;
//    [[BleManager shareManager].peripheralDataArray removeAllObjects];
//    [[BleManager shareManager].multipleArray removeAllObjects];
//    [self.tableView reloadData];
//    [[BleManager shareManager] disConnectAllPeripheral];
//    CBPeripheral *peripheral=[BleManager shareManager].peripheralArray[1];

    [[BleManager shareManager] disConnectAllPeripheral];
}

@end
