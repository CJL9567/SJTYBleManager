//
//  SJTYBLESecret.m
//  TestApp
//
//  Created by sjty on 2022/12/15.
//

#import "SJTYBLESecret.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

Byte Secret[] ={0xBA, 0x78, 0x16,0xCF,0x8F, 0x01, 0xCF, 0xEA,0x41,0x41,0x40,0xDE,
    0x5D,0xAE,0x22,0x23,0xB0,0x03,0x61,0xA3,0x96,0x17,0x7B,0x9C,0xB4,0x10,0xFF,
    0x61,0xF2,0x00,0x15,0xAD};

@implementation SJTYBLESecret


+(NSData *)secrect:(NSData *)data{

    NSData *resultData= [SJTYBLESecret yihuo:(Byte *)[data bytes]];
    NSData *secrectKeyData= [NSData dataWithBytes:Secret length:32];
    NSMutableData * secrectData=  [NSMutableData data];
    [secrectData appendData:data];
    [secrectData appendData:resultData];
    [secrectData appendData:secrectKeyData];
    NSData *sha256Data=  [SJTYBLESecret sha256Data:secrectData];

    return sha256Data;
}



/**
 * NSData转换成16进制数字字符串
 **/
+(NSString *)stringConvertForData:(NSData *) data{
    Byte *bytes = (Byte *)[data bytes];
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++){
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

+ (NSData  *)sha256Data:(NSData *)srcData {
    NSData *data = srcData;
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (CC_LONG)data.length, digest);
    NSData *adata = [[NSData alloc] initWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    return adata;

}


+(NSData * )yihuo:(Byte *)byte{
    Byte yihuoResult[8];
    
    yihuoResult[0]=byte[0]^(0xff);
    yihuoResult[1]=byte[1]^(0xff);
    yihuoResult[2]=byte[2]^(0xff);
    yihuoResult[3]=byte[3]^(0xff);
    yihuoResult[4]=byte[4]^(0xff);
    yihuoResult[5]=byte[5]^(0xff);
    yihuoResult[6]=byte[6]^(0xff);
    yihuoResult[7]=byte[7]^(0xff);
    
    return [NSData dataWithBytes:yihuoResult length:8];
    
}



@end




