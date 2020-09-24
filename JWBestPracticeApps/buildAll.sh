#!/bin/bash -e
set +x

allTargets=(Casting NativeControls JWAirPlay Voicer JWConviva JWCasting BasicVideoViewController FeedCollectionViewController FeedTableViewController AutoplayVideoFeed GoogleDAI JWFairPlayDrm)
for t in ${allTargets[@]}; do
  echo "Building $t"
  set -o pipefail && xcodebuild -derivedDataPath $(pwd)/DerivedData -workspace JWBestPracticeApps.xcworkspace -scheme $t clean archive -configuration Release -archivePath $(pwd)/$t/build/$t.xcarchive -sdk iphoneos | xcpretty
  set -o pipefail && xcodebuild -allowProvisioningUpdates -exportArchive -archivePath $(pwd)/$t/build/$t.xcarchive -exportOptionsPlist exportOptions.plist -exportPath $(pwd)/$t/build/Release-iphoneos | xcpretty
done

allWatchOsTargets=(JWRemoteCastPlayer JWRemotePlayer)
for t in ${allWatchOsTargets[@]}; do
  echo "Building $t"
  set -o pipefail && xcodebuild -derivedDataPath $(pwd)/DerivedData -workspace JWBestPracticeApps.xcworkspace -scheme $t clean archive -configuration Release -archivePath $(pwd)/$t/build/$t.xcarchive | xcpretty
  set -o pipefail && xcodebuild -allowProvisioningUpdates -exportArchive -archivePath $(pwd)/$t/build/$t.xcarchive -exportOptionsPlist exportOptions.plist -exportPath $(pwd)/$t/build/Release-iphoneos | xcpretty
done