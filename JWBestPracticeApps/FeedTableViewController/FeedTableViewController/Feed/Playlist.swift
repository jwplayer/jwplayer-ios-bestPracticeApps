//
//  Playlist.swift
//  FeedTableViewController
//
//  Created by Amitai Blickstein on 6/26/22.
//

import Foundation
import JWPlayerKit

/// A structure that provides a hard-coded 'feed' of `JWPlayerItem`s.
struct Playlist {
    /// A hard-coded playlist on the of assets in portrait resolution, with `playlistId`: [V44RvNO4](https://cdn.jwplayer.com/v2/playlists/V44RvNO4)
    static var bpaManual: [JWPlayerItem] = {
        titledSources
            .compactMap {
                try? JWPlayerItemBuilder()
                    .title($0)
                    .file(URL(string: $1)!)
                    .build()
            }
    }()
      
    /// A dictionary of assets in portrait resolution.
    static let titledSources = [
        "Two Girls Having Fun In A Retro Restaurant":
            "https://cdn.jwplayer.com/manifests/fZcd504K.m3u8",
        
        "Computer Fan With Neon Lights":
            "https://cdn.jwplayer.com/manifests/eUTsrVbB.m3u8",
        
        "Little Girl Dressed As An Astronaut Jumping On The Bed":
            "https://cdn.jwplayer.com/manifests/ezBTdlUs.m3u8",
        
        "Lens Focus In Motion":
            "https://cdn.jwplayer.com/manifests/O7oifTAY.m3u8",
        
        "Competitive Woman Playing Together With Other Gamers":
            "https://cdn.jwplayer.com/manifests/ScxgEIPi.m3u8",
    ]
}
