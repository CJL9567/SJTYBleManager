//
//  BKOTAManager.h
//  SJTYBleManager
//
//  Created by sjty on 2024/1/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BKOTAManager : NSObject

@property(assign,nonatomic)NSInteger index;
-(instancetype)initWithOTAFilePath:(NSString *)filePath;

-(NSInteger)getType;

-(NSInteger) getVersion;

-(NSInteger)getRomVersion;

-(Byte *)getBytes;

-(NSInteger)getBlockCount;

-(NSData *)getData;
@end

NS_ASSUME_NONNULL_END
