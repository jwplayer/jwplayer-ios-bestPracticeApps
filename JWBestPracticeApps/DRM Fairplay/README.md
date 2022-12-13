##  DRM Fairplay - Best Practices App

The DRM Fairplay project illustrates how to use our DRM implementation to play FairPlay encrypted streams. The stream should be a [signed URL](https://docs.jwplayer.com/platform/reference/protect-your-content-with-signed-urls) that you generate for DRM protected content from JW Player StudioDRM.

When a FairPlay encrypted stream is loaded through the `JWPlayerKit` framework, the `JWDRMContentKeyDataSource` protocol methods are called to request the data required to decrypt the stream. Please note that the data required and the procedures for obtaining the data are specific to your business needs and may not be covered in this demo.

> **Note:** FairPlay streams **cannot** be played on the simulator; you will need to run this project on a device.
