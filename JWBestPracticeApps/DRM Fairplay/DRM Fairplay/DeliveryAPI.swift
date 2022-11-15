//
//  DeliveryAPI.swift
//  DRM Fairplay
//
//  Created by Amitai Blickstein on 11/14/22.
//

import Foundation

// MARK: - DeliveryAPI
/// `struct` copied straight from [our docs](https://docs.jwplayer.com/players/docs/ios-apply-studio-drm-with-jw-platform#implementation).
struct DeliveryAPI: Codable {
    let title, welcomeDescription, kind: String
    let playlist: [Playlist]
    let feedInstanceID: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case welcomeDescription = "description"
        case kind, playlist
        case feedInstanceID = "feed_instance_id"
    }
}

// MARK: - Playlist
struct Playlist: Codable {
    let title, mediaid: String
    let link: String
    let image: String
    let images: [Image]
    let duration, pubdate: Int
    let playlistDescription: String
    let sources: [Source]
    let tracks: [Track]
    
    enum CodingKeys: String, CodingKey {
        case title, mediaid, link, image, images, duration, pubdate
        case playlistDescription = "description"
        case sources, tracks
    }
}

// MARK: - Image
struct Image: Codable {
    let src: String
    let width: Int
    let type: String
}

// MARK: - Source
struct Source: Codable {
    let drm: DRM
    let file: String
    let type: String
}

// MARK: - DRM
struct DRM: Codable {
    let widevine, playready: Playready?
    let fairplay: Fairplay?
}

// MARK: - Fairplay
struct Fairplay: Codable {
    let processSpcURL, certificateURL: String
    
    enum CodingKeys: String, CodingKey {
        case processSpcURL = "processSpcUrl"
        case certificateURL = "certificateUrl"
    }
}

// MARK: - Playready
struct Playready: Codable {
    let url: String
}

// MARK: - Track
struct Track: Codable {
    let file: String
    let kind: String
}

// MARK: - Helper functions for creating encoders and decoders

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}
