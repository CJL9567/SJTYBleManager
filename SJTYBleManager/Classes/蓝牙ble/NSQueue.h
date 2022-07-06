//
//  NSQueue.h
//  蓝牙灯
//
//  Created by sjty on 2018/6/8.
//  Copyright © 2018年 sjty. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSQueue : NSObject  {
    NSMutableArray *queue;
}

@property (nonatomic, retain) NSMutableArray *queue;    // The queue array

- (NSInteger)size;                        // Get size of queue
- (void)printQueue;                 // Print queue to logs
- (void)enqueue:(id)object;  // Enqueue object in queue
- (void)clearQueue;                 // Clears the queue of all objects
- (id)dequeue;                      // Dequeue object from queue
- (BOOL)isEmpty;                    // Check if queue is empty

@end
