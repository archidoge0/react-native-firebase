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
 *
 */

#import <React/RCTBridge.h>
#import <React/RCTInvalidating.h>
#import <React/RCTUtils.h>

#import "RNFBAppModule.h"
#import "RNFBAppTurboModules.h"
#import "RNFBJSON.h"
#import "RNFBMeta.h"
#import "RNFBPreferences.h"
#import "RNFBRCTEventEmitter.h"
#import "RNFBSharedUtils.h"
#import "RNFBVersion.h"

#if __has_include(<RNFBApp/RNFBApp-Swift.h>)
#import <RNFBApp/RNFBApp-Swift.h>
#elif __has_include("RNFBApp-Swift.h")
#import "RNFBApp-Swift.h"
#elif __has_include("RNFBHandleMapStorage-Swift.inc")
#import "RNFBHandleMapStorage-Swift.inc"
#else
#error "RNFBApp Swift interface not found"
#endif

@interface RNFBAppModule () <NativeRNFBTurboAppSpec, RCTInvalidating>

- (void)completeInitializeApp:(id)firApp
                   authDomain:(nullable NSString *)authDomain
                    jsAppName:(NSString *)jsAppName
                    appConfig:(NSDictionary *)appConfig
                      resolve:(RCTPromiseResolveBlock)resolve;

@end

@implementation RNFBAppModule

#pragma mark -
#pragma mark Module Setup

RCT_EXPORT_MODULE(NativeRNFBTurboApp)

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params {
  return std::make_shared<facebook::react::NativeRNFBTurboAppSpecJSI>(params);
}

- (void)setBridge:(RCTBridge *)bridge {
  [RNFBRCTEventEmitter shared].bridge = bridge;
}

- (id)init {
  if (self = [super init]) {
    // Once-gate lives solely in RNFBAppModuleFirebase.registerLibraryOnce.
    [RNFBAppModuleFirebase registerLibraryOnceWithName:@"react-native-firebase"
                                               version:[RNFBVersionString copy]];
    if ([[RNFBJSON shared] contains:@"app_log_level"]) {
      NSString *logLevel = [[RNFBJSON shared] getStringValue:@"app_log_level" defaultValue:@"info"];
      [self setLogLevel:logLevel];
    }
  }

  return self;
}

#pragma mark -
#pragma mark Constants

- (NSDictionary *)appConstantsDictionary {
  NSArray *firApps = [RNFBAppModuleFirebase allApps];
  NSMutableArray *appsArray = [NSMutableArray new];
  NSMutableDictionary *constants = [NSMutableDictionary new];

  for (id firApp in firApps) {
    [appsArray addObject:[RNFBSharedUtils firAppToDictionary:firApp]];
  }

  constants[@"NATIVE_FIREBASE_APPS"] = appsArray;
  constants[@"FIREBASE_RAW_JSON"] = [[RNFBJSON shared] getRawJSON];

  return constants;
}

- (facebook::react::ModuleConstants<JS::NativeRNFBTurboApp::Constants>)constantsToExport {
  return [_RCTTypedModuleConstants newWithUnsafeDictionary:[self appConstantsDictionary]];
}

- (facebook::react::ModuleConstants<JS::NativeRNFBTurboApp::Constants>)getConstants {
  return [self constantsToExport];
}

#pragma mark -
#pragma mark META Methods

- (void)metaGetAll:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  resolve([RNFBMeta getAll]);
}

#pragma mark -
#pragma mark JSON Methods

- (void)jsonGetAll:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  resolve([[RNFBJSON shared] getAll]);
}

#pragma mark -
#pragma mark Preference Methods

- (void)preferencesSetBool:(NSString *)key
                     value:(BOOL)value
                   resolve:(RCTPromiseResolveBlock)resolve
                    reject:(RCTPromiseRejectBlock)reject {
  [[RNFBPreferences shared] setBooleanValue:key boolValue:value];
  resolve([NSNull null]);
}

