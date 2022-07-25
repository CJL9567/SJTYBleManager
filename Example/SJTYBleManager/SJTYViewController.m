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
@interface SJTYViewController ()
<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation SJTYViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self setupUI];
    [BleManager shareManager].baseBleDevice=[[TreeBleDevice alloc] initWithBluetooth];
    [BleManager shareManager].isMultiple=NO;
//    [[BleManager shareManager] setFilterByName:YES];
    [[BleManager shareManager] setFilterByUUID:YES];
    [BleManager shareManager].mutipleClass=@"TreeBleDevice";
//    [BleManager shareManager].autoConnected=YES;
    [[BleManager shareManager] scanDevice];

    [self babyDelegate];
    
}

-(void)setupUI{
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
}


-(void)babyDelegate{

    __weak typeof(self)weakSelf=self;
    [[BleManager shareManager] setReloadBlock:^(CBPeripheral * _Nonnull peripheral) {
//        if (weakSelf.connectIndex==0) {
//            [[BleManager shareManager] connectedCBPeripheral:peripheral];
//        }
        [weakSelf.tableView reloadData];
    }];

    [[BleManager shareManager] setConnectedBlock:^(NSString * _Nonnull UUID) {
        if (![BleManager shareManager].isMultiple) {
            TreeBleDevice *treeBleDevice=(TreeBleDevice *)[BleManager shareManager].baseBleDevice;
            [treeBleDevice sendRGBToDevice:255 green:0 blue:0];
        }else{
            for (TreeBleDevice *treeBleDevice in [BleManager shareManager].multipleArray) {
                
                if ([treeBleDevice.activityCBPeripheral.identifier.UUIDString isEqualToString:UUID]) {
                    [treeBleDevice sendRGBToDevice:255 green:0 blue:0];
                    break;
                }
            }
        }
        
        [weakSelf.tableView reloadData];

    }];

    [[BleManager shareManager] setDisConnectedBlock:^(CBPeripheral * _Nonnull peripheral) {

    }];
    

    [[BleManager shareManager] setAutoDisConnectedBlock:^(CBPeripheral * _Nonnull peripheral) {

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

    [[BleManager shareManager] connectedCBPeripheral:peripheral];
}

- (IBAction)refreshAction:(id)sender {
//    self.connectIndex=0;
//    [[BleManager shareManager] disConnectAllPeripheral];
    
    [[BleManager shareManager] refresh];
//    [[BleManager shareManager].peripheralDataArray removeAllObjects];
//    [[BleManager shareManager].multipleArray removeAllObjects];
    [self.tableView reloadData];
    
}
- (IBAction)disconnect:(id)sender {
//    self.connectIndex=0;
//    [[BleManager shareManager].peripheralDataArray removeAllObjects];
//    [[BleManager shareManager].multipleArray removeAllObjects];
//    [self.tableView reloadData];
//    [[BleManager shareManager] disConnectAllPeripheral];
    CBPeripheral *peripheral=[BleManager shareManager].peripheralArray[1];

    [[BleManager shareManager] disConnectPeripheral:peripheral];
}

@end
