import UIKit
import GoogleMobileAds

class SmallNativeAdView: NativeAdView {

    // Remove @IBOutlet declarations - these properties are inherited from NativeAdView
    // The parent class already provides: iconView, headlineView, bodyView, callToActionView

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    private func setupView() {
        // Set background and styling
        backgroundColor = UIColor.white
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor
        clipsToBounds = true
    }

    func configure(with nativeAd: NativeAd) {
        self.nativeAd = nativeAd

        // Configure headline - cast to UILabel
        if let headlineLabel = headlineView as? UILabel {
            headlineLabel.text = nativeAd.headline
        }

        // Configure body - cast to UILabel
        if let bodyLabel = bodyView as? UILabel {
            bodyLabel.text = nativeAd.body
        }

        // Configure call to action - cast to UIButton
        if let ctaButton = callToActionView as? UIButton {
            ctaButton.setTitle(nativeAd.callToAction?.uppercased(), for: .normal)
            ctaButton.isHidden = (nativeAd.callToAction == nil)
        }

        // Configure icon - cast to UIImageView
        if let iconImageView = iconView as? UIImageView {
            if let icon = nativeAd.icon {
                iconImageView.image = icon.image
                iconImageView.isHidden = false
            } else {
                iconImageView.isHidden = true
            }
        }
    }
}

extension SmallNativeAdView {
    static func fromNib() -> SmallNativeAdView? {
        let bundle = Bundle(for: SmallNativeAdView.self)
        let nib = UINib(nibName: "SNativeView", bundle: bundle)
        return nib.instantiate(withOwner: nil, options: nil).first as? SmallNativeAdView
    }
}