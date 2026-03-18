import Flutter
import UIKit
import GoogleMobileAds

// Protocol that matches google_mobile_ads FLTNativeAdFactory
@objc public protocol FLTNativeAdFactory {
    @objc func createNativeAd(_ nativeAd: NativeAd,
                             customOptions: [AnyHashable: Any]?) -> NativeAdView?
}

public class BaseNativeAdFactory: NSObject {
    var styleMap: [String: Any] = [:]

    public init(styleMap: [String: Any] = [:]) {
        self.styleMap = styleMap
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(onStyleUpdate(_:)), name: NSNotification.Name("PreloadGoogleAds_UpdateStyle"), object: nil)
    }

    @objc func onStyleUpdate(_ notification: Notification) {
        if let newStyle = notification.userInfo as? [String: Any] {
            self.styleMap = newStyle
        }
    }

    func parseColor(_ hex: String?, defaultColor: UIColor = .black) -> UIColor {
        guard let hex = hex else { return defaultColor }
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if cString.count != 6 {
            return defaultColor
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    func applyCommonStyles(adView: NativeAdView, nativeAd: NativeAd) {
        // Headline
        if let headlineView = adView.headlineView as? UILabel {
            headlineView.text = nativeAd.headline
            let titleColorHex = styleMap["title"] as? String
            headlineView.textColor = parseColor(titleColorHex, defaultColor: .black)
        }

        // Body
        if let bodyView = adView.bodyView as? UILabel {
            bodyView.text = nativeAd.body
            bodyView.isHidden = nativeAd.body == nil
            let bodyColorHex = styleMap["description"] as? String
            bodyView.textColor = parseColor(bodyColorHex, defaultColor: .gray)
        }

        // Icon
        if let iconView = adView.iconView as? UIImageView {
            iconView.image = nativeAd.icon?.image
            iconView.isHidden = nativeAd.icon == nil
        }

        // Call to Action
        if let ctaView = adView.callToActionView as? UIButton {
            ctaView.setTitle(nativeAd.callToAction, for: .normal)
            ctaView.isHidden = nativeAd.callToAction == nil
            
            let fgColorHex = styleMap["button_foreground"] as? String
            ctaView.setTitleColor(parseColor(fgColorHex, defaultColor: .white), for: .normal)
            
            let radius = (styleMap["button_radius"] as? NSNumber)?.floatValue ?? 5.0
            ctaView.layer.cornerRadius = CGFloat(radius)
            ctaView.clipsToBounds = true

            applyButtonBackground(button: ctaView)
        }

        // Ad Attribution Tag (Custom View usually)
        if let attributionTag = adView.viewWithTag(100) as? UILabel {
            let tagFgHex = styleMap["tag_foreground"] as? String
            attributionTag.textColor = parseColor(tagFgHex, defaultColor: .white)
            
            let tagBgHex = styleMap["tag_background"] as? String
            attributionTag.backgroundColor = parseColor(tagBgHex, defaultColor: UIColor(red: 0.95, green: 0.60, blue: 0.22, alpha: 1.0))
            
            let tagRadius = (styleMap["tag_radius"] as? NSNumber)?.floatValue ?? 3.0
            attributionTag.layer.cornerRadius = CGFloat(tagRadius)
            attributionTag.clipsToBounds = true
        }

        adView.nativeAd = nativeAd
    }

    private func applyButtonBackground(button: UIButton) {
        let radius = (styleMap["button_radius"] as? NSNumber)?.floatValue ?? 5.0
        
        if let gradients = styleMap["button_gradients"] as? [String], !gradients.isEmpty {
            let colors = gradients.map { parseColor($0).cgColor }
            if colors.count >= 2 {
                if let gradientButton = button as? GradientButton {
                    gradientButton.gradientColors = colors
                    gradientButton.cornerRadius = CGFloat(radius)
                    return
                }
            }
        }
        
        // Fallback to solid color
        let bgColorHex = styleMap["button_background"] as? String
        button.backgroundColor = parseColor(bgColorHex, defaultColor: UIColor(red: 0.13, green: 0.59, blue: 0.95, alpha: 1.0))
        button.layer.cornerRadius = CGFloat(radius)
        if let gradientButton = button as? GradientButton {
            gradientButton.gradientColors = nil
        }
    }
}

class GradientButton: UIButton {
    var gradientColors: [CGColor]? {
        didSet {
            updateGradient()
        }
    }
    var cornerRadius: CGFloat = 5.0 {
        didSet {
            layer.cornerRadius = cornerRadius
            gradientLayer.cornerRadius = cornerRadius
        }
    }
    
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.insertSublayer(gradientLayer, at: 0)
        layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    private func updateGradient() {
        if let colors = gradientColors {
            gradientLayer.colors = colors
            gradientLayer.isHidden = false
            backgroundColor = .clear
        } else {
            gradientLayer.isHidden = true
        }
    }
}

public class NativeAdFactorySmall: BaseNativeAdFactory, FLTNativeAdFactory {
    public override init(styleMap: [String: Any] = [:]) {
        super.init(styleMap: styleMap)
    }

    public func createNativeAd(_ nativeAd: NativeAd,
                             customOptions: [AnyHashable: Any]?) -> NativeAdView? {
        let adView = NativeAdView()
        
        // Simple Programmatic Layout for Small
        let iconView = UIImageView()
        adView.addSubview(iconView)
        adView.iconView = iconView
        
        let headlineView = UILabel()
        headlineView.font = .boldSystemFont(ofSize: 14)
        adView.addSubview(headlineView)
        adView.headlineView = headlineView
        
        let bodyView = UILabel()
        bodyView.font = .systemFont(ofSize: 12)
        bodyView.numberOfLines = 2
        adView.addSubview(bodyView)
        adView.bodyView = bodyView
        
        let ctaButton = GradientButton(type: .custom)
        ctaButton.titleLabel?.font = .boldSystemFont(ofSize: 12)
        adView.addSubview(ctaButton)
        adView.callToActionView = ctaButton
        
        let tagLabel = UILabel()
        tagLabel.text = "Ad"
        tagLabel.font = .systemFont(ofSize: 8)
        tagLabel.textAlignment = .center
        tagLabel.tag = 100 // To find it in applyCommonStyles
        adView.addSubview(tagLabel)

        // Constraints
        iconView.translatesAutoresizingMaskIntoConstraints = false
        headlineView.translatesAutoresizingMaskIntoConstraints = false
        bodyView.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 8),
            iconView.topAnchor.constraint(equalTo: adView.topAnchor, constant: 8),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),
            
            tagLabel.topAnchor.constraint(equalTo: adView.topAnchor, constant: 4),
            tagLabel.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -4),
            tagLabel.widthAnchor.constraint(equalToConstant: 20),
            
            headlineView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            headlineView.topAnchor.constraint(equalTo: adView.topAnchor, constant: 8),
            headlineView.trailingAnchor.constraint(equalTo: tagLabel.leadingAnchor, constant: -4),
            
            bodyView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            bodyView.topAnchor.constraint(equalTo: headlineView.bottomAnchor, constant: 2),
            bodyView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -8),
            
            ctaButton.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 8),
            ctaButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -8),
            ctaButton.topAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: 8),
            ctaButton.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -8),
            ctaButton.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        applyCommonStyles(adView: adView, nativeAd: nativeAd)
        return adView
    }
}

