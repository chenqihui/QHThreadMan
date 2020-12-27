//
//  QHGCDThread.m
//  QHThreadDemo
//
//  Created by Anakin chen on 2020/12/7.
//


/*
 * [iOS开发中的11种锁以及性能对比 - 简书](https://www.jianshu.com/p/b1edc6b0937a)
 * [GCD信号量-dispatch_semaphore_t - 简书](https://www.jianshu.com/p/24ffa819379c)
*/

#import "QHGCDThread.h"

@implementation QHGCDThread

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)runThread {
    @autoreleasepool {
        self.func();
    }
}

+ (instancetype)createThread:(const char *_Nullable)label block:(thread_block_t)block {
    QHGCDThread *this = [QHGCDThread new];
    this.queue = dispatch_queue_create(label, NULL);
    this.func = block;
    dispatch_async(this.queue, ^{
        [this runThread];
    });
    return this;
}

@end

@implementation QHGCDMutex

- (void)dealloc {
    NSLog(@"%s", __func__);
}

+ (instancetype)create {
    QHGCDMutex *this = [QHGCDMutex new];
    this.lockMutex = dispatch_semaphore_create(1);
    return this;
}

- (void)lock {
    dispatch_semaphore_wait(_lockMutex, DISPATCH_TIME_FOREVER);
}

- (void)unlock {
    dispatch_semaphore_signal(_lockMutex);
}

@end

@implementation QHGCDCond

- (void)dealloc {
    NSLog(@"%s", __func__);
}

+ (instancetype)create {
    QHGCDCond *this = [QHGCDCond new];
    this.lockCond = dispatch_semaphore_create(0);
    return this;
}

- (void)waitTimeout:(float)delayInSeconds {
    if (delayInSeconds <= 0) {
        intptr_t ret = dispatch_semaphore_wait(_lockCond, DISPATCH_TIME_FOREVER);
        NSLog(@"ret1-%li", ret);
    }
    else {
        intptr_t ret = dispatch_semaphore_wait(_lockCond, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)));
        NSLog(@"ret2-%li", ret);
    }
}

- (void)condSignal {
    dispatch_semaphore_signal(_lockCond);
}

@end
