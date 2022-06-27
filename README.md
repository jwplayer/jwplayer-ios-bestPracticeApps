# JWPlayerKit 4.x Best Practice Apps

This repository contains samples relating to the JWPlayerKit SDK version 4.x for iOS and JWPlayerTVKit SDK version 4.x for tvOS. 

## BestPracticeApps

The BestPracticeApps [workspace](https://developer.apple.com/documentation/xcode/managing-multiple-projects-and-their-dependencies) is composed of several projects (with corresponding targets), each of which runs as a separate application.

|Platform | Project | Description|
| ------------- | ------------- | ------------- |
|`iOS`|[Advanced Player](https://github.com/jwplayer/jwplayer-ios-bestPracticeApps/tree/main/JWBestPracticeApps/AdvancedPlayer) | Advanced implementation of JWPlayerKit SDK with VAST ads. |
|`iOS`|[Basic Player](https://github.com/jwplayer/jwplayer-ios-bestPracticeApps/tree/main/JWBestPracticeApps/BasicPlayer) | Simple implementation of JWPlayerKit SDK with a single player item. |
|`tvOS`|[BasicTVPlayer](https://github.com/jwplayer/jwplayer-ios-bestPracticeApps/tree/main/JWBestPracticeApps/BasicTVPlayer) | Simple implementation of JWPlayerTVKit SDK with a single player item. |
|`iOS`|[ChromeCast](https://github.com/jwplayer/jwplayer-ios-bestPracticeApps/tree/main/JWBestPracticeApps/ChromeCast) | Simple implementation including the ability to cast to ChromeCast devices.[^chromecastDisclaimer]  |
|`iOS`|[ChromeCast-GCKUICastButton](https://github.com/jwplayer/jwplayer-ios-bestPracticeApps/tree/main/JWBestPracticeApps/Chromecast-GCKUICastButton) | Simple implementation using the cast button provided by the ChromeCast framework to cast to ChromeCast devices.[^chromecastDisclaimer] |
|`iOS`|[Custom UI](https://github.com/jwplayer/jwplayer-ios-bestPracticeApps/tree/main/JWBestPracticeApps/Custom%20UI) | Demonstrates how to create a basic user interface from scratch, using only JWPlayerView. |
|`iOS`|[DRM Fairplay](https://github.com/jwplayer/jwplayer-ios-bestPracticeApps/tree/main/JWBestPracticeApps/DRM%20Fairplay#drm-fairplay---best-practices-app)  | Simple implementation of JWPlayerKit SDK that plays protected video content through FairPlay (DRM). |
|`iOS`|[Google IMA Ads](https://github.com/jwplayer/jwplayer-ios-bestPracticeApps/tree/main/JWBestPracticeApps/Google%20IMA%20Ads#google-ima-ads---best-practices-app) | Simple implementation of JWPlayerKit SDK with Google IMA. |
|`iOS`|[Google DAI Ads](https://github.com/jwplayer/jwplayer-ios-bestPracticeApps/tree/main/JWBestPracticeApps/Google%20DAI%20Ads#google-dai-ads---best-practices-app) | Simple implementation of JWPlayerKit SDK with Google DAI. |
|`iOS`|[JWPlayer Ads](https://github.com/jwplayer/jwplayer-ios-bestPracticeApps/tree/main/JWBestPracticeApps/JWPlayer%20Ads#jwplayer-ads---best-practices-app) | Simple implementation of JWPlayerKit SDK with advertising. |
|`iOS`|[Recommendations](https://github.com/jwplayer/jwplayer-ios-bestPracticeApps/tree/main/JWBestPracticeApps/Recommendations) | Simple implementation including recommended related content. |
|`iOS`|[Picture in Picture](https://github.com/jwplayer/jwplayer-ios-bestPracticeApps/tree/main/JWBestPracticeApps/Picture%20in%20Picture) | Demonstrates how to enable Picture in Picture. |

[^chromecastDisclaimer]: Unlike the other apps in this project which are *working* code examples, this app is a valid code example that nevertheless does **not** work as-is. 
Rather, it requires the **dynamic** build of the Google Cast SDK. As Google does not distribute this via CocoaPods, it must be [added manually](https://developers.google.com/cast/docs/ios_sender#manual_setup) to a given project — as we do not include external frameworks in our repositories. Please refer to our [documentation](https://developer.jwplayer.com/jwplayer/docs/ios-enable-casting-to-chromecast-devices) for more information.

## Setup

| :information_source: The project uses [cocoapods](https://guides.cocoapods.org/using/getting-started.html) to manage dependencies. |
|-|

#### Steps to compile:
1. Make sure Xcode is closed.
1. In the Terminal app, navigate to the project's root directory.
1. To download and integrate the dependencies in the project, run: 
    ```console
    pod install
    ```
1. Open `JWBestPracticeApps-4x.xcworkspace`.
1. Add your [JWPlayer iOS SDK license key](https://support.jwplayer.com/articles/android-and-ios-sdk-reference#:~:text=HOW%20DO%20I%20GET%20THE%20IOS%20OR%20ANDROID%20SDK%3F%20HOW%20DO%20I%20USE%20THE%20SDKS%3F) to the AppDelegate for the target project:
    ```swift 
    JWPlayerKitLicense.setLicenseKey(<#Your License Key#>)
    ```
Now you can build and run the project.

---
| :warning: Looking for SDK version 3.x?  | 
|-|
| The demo apps in this repository are intended to be used with **version 4.x** of the JWPlayerKit iOS SDK. <br> For information on JWPlayer SDK **version 3.x** BestPracticeApps, go to [this link](https://github.com/jwplayer/jwplayer-ios-bestPracticeApps/tree/main-v3/). | 

