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

#import <XCTest/XCTest.h>
#import <objc/runtime.h>

#import "RNFBNullSentinelInterceptor.h"

/**
 * Stand-in for RCTCxxConvert codegen categories. Class methods whose selectors match
 * JS_NativeRNFBTurbo*_Spec* are what swizzleTurboModuleConversions: wraps.
 */
@interface RNFBNullSentinelStandInConvert : NSObject
@end

static id gLastJsonSeenByOriginalIMP = nil;

@implementation RNFBNullSentinelStandInConvert

+ (id)JS_NativeRNFBTurboFunctions_SpecHttpsCallableData:(id)json {
  gLastJsonSeenByOriginalIMP = json;
  return json;
}

/** Prefix matches JS_NativeRNFBTurbo* but lacks _Spec — must not be wrapped. */
+ (id)JS_NativeRNFBTurboFunctions_NotASpecMethod:(id)json {
  return json;
}

+ (id)unrelatedConverter:(id)json {
  return json;
}

@end

@interface RNFBNullSentinelInterceptorTests : XCTestCase
@end

@implementation RNFBNullSentinelInterceptorTests

- (NSDictionary *)nullSentinel {
  return @{@"__rnfbNull" : @YES};
}

- (NSDictionary *)unrelatedOneKeyDictionary {
  return @{@".sv" : @"timestamp"};
}

- (IMP)classMethodIMP:(Class)cls selector:(SEL)selector {
  Method method = class_getClassMethod(cls, selector);
  XCTAssertTrue(method != NULL, @"missing class method %@", NSStringFromSelector(selector));
  return method_getImplementation(method);
}

- (void)drainMainQueue {
  // Flush already-queued main-queue blocks without waiting on a wall-clock timeout.
  XCTestExpectation *drained = [self expectationWithDescription:@"main queue drained"];
  dispatch_async(dispatch_get_main_queue(), ^{
    [drained fulfill];
  });
  [self waitForExpectations:@[ drained ] timeout:2.0];
}

- (void)testSwizzleTurboModuleConversions_nullSentinel_handsNSNullToOriginalIMP {
  Class standIn = [RNFBNullSentinelStandInConvert class];
  SEL selector = @selector(JS_NativeRNFBTurboFunctions_SpecHttpsCallableData:);
  IMP before = [self classMethodIMP:standIn selector:selector];

  [RNFBNullSentinelInterceptor swizzleTurboModuleConversions:standIn];

  IMP after = [self classMethodIMP:standIn selector:selector];
  XCTAssertNotEqual(before, after);

  gLastJsonSeenByOriginalIMP = nil;
  id result = [RNFBNullSentinelStandInConvert
      JS_NativeRNFBTurboFunctions_SpecHttpsCallableData:[self nullSentinel]];
  XCTAssertEqualObjects(gLastJsonSeenByOriginalIMP, [NSNull null]);
  XCTAssertEqualObjects(result, [NSNull null]);
}

- (void)testSwizzleTurboModuleConversions_unrelatedOneKeyDictionary_unchanged {
  Class standIn = [RNFBNullSentinelStandInConvert class];
  [RNFBNullSentinelInterceptor swizzleTurboModuleConversions:standIn];

  gLastJsonSeenByOriginalIMP = nil;
  NSDictionary *payload = [self unrelatedOneKeyDictionary];
  id result =
      [RNFBNullSentinelStandInConvert JS_NativeRNFBTurboFunctions_SpecHttpsCallableData:payload];

  XCTAssertEqualObjects(gLastJsonSeenByOriginalIMP, payload);
  XCTAssertEqualObjects(result, payload);
}

