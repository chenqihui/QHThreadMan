//
//  QHTableSubViewController.m
//  QHTableViewDemo
//
//  Created by chen on 17/3/21.
//  Copyright © 2017年 chen. All rights reserved.
//

#import "QHTableSubViewController.h"

#import "QHGCDThread.h"
#import "ijksdl_thread_ios.h"

typedef struct sdl_t {
    SDL_Thread *tid;
    SDL_Thread _tid;
    
    SDL_cond  *cond;
} sdl_t;

@interface QHTableSubViewController ()

@property (nonatomic, strong) QHGCDThread *gcd_td1;
@property (nonatomic, strong) QHGCDMutex *gcd_mt1;
@property (nonatomic, strong) QHGCDCond *gcd_cond1;

@property (nonatomic, strong) QHGCDThread *gcd_td2;
@property (nonatomic, strong) QHGCDMutex *gcd_mt2;
@property (nonatomic, strong) QHGCDCond *gcd_cond2;

@property (nonatomic, strong) QHGCDMutex *gcd_mt;

@property (nonatomic) BOOL bW1;
@property (nonatomic) BOOL bQ1;
@property (nonatomic) BOOL bL1;

@property (nonatomic) BOOL bW2;
@property (nonatomic) BOOL bQ2;
@property (nonatomic) BOOL bL2;

@property (nonatomic) sdl_t sdl_tid1;
@property (nonatomic) SDL_mutex *wait_mutex;

@end

@implementation QHTableSubViewController

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _gcd_mt = [QHGCDMutex create];
    _wait_mutex = SDL_CreateMutex();
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (int)p_do1 {
    
    while (!self.bQ1) {
        
        if (self.bW1) {
            
            NSLog(@"chen>wait1");
            
            [self.gcd_cond1 waitTimeout:0];
            
            self.bW1 = NO;
        }
        
        if (self.bL1) {
            [self.gcd_mt lock];
            NSLog(@"chen>lock1");
            [NSThread sleepForTimeInterval:10];
            [self.gcd_mt unlock];
            self.bL1 = NO;
        }
        
        sleep(1);
        [NSThread sleepForTimeInterval:0.2];
        
        NSLog(@"run1");
    }
    
    NSLog(@"quit1");
    return 0;
}

- (int)p_do2 {
    
    while (!self.bQ2) {
        
        if (self.bW2) {
            
            NSLog(@"chen>wait2");
            
            [self.gcd_cond2 waitTimeout:0];
            
            self.bW2 = NO;
        }
        
        sleep(1);
        [NSThread sleepForTimeInterval:2];
        
        if (self.bL2) {
            [self.gcd_mt lock];
            NSLog(@"chen>lock2");
            [NSThread sleepForTimeInterval:2];
            [self.gcd_mt unlock];
            self.bL2 = NO;
        }
        
        NSLog(@"run2");
    }
    
    NSLog(@"quit2");
    return 0;
}

static int p_thread1(void *arg) {
    QHTableSubViewController *vc = (__bridge QHTableSubViewController *)(arg);
    while (!vc.bQ1) {
        
        if (vc.bW1) {
            
            NSLog(@"chen>wait1");
            
            SDL_LockMutex(vc.wait_mutex);
            SDL_CondWaitTimeout(vc.sdl_tid1.cond, vc.wait_mutex, 10*1000);
            SDL_UnlockMutex(vc.wait_mutex);
            
            vc.bW1 = NO;
        }
        
        if (vc.bL1) {
            [vc.gcd_mt lock];
            NSLog(@"chen>lock1");
            [NSThread sleepForTimeInterval:10];
            [vc.gcd_mt unlock];
            vc.bL1 = NO;
        }
        
        sleep(1);
        [NSThread sleepForTimeInterval:0.2];
        
        NSLog(@"run1");
    }
    
    NSLog(@"quit1");
    return 0;
}

#pragma mark - Action

- (IBAction)s1:(id)sender {
//    if (!_gcd_td1) {
//        _gcd_mt1 = [QHGCDMutex create];
//        _gcd_cond1 = [QHGCDCond create];
//        __weak typeof(self) weakSelf = self;
//        _gcd_td1 = [QHGCDThread createThread:"com.gcd_td1" block:^int{
//            return [weakSelf p_do1];
//        }];
//    }
    
    memset(&_sdl_tid1, 0, sizeof(sdl_t));
    _sdl_tid1.tid = SDL_CreateThreadEx(&(_sdl_tid1._tid), p_thread1, (__bridge void *)(self), "com.sdl_tid1");
    _sdl_tid1.cond = SDL_CreateCond();
    
}
- (IBAction)w1:(id)sender {
    self.bW1 = YES;
}
- (IBAction)l1:(id)sender {
    self.bL1 = YES;
}
- (IBAction)si1:(id)sender {
//    [self.gcd_cond1 condSignal];
    
    SDL_CondSignal(_sdl_tid1.cond);
}
- (IBAction)q1:(id)sender {
    self.bQ1 = YES;
}

- (IBAction)s2:(id)sender {
    if (!_gcd_td2) {
        _gcd_mt2 = [QHGCDMutex create];
        _gcd_cond2 = [QHGCDCond create];
        __weak typeof(self) weakSelf = self;
        _gcd_td2 = [QHGCDThread createThread:"com.gcd_td2" block:^int{
            return [weakSelf p_do2];
        }];
    }
}
- (IBAction)w2:(id)sender {
    self.bW2 = YES;
}
- (IBAction)l2:(id)sender {
    self.bL2 = YES;
}
- (IBAction)si2:(id)sender {
    [self.gcd_cond2 condSignal];
}
- (IBAction)q2:(id)sender {
    self.bQ2 = YES;
}

@end
