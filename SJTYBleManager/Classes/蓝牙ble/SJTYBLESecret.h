//
//  SJTYBLESecret.h
//  TestApp
//
//  Created by sjty on 2022/12/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SJTYBLESecret : NSObject

+(NSData *)secrect:(NSData *)data;
+(NSString *)stringConvertForData:(NSData *) data;

@end

NS_ASSUME_NONNULL_END