- (void)testScheduleSwizzle_doesNotSwizzleUntilMainQueueRuns {
  Class standIn = [RNFBNullSentinelStandInConvert class];
  SEL selector = @selector(JS_NativeRNFBTurboFunctions_SpecHttpsCallableData:);
  IMP before = [self classMethodIMP:standIn selector:selector];

  dispatch_once_t onceToken = 0;
  [RNFBNullSentinelInterceptor scheduleSwizzleOnMainQueueWithOnceToken:&onceToken
                                                     turboConvertClass:standIn];

  IMP afterSchedule = [self classMethodIMP:standIn selector:selector];
  XCTAssertEqual(before, afterSchedule, @"swizzle must not run synchronously from schedule");

  [self drainMainQueue];

  IMP afterDrain = [self classMethodIMP:standIn selector:selector];
  XCTAssertNotEqual(before, afterDrain, @"swizzle must run once the main queue drains");

  gLastJsonSeenByOriginalIMP = nil;
  [RNFBNullSentinelStandInConvert
      JS_NativeRNFBTurboFunctions_SpecHttpsCallableData:[self nullSentinel]];
  XCTAssertEqualObjects(gLastJsonSeenByOriginalIMP, [NSNull null]);
}

- (void)testScheduleSwizzle_secondCallDoesNotDoubleWrap {
  Class standIn = [RNFBNullSentinelStandInConvert class];
  SEL selector = @selector(JS_NativeRNFBTurboFunctions_SpecHttpsCallableData:);

  dispatch_once_t onceToken = 0;
  [RNFBNullSentinelInterceptor scheduleSwizzleOnMainQueueWithOnceToken:&onceToken
                                                     turboConvertClass:standIn];
  [self drainMainQueue];
  IMP afterFirst = [self classMethodIMP:standIn selector:selector];

  [RNFBNullSentinelInterceptor scheduleSwizzleOnMainQueueWithOnceToken:&onceToken
                                                     turboConvertClass:standIn];
  [self drainMainQueue];
  IMP afterSecond = [self classMethodIMP:standIn selector:selector];

  XCTAssertEqual(afterFirst, afterSecond, @"dispatch_once must prevent a second IMP wrap");
}

- (void)testSwizzleRCTConvertMethods_missingRCTCxxConvert_isNoOp {
  // Host XCTest has no React runtime unless a later test registers a stand-in.
  // Keep this case before testSwizzleRCTConvertMethods_whenRCTCxxConvertPresent_*
  // (alphabetical order) so the nil early-return stays covered.
  XCTAssertNil(NSClassFromString(@"RCTCxxConvert"));
  XCTAssertNoThrow([RNFBNullSentinelInterceptor swizzleRCTConvertMethods]);
}

- (void)testSwizzleRCTConvertMethods_whenRCTCxxConvertPresent_swizzlesSpecMethods {
  Class convertClass = NSClassFromString(@"RCTCxxConvert");
  if (convertClass == Nil) {
    convertClass = objc_allocateClassPair([NSObject class], "RCTCxxConvert", 0);
    XCTAssertNotNil(convertClass);
    Class meta = object_getClass(convertClass);
    SEL selector = sel_registerName("JS_NativeRNFBTurboApp_SpecData:");
    IMP imp = imp_implementationWithBlock(^id(id self, id json) {
      gLastJsonSeenByOriginalIMP = json;
      return json;
    });
    class_addMethod(meta, selector, imp, "@@:@");
    objc_registerClassPair(convertClass);
  }

  SEL selector = sel_registerName("JS_NativeRNFBTurboApp_SpecData:");
  IMP before = [self classMethodIMP:convertClass selector:selector];
  [RNFBNullSentinelInterceptor swizzleRCTConvertMethods];
  IMP after = [self classMethodIMP:convertClass selector:selector];
  XCTAssertNotEqual(before, after);

  gLastJsonSeenByOriginalIMP = nil;
  typedef id (*ConvertFunc)(id, SEL, id);
  ConvertFunc convert = (ConvertFunc)after;
  id result = convert(convertClass, selector, [self nullSentinel]);
  XCTAssertEqualObjects(gLastJsonSeenByOriginalIMP, [NSNull null]);
  XCTAssertEqualObjects(result, [NSNull null]);
}

- (void)testSwizzleTurboModuleConversions_prefixWithoutSpec_leavesIMPUnchanged {
  Class standIn = [RNFBNullSentinelStandInConvert class];
  SEL selector = @selector(JS_NativeRNFBTurboFunctions_NotASpecMethod:);
  IMP before = [self classMethodIMP:standIn selector:selector];
  [RNFBNullSentinelInterceptor swizzleTurboModuleConversions:standIn];
  IMP after = [self classMethodIMP:standIn selector:selector];
  XCTAssertEqual(before, after);
}

@end
