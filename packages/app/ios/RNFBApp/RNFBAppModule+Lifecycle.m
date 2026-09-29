/**
 * Copyright (c) 2016-present Invertase Limited & Contributors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this library except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <React/RCTBridge.h>
#import <React/RCTBridgeModule.h>

#import "RNFBAppModule.h"
#import "RNFBRCTEventEmitter.h"
#import "RNFBSharedUtils.h"

#if __has_include(<RNFBApp/RNFBApp-Swift.h>)
#import <RNFBApp/RNFBApp-Swift.h>
#elif __has_include("RNFBApp-Swift.h")
#import "RNFBApp-Swift.h"
#elif __has_include("RNFBHandleMapStorage-Swift.inc")
#import "RNFBHandleMapStorage-Swift.inc"
#else
#error "RNFBApp Swift interface not found"
#endif

/**
 * Invalidate + initialize completion previously inline in `RNFBAppModule.mm`.
 * Host XCTest compiles this category without TurboModule C++.
 * `setBridge:` stays on the main `@implementation` so RN always finds it.
 */
@implementation RNFBAppModule (Lifecycle)

- (void)invalidate {
  [[RNFBRCTEventEmitter shared] invalidate];
}

- (RCTBridge *)bridge {
  return [RNFBRCTEventEmitter shared].bridge;
}

- (void)completeInitializeApp:(id)firApp
                   authDomain:(nullable NSString *)authDomain
                    jsAppName:(NSString *)jsAppName
                    appConfig:(NSDictionary *)appConfig
                      resolve:(RCTPromiseResolveBlock)resolve {
  [RNFBAppCustomAuthDomains setCustomDomain:authDomain forAppName:jsAppName];
  [RNFBAppModuleFirebase
      setDataCollectionDefaultEnabled:(BOOL)
                                          [appConfig valueForKey:@"automaticDataCollectionEnabled"]
                               forApp:firApp];
  resolve([RNFBSharedUtils firAppToDictionary:firApp]);
}

@end
