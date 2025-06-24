import UIKit
import google_mobile_ads
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    print("🚀 Registering native ad factories...")

    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
      self,
      factoryId: "medium_native",
      nativeAdFactory: MNative()
    )

    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
      self,
      factoryId: "small_native",
      nativeAdFactory: SNative()
    )

    print("✅ Native ad factories registered")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

// MEDIUM NATIVE AD FACTORY
@objc class MNative: NSObject, FLTNativeAdFactory {
  func createNativeAd(_ nativeAd: NativeAd, customOptions: [AnyHashable : Any]? = nil) -> NativeAdView? {

    print("🔧 MNative: Starting createNativeAd")

    // Safety check
    guard let headline = nativeAd.headline, !headline.isEmpty else {
      print("❌ MNative: Invalid native ad data")
      return nil
    }

    print("📊 MNative: Ad data - headline: \(headline)")

    // Try XIB loading with proper error handling
    if let nativeAdView = loadMNativeFromXIB() {
      print("✅ MNative: Loaded from XIB")
      return setupMediumNativeAd(nativeAdView, with: nativeAd)
    } else {
      print("⚠️ MNative: XIB failed, using programmatic view")
      return createProgrammaticMediumView(nativeAd)
    }
  }

  private func loadMNativeFromXIB() -> NativeAdView? {
    print("📱 MNative: Attempting XIB load...")

    guard let bundle = Bundle.main.path(forResource: "MNativeView", ofType: "nib") else {
      print("❌ MNative: MNativeView.nib not found in bundle")
      return nil
    }

    print("✅ MNative: Found XIB at \(bundle)")

    guard let objects = Bundle.main.loadNibNamed("MNativeView", owner: nil, options: nil),
          let nativeAdView = objects.first as? NativeAdView else {
      print("❌ MNative: Failed to load or cast XIB")
      return nil
    }

    print("✅ MNative: Successfully loaded XIB")
    return nativeAdView
  }

  private func setupMediumNativeAd(_ nativeAdView: NativeAdView, with nativeAd: NativeAd) -> NativeAdView {
    print("🔧 MNative: Setting up XIB-loaded view")

    // Set native ad FIRST (critical for Google Ads)
    nativeAdView.nativeAd = nativeAd

    // Safely populate outlets
    if let headlineView = nativeAdView.headlineView as? UILabel {
      headlineView.text = nativeAd.headline
      print("📝 MNative: Set headline")
    }

    if let bodyView = nativeAdView.bodyView as? UILabel {
      bodyView.text = nativeAd.body
      print("📝 MNative: Set body")
    }

    if let iconView = nativeAdView.iconView as? UIImageView {
      iconView.image = nativeAd.icon?.image
      print("🖼️ MNative: Set icon")
    }

    if let mediaView = nativeAdView.mediaView {
      mediaView.mediaContent = nativeAd.mediaContent
      print("🎥 MNative: Set media content")
    }

    if let ctaView = nativeAdView.callToActionView as? UIButton {
      ctaView.setTitle(nativeAd.callToAction, for: .normal)
      ctaView.isUserInteractionEnabled = false
      print("🔘 MNative: Set CTA")
    }

    print("✅ MNative: Setup complete")
    return nativeAdView
  }

