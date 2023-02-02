//
//  ViewController.swift
//  Google IMA Companion Ads
//
//  Created by David Almaguer on 01/02/23.
//

import UIKit
import JWPlayerKit

class ViewController: UIViewController {

    private weak var jwpvc: PlayerViewController!
    
    @IBOutlet weak var companion970x90: UIView!
    @IBOutlet weak var companion320x100: UIView!
    @IBOutlet weak var companion728x90: UIView!
    @IBOutlet weak var companion970x250: UIView!
    @IBOutlet weak var companion300x250: UIView!
    
    /**
     The **preroll** VAST ad below has companion ads with the following dimensions:
     - 970x90
     - 970x250
     - 728x90
     - 320x100
     */
    private let prerollAdTag = URL(string:"https://pubads.g.doubleclick.net/gampad/ads?slotname=/21769262945/Test_OneD/Test_VOD01&sz=640x480&ciu_szs=970x90,320x100,728x90,970x250&cust_params=&url=&unviewed_position_start=1&output=xml_vast4&impl=s&env=vp&gdfp_req=1&ad_rule=0&video_url_to_fetch=https://oned.net/&useragent=Mozilla/5.0+(Macintosh%3B+Intel+Mac+OS+X+10_15_7)+AppleWebKit/605.1.15+(KHTML,+like+Gecko)+Version/16.2+Safari/605.1.15,gzip(gfe)&vad_type=linear&vpos=preroll&pod=1&ppos=1&min_ad_duration=0&max_ad_duration=300000&vrid=1284172&npa=false&cmsid=2596227&video_doc_id=__item-mediaid__&kfa=0&tfcd=0")!
    /**
     The **midroll** VAST ad below has companion ads with the following dimensions:
     - 300x250
     */
    private let midrollAdTag = URL(string: "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dskippablelinear&correlator=__timestamp__")!
    /**
     The **postroll** VAST ad below has companion ads with the following dimensions:
     - 970x90
     - 970x250
     - 728x90
     - 320x100
     */
    private let postrollAdTag = URL(string: "https://pubads.g.doubleclick.net/gampad/ads?slotname=/21769262945/Test_OneD/Test_VOD01&sz=640x480&ciu_szs=970x90,320x100,728x90,970x250&cust_params=&url=&unviewed_position_start=1&output=xml_vast4&impl=s&env=vp&gdfp_req=1&ad_rule=0&video_url_to_fetch=https://oned.net/&useragent=Mozilla/5.0+(Macintosh%3B+Intel+Mac+OS+X+10_15_7)+AppleWebKit/605.1.15+(KHTML,+like+Gecko)+Version/16.2+Safari/605.1.15,gzip(gfe)&vad_type=linear&vpos=postroll&pod=2&ppos=1&lip=true&min_ad_duration=0&max_ad_duration=300000&vrid=1284172&npa=false&cmsid=2596227&video_doc_id=__item-mediaid__&kfa=0&tfcd=0")!
    
    /*
     Make sure you specify the size of the companion ad you want to include in the view, regardless of the view size.
     
     Note: Be sure to maintain the appropriate view size aspect ratio, so we can ensure your companion ad displays without any distortion.
     */
    var companions: [JWCompanionAdSlot] {
        [
            JWCompanionAdSlot(companion728x90, size: CGSize(width: 728, height: 90)),
            JWCompanionAdSlot(companion970x90, size: CGSize(width: 970, height: 90)),
            JWCompanionAdSlot(companion970x250, size: CGSize(width: 970, height: 250)),
            JWCompanionAdSlot(companion300x250, size: CGSize(width: 300, height: 250)),
            JWCompanionAdSlot(companion320x100, size: CGSize(width: 320, height: 100)),
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPlayer()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PlayerViewController {
            jwpvc = vc
        }
    }

    /**
     Sets up the player with an advertising configuration.
     */
    private func setUpPlayer() {
        do {
            // First, use the JWPlayerItemBuilder to create a JWPlayerItem that will be used by the player configuration.
            let playerItem = try JWPlayerItemBuilder()
                .file(URL(string: "https://content.bitsontherun.com/videos/bkaovAYt-52qL9xLP.mp4")!)
                .build()
            
            // Seconds, use the JWAdBreakBuilder to create JWAdBreaks.
            let prerollAdBreak = try JWAdBreakBuilder()
                .tags([prerollAdTag])
                .offset(.preroll())
                .build()
            let midrollAdBreak = try JWAdBreakBuilder()
                .tags([midrollAdTag])
                .offset(.midroll(seconds: 10))
                .build()
            let postrollAdBreak = try JWAdBreakBuilder()
                .tags([postrollAdTag])
                .offset(.postroll())
                .build()
            
            // Third, Use the JWImaAdvertisingConfigBuilder to create a valid IMA configuration, make sure you pass a VMAP URL or an array of JWAdBreak objects with a valid ad tag configured to return a companion ad.
            let adConfig = try JWImaAdvertisingConfigBuilder()
                // .vmapURL(URL(string: "")!)
                .schedule([prerollAdBreak, midrollAdBreak, postrollAdBreak])
                .companionAdSlots(companions)
                .build()

            // Fourth, create a player config with the created JWPlayerItem and JWAdvertisingConfig.
            let config = try JWPlayerConfigurationBuilder()
                .playlist(items: [playerItem])
                .advertising(adConfig)
                .build()

            // Lastly, use the created JWPlayerConfiguration to set up the player.
            jwpvc.player.configurePlayer(with: config)
        }
        catch {
            // Builders can throw, so be sure to handle build failures.
            print("\(error.localizedDescription)")
        }
    }
}


