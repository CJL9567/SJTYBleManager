//
//  NSQueue.m
//  蓝牙灯
//
//  Created by sjty on 2018/6/8.
//  Copyright © 2018年 sjty. All rights reserved.
//

#import "NSQueue.h"

@implementation NSQueue

@synthesize queue;

- (NSInteger)size
{
    return [queue count];
}

- (void)printQueue
{
    if([queue count] == 0)
    {
        NSLog(@"Queue is empty! Cannot print.");
    }
    else
    {
        for(int i=0;i<[queue count]; i++)
        {
            NSLog(@"Object at index %d is: %@", i, [queue objectAtIndex:i]);
        }
    }
}

- (void)clearQueue
{
    [queue removeAllObjects];
}

- (void)enqueue:(id)object
{
    if([queue count] == 0)
    {
        queue = [[NSMutableArray alloc] init];
    }
    
    [queue addObject:object];
}

- (id)dequeue
{
    if([queue count] != 0)
    {
        // Get the object at index 0
        id object = [queue objectAtIndex:0];
        
        // Remove the object from index 0
        [queue removeObjectAtIndex:0];
        
        // Return the object
        return object;
    }
    else
    {
        return nil;
    }
}

- (BOOL)isEmpty {
    
    if([queue count] == 0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
    
}

@end