  private func createProgrammaticMediumView(_ nativeAd: NativeAd) -> NativeAdView {
    print("🔧 MNative: Creating programmatic fallback")

    let nativeAdView = NativeAdView()
    nativeAdView.backgroundColor = UIColor.white
    nativeAdView.layer.cornerRadius = 8
    nativeAdView.layer.borderWidth = 1
    nativeAdView.layer.borderColor = UIColor.lightGray.cgColor

    // Set fixed size
    nativeAdView.translatesAutoresizingMaskIntoConstraints = false
    nativeAdView.widthAnchor.constraint(equalToConstant: 350).isActive = true
    nativeAdView.heightAnchor.constraint(equalToConstant: 300).isActive = true

    // Create media view
    let mediaView = MediaView()
    mediaView.frame = CGRect(x: 70, y: 20, width: 210, height: 120)
    mediaView.backgroundColor = UIColor.systemGray6
    mediaView.layer.cornerRadius = 8
    mediaView.mediaContent = nativeAd.mediaContent
    nativeAdView.addSubview(mediaView)
    nativeAdView.mediaView = mediaView

    // Create icon
    let iconView = UIImageView()
    iconView.frame = CGRect(x: 20, y: 150, width: 50, height: 50)
    iconView.backgroundColor = UIColor.systemGray5
    iconView.layer.cornerRadius = 8
    iconView.contentMode = .scaleAspectFit
    iconView.image = nativeAd.icon?.image
    nativeAdView.addSubview(iconView)
    nativeAdView.iconView = iconView

    // Create headline
    let headlineLabel = UILabel()
    headlineLabel.frame = CGRect(x: 80, y: 150, width: 250, height: 25)
    headlineLabel.font = UIFont.boldSystemFont(ofSize: 16)
    headlineLabel.text = nativeAd.headline
    nativeAdView.addSubview(headlineLabel)
    nativeAdView.headlineView = headlineLabel

    // Create body
    let bodyLabel = UILabel()
    bodyLabel.frame = CGRect(x: 80, y: 175, width: 250, height: 40)
    bodyLabel.font = UIFont.systemFont(ofSize: 14)
    bodyLabel.numberOfLines = 2
    bodyLabel.text = nativeAd.body
    nativeAdView.addSubview(bodyLabel)
    nativeAdView.bodyView = bodyLabel

    // Create CTA button
    let ctaButton = UIButton(type: .system)
    ctaButton.frame = CGRect(x: 20, y: 230, width: 310, height: 40)
    ctaButton.backgroundColor = UIColor.systemBlue
    ctaButton.setTitleColor(.white, for: .normal)
    ctaButton.layer.cornerRadius = 8
    ctaButton.setTitle(nativeAd.callToAction ?? "Install", for: .normal)
    ctaButton.isUserInteractionEnabled = false
    nativeAdView.addSubview(ctaButton)
    nativeAdView.callToActionView = ctaButton

    // Set native ad LAST
    nativeAdView.nativeAd = nativeAd

    print("✅ MNative: Programmatic view created")
    return nativeAdView
  }
}

// SMALL NATIVE AD FACTORY
@objc class SNative: NSObject, FLTNativeAdFactory {
  func createNativeAd(_ nativeAd: NativeAd, customOptions: [AnyHashable : Any]? = nil) -> NativeAdView? {

    print("🔧 SNative: Starting createNativeAd")

    // Safety check
    guard let headline = nativeAd.headline, !headline.isEmpty else {
      print("❌ SNative: Invalid native ad data")
      return nil
    }

    print("📊 SNative: Ad data - headline: \(headline)")

    // Try XIB loading with proper error handling
    if let nativeAdView = loadSNativeFromXIB() {
      print("✅ SNative: Loaded from XIB")
      return setupSmallNativeAd(nativeAdView, with: nativeAd)
    } else {
      print("⚠️ SNative: XIB failed, using programmatic view")
      return createProgrammaticSmallView(nativeAd)
    }
  }

  private func loadSNativeFromXIB() -> NativeAdView? {
    print("📱 SNative: Attempting XIB load...")

    guard let bundle = Bundle.main.path(forResource: "SNativeView", ofType: "nib") else {
      print("❌ SNative: SNativeView.nib not found in bundle")
      return nil
    }

    print("✅ SNative: Found XIB at \(bundle)")

    guard let objects = Bundle.main.loadNibNamed("SNativeView", owner: nil, options: nil),
          let nativeAdView = objects.first as? NativeAdView else {
      print("❌ SNative: Failed to load or cast XIB")
      return nil
    }

    print("✅ SNative: Successfully loaded XIB")
    return nativeAdView
  }

