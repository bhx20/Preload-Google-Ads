import UIKit
import GoogleMobileAds

class NativeAdsFactory: NSObject {
    
    var nibName: String
    
    init(nibName: String) {
        self.nibName = nibName
        super.init()
    }
    
    func createNativeAdView(with nativeAd: NativeAd) -> NativeAdView? {
        // Create the appropriate view based on nib name
        var nativeAdView: NativeAdView?
        
        switch nibName {
        case "SNativeView":
            nativeAdView = SmallNativeAdView.fromNib()
            if let smallView = nativeAdView as? SmallNativeAdView {
                smallView.configure(with: nativeAd)
            }
        case "MNativeView":
            nativeAdView = MediumNativeAdView.fromNib()
            if let mediumView = nativeAdView as? MediumNativeAdView {
                mediumView.configure(with: nativeAd)
            }
        default:
            print("❌ Unknown nib name: \(nibName)")
            return nil
        }
        
        return nativeAdView
    }
}