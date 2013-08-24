//
//  SegmentioTests.m
//  Analytics
//
//  Created by Tony Xiao on 8/23/13.
//  Copyright (c) 2013 Segment.io. All rights reserved.
//

#import "AnalyticsUtils.h"
#import "SegmentioProvider.h"

@interface SegmentioProvider (Private)
@property (nonatomic, readonly) NSMutableArray *queue;
@end

SPEC_BEGIN(SegmentioTests)

describe(@"Segment.io", ^{
    __block SegmentioProvider *segmentio = nil;
    beforeAll(^{
        SetShowDebugLogs(YES);
        segmentio = [[SegmentioProvider alloc] initWithSecret:@"testsecret" flushAt:2 flushAfter:2];
        [segmentio reset];
    });
    
    it(@"Should have a sessionID", ^{
        [segmentio.sessionId shouldNotBeNil];
    });
    
    it(@"Should queue when not full", ^{
        NSString *userId = @"smile@wrinkledhippo.com";
        [segmentio identify:userId traits:nil context:nil];
        [[expectFutureValue(@(segmentio.queue.count)) shouldEventually] equal:@1];
    });
    
    it(@"Should flush when full", ^{
        NSString *eventName = @"Purchased an iPad 5";
        NSDictionary *properties = @{@"Filter": @"Tilt-shift"};
        [segmentio track:eventName properties:properties context:nil];
        [[expectFutureValue(@(segmentio.queue.count)) shouldEventually] equal:@2];
        [[expectFutureValue(@(segmentio.queue.count)) shouldEventually] equal:@0];
    });
});

SPEC_END