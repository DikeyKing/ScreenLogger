//
//  ARSPerformance.h
//  NEARFace
//
//  Created by lvbingru on 2018/11/7.
//  Copyright © 2018 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface ARSPerformance : NSObject

+ (instancetype)sharedInstance;

/**
 开始监测
 */
- (void)start;

/**
 停止监测
 */
- (void)stop;

/**
 cpu 占用率
 单位 %
 */
@property (nonatomic, readonly) float cpu;

/**
 内存占用
 单位 M
 特别注意，debug 模式会多统计40M左右
 */
@property (nonatomic, readonly) float memory;


/**
 显示帧率
 单位 f/s
 */
@property (nonatomic, readonly) float fps;


/**
 每帧处理时间，自己设置
 单位 ms
 */
@property (nonatomic, assign) float frameTime;

@end

NS_ASSUME_NONNULL_END
