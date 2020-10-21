//
//  ARSMonitorView.m
//  InsightSDK
//
//  Created by Carmine on 2019/1/18.
//  Copyright © 2019 DikeyKing. All rights reserved.
//

#import "ARSMonitorView.h"
#import "ARSPerformance.h"
#import "Utility.h"
#import "ARSMonitorLogView.h"

typedef NS_ENUM(NSUInteger, ARSMonitorType) {
//    ARSMonitorTypeFrameTime = 0,
    ARSMonitorTypeFps = 0,
    ARSMonitorTypeCPU,
    ARSMonitorTypeMemory,
//    ARSMonitorTypeVM,
    ARSMonitorTypeNum
};

@interface ARSMonitorView ()

@property (nonatomic, strong) NSMutableArray<UILabel *> * pLabels;

@end

static ARSMonitorView * __monitorView = nil;
static ARSMonitorLogView * __monitorLogView = nil;

@implementation ARSMonitorView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _pLabels = [NSMutableArray arrayWithCapacity:ARSMonitorTypeNum];
        for (NSInteger i = 0; i < ARSMonitorTypeNum; i++) {
            UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(5, 5 + 20*i, 200, 15)];
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont systemFontOfSize:12.0f];
            [self addSubview:label];
            _pLabels[i] = label;
        }
    }
    return self;
}

+ (void)startMonitor {
    [self startMonitorWithFrame:CGRectMake(10, (IPHONE_X_SERIES ? 100 : 64)+80, 140, 20 * ARSMonitorTypeNum + 5)];
}

+ (void)startMonitorWithFrame:(CGRect)frame {
    UIWindow * keyWindow = [UIApplication sharedApplication].delegate.window;
    if (!__monitorView) {
        __monitorView = [[ARSMonitorView alloc] initWithFrame:frame];
        __monitorView.userInteractionEnabled = NO;
        __monitorView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6]; // 半透明
        [[ARSPerformance sharedInstance] start];
    }
    if (!__monitorLogView) {
        __monitorLogView = [[ARSMonitorLogView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y + frame.size.height+5, frame.size.width, 5)];
        __monitorLogView.userInteractionEnabled = NO;
        __monitorLogView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6]; // 半透明
    }
    [keyWindow addSubview:__monitorView];
    [keyWindow addSubview:__monitorLogView];
}

+ (void)stopMonitor {
    if (__monitorView) {
        [[ARSPerformance sharedInstance] stop];
        [__monitorView removeFromSuperview];
        __monitorView = nil;
    }
}

+ (void)update {
    if (__monitorView) {
        __monitorView.pLabels[ARSMonitorTypeMemory].text = [NSString stringWithFormat:@"Memory :  %dMB", (int)[ARSPerformance sharedInstance].memory];
        __monitorView.pLabels[ARSMonitorTypeFps].text = [NSString stringWithFormat:@"FPS  :  %d", (int)[ARSPerformance sharedInstance].fps];
        __monitorView.pLabels[ARSMonitorTypeCPU].text = [NSString stringWithFormat:@"CPU  :  %.2f%%", [ARSPerformance sharedInstance].cpu];
    }
}

+ (void)addLog:(NSString *)log
       withTag:(NSInteger)tag
{
    // 保证主线程
    if ([NSThread isMainThread]) {
        // 先更新log字典
        [__monitorLogView addLog:log withTag:tag];
        // 判断log字典和现有label数量是否一致
        // 如果一致，直接更新label
        // 如果不一致，先更新数量，然后更新
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [__monitorLogView addLog:log withTag:tag];
        });
    }
}

@end
