//
//  PNChannelGroupSubscribeTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/28/15.
//
//

#import "PNBasicSubscribeTestCase.h"

static NSString * const kPNChannelGroupTestsName = @"PNChannelGroupSubscribeTests";

@interface PNChannelGroupSubscribeTests : PNBasicSubscribeTestCase
@end

@implementation PNChannelGroupSubscribeTests

- (BOOL)isRecording{
    return YES;
}

- (NSArray *)channelGroups {
    return @[
             kPNChannelGroupTestsName
             ];
}

- (void)setUp {
    [super setUp];
    [self performVerifiedRemoveAllChannelsFromGroup:kPNChannelGroupTestsName withAssertions:nil];
    PNWeakify(self);
    [self performVerifiedAddChannels:@[@"a", @"b"] toGroup:kPNChannelGroupTestsName withAssertions:^(PNAcknowledgmentStatus *status) {
        PNStrongify(self);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.operation, PNAddChannelsToGroupOperation);
        XCTAssertEqual(status.category, PNAcknowledgmentCategory);
        XCTAssertEqual(status.statusCode, 200);
    }];
}

- (void)testSubscribeThenRemoveChannelFromSubscribedGroup {
    PNWeakify(self);
    __block NSInteger timesMessageReceivedCalled = 0;
    __block NSInteger timesStatusReceivedCalled = 0;
    __block XCTestExpectation *channelGroupRemoveExpectation = [self expectationWithDescription:@"channelGroupRemove"];
    PNClientDidReceiveStatusAssertions firstStatusAssertion = ^void (PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNConnectedCategory);
        NSArray *expectedChannelGroups = @[
                                           kPNChannelGroupTestsName,
                                           [kPNChannelGroupTestsName stringByAppendingString:@"-pnpres"]
                                           ];
        XCTAssertEqual(status.subscribedChannels.count, 0);
        XCTAssertEqualObjects([NSSet setWithArray:status.subscribedChannelGroups],
                              [NSSet setWithArray:expectedChannelGroups]);
        
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        NSLog(@"timeToken: %@", status.currentTimetoken);
        XCTAssertEqual(status.statusCode, 200);
        XCTAssertEqualObjects(status.currentTimetoken, @14508287398196981);
        XCTAssertEqualObjects(status.currentTimetoken, status.data.timetoken);
    };
    PNClientDidReceiveMessageAssertions firstMessageAssertion = ^void (PubNub *client, PNMessageResult *message) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertEqualObjects(client.uuid, message.uuid);
        XCTAssertNotNil(message.uuid);
        XCTAssertNil(message.authKey);
        XCTAssertEqual(message.statusCode, 200);
        XCTAssertTrue(message.TLSEnabled);
        XCTAssertEqual(message.operation, PNSubscribeOperation);
        NSLog(@"message:");
        NSLog(@"%@", message.data.message);
        XCTAssertNotNil(message.data);
        XCTAssertEqualObjects(message.data.message, @"******......... 6158 - 2015-12-22 15:59:00");
        XCTAssertEqualObjects(message.data.actualChannel, @"a");
        XCTAssertEqualObjects(message.data.subscribedChannel, kPNChannelGroupTestsName);
        XCTAssertEqualObjects(message.data.timetoken, @14508287407082352);
//        [self.client removeChannels:@[@"a"] fromGroup:kPNChannelGroupTestsName withCompletion:^(PNAcknowledgmentStatus *status) {
//            PNStrongify(self);
//            XCTAssertNotNil(status);
//        }];
        //        [self.channelGroupSubscribeExpectation fulfill];
