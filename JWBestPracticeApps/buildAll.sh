#!/bin/bash -e
set +x

allTargets=(Casting NativeControls JWAirPlay Voicer JWConviva JWCasting BasicVideoViewController FeedCollectionViewController FeedTableViewController AutoplayVideoFeed GoogleDAI JWFairPlayDrm)
for t in ${allTargets[@]}; do
  echo "Building $t"
  set -o pipefail && xcodebuild clean -derivedDataPath $(pwd)/DerivedData -workspace JWBestPracticeApps.xcworkspace -scheme $t -sdk iphoneos OBJROOT=$(pwd)/$t/build SYMROOT=$(pwd)/build PODS_CONFIGURATION_BUILD_DIR=$(pwd)/$t/build | xcpretty
  set -o pipefail && xcodebuild -derivedDataPath $(pwd)/DerivedData -workspace JWBestPracticeApps.xcworkspace -scheme $t -sdk iphoneos OBJROOT=$(pwd)/$t/build SYMROOT=$(pwd)/$t/build PODS_CONFIGURATION_BUILD_DIR=$(pwd)/$t/build | xcpretty
done

allWatchOsTargets=(JWRemoteCastPlayer JWRemotePlayer)
for t in ${allWatchOsTargets[@]}; do
  echo "Building $t"
  set -o pipefail && xcodebuild clean -derivedDataPath $(pwd)/DerivedData -workspace JWBestPracticeApps.xcworkspace -scheme $t OBJROOT=$(pwd)/$t/build SYMROOT=$(pwd)/build PODS_CONFIGURATION_BUILD_DIR=$(pwd)/$t/build | xcpretty
  set -o pipefail && xcodebuild -derivedDataPath $(pwd)/DerivedData -workspace JWBestPracticeApps.xcworkspace -scheme $t OBJROOT=$(pwd)/$t/build SYMROOT=$(pwd)/$t/build PODS_CONFIGURATION_BUILD_DIR=$(pwd)/$t/build | xcpretty
done