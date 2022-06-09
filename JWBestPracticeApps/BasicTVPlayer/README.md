##  BasicTVPlayer - Best Practices App

The **BasicTVPlayer** project provides minimal setup for a single player item.

### Requirements
- tvOS 14.0+

### Implementation
1. Set your JW Player license key:
    `JWPlayerKitLicense.setLicenseKey("#YOUR_LICENSE_KEY#")`
2. Subclass from `JWCinematicViewController`:
    `class PlayerViewController: JWCinematicViewController`
3. Configure the player:
    ```swift
    // First, build a player item with the stream URL
    let item = try JWPlayerItemBuilder()
        .title("Big Buck Bunny")
        .file(URL(string: videoUrlString)!)
        .build()

    // Second, build a player configuration using the player item
    let config = try JWPlayerConfigurationBuilder()
        .playlist([item])
        .build()
    
    // Last, configure the player
    player.configurePlayer(with: config)```