//        self.channelGroupSubscribeExpectation = nil;
    };
    PNClientDidReceiveStatusAssertions secondStatusAssertion = ^void (PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        NSLog(@"second status!!!!!");
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNConnectedCategory);
        NSArray *expectedChannelGroups = @[
                                           kPNChannelGroupTestsName,
                                           [kPNChannelGroupTestsName stringByAppendingString:@"-pnpres"]
                                           ];
        XCTAssertEqual(status.subscribedChannels.count, 0);
        XCTAssertEqualObjects([NSSet setWithArray:status.subscribedChannelGroups],
                              [NSSet setWithArray:expectedChannelGroups]);
        
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        NSLog(@"timeToken: %@", status.currentTimetoken);
        XCTAssertEqual(status.statusCode, 200);
        XCTAssertEqualObjects(status.currentTimetoken, @14508287398196981);
        XCTAssertEqualObjects(status.currentTimetoken, status.data.timetoken);
    };
    PNClientDidReceiveMessageAssertions secondMessageAssertion = ^void (PubNub *client, PNMessageResult *message) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertEqualObjects(client.uuid, message.uuid);
        XCTAssertNotNil(message.uuid);
        XCTAssertNil(message.authKey);
        XCTAssertEqual(message.statusCode, 200);
        XCTAssertTrue(message.TLSEnabled);
        XCTAssertEqual(message.operation, PNSubscribeOperation);
        NSLog(@"message:");
        NSLog(@"%@", message.data.message);
        XCTAssertNotNil(message.data);
        XCTAssertEqualObjects(message.data.message, @"******......... 6158 - 2015-12-22 15:59:00");
        XCTAssertEqualObjects(message.data.actualChannel, @"a");
        XCTAssertEqualObjects(message.data.subscribedChannel, kPNChannelGroupTestsName);
        XCTAssertEqualObjects(message.data.timetoken, @14508287407082352);
//                [self.client removeChannels:@[@"a"] fromGroup:kPNChannelGroupTestsName withCompletion:^(PNAcknowledgmentStatus *status) {
//                    PNStrongify(self);
//                    XCTAssertNotNil(status);
//                }];
//                [self.channelGroupSubscribeExpectation fulfill];
//                self.channelGroupSubscribeExpectation = nil;
    };
    PNClientDidReceiveMessageAssertions thirdMessageAssertion = ^void (PubNub *client, PNMessageResult *message) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertEqualObjects(client.uuid, message.uuid);
        XCTAssertNotNil(message.uuid);
        XCTAssertNil(message.authKey);
        XCTAssertEqual(message.statusCode, 200);
        XCTAssertTrue(message.TLSEnabled);
        XCTAssertEqual(message.operation, PNSubscribeOperation);
        NSLog(@"message:");
        NSLog(@"%@", message.data.message);
        XCTAssertNotNil(message.data);
        XCTAssertEqualObjects(message.data.message, @"******......... 6158 - 2015-12-22 15:59:00");
        XCTAssertEqualObjects(message.data.actualChannel, @"a");
        XCTAssertEqualObjects(message.data.subscribedChannel, kPNChannelGroupTestsName);
        XCTAssertEqualObjects(message.data.timetoken, @14508287407082352);
        //        [self.client removeChannels:@[@"a"] fromGroup:kPNChannelGroupTestsName withCompletion:^(PNAcknowledgmentStatus *status) {
        //            PNStrongify(self);
        //            XCTAssertNotNil(status);
        //        }];
        //        [self.channelGroupSubscribeExpectation fulfill];
        //        self.channelGroupSubscribeExpectation = nil;
    };
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        switch (timesStatusReceivedCalled) {
            case 0:
            {
                firstStatusAssertion(client, status);
            }
                break;
            case 1:
            {
                secondStatusAssertion(client, status);
            }
                break;
            default:
            {
                XCTFail(@"status: %@ shouldn't be here, time: %ld", status.debugDescription, (long)timesStatusReceivedCalled);
            }
                break;
        }
        timesStatusReceivedCalled++;
    };
    self.didReceiveMessageAssertions = ^void (PubNub *client, PNMessageResult *message) {
        PNStrongify(self);
        switch (timesMessageReceivedCalled) {
            case 0:
            {
                firstMessageAssertion(client, message);
                [self.client removeChannels:@[@"b"] fromGroup:kPNChannelGroupTestsName withCompletion:^(PNAcknowledgmentStatus *status) {
                    PNStrongify(self);
                    XCTAssertNotNil(status);
                    XCTAssertFalse(status.isError);
                    XCTAssertEqualObjects(self.client, client);
                    XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                    XCTAssertEqual(status.operation, PNRemoveChannelsFromGroupOperation);
                    XCTAssertEqual(status.statusCode, 200);
                    [channelGroupRemoveExpectation fulfill];
                    channelGroupRemoveExpectation = nil;
                }];
            }
                break;
            case 1:
            {
                secondMessageAssertion(client, message);
            }
                break;
            case 2:
            {
                thirdMessageAssertion(client, message);
                [self.channelGroupSubscribeExpectation fulfill];
                self.channelGroupSubscribeExpectation = nil;
            }
                break;
            default:
            {
                XCTFail(@"message: %@ shouldn't be here, time: %ld", message.debugDescription, (long)timesMessageReceivedCalled);
            }
                break;
        }
        timesMessageReceivedCalled++;
    };
    [self PNTest_subscribeToChannelGroups:[self channelGroups] withPresence:YES];
}

