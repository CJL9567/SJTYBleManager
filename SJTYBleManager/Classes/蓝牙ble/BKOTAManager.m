//
//  BKOTAManager.m
//  SJTYBleManager
//
//  Created by sjty on 2024/1/15.
//

#import "BKOTAManager.h"


@interface BKOTAManager()

@property(nonatomic,strong)NSData *otaData;
@property(nonatomic,assign)NSInteger fileType;
@property(assign,nonatomic)NSInteger version;
@property(assign,nonatomic)NSInteger romVersion;
@property(assign,nonatomic)NSInteger blockCount;

@end

@implementation BKOTAManager




-(instancetype)initWithOTAFilePath:(NSString *)filePath{
    if (self==[super init]) {
        self.otaData=[NSData dataWithContentsOfFile:filePath];

        [self getFileInfo:(Byte *)[self.otaData bytes]];
        
        NSLog(@" Bin 文件类型%ld Version %ld RomVersion %ld",[self getFileType:(Byte *)[self.otaData bytes]],self.version,self.romVersion);
        self.index=0;
        
    }
    return self;
}



/**

 * BIN文件类型

 * @param fileBytes
 *  return 1：部分升级文件 2：全量升级文件 0：不是升级文件
 */
-(NSInteger)getFileType:(Byte *)fileBytes{
    
    if((fileBytes[8] == 0x42) && (fileBytes[9] == 0x42) && (fileBytes[10] == 0x42) && (fileBytes[11] == 0x42)){
        return 1;

    }else  if((fileBytes[8] == 0x53) && (fileBytes[9] == 0x53) && (fileBytes[10] == 0x53) && (fileBytes[11] == 0x53)){
        return 2;
    }else{
        return 0;
    }
}


-(void)getFileInfo:(Byte *)byte{
    self.version=(byte[5]<<8)|byte[4];
    self.romVersion=(byte[15]<<8)|byte[14];
    self.blockCount=((byte[7]<<8)|byte[6])/(16/4);
    NSLog(@"");
}


-(NSInteger)getType{
//    1：部分升级文件 2：全量升级文件 0：不是升级文件
    return [self getFileType:(Byte *)[self.otaData bytes]];
}


-(NSInteger) getVersion{
    return self.version;
}


-(NSInteger)getRomVersion{
    return self.romVersion;
}


-(Byte *)getBytes{
    return (Byte *)[self.otaData bytes];
}

-(NSData *)getData{
    return self.otaData;
}


-(NSInteger)getBlockCount{
    return self.blockCount;
}

@end
