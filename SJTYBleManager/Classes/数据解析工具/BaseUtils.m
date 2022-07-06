//
//  BaseUtils.m
//  BLEBracelet
//
//  Created by sjty on 14-6-26.
//  Copyright (c) 2014年 蒋顺成. All rights reserved.
//

#import "BaseUtils.h"

@implementation BaseUtils
@synthesize vibrationTimer;

+(UIColor *)colorWithHexColorString:(NSString *)hexColorString{
    if ([hexColorString length] <6){//长度不合法
        return [UIColor blackColor];
    }
    NSString *tempString=[hexColorString lowercaseString];
    if ([tempString hasPrefix:@"0x"]){//检查开头是0x
        tempString = [tempString substringFromIndex:2];
    }else if ([tempString hasPrefix:@"#"]){//检查开头是#
        tempString = [tempString substringFromIndex:1];
    }
    if ([tempString length] !=6){
        return [UIColor blackColor];
    }
    //分解三种颜色的值
    NSRange range;
    range.location =0;
    range.length =2;
    NSString *rString = [tempString substringWithRange:range];
    range.location =2;
    NSString *gString = [tempString substringWithRange:range];
    range.location =4;
    NSString *bString = [tempString substringWithRange:range];
    //取三种颜色值
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString]scanHexInt:&r];
    [[NSScanner scannerWithString:gString]scanHexInt:&g];
    [[NSScanner scannerWithString:bString]scanHexInt:&b];
    return [UIColor colorWithRed:((float) r /255.0f)
                           green:((float) g /255.0f)
                            blue:((float) b /255.0f)
                           alpha:1.0f];
}
/**
 一个字节十六进制转换成十进制
 */
+(NSString *)stringForData:(NSData *)data{
    if (data) {
        uint8_t* a = (uint8_t*) [data bytes];
        if(a){
            NSString *str=[NSString stringWithFormat:@"%d",*a];
            return str;
        }
    }
    return @"";
}

