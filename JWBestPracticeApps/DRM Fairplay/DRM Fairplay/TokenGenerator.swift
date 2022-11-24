//
//  TokenGenerator.swift
//  DRM Fairplay
//
//  Created by Amitai Blickstein on 11/23/22.
//

import Foundation
import SwiftJWT

/**
 A class external to the demonstration. A JWT can be obtained from many sources (e.g., remote),
 in myriad ways.
 
 
 JWT, headers, claims, etc are all found in JWT's [RFC 7519](https://www.rfc-editor.org/rfc/rfc7519.html). Usage looks something like this:
 ```
 let token = TokenGenerator.createToken(forMediaId: jwtest_mediaId, policyId: jwtest_policyId, expiration: 14400)
 
 let protectedVideoUrl = URL(string:
 "https://cdn.jwplayer.com/v2/media/\(mediaId)/drm/\(policyId)?token=\(token)")!
 
 // In the JWPlayerItemConfigBuilder...
 .file(protectedVideoUrl)
 ```
 */
class TokenGenerator {
    static func createToken(forMediaId mediaId: String, policyId: String, expiration expInSec: TimeInterval) -> String {
        let header = Header() // 'typ' is 'JWT' by default
        
        let claims = StudioDRMClaims(
            exp: Date(timeIntervalSinceNow: expInSec),
            mediaId: mediaId,
            policyId: policyId
        )
        
        // unsigned + signer => signed token
        var unsignedJWT = JWT(header: header, claims: claims)
        let signer = JWTSigner.hs256(key: JWTestAsset.clientSecret.data(using: .utf8)!)
        let signedJWT = try! unsignedJWT.sign(using: signer)
        
        return signedJWT
    }
}

/**
 Conforms to the `Claims` protocol, a requirement for the `SwiftJWT` library. `resource` and `exp` are
 required, as described in the JWPlayer Studio DRM docs.
 */
fileprivate class StudioDRMClaims: Claims {
    /**
     The "exp" (expiration time) claim identifies the expiration time on
     or after which the JWT MUST NOT be accepted for processing.  The
     processing of the "exp" claim requires that the current date/time
     MUST be before the expiration date/time listed in the "exp" claim.
     Implementers MAY provide for some small leeway, usually no more than
     a few minutes, to account for clock skew.
     */
    public var exp: Date?
    
    // required by the StudioDRM platform.
    public var resource: String?
    
    init(exp: Date? = .now + 3600, mediaId mid: String, policyId pid: String) {
        self.exp = exp
        self.resource = "/v2/media/\(mid)/drm/\(pid)"
    }
    
    /**
     The "jti" (JWT ID) claim provides a unique identifier for the JWT.
     The identifier value MUST be assigned in a manner that ensures that
     there is a negligible probability that the same value will be
     accidentally assigned to a different data object; if the application
     uses multiple issuers, collisions MUST be prevented among values
     produced by different issuers as well.  The "jti" claim can be used
     to prevent the JWT from being replayed.  The "jti" value is case-
     sensitive
     */
    public var jti: String? = UUID().uuidString
}
