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
 * Declares the testable decode seams compiled from the production helper .m files under
 * -DRNFB_DATABASE_UNIT_TEST (Firebase SDK paths omitted). The unit-test target compiles
 * packages/app/ios/RNFBApp/RNFBSharedUtils.m so seams call the production decoder.
 */
@interface RNFBDatabaseReferenceHelper : NSObject
+ (id)decodedValueFromProps:(NSDictionary *)props;
+ (id)decodedValuesFromProps:(NSDictionary *)props;
+ (id)decodedPriorityFromProps:(NSDictionary *)props;
@end

@interface RNFBDatabaseOnDisconnectHelper : NSObject
+ (id)decodedValueFromProps:(NSDictionary *)props;
+ (id)decodedValuesFromProps:(NSDictionary *)props;
+ (id)decodedPriorityFromProps:(NSDictionary *)props;
@end

@interface RNFBDatabaseTransactionHelper : NSObject
+ (id)decodedTransactionValue:(id)value;
@end

@interface RNFBDatabaseNullSentinelDecodeTests : XCTestCase
@end

@implementation RNFBDatabaseNullSentinelDecodeTests

- (NSDictionary *)nullSentinel {
  return @{@"__rnfbNull" : @YES};
}

- (NSDictionary *)serverTimestamp {
  return @{@".sv" : @"timestamp"};
}

#pragma mark - Reference helper seams

- (void)testReferenceSet_topLevelNullSentinel_becomesNSNull {
  NSDictionary *props = @{@"value" : [self nullSentinel]};
  XCTAssertEqualObjects([RNFBDatabaseReferenceHelper decodedValueFromProps:props], [NSNull null]);
}

- (void)testReferenceUpdate_childNullSentinel_becomesNSNull {
  NSDictionary *props = @{@"values" : @{@"a" : [self nullSentinel], @"b" : @1}};
  NSDictionary *decoded = [RNFBDatabaseReferenceHelper decodedValuesFromProps:props];
  XCTAssertEqualObjects(decoded[@"a"], [NSNull null]);
  XCTAssertEqualObjects(decoded[@"b"], @1);
}

- (void)testReferenceSetWithPriority_valueAndPrioritySentinels_becomeNSNull {
  NSDictionary *props = @{
    @"value" : [self nullSentinel],
    @"priority" : [self nullSentinel],
  };
  XCTAssertEqualObjects([RNFBDatabaseReferenceHelper decodedValueFromProps:props], [NSNull null]);
  XCTAssertEqualObjects([RNFBDatabaseReferenceHelper decodedPriorityFromProps:props],
                        [NSNull null]);
}

- (void)testReferenceSetPriority_sentinel_becomesNSNull {
  NSDictionary *props = @{@"priority" : [self nullSentinel]};
  XCTAssertEqualObjects([RNFBDatabaseReferenceHelper decodedPriorityFromProps:props],
                        [NSNull null]);
}

- (void)testReference_serverTimestampDictionary_unchanged {
  NSDictionary *props = @{@"value" : [self serverTimestamp]};
  XCTAssertEqualObjects([RNFBDatabaseReferenceHelper decodedValueFromProps:props],
                        [self serverTimestamp]);
}

#pragma mark - OnDisconnect helper seams

- (void)testOnDisconnectSet_topLevelNullSentinel_becomesNSNull {
  NSDictionary *props = @{@"value" : [self nullSentinel]};
  XCTAssertEqualObjects([RNFBDatabaseOnDisconnectHelper decodedValueFromProps:props],
                        [NSNull null]);
}

- (void)testOnDisconnectSetWithPriority_valueAndPrioritySentinels_becomeNSNull {
  NSDictionary *props = @{
    @"value" : [self nullSentinel],
    @"priority" : [self nullSentinel],
  };
  XCTAssertEqualObjects([RNFBDatabaseOnDisconnectHelper decodedValueFromProps:props],
                        [NSNull null]);
  XCTAssertEqualObjects([RNFBDatabaseOnDisconnectHelper decodedPriorityFromProps:props],
                        [NSNull null]);
}

- (void)testOnDisconnectUpdate_childNullSentinel_becomesNSNull {
  NSDictionary *props = @{@"values" : @{@"gone" : [self nullSentinel]}};
  NSDictionary *decoded = [RNFBDatabaseOnDisconnectHelper decodedValuesFromProps:props];
  XCTAssertEqualObjects(decoded[@"gone"], [NSNull null]);
}

- (void)testOnDisconnect_serverTimestampDictionary_unchanged {
  NSDictionary *props = @{@"value" : [self serverTimestamp]};
  XCTAssertEqualObjects([RNFBDatabaseOnDisconnectHelper decodedValueFromProps:props],
                        [self serverTimestamp]);
}

#pragma mark - Transaction helper seam

- (void)testTransactionTryCommit_valueSentinel_becomesNSNull {
  id decoded = [RNFBDatabaseTransactionHelper decodedTransactionValue:[self nullSentinel]];
  XCTAssertEqualObjects(decoded, [NSNull null]);
  XCTAssertFalse([decoded isKindOfClass:[NSDictionary class]]);
}

- (void)testTransactionTryCommit_serverTimestamp_unchanged {
  XCTAssertEqualObjects(
      [RNFBDatabaseTransactionHelper decodedTransactionValue:[self serverTimestamp]],
      [self serverTimestamp]);
}

@end
