//
//  ARSMonitorView.h
//  InsightSDK
//
//  Created by Carmine on 2019/1/18.
//  Copyright © 2019 DikeyKing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ARSMonitorView : UIView

+ (void)startMonitorWithFrame:(CGRect)frame;
+ (void)startMonitor;
+ (void)stopMonitor;
+ (void)update;

+ (void)addLog:(NSString *)log
       withTag:(NSInteger)tag;
@end

