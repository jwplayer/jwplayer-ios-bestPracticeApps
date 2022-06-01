# JWPlayerKit 4.0.0 Best Practice Apps

This repository contains samples relating to the JWPlayerKit SDK version 4.0.0 for iOS. 

## BestPracticeApps

This BestPractice project is composed of several targets which can be run as separate iOS applications.
Showcasing functionality for the JWPlayerKit 4.0.0 SDK in each project.

|Project | Description|
| ------------- | ------------- |
|[Advanced Player](https://github.com/jwplayer/jwplayer-ios-bestPracticeApps/tree/main/JWBestPracticeApps/AdvancedPlayer) | Advanced implementation of JWPlayerKit SDK with VAST ads. |
|[Basic Player](https://github.com/jwplayer/jwplayer-ios-bestPracticeApps/tree/main/JWBestPracticeApps/BasicPlayer) | Simple implementation of JWPlayerKit SDK with a single player item. |
|[ChromeCast](https://github.com/jwplayer/jwplayer-ios-bestPracticeApps/tree/main/JWBestPracticeApps/ChromeCast) | Simple implementation including the ability to cast to ChromeCast devices. This app shows what needs to be done to get it to work, but requires that the dynamic build of the Google Cast SDK be included in the project, because we do not include that framework in our repository. Please refer to our [documentation](https://developer.jwplayer.com/jwplayer/docs/ios-enable-casting-to-chromecast-devices) for more information. |
|[ChromeCast-GCKUICastButton](https://github.com/jwplayer/jwplayer-ios-bestPracticeApps/tree/main/JWBestPracticeApps/Chromecast-GCKUICastButton) | Simple implementation using the cast button provided by the ChromeCast framework to cast to ChromeCast devices. This app shows what needs to be done to get it to work, but requires that the dynamic build of the Google Cast SDK be included in the project, because we do not include that framework in our repository. Please refer to our [documentation](https://developer.jwplayer.com/jwplayer/docs/ios-enable-casting-to-chromecast-devices) for more information. |
|[Custom UI](https://github.com/jwplayer/jwplayer-ios-bestPracticeApps/tree/main/JWBestPracticeApps/Custom%20UI) | Demonstrates how to create a basic user interface from scratch, using only JWPlayerView. |
|[DRM Fairplay](https://github.com/jwplayer/jwplayer-ios-bestPracticeApps/tree/main/JWBestPracticeApps/DRM%20Fairplay#drm-fairplay---best-practices-app)  | Simple implementation of JWPlayerKit SDK that plays protected video content through FairPlay (DRM). |
|[Google IMA Ads](https://github.com/jwplayer/jwplayer-ios-bestPracticeApps/tree/main/JWBestPracticeApps/Google%20IMA%20Ads#google-ima-ads---best-practices-app) | Simple implementation of JWPlayerKit SDK with Google IMA. |
|[Google DAI Ads](https://github.com/jwplayer/jwplayer-ios-bestPracticeApps/tree/main/JWBestPracticeApps/Google%20DAI%20Ads#google-dai-ads---best-practices-app) | Simple implementation of JWPlayerKit SDK with Google DAI. |
|[JWPlayer Ads](https://github.com/jwplayer/jwplayer-ios-bestPracticeApps/tree/main/JWBestPracticeApps/JWPlayer%20Ads#jwplayer-ads---best-practices-app) | Simple implementation of JWPlayerKit SDK with advertising. |
|[Recommendations](https://github.com/jwplayer/jwplayer-ios-bestPracticeApps/tree/main/JWBestPracticeApps/Recommendations) | Simple implementation including recommended related content. |
|[Picture in Picture](https://github.com/jwplayer/jwplayer-ios-bestPracticeApps/tree/main/JWBestPracticeApps/Picture%20in%20Picture) | Demonstrates how to enable Picture in Picture. |

## Setup

Before compiling, this uses some pod dependencies so you will require [cocoapods](https://guides.cocoapods.org/using/getting-started.html) in you machine.

Steps to compile:
* Make sure your Xcode is closed.
* In the terminal.app, in the project directory root.
* Run:
```console
pod install
```
* This should update the dependencies in your Pods
* Now open the `.xcworkspace`


Add your JWPlayer license key to the AppDelegate for the target project.

Here:
```swift 
JWPlayerKitLicense.setLicenseKey(<#Your License Key#>)
```

And run and build the project.

**Note**: The demo apps in this repository are intended to be used with **version 4.0.0** of the JWPlayerKit iOS SDK.

For information on JWPlayer SDK **version 3.*** BestPracticeApps go to [this link](https://github.com/jwplayer/jwplayer-ios-bestPracticeApps/tree/main-v3/).