//string 转 NSData
+ (NSData*) stringToBytes:(NSString *) string {
    NSMutableData *data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2<=string.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [string substringWithRange:range];
         NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
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
/**
 * Byte转换成16进制数字字符串
 **/
+(NSString *)stringConvertForByte:(Byte) data{
    NSString *newHexStr = [NSString stringWithFormat:@"%x",data&0xff];///16进制数
    
    NSString *hexStr=@"";
    if([newHexStr length]==1)
        hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
    else
        hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    return hexStr;
}
/**
 *2个字节转化转换成16进制
 **/
+(NSString *)stringConvertForShort:(UInt16) data{
    NSString *newHexStr = [NSString stringWithFormat:@"%x",data&0xffff];///16进制数
    
    NSString *hexStr=@"";
    if([newHexStr length]==3) {
        hexStr = [NSString stringWithFormat:@"0%@",newHexStr];
    } else if([newHexStr length]==2) {
        hexStr = [NSString stringWithFormat:@"00%@",newHexStr];
    } else if([newHexStr length]==1) {
        hexStr = [NSString stringWithFormat:@"000%@",newHexStr];
    } else {
        hexStr = [NSString stringWithFormat:@"%@",newHexStr];
    }
    return hexStr;
    
}
+ (NSString *)stringConvertForInt:(UInt32)data{
    NSString *newHexStr = [NSString stringWithFormat:@"%x",data&0xffffffff];///16进制数
    
    NSString *hexStr=@"";
    if([newHexStr length]==7) {
        hexStr = [NSString stringWithFormat:@"0%@",newHexStr];
    } else if([newHexStr length]==6) {
        hexStr = [NSString stringWithFormat:@"00%@",newHexStr];
    }
    else if([newHexStr length]==5) {
        hexStr = [NSString stringWithFormat:@"000%@",newHexStr];
    }
    else if([newHexStr length]==4) {
        hexStr = [NSString stringWithFormat:@"0000%@",newHexStr];
    }
    else if([newHexStr length]==3) {
        hexStr = [NSString stringWithFormat:@"00000%@",newHexStr];
    }
    else if([newHexStr length]==2) {
        hexStr = [NSString stringWithFormat:@"000000%@",newHexStr];
    }
    else if([newHexStr length]==1) {
        hexStr = [NSString stringWithFormat:@"0000000%@",newHexStr];
    }
    else {
        hexStr = [NSString stringWithFormat:@"%@",newHexStr];
    }
    return hexStr;
}










/**
     *
     * @param data 数据
     * @param digitHex 处理16进制位数
     * @param symbol 是否带符号
     * @return
     */
+(NSString *) highToLow:(int)  data digitHex:(int)digitHex symbol:(Boolean)symbol{
        if(digitHex > 4){
//            throw new RuntimeException("digitHex最大值为4");
            return @"digitHex最大值为4";
        }

//        int[] bytes = new int[4];
        Byte bytes[4];
        for(int i = 0 ; i < digitHex; i++){
            bytes[i] = (data >> (i*8))&0xFF;
        }

        int re = 0;
        for(int i = 0 ; i <digitHex ; i++){
            re = re | (bytes[i]<< ((digitHex - 1 - i)*8));
        }
        if(symbol){
            int symbolI = data >> 31 << (digitHex*8-1);
            re = re|symbolI;
        }
//        return BaseUtils ten2HexStr(re,digitHex);
    NSString *string=[BaseUtils ten2HexStr:re digitHex:digitHex];
    return [BaseUtils ten2HexStr:re digitHex:digitHex];
    }

    /**
     * 十进制转换为16进制字符串
     * @param ten
     * @param digitHex 处理16进制位数
     * @return
     */
+(NSString *)ten2HexStr:(int)ten digitHex:(int )digitHex{
        if(digitHex > 4){
            return @"digitHex最大值为4";
        }
        NSString *hex =  @"";
        if(digitHex == 1) {
            hex = [NSString stringWithFormat:@"%x",ten&0xff];
            
        }else if(digitHex == 2) {
            hex = [NSString stringWithFormat:@"%x",ten&0xffff];
        }else if(digitHex == 3) {
            hex = [NSString stringWithFormat:@"%x",ten&0xffFFFF];
        }else if(digitHex == 4) {
            hex = [NSString stringWithFormat:@"%x",ten&0xffffffff];
        }

        int appedleng = digitHex * 2 - hex.length;

        for(int i = 0 ; i < appedleng ; i++){
            hex =[NSString stringWithFormat:@"0%@",hex];
        }
        return hex;
    }


/**
 * NSData转换成16进制数字字符串
 **/
+(NSString *)getPassword:(NSData *) data{
    Byte *bytes = (Byte *)[data bytes];
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++){
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

//十六进制字符串转换成十进制数值
+(int) intConvertForHexString:(NSString *) hexString{
    int value;
    const char *hexChar = [hexString cStringUsingEncoding:NSASCIIStringEncoding];
    sscanf(hexChar,"%x",&value);
    return value;
}
+(Byte) byteConvertForHexString:(NSString *)hexString{
    int value;
    const char *hexChar = [hexString cStringUsingEncoding:NSASCIIStringEncoding];
    sscanf(hexChar,"%x",&value);
    return value & 0xff;
}

//NSData转换成十进制数值
+(int) intConvertForData:(NSData *) data{
    NSString *hexString = [self stringConvertForData:data];
    return [self intConvertForHexString:hexString];
}


//把对象放入NSUserDefaults
+(void) setUserDefaultWithKey:(id) obj key:(NSString *)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:obj forKey:key];
    [defaults synchronize];
}
//从NSUserDefaults取出对象
+(id) getUserDefaultWithKey:(NSString *) key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id obj = [defaults objectForKey:key];
    [defaults synchronize];
    return obj;
}

+(void) clearUserDefaultWithKey:(NSString *) key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:key];
    [defaults synchronize];
}


+(int)getRandomNumber:(int)from to:(int)to{
    
    return (int)(from + (arc4random() % (to - from + 1)));
}


+(void)showTextFiledAlertDialgo:(NSString*)message
                          title:(NSString*)title
                             ok:(NSString*)ok
                         cancel:(NSString*)cancel
                       isNumber:(BOOL)isNumber
                   ofController:(UIViewController*)controller
                     holderText:(NSString*)holderText
                          block:(void(^)(NSString*text))block{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:ok style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField *field = alert.textFields[0];
        if (field) {
           block(field.text);
        }
 
    }];
    
    [alert addAction:okAction];
    UIAlertAction * cancleAction = [UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancleAction];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        if (isNumber) {
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }
        textField.placeholder = holderText;
        
    }];
    [controller presentViewController:alert animated:YES completion:nil];
    
}

