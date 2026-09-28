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

#if RNFB_DATABASE_UNIT_TEST

#import <Foundation/Foundation.h>
#import "RNFBSharedUtils.h"

@interface RNFBDatabaseReferenceHelper : NSObject
@end

#else

#if __has_include(<Firebase/Firebase.h>)
#import <Firebase/Firebase.h>
#else
@import FirebaseCore;
@import FirebaseDatabaseInternal;
#endif

#import "RNFBApp/RCTConvert+FIRApp.h"
#import "RNFBApp/RNFBSharedUtils.h"
#import "RNFBDatabaseCommon.h"
#import "RNFBDatabaseReferenceHelper.h"

#endif

@implementation RNFBDatabaseReferenceHelper

/**
 * Testable seam: decode New Architecture null sentinels before FIRDatabaseReference writes.
 * Top-level set(null) arrives as props.value = { __rnfbNull: true }.
 */
+ (id)decodedValueFromProps:(NSDictionary *)props {
  return [RNFBSharedUtils decodeNullSentinels:[props valueForKey:@"value"]];
}

+ (id)decodedValuesFromProps:(NSDictionary *)props {
  return [RNFBSharedUtils decodeNullSentinels:[props valueForKey:@"values"]];
}

+ (id)decodedPriorityFromProps:(NSDictionary *)props {
  return [RNFBSharedUtils decodeNullSentinels:[props valueForKey:@"priority"]];
}

#if !RNFB_DATABASE_UNIT_TEST

+ (void)set:(NSString *)app
      dbURL:(NSString *)dbURL
       path:(NSString *)path
      props:(NSDictionary *)props
    resolve:(RCTPromiseResolveBlock)resolve
     reject:(RCTPromiseRejectBlock)reject {
  FIRApp *firebaseApp = [RCTConvert firAppFromString:app];
  FIRDatabase *firDatabase = [RNFBDatabaseCommon getDatabaseForApp:firebaseApp dbURL:dbURL];
  FIRDatabaseReference *firDatabaseReference =
      [RNFBDatabaseCommon getReferenceForDatabase:firDatabase path:path];

  [firDatabaseReference setValue:[self decodedValueFromProps:props]
             withCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
               if (error != nil) {
                 [RNFBDatabaseCommon promiseRejectDatabaseException:reject error:error];
               } else {
                 resolve([NSNull null]);
               }
             }];
}

+ (void)update:(NSString *)app
         dbURL:(NSString *)dbURL
          path:(NSString *)path
         props:(NSDictionary *)props
       resolve:(RCTPromiseResolveBlock)resolve
        reject:(RCTPromiseRejectBlock)reject {
  FIRApp *firebaseApp = [RCTConvert firAppFromString:app];
  FIRDatabase *firDatabase = [RNFBDatabaseCommon getDatabaseForApp:firebaseApp dbURL:dbURL];
  FIRDatabaseReference *firDatabaseReference =
      [RNFBDatabaseCommon getReferenceForDatabase:firDatabase path:path];

  [firDatabaseReference updateChildValues:[self decodedValuesFromProps:props]
                      withCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
                        if (error != nil) {
                          [RNFBDatabaseCommon promiseRejectDatabaseException:reject error:error];
                        } else {
                          resolve([NSNull null]);
                        }
                      }];
}

+ (void)setWithPriority:(NSString *)app
                  dbURL:(NSString *)dbURL
                   path:(NSString *)path
                  props:(NSDictionary *)props
                resolve:(RCTPromiseResolveBlock)resolve
                 reject:(RCTPromiseRejectBlock)reject {
  FIRApp *firebaseApp = [RCTConvert firAppFromString:app];
  FIRDatabase *firDatabase = [RNFBDatabaseCommon getDatabaseForApp:firebaseApp dbURL:dbURL];
  FIRDatabaseReference *firDatabaseReference =
      [RNFBDatabaseCommon getReferenceForDatabase:firDatabase path:path];

  [firDatabaseReference setValue:[self decodedValueFromProps:props]
                     andPriority:[self decodedPriorityFromProps:props]
             withCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
               if (error != nil) {
                 [RNFBDatabaseCommon promiseRejectDatabaseException:reject error:error];
               } else {
                 resolve([NSNull null]);
               }
             }];
}

+ (void)remove:(NSString *)app
         dbURL:(NSString *)dbURL
          path:(NSString *)path
       resolve:(RCTPromiseResolveBlock)resolve
        reject:(RCTPromiseRejectBlock)reject {
  FIRApp *firebaseApp = [RCTConvert firAppFromString:app];
  FIRDatabase *firDatabase = [RNFBDatabaseCommon getDatabaseForApp:firebaseApp dbURL:dbURL];
  FIRDatabaseReference *firDatabaseReference =
      [RNFBDatabaseCommon getReferenceForDatabase:firDatabase path:path];

  [firDatabaseReference
      removeValueWithCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
        if (error != nil) {
          [RNFBDatabaseCommon promiseRejectDatabaseException:reject error:error];
        } else {
          resolve([NSNull null]);
        }
      }];
}

+ (void)setPriority:(NSString *)app
              dbURL:(NSString *)dbURL
               path:(NSString *)path
              props:(NSDictionary *)props
            resolve:(RCTPromiseResolveBlock)resolve
             reject:(RCTPromiseRejectBlock)reject {
  FIRApp *firebaseApp = [RCTConvert firAppFromString:app];
  FIRDatabase *firDatabase = [RNFBDatabaseCommon getDatabaseForApp:firebaseApp dbURL:dbURL];
  FIRDatabaseReference *firDatabaseReference =
      [RNFBDatabaseCommon getReferenceForDatabase:firDatabase path:path];

  [firDatabaseReference setPriority:[self decodedPriorityFromProps:props]
                withCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
                  if (error != nil) {
                    [RNFBDatabaseCommon promiseRejectDatabaseException:reject error:error];
                  } else {
                    resolve([NSNull null]);
                  }
                }];
}

#endif

@end
