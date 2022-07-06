//
//  BaseUtils.h
//  BLEBracelet
//
//  Created by sjty on 14-6-26.
//  Copyright (c) 2014年 蒋顺成. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface BaseUtils : NSObject{
    
}

@property(nonatomic,retain) NSTimer *vibrationTimer;

+(UIColor *)colorWithHexColorString:(NSString *)hexColorString;

+(NSString *)stringForData:(NSData *)data;

+ (NSData*) stringToBytes:(NSString *) string ;


+(NSString*)getPassword:(NSData*) data;

/**
 * Byte转换成16进制数字字符串
 **/
+(NSString *)stringConvertForByte:(Byte) data;

/**
 *2个字节转化转换成16进制
 **/
+(NSString *)stringConvertForShort:(UInt16) data;


/**
 *4个字节转化转换成16进制
 **/
+(NSString *)stringConvertForInt:(UInt32) data;

/**
 * NSData转换成16进制数字字符串
 **/
+(NSString *)stringConvertForData:(NSData *) data;
//十六进制字符串转换成十进制数值
+(int) intConvertForHexString:(NSString *) hexString;
//NSData转换成十进制数值
+(int) intConvertForData:(NSData *) data;

+(Byte) byteConvertForHexString:(NSString *)hexString;

//把对象放入NSUserDefaults
+(void) setUserDefaultWithKey:(id) obj key:(NSString *)key;

//从NSUserDefaults取出对象
+(id) getUserDefaultWithKey:(NSString *) key;

+(void) clearUserDefaultWithKey:(NSString *) key;

+(void)showAlertDialog:(NSString *) message
                 title:(NSString *)title
          ofController:(UIViewController *) controller;
//获取某个两个值范围的随数
+(int)getRandomNumber:(int)from to:(int)to;

+(void)showAlertDialog:(NSString *) message
                 title:(NSString *)title
          ofController:(UIViewController *) controller
                 block:(void(^)()) block;

+(void)showTextFiledAlertDialgo:(NSString*)message
                          title:(NSString*)title
                             ok:(NSString*)ok
                         cancel:(NSString*)cancel
                       isNumber:(BOOL)isNumber
                   ofController:(UIViewController*)controller
                     holderText:(NSString*)holderText
                          block:(void(^)(NSString*text))block;


+(NSString *)getMacString:(NSString *) mac;

+(NSString *)arrayToJSONString:(NSMutableArray *)array;


/**
 16进制转二进制

 @param hex 16进制字符串
 @return 二进制字符串
 */
+(NSString *)binaryToHex:(NSString *)hex;

+ (UInt16)highAndLowToChanage:(UInt16)data;

+(UInt32)highAndLowToChanageOf32:(UInt32)data;


+(NSString*)getDoubleString:(NSString*)string;

+ (NSMutableString*)arrayToString:(NSArray*)groudIds;

+ (NSArray*)stringToArray:(NSString*)string;


+(NSString *) highToLow:(int)  data digitHex:(int)digitHex symbol:(Boolean)symbol;

/**
 二进制转换为十进制
 
 @param binary 二进制数
 @return 十进制数
 */
+ (NSInteger)getDecimalByBinary:(NSString *)binary;


@end