+(NSString *)getMacString:(NSString *) mac{
    NSMutableString *string = [NSMutableString string];
    
    NSLog(@"====>%@,",mac);
    [string appendString:[mac substringWithRange:NSMakeRange(0, 2)]];
    [string appendString:@":"];
    
    [string appendString:[mac substringWithRange:NSMakeRange(2, 2)]];
    [string appendString:@":"];


    [string appendString:[mac substringWithRange:NSMakeRange(4, 2)]];
    [string appendString:@":"];


    [string appendString:[mac substringWithRange:NSMakeRange(6, 2)]];
    [string appendString:@":"];

    [string appendString:[mac substringWithRange:NSMakeRange(8, 2)]];
    [string appendString:@":"];
    [string appendString:[mac substringWithRange:NSMakeRange(10, 2)]];
    return string;
}

+(NSString *)arrayToJSONString:(NSMutableArray *)array {
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}
+(NSString *)binaryToHex:(NSString *)hex
{
    NSMutableDictionary  *hexDic = [[NSMutableDictionary alloc] init];
    
    hexDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    
    [hexDic setObject:@"0000" forKey:@"0"];
    
    [hexDic setObject:@"0001" forKey:@"1"];
    
    [hexDic setObject:@"0010" forKey:@"2"];
    
    [hexDic setObject:@"0011" forKey:@"3"];
    
    [hexDic setObject:@"0100" forKey:@"4"];
    
    [hexDic setObject:@"0101" forKey:@"5"];
    
    [hexDic setObject:@"0110" forKey:@"6"];
    
    [hexDic setObject:@"0111" forKey:@"7"];
    
    [hexDic setObject:@"1000" forKey:@"8"];
    
    [hexDic setObject:@"1001" forKey:@"9"];
    
    [hexDic setObject:@"1010" forKey:@"A"];
    
    [hexDic setObject:@"1011" forKey:@"B"];
    
    [hexDic setObject:@"1100" forKey:@"C"];
    
    [hexDic setObject:@"1101" forKey:@"D"];
    
    [hexDic setObject:@"1110" forKey:@"E"];
    
    [hexDic setObject:@"1111" forKey:@"F"];
    
    NSString *binaryString=[[NSString alloc] init];
    hex = [hex uppercaseString];
    
    for (int i=0; i<[hex length]; i++) {
        
        NSRange rage;
        
        rage.length = 1;
        
        rage.location = i;
        
        NSString *key = [hex substringWithRange:rage];
        
        //NSLog(@"%@",[NSString stringWithFormat:@"%@",[hexDic objectForKey:key]]);
        
        binaryString = [NSString stringWithFormat:@"%@%@",binaryString,[NSString stringWithFormat:@"%@",[hexDic objectForKey:key]]];
        
    }
    
    //NSLog(@"转化后的二进制为:%@",binaryString);
    
    return binaryString;
    
}
+ (UInt16)highAndLowToChanage:(UInt16)data {
    UInt8 l_b = data & 0xff;//低8位
    
    UInt8 h_b = (data >> 8) & 0xff;//高8位
    
    UInt16 newValue = 0x0000;
    newValue = l_b | newValue;
    newValue = (newValue << 8) | h_b;
    
    return newValue;
}

+ (UInt32)highAndLowToChanageOf32:(UInt32)data {
    
    return ((data & 0xff) << 24) | (((data >> 8 ) & 0xff) << 16) |
    (((data >> 16) & 0xff) << 8) | ((data >> 24) & 0xff);
}
+(NSString*)getDoubleString:(NSString*)string {
    if (string.length ==1) {
        return [NSString stringWithFormat:@"0%@",string];
    }
    return string;
}

+ (NSMutableString*)arrayToString:(NSArray*)groudIds {
    NSMutableString* string = [NSMutableString string];
    
    for (int i = 0; i < groudIds.count; i++) {
        NSString* obj = groudIds[i];
        [string appendString:obj];
        if (i < groudIds.count - 1) {
            [string appendString:@","];
        }
    }
    return string;
}

+ (NSArray*)stringToArray:(NSString*)string {
    NSArray* array =  [string componentsSeparatedByString:@","];
    
    return array;
}

/**
 二进制转换为十进制
 
 @param binary 二进制数
 @return 十进制数
 */
+ (NSInteger)getDecimalByBinary:(NSString *)binary {
    
    NSInteger decimal = 0;
    for (int i=0; i<binary.length; i++) {
        
        NSString *number = [binary substringWithRange:NSMakeRange(binary.length - i - 1, 1)];
        if ([number isEqualToString:@"1"]) {
            
            decimal += pow(2, i);
        }
    }
    return decimal;
}

@end
