//
//  ARSMonitorLogView.m
//  InsightSDK
//
//  Created by Dikey on 2020/10/21.
//  Copyright © 2020 DikeyKing. All rights reserved.
//

#import "ARSMonitorLogView.h"


@interface ARSMonitorLogView()

@property (nonatomic, strong) NSMutableArray<UILabel *> *logLabels;

@end

@implementation ARSMonitorLogView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _logs = [NSMutableDictionary new];
        [self addLogLables];
    }
    return self;
}

- (void)addLogLables
{
    _logLabels = [NSMutableArray arrayWithCapacity:_logs.count];
    for (NSInteger i = 0; i < _logs.count; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 5 + 20*i, 200, 15)];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:12.0f];
        [self addSubview:label];
        _logLabels[i] = label;
    }
}

- (void)addLog:(NSString *)log
       withTag:(NSInteger)tag
{
    [_logs setObject:log forKey:@(tag)];
    // 判断log字典和现有label数量是否一致
    if (_logLabels.count != _logs.count) {
        // 如果不一致，先更新数量，然后更新
        [self update];
    }
    // 如果一致，直接更新label
    [self updateLabel];
}

- (void)update
{
    if (_logLabels.count != _logs.count) {
        for (UILabel *label in _logLabels) {
            [label removeFromSuperview];
        }
        [_logLabels removeAllObjects];
        _logLabels = nil;
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 20 * _logs.count +5);
        [self addLogLables];
    }
}

- (void)updateLabel{
    NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:_logs.count];
    for (NSString *key in _logs) {
        NSString *log = _logs[key];
        [array addObject:log];
    }
    unsigned long count = MIN(_logs.count, _logLabels.count);
    for (int i = 0; i<count; i++) {
        UILabel *label = _logLabels[i];
        NSString *log = array[i];
        label.text = log;
    }
}

@end