- (void)preferencesSetString:(NSString *)key
                       value:(NSString *)value
                     resolve:(RCTPromiseResolveBlock)resolve
                      reject:(RCTPromiseRejectBlock)reject {
  [[RNFBPreferences shared] setStringValue:key stringValue:value];
  resolve([NSNull null]);
}

- (void)preferencesGetAll:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  resolve([[RNFBPreferences shared] getAll]);
}

- (void)preferencesClearAll:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  [[RNFBPreferences shared] clearAll];
  resolve([NSNull null]);
}

#pragma mark -
#pragma mark Event Methods

- (void)eventsNotifyReady:(BOOL)ready {
  [[RNFBRCTEventEmitter shared] notifyJsReady:ready];
}

- (void)eventsGetListeners:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  resolve([[RNFBRCTEventEmitter shared] getListenersDictionary]);
}

- (void)eventsPing:(NSString *)eventName
         eventBody:(NSDictionary *)eventBody
           resolve:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject {
  [[RNFBRCTEventEmitter shared] sendEventWithName:eventName body:eventBody];
  resolve(eventBody);
}

- (void)eventsAddListener:(NSString *)eventName {
  [[RNFBRCTEventEmitter shared] addListener:eventName];
}

- (void)eventsRemoveListener:(NSString *)eventName all:(BOOL)all {
  [[RNFBRCTEventEmitter shared] removeListeners:eventName all:all];
}

#pragma mark -
#pragma mark Events Unused

- (void)addListener:(NSString *)eventName {
  // Keep: Required for RN built in Event Emitter Calls.
}

- (void)removeListeners:(double)count {
  // Keep: Required for RN built in Event Emitter Calls.
}

#pragma mark -
#pragma mark Firebase App Methods

- (void)initializeApp:(NSDictionary *)options
            appConfig:(NSDictionary *)appConfig
              resolve:(RCTPromiseResolveBlock)resolve
               reject:(RCTPromiseRejectBlock)reject {
  RCTUnsafeExecuteOnMainQueueSync(^{
    id firApp;
    RNFBAppInitializeNameResolution *names =
        [RNFBAppInitializeOptionsMapper resolveNameFromAppConfig:appConfig];
    NSString *authDomain = [RNFBAppInitializeOptionsMapper authDomainFromOptions:options];
    id firOptions =
        [RNFBAppInitializeOptionsMapper buildOptionsFrom:options
                                          optionsFactory:[RNFBAppModuleFirebase optionsFactory]];

    @try {
      firApp = [RNFBAppModuleFirebase configureOrReuseAppWithOptions:firOptions
                                                      nameResolution:names];
    } @catch (NSException *exception) {
      return [RNFBSharedUtils rejectPromiseWithExceptionDict:reject exception:exception];
    }

    // Store under the JS bridge app name ([DEFAULT]), never native __FIRAPP_DEFAULT.
    // clang-format off
    [self completeInitializeApp:firApp authDomain:authDomain jsAppName:names.jsAppName appConfig:appConfig resolve:resolve];
    // clang-format on
  });
}

+ (NSString *)getCustomDomain:(NSString *)appName {
  return [RNFBAppCustomAuthDomains getCustomDomain:appName];
}

- (void)setLogLevel:(NSString *)logLevel {
  int level = (int)[RNFBAppLogLevelMapper loggerLevelForString:logLevel];
  DLog(@"RNFBSetLogLevel: setting level to %d from %@.", level, logLevel);
  [RNFBAppModuleFirebase setLoggerLevel:level];
}

- (void)setAutomaticDataCollectionEnabled:(NSString *)appName enabled:(BOOL)enabled {
  [RNFBAppModuleFirebase setAutomaticDataCollectionEnabled:enabled forAppName:appName];
}

- (void)deleteApp:(NSString *)appName
          resolve:(RCTPromiseResolveBlock)resolve
           reject:(RCTPromiseRejectBlock)reject {
  [RNFBAppModuleFirebase deleteAppNamed:appName resolve:resolve reject:reject];
}

+ (BOOL)requiresMainQueueSetup {
  return NO;
}

@end