public class NativeAdFactoryMedium: BaseNativeAdFactory, FLTNativeAdFactory {
    public override init(styleMap: [String: Any] = [:]) {
        super.init(styleMap: styleMap)
    }

    public func createNativeAd(_ nativeAd: NativeAd,
                             customOptions: [AnyHashable: Any]?) -> NativeAdView? {
        let adView = NativeAdView()
        
        let mediaView = MediaView()
        adView.addSubview(mediaView)
        adView.mediaView = mediaView
        
        let iconView = UIImageView()
        adView.addSubview(iconView)
        adView.iconView = iconView
        
        let headlineView = UILabel()
        headlineView.font = .boldSystemFont(ofSize: 14)
        adView.addSubview(headlineView)
        adView.headlineView = headlineView
        
        let bodyView = UILabel()
        bodyView.font = .systemFont(ofSize: 12)
        bodyView.numberOfLines = 2
        adView.addSubview(bodyView)
        adView.bodyView = bodyView
        
        let ctaButton = GradientButton(type: .custom)
        ctaButton.titleLabel?.font = .boldSystemFont(ofSize: 12)
        adView.addSubview(ctaButton)
        adView.callToActionView = ctaButton
        
        let tagLabel = UILabel()
        tagLabel.text = "Ad"
        tagLabel.font = .systemFont(ofSize: 8)
        tagLabel.textAlignment = .center
        tagLabel.tag = 100
        adView.addSubview(tagLabel)

        // Constraints
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        headlineView.translatesAutoresizingMaskIntoConstraints = false
        bodyView.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mediaView.topAnchor.constraint(equalTo: adView.topAnchor),
            mediaView.leadingAnchor.constraint(equalTo: adView.leadingAnchor),
            mediaView.trailingAnchor.constraint(equalTo: adView.trailingAnchor),
            mediaView.heightAnchor.constraint(equalTo: adView.widthAnchor, multiplier: 0.5),
            
            iconView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 8),
            iconView.topAnchor.constraint(equalTo: mediaView.bottomAnchor, constant: 8),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),
            
            tagLabel.topAnchor.constraint(equalTo: mediaView.bottomAnchor, constant: 4),
            tagLabel.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -4),
            tagLabel.widthAnchor.constraint(equalToConstant: 20),
            
            headlineView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            headlineView.topAnchor.constraint(equalTo: mediaView.bottomAnchor, constant: 8),
            headlineView.trailingAnchor.constraint(equalTo: tagLabel.leadingAnchor, constant: -4),
            
            bodyView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            bodyView.topAnchor.constraint(equalTo: headlineView.bottomAnchor, constant: 2),
            bodyView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -8),
            
            ctaButton.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 8),
            ctaButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -8),
            ctaButton.topAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: 8),
            ctaButton.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -8),
            ctaButton.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        applyCommonStyles(adView: adView, nativeAd: nativeAd)
        return adView
    }
}
