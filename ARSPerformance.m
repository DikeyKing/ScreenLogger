//
//  ARSPerformance.m
//  NEARFace
//
//  Created by lvbingru on 2018/11/7.
//  Copyright © 2018 Netease. All rights reserved.
//

#import "ARSPerformance.h"
#import <sys/sysctl.h>
#import <mach/mach.h>
#import <QuartzCore/CADisplayLink.h>

vm_size_t memory_usage(void) {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    return (kerr == KERN_SUCCESS) ? info.resident_size : 0; // size in bytes
}

struct task_basic_info memory_info(void) {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    assert(kerr == KERN_SUCCESS);
    return info;
}

@interface ARSPerformance() {
    CADisplayLink *_displayLink;
}

@end

@implementation ARSPerformance

+ (instancetype)sharedInstance
{
    static id instance ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [ARSPerformance sharedInstance];
}

- (id)copyWithZone:(struct _NSZone *)zone
{
    return [ARSPerformance sharedInstance];
}

- (id)init
{
    self = [super init];
    if (self) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction:)];
    }
    return self;
}

- (void)start
{
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stop
{
    [_displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)displayLinkAction:(CADisplayLink *)link
{
    static NSTimeInterval lastTime = 0;
    static int frameCount = 0;
    if (lastTime == 0) {
        lastTime = link.timestamp;
        return;
    }
    
    frameCount++;
    NSTimeInterval passTime = link.timestamp - lastTime;
    
    if (passTime > 1) {
        _fps = frameCount / passTime + 0.5;
        lastTime = link.timestamp;
        frameCount = 0;
    }
}

- (float)memory
{
    return memory_usage() / 1024.0 / 1024.0;
}

- (float)cpu
{
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
//    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
//    uint32_t stat_thread = 0; // Mach threads
    
//    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
//    if (thread_count > 0)
//        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    return tot_cpu;
}

- (void)hide
{
    // Get Page Size
    int mib[2];
    vm_size_t page_size;
    size_t len;
    
    mib[0] = CTL_HW;
    mib[1] = HW_PAGESIZE;
    len = sizeof(page_size);
    
    //    // 方法一: 16384
    //    int status = sysctl(mib, 2, &page_size, &len, NULL, 0);
    //    if (status < 0) {
    //        perror("Failed to get page size");
    //    }
    //    // 方法二: 16384
    //    page_size = getpagesize();
    // 方法三: 4096
    if( host_page_size(mach_host_self(), &page_size)!= KERN_SUCCESS ){
        perror("Failed to get page size");
    }
    //    printf("Page size is %d bytes\n", page_size);
    
    // Get Memory Size
    mib[0] = CTL_HW;
    mib[1] = HW_MEMSIZE;
    long ram;
    len = sizeof(ram);
    if (sysctl(mib, 2, &ram, &len, NULL, 0)) {
        perror("Failed to get ram size");
    }
    //    printf("Ram size is %f MB\n", ram / (1024.0) / (1024.0));
    
    // Get Memory Statistics
    //    vm_statistics_data_t vm_stats;
    //    mach_msg_type_number_t info_count = HOST_VM_INFO_COUNT;
    vm_statistics64_data_t vm_stats;
    mach_msg_type_number_t info_count64 = HOST_VM_INFO64_COUNT;
    //    kern_return_t kern_return = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vm_stats, &info_count);
    kern_return_t kern_return = host_statistics64(mach_host_self(), HOST_VM_INFO64, (host_info64_t)&vm_stats, &info_count64);
    if (kern_return != KERN_SUCCESS) {
        printf("Failed to get VM statistics!");
    }
    
#if DEBUG
    double vm_total = vm_stats.wire_count + vm_stats.active_count + vm_stats.inactive_count + vm_stats.free_count;
    double vm_wire = vm_stats.wire_count;
    double vm_active = vm_stats.active_count;
    double vm_inactive = vm_stats.inactive_count;
    double vm_free = vm_stats.free_count;
    double unit = (1024.0) * (1024.0);
    
    NSLog(@"Total Memory: %f", vm_total * page_size / unit);
    NSLog(@"Wired Memory: %f", vm_wire * page_size / unit);
    NSLog(@"Active Memory: %f", vm_active * page_size / unit);
    NSLog(@"Inactive Memory: %f", vm_inactive * page_size / unit);
    NSLog(@"Free Memory: %f", vm_free * page_size / unit);
#else
#endif
}
@end
