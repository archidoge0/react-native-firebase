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
 * Declares the testable decode seam compiled from RNFBAuthHelper.m under
 * -DRNFB_AUTH_UNIT_TEST (Firebase SDK paths omitted). The unit-test target compiles
 * packages/app/ios/RNFBApp/RNFBSharedUtils.m so the seam calls the production decoder.
 */
@interface RNFBAuthHelper : NSObject
+ (NSDictionary *)decodedProfileProps:(NSDictionary *)props;
@end

@interface RNFBAuthNullSentinelDecodeTests : XCTestCase
@end

@implementation RNFBAuthNullSentinelDecodeTests

- (NSDictionary *)nullSentinel {
  return @{@"__rnfbNull" : @YES};
}

- (NSDictionary *)unrelatedOneKeyDictionary {
  return @{@".sv" : @"timestamp"};
}

- (void)testUpdateProfile_displayNameNullSentinel_becomesNSNull {
  NSDictionary *props = @{@"displayName" : [self nullSentinel]};
  NSDictionary *decoded = [RNFBAuthHelper decodedProfileProps:props];
  XCTAssertEqualObjects(decoded[@"displayName"], [NSNull null]);
  XCTAssertFalse([decoded[@"displayName"] isKindOfClass:[NSDictionary class]]);
}

- (void)testUpdateProfile_photoURLNullSentinel_becomesNSNull {
  NSDictionary *props = @{@"photoURL" : [self nullSentinel]};
  NSDictionary *decoded = [RNFBAuthHelper decodedProfileProps:props];
  XCTAssertEqualObjects(decoded[@"photoURL"], [NSNull null]);
  XCTAssertFalse([decoded[@"photoURL"] isKindOfClass:[NSDictionary class]]);
}

- (void)testUpdateProfile_unrelatedOneKeyDictionary_unchanged {
  NSDictionary *props = @{@"displayName" : [self unrelatedOneKeyDictionary]};
  NSDictionary *decoded = [RNFBAuthHelper decodedProfileProps:props];
  XCTAssertEqualObjects(decoded[@"displayName"], [self unrelatedOneKeyDictionary]);
}

@end