- (void)testSubscribeThenAddChannelToSubscribedGroup {
    
}

- (void)testSimpleSubscribeWithPresence {
    PNWeakify(self);
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNConnectedCategory);
        NSArray *expectedChannelGroups = @[
                                           kPNChannelGroupTestsName,
                                           [kPNChannelGroupTestsName stringByAppendingString:@"-pnpres"]
                                           ];
        XCTAssertEqual(status.subscribedChannels.count, 0);
        XCTAssertEqualObjects([NSSet setWithArray:status.subscribedChannelGroups],
                              [NSSet setWithArray:expectedChannelGroups]);
        
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        NSLog(@"timeToken: %@", status.currentTimetoken);
        XCTAssertEqualObjects(status.currentTimetoken, @14508287398196981);
        XCTAssertEqualObjects(status.currentTimetoken, status.data.timetoken);
        
    };
    self.didReceiveMessageAssertions = ^void (PubNub *client, PNMessageResult *message) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertEqualObjects(client.uuid, message.uuid);
        XCTAssertNotNil(message.uuid);
        XCTAssertNil(message.authKey);
        XCTAssertEqual(message.statusCode, 200);
        XCTAssertTrue(message.TLSEnabled);
        XCTAssertEqual(message.operation, PNSubscribeOperation);
        NSLog(@"message:");
        NSLog(@"%@", message.data.message);
        XCTAssertNotNil(message.data);
        XCTAssertEqualObjects(message.data.message, @"******......... 6158 - 2015-12-22 15:59:00");
        XCTAssertEqualObjects(message.data.actualChannel, @"a");
        XCTAssertEqualObjects(message.data.subscribedChannel, kPNChannelGroupTestsName);
        XCTAssertEqualObjects(message.data.timetoken, @14508287407082352);
        [self.channelGroupSubscribeExpectation fulfill];
    };
    [self PNTest_subscribeToChannelGroups:[self channelGroups] withPresence:YES];
}

- (void)testSimpleSubscribeWithNoPresence {
    PNWeakify(self);
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNConnectedCategory);
        NSArray *expectedChannelGroups = @[
                                           kPNChannelGroupTestsName
                                           ];
        XCTAssertEqual(status.subscribedChannels.count, 0);
        XCTAssertEqualObjects([NSSet setWithArray:status.subscribedChannelGroups],
                              [NSSet setWithArray:expectedChannelGroups]);
        
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        NSLog(@"timeToken: %@", status.currentTimetoken);
        XCTAssertEqualObjects(status.currentTimetoken, @14508287387303892);
        XCTAssertEqualObjects(status.currentTimetoken, status.data.timetoken);
        
    };
    self.didReceiveMessageAssertions = ^void (PubNub *client, PNMessageResult *message) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertEqualObjects(client.uuid, message.uuid);
        XCTAssertNotNil(message.uuid);
        XCTAssertNil(message.authKey);
        XCTAssertEqual(message.statusCode, 200);
        XCTAssertTrue(message.TLSEnabled);
        XCTAssertEqual(message.operation, PNSubscribeOperation);
        NSLog(@"message:");
        NSLog(@"%@", message.data.message);
        XCTAssertNotNil(message.data);
        // the string from this channel is absurd, should simplify at some point, but want to just keep cranking for now
        // cast to NSData to compare
        
        XCTAssertEqualObjects(message.data.message, @"*****.......... 6157 - 2015-12-22 15:58:59");
        XCTAssertEqualObjects(message.data.actualChannel, @"a");
        XCTAssertEqualObjects(message.data.subscribedChannel, kPNChannelGroupTestsName);
        XCTAssertEqualObjects(message.data.timetoken, @14508287395304656);
        [self.channelGroupSubscribeExpectation fulfill];
    };
    [self PNTest_subscribeToChannelGroups:[self channelGroups] withPresence:NO];
}

@end
