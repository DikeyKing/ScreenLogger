//
//  ARSMonitorLogView.h
//  InsightSDK
//
//  Created by Dikey on 2020/10/21.
//  Copyright © 2020 DikeyKing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ARSMonitorLogView : UIView

@property (nonatomic, strong) NSMutableDictionary *logs;

- (void)update;
- (void)addLog:(NSString *)log
       withTag:(NSInteger)tag;

@end
