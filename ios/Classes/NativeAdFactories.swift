import Flutter
import UIKit
import GoogleMobileAds
import google_mobile_ads

/**
 * A builder-only Native Ad Factory for iOS.
 * It creates a transparent NativeAdView that serves as a click-tracker
 * for the assets rendered in Flutter.
 */
@objc public class DynamicNativeAdFactory: NSObject, FLTNativeAdFactory {
    private let factoryId: String

    @objc public init(factoryId: String) {
        self.factoryId = factoryId
        super.init()
    }

    public func createNativeAd(_ nativeAd: NativeAd,
                               customOptions: [AnyHashable: Any]?) -> NativeAdView? {
        let adView = NativeAdView()
        
        // Transparent clickable overlay to catch clicks on the native side.
        let overlay = UIButton()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.backgroundColor = .clear
        adView.addSubview(overlay)
        adView.callToActionView = overlay
        
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: adView.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: adView.bottomAnchor),
            overlay.leadingAnchor.constraint(equalTo: adView.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: adView.trailingAnchor)
        ])
        
        adView.nativeAd = nativeAd
        
        // Send assets to Flutter via the plugin channel
        PreloadGoogleAdsPlugin.sendAdAssets(factoryId: factoryId, nativeAd: nativeAd)
        
        return adView
    }
}
