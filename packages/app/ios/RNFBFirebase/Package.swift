// swift-tools-version: 5.9
//
// CI probe only (RNFB_TEST_RN_BARE_DYNAMIC_FIREBASE=1). Shipped podspecs keep
// spm_dependency on firebase-ios-sdk. Exact pin tracks packages/app/package.json
// sdkVersions.ios.firebase.

import PackageDescription

let package = Package(
  name: "RNFBFirebase",
  platforms: [
    .iOS(.v15),
    .macOS(.v10_15),
    .tvOS(.v15),
  ],
  products: [
    .library(
      name: "RNFBFirebase",
      type: .dynamic,
      targets: ["RNFBFirebase"]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/firebase/firebase-ios-sdk.git",
      exact: "12.19.0"
    ),
  ],
  targets: [
    .target(
      name: "RNFBFirebase",
      dependencies: [
        .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
        .product(name: "FirebaseInstallations", package: "firebase-ios-sdk"),
      ]
    ),
  ]
)
