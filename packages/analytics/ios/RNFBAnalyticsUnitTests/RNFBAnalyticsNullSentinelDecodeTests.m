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

/**
 * Declares the testable decode seam compiled from RNFBAnalyticsHelper.m.
 * The unit-test target compiles packages/app/ios/RNFBApp/RNFBSharedUtils.m so the
 * seam calls the production decoder.
 */
@interface RNFBAnalyticsHelper : NSObject
+ (NSDictionary *)decodedParams:(NSDictionary *)params;
@end

@interface RNFBAnalyticsNullSentinelDecodeTests : XCTestCase
@end

@implementation RNFBAnalyticsNullSentinelDecodeTests

- (NSDictionary *)nullSentinel {
  return @{@"__rnfbNull" : @YES};
}

- (NSDictionary *)unrelatedOneKeyDictionary {
  return @{@".sv" : @"timestamp"};
}

- (void)testLogEventParams_childNullSentinel_becomesNSNull {
  NSDictionary *params = @{@"item" : [self nullSentinel], @"value" : @1};
  NSDictionary *decoded = [RNFBAnalyticsHelper decodedParams:params];
  XCTAssertEqualObjects(decoded[@"item"], [NSNull null]);
  XCTAssertEqualObjects(decoded[@"value"], @1);
}

- (void)testSetUserProperties_childNullSentinel_becomesNSNull {
  NSDictionary *properties = @{@"favorite_food" : [self nullSentinel]};
  NSDictionary *decoded = [RNFBAnalyticsHelper decodedParams:properties];
  XCTAssertEqualObjects(decoded[@"favorite_food"], [NSNull null]);
  XCTAssertFalse([decoded[@"favorite_food"] isKindOfClass:[NSDictionary class]]);
}

- (void)testSetDefaultEventParameters_childNullSentinel_becomesNSNull {
  NSDictionary *params = @{@"campaign" : [self nullSentinel]};
  NSDictionary *decoded = [RNFBAnalyticsHelper decodedParams:params];
  XCTAssertEqualObjects(decoded[@"campaign"], [NSNull null]);
}

- (void)testDecodedParams_unrelatedOneKeyDictionary_unchanged {
  NSDictionary *params = @{@"custom" : [self unrelatedOneKeyDictionary]};
  NSDictionary *decoded = [RNFBAnalyticsHelper decodedParams:params];
  XCTAssertEqualObjects(decoded[@"custom"], [self unrelatedOneKeyDictionary]);
}

@end