  private func setupSmallNativeAd(_ nativeAdView: NativeAdView, with nativeAd: NativeAd) -> NativeAdView {
    print("🔧 SNative: Setting up XIB-loaded view")

    // Set native ad FIRST (critical for Google Ads)
    nativeAdView.nativeAd = nativeAd

    // Safely populate outlets
    if let headlineView = nativeAdView.headlineView as? UILabel {
      headlineView.text = nativeAd.headline
      print("📝 SNative: Set headline")
    }

    if let bodyView = nativeAdView.bodyView as? UILabel {
      bodyView.text = nativeAd.body
      print("📝 SNative: Set body")
    }

    if let iconView = nativeAdView.iconView as? UIImageView {
      iconView.image = nativeAd.icon?.image
      print("🖼️ SNative: Set icon")
    }

    if let ctaView = nativeAdView.callToActionView as? UIButton {
      ctaView.setTitle(nativeAd.callToAction, for: .normal)
      ctaView.isUserInteractionEnabled = false
      print("🔘 SNative: Set CTA")
    }

    // Note: SNative XIB doesn't have mediaView, which is correct

    print("✅ SNative: Setup complete")
    return nativeAdView
  }

  private func createProgrammaticSmallView(_ nativeAd: NativeAd) -> NativeAdView {
    print("🔧 SNative: Creating programmatic fallback")

    let nativeAdView = NativeAdView()
    nativeAdView.backgroundColor = UIColor.white
    nativeAdView.layer.cornerRadius = 6
    nativeAdView.layer.borderWidth = 1
    nativeAdView.layer.borderColor = UIColor.lightGray.cgColor

    // Set fixed size
    nativeAdView.translatesAutoresizingMaskIntoConstraints = false
    nativeAdView.widthAnchor.constraint(equalToConstant: 350).isActive = true
    nativeAdView.heightAnchor.constraint(equalToConstant: 120).isActive = true

    // Create icon
    let iconView = UIImageView()
    iconView.frame = CGRect(x: 15, y: 15, width: 50, height: 50)
    iconView.backgroundColor = UIColor.systemGray5
    iconView.layer.cornerRadius = 6
    iconView.contentMode = .scaleAspectFit
    iconView.image = nativeAd.icon?.image
    nativeAdView.addSubview(iconView)
    nativeAdView.iconView = iconView

    // Create headline
    let headlineLabel = UILabel()
    headlineLabel.frame = CGRect(x: 75, y: 15, width: 180, height: 20)
    headlineLabel.font = UIFont.boldSystemFont(ofSize: 16)
    headlineLabel.text = nativeAd.headline
    nativeAdView.addSubview(headlineLabel)
    nativeAdView.headlineView = headlineLabel

    // Create body
    let bodyLabel = UILabel()
    bodyLabel.frame = CGRect(x: 75, y: 35, width: 180, height: 30)
    bodyLabel.font = UIFont.systemFont(ofSize: 14)
    bodyLabel.numberOfLines = 2
    bodyLabel.text = nativeAd.body
    nativeAdView.addSubview(bodyLabel)
    nativeAdView.bodyView = bodyLabel

    // Create CTA button
    let ctaButton = UIButton(type: .system)
    ctaButton.frame = CGRect(x: 265, y: 25, width: 70, height: 30)
    ctaButton.backgroundColor = UIColor.systemBlue
    ctaButton.setTitleColor(.white, for: .normal)
    ctaButton.layer.cornerRadius = 6
    ctaButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
    ctaButton.setTitle(nativeAd.callToAction ?? "Install", for: .normal)
    ctaButton.isUserInteractionEnabled = false
    nativeAdView.addSubview(ctaButton)
    nativeAdView.callToActionView = ctaButton

    // Set native ad LAST
    nativeAdView.nativeAd = nativeAd

    print("✅ SNative: Programmatic view created")
    return nativeAdView
  }
}