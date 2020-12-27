//
//  QHGCDThread.h
//  QHThreadDemo
//
//  Created by Anakin chen on 2020/12/7.
//

#import <Foundation/Foundation.h>

typedef int (^thread_block_t)(void);

NS_ASSUME_NONNULL_BEGIN

@interface QHGCDThread : NSObject

@property (nonatomic) dispatch_queue_t queue;
@property (nonatomic, strong) thread_block_t func;

+ (instancetype)createThread:(const char *_Nullable)label block:(thread_block_t)block;

@end

@interface QHGCDMutex : NSObject

@property (nonatomic) dispatch_semaphore_t lockMutex;

+ (instancetype)create;
- (void)lock;
- (void)unlock;

@end

@interface QHGCDCond : NSObject

@property (nonatomic) dispatch_semaphore_t lockCond;

+ (instancetype)create;
- (void)waitTimeout:(float)delayInSeconds;
- (void)condSignal;

@end

NS_ASSUME_NONNULL_END
