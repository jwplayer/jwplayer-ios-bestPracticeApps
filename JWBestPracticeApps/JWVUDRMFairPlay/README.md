The JWVUDRMFairPlay target illustrates how to use our VUDRMFairPlaySDK implementation to play a VUDRM FairPlay encrypted stream.

When a VUDRM FairPlay encrypted stream is loaded with a valid token to the JW Player iOS SDK, the JWDrmDataSource delegate methods are called to request the data required to decrypt the stream. Please note that the data required and the procedures for obtaining the data are specific to your business needs and may not be covered in this demo.

**Note:** FairPlay streams cannot be played on the simulator; you will need to run this target on a device.
