//
//  AppDelegate.m
//  Tutorial1
//
//  Created by gcohen on 5/12/15.
//  Copyright (c) 2015 geremy cohen. All rights reserved.
//

#import "AppDelegate.h"
#import "PubNub.h"


#pragma mark Private interface declaration

@interface AppDelegate () <PNObjectEventListener>

#pragma mark - Properteis

@property (nonatomic, strong) PubNub *client;
@property (nonatomic, strong) NSString *channel;


#pragma mark - Configuration

- (void)updateClientConfiguration;
- (void)printClientConfiguration;


#pragma mark -


@end


#pragma mark - Interface implementation

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Initialize PubNub client.
    self.channel = @"myCh";
    self.client = [PubNub clientWithPublishKey:@"demo-36" andSubscribeKey:@"demo-36"];
    [self.client addListeners:@[self]];
    [PNLog enableLogLevel:PNRequestLogLevel];
    
    [self updateClientConfiguration];
    [self printClientConfiguration];

    // Time (Ping) to PubNub Servers
    [self.client timeWithCompletion:^(PNResult *result, PNStatus *status) {
        if (result.data) {
            NSLog(@"Result from Time: %@", result.data);
        }

        if (status.debugDescription)  {
            NSLog(@"Event Status from Time: %@ - Is an error: %@", [status debugDescription], (status.isError ? @"YES" : @"NO"));
        }

    }];

    [self.client subscribeToChannels:@[_channel] withPresence:YES andCompletion:^(PNStatus *status) {
        
        // On initial subscribe connect event
        if (status.category == PNConnectedCategory) {
            
            NSLog(@"Subscribe Connected to %@", status.data[@"channels"]);
            
            [self.client publish:@"I'm here!" toChannel:_channel compressed:YES
                  withCompletion:^(PNStatus *status) {
                    
                if (!status.isError) {
                    
                    NSLog(@"Message sent at TT: %@", status.data[@"tt"]);
                } else {
                    
                    NSLog(@"An error occurred while publishing: %@", status.data[@"information"]);
                    NSLog(@"Because this WILL NOT autoretry (%@), you must manually resend this message again.",
                          (status.willAutomaticallyRetry ? @"YES" : @"NO"));
                }
            }];
         
        }
    }];


    return YES;
}

- (void)client:(PubNub *)client didReceiveMessage:(PNResult *)message {
    
    NSLog(@"Did receive message: %@", message.data);
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNResult *)event {
    
    NSLog(@"Did receive presence event: %@", event.data);
}

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {
    
    NSLog(@"Did status: %@", status.data);
    
    // On expected disconnect. For example, channel changing
    if (status.category == PNDisconnectedCategory) {
        
        NSLog(@"Subscribe disconnected expectedly from %@", status.data[@"channels"]);
    }
    // On unexpected disconnect. For example, Airplane mode turned on, Suspended, Backgrounded
    else if (status.category == PNUnexpectedDisconnectCategory) {
        
        NSLog(@"Subscribe disconnected unexpectedly from %@", status.data[@"channels"]);
    }
    // When reconnecting from an unexpected disconnect (airplane mode disabled, resuming from foreground)
    else if (status.category == PNReconnectedCategory) {
        
        NSLog(@"Subscribe reconnected to %@", status.data[@"channels"]);
    }
    // !!!: This case almost impossible for subscrib/unsubscribe events.
    // When receiving malformed / Non-JSON
    else if (status.category == PNMalformedResponseCategory) {
        
        NSLog(@"Bad JSON. Is error? %@, It will autoretry (%@)",
              (status.isError ? @"YES" : @"NO"),
              (status.willAutomaticallyRetry ? @"YES" : @"NO"));
        
        // If willAutomaticallyRetry is 'NO' then it is possible manually relaunch request
        // using: [status retry];

    }
    // When receiving a 403
    else if (status.category == PNAccessDeniedCategory) {
        
        NSLog(@"PAM Access Denied against channel %@ -- it will autoretry: %@",
              status.data[@"channels"], (status.willAutomaticallyRetry ? @"YES" : @"NO"));
        NSLog(@"In the meantime, you may wish to change the autotoken or unsubscribe from the channel in question.");
        
        // Retry attempts can be canceled with this code: [status cancelAutomaticRetry];
    }
}


#pragma mark - Configuration

- (void)updateClientConfiguration {
    
    [self.client commitConfiguration:^{
        
        // Set PubNub Configuration
        self.client.SSLEnabled = YES;
        self.client.origin = @"ios4.pubnub.com";
        self.client.authKey = @"myAuthKey";
        self.client.uuid = @"ios4.0Tutorial";
        
        // Presence Settings
        self.client.presenceHeartbeatValue = 120;
        self.client.presenceHeartbeatInterval = 3;
        
        // Cipher Key Settings
        self.client.cipherKey = @"enigma";
        
        // Time Token Handling Settings
        self.client.keepTimeTokenOnListChange = YES;
        self.client.restoreSubscription = YES;
        self.client.catchUpOnSubscriptionRestore = YES;
    }];
}

- (void)printClientConfiguration {
    
    // Get PubNub Options
    NSLog(@"SSELEnabled: %@", (self.client.isSSLEnabled ? @"YES" : @"NO"));
    NSLog(@"Origin: %@", self.client.origin);
    NSLog(@"authKey: %@", self.client.authKey);
    NSLog(@"UUID: %@", self.client.uuid);
    
    // Time Token Handling Settings
    NSLog(@"keepTimeTokenOnChannelChange: %@",
          (self.client.shouldKeepTimeTokenOnListChange ? @"YES" : @"NO"));
    NSLog(@"resubscribeOnConnectionRestore: %@",
          (self.client.shouldRestoreSubscription ? @"YES" : @"NO"));
    NSLog(@"catchUpOnSubscriptionRestore: %@",
          (self.client.shouldTryCatchUpOnSubscriptionRestore ? @"YES" : @"NO"));
    
    // Get Presence Options
    NSLog(@"Heartbeat value: %@", @(self.client.presenceHeartbeatValue));
    NSLog(@"Heartbeat interval: %@", @(self.client.presenceHeartbeatInterval));
    
    // Get CipherKey
    NSLog(@"Cipher key: %@", self.client.cipherKey);
}

#pragma mark -

@end