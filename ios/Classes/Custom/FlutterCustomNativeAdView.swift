import Flutter
import UIKit
import GoogleMobileAds

/// A transparent native ad view that acts as an overlay on top of Flutter's
/// custom UI. This PlatformView (iOS counterpart of FlutterCustomNativeAdView.kt):
///
/// 1. Creates a transparent NativeAdView container
/// 2. Loads an ad via Google's AdLoader (or picks one from preload cache)
/// 3. Extracts all text assets and sends them to Flutter via FlutterMethodChannel
/// 4. Provides MediaView and UIImageView for sub-platform-view embedding
/// 5. Registers click areas received from Flutter as invisible overlay views
///    that the SDK recognises as headlineView, callToActionView, etc.
///
/// PRELOAD CACHE:
///   `preloadedAds` stores NativeAd objects pre-loaded during plugin init.
///   When a new FlutterCustomNativeAdView is created and calls `loadAd()`,
///   it checks the cache first — if a matching adUnitId is found, the cached
///   ad is used immediately without a network round-trip.
///
/// PER-VIEWID CHANNELS:
///   Channel name is "com.plug.preload/customNativeAd/{viewId}" so multiple
///   ad instances on the same screen never collide. This matches the Android
///   pattern and Flutter's NativeAdController per-viewId channel creation.
class FlutterCustomNativeAdView: NSObject, FlutterPlatformView, NativeAdLoaderDelegate, NativeAdDelegate {

    // MARK: - Static Registry & Cache

    /// Global registry mapping viewId → FlutterCustomNativeAdView.
    ///
    /// Sub-platform-views (MediaView, IconView) look up their parent
    /// by viewId to access the loaded ad's MediaView and icon UIImageView.
    static var registry: [Int: FlutterCustomNativeAdView] = [:]

    /// Preload cache: maps adUnitId → array of pre-loaded NativeAd objects.
    fileprivate static var preloadedAds: [String: [NativeAd]] = [:]

    /// Delegate objects retained during async preload to prevent deallocation.
    fileprivate static var preloadDelegates: [PreloadAdLoaderDelegate] = []

    // MARK: - Preload API

    /// Preloads a native ad and stores it in `preloadedAds` for later use.
    ///
    /// Called from `PreloadGoogleAdsPlugin` during initialization, before
    /// any PlatformView exists. The loaded ad is kept alive in the cache so
    /// the first FlutterCustomNativeAdView that requests this adUnitId can
    /// bind it instantly without a network round-trip.
    ///
    /// Also sends asset data to Flutter via `PreloadGoogleAdsPlugin.sendAdAssets`
    /// so Flutter-side preload listeners can receive the data.
    static func preloadAd(adUnitId: String, factoryId: String) {
        NSLog("FlutterCustomNativeAdView: Preloading builder ad for adUnitId=\(adUnitId)")

        let options = NativeAdViewAdOptions()
        options.preferredAdChoicesPosition = .topRightCorner

        let videoOptions = VideoOptions()
        videoOptions.shouldStartMuted = true

        let rootVC = UIApplication.shared.keyWindow?.rootViewController

        let adLoader = AdLoader(
            adUnitID: adUnitId,
            rootViewController: rootVC,
            adTypes: [.native],
            options: [options, videoOptions]
        )

        let delegate = PreloadAdLoaderDelegate(adUnitId: adUnitId, factoryId: factoryId)
        preloadDelegates.append(delegate)
        adLoader.delegate = delegate
        delegate.adLoader = adLoader

        adLoader.load(Request())
    }

    /// Retrieves and removes a cached pre-loaded ad for the given adUnitId.
    ///
    /// Returns nil if no cached ad is available, in which case the caller
    /// should fall back to loading from network.
    static func getCachedAd(adUnitId: String) -> NativeAd? {
        guard var list = preloadedAds[adUnitId], !list.isEmpty else {
            return nil
        }
        let ad = list.removeFirst()
        if list.isEmpty {
            preloadedAds.removeValue(forKey: adUnitId)
        } else {
            preloadedAds[adUnitId] = list
        }
        return ad
    }

    /// Stores a preloaded ad in the cache.
    fileprivate static func cacheAd(_ ad: NativeAd, forUnitId adUnitId: String) {
        var list = preloadedAds[adUnitId] ?? []
        list.append(ad)
        preloadedAds[adUnitId] = list
    }

    /// Purges the entire preloaded ad cache.
    /// Called when global ad configuration changes or on hot restart to ensure
    /// no stale ads are served from a previous session.
    static func clearCache() {
        preloadDelegates.forEach { $0.adLoader?.delegate = nil }
        preloadDelegates.removeAll()
        preloadedAds.removeAll()
        NSLog("FlutterCustomNativeAdView: Native ad cache cleared")
    }

    // MARK: - Properties

    /// The root NativeAdView — used by the SDK for impression tracking,
    /// AdChoices rendering, and click forwarding.
    private let nativeAdView: NativeAdView

    /// Reference to the loaded ad (needed for proper cleanup on dispose).
    private var nativeAd: NativeAd?

    /// The per-instance MethodChannel — unique per viewId so multiple
    /// ad instances on the same screen never collide.
    private let channel: FlutterMethodChannel

    /// The platform view ID assigned by Flutter.
    private let viewId: Int

    /// The AdLoader used for network ad loading.
    private var adLoader: AdLoader?

    /// Root view controller for ad presentation.
    private weak var rootViewController: UIViewController?

    /// Current adUnitId for cache lookup and reload.
    private var currentAdUnitId: String?

    /// The MediaView instance — created once and reused when sub-platform-views request it.
    /// Must be kept alive for the full lifetime of this PlatformView.
    let mediaView: MediaView = MediaView()

    /// The icon UIImageView — populated when the ad loads.
    let iconImageView: UIImageView = UIImageView()

    /// Track only the overlay views we added for text slots.
    /// This lets us remove just overlays on re-registration without touching
    /// the MediaView or iconImageView, which must stay attached.
    private var overlayViews: [UIView] = []

    /// Track whether MediaView has been added to nativeAdView already,
    /// so we don't double-add it on subsequent registerClickAreas calls.
    private var mediaViewAdded: Bool = false

    // MARK: - Init

    init(
        frame: CGRect,
        viewId: Int,
        messenger: FlutterBinaryMessenger,
        args: [String: Any]?
    ) {
        self.viewId = viewId
        self.channel = FlutterMethodChannel(
            name: "com.plug.preload/customNativeAd/\(viewId)",
            binaryMessenger: messenger
        )

        self.nativeAdView = NativeAdView(frame: frame)
        self.nativeAdView.backgroundColor = .clear
        self.nativeAdView.isOpaque = false

        super.init()

        rootViewController = UIApplication.shared.keyWindow?.rootViewController

        // Register this view instance so sub-views (media, icon factories) can find it.
        FlutterCustomNativeAdView.registry[viewId] = self

        setupChannelHandler()
    }

    func view() -> UIView {
        return nativeAdView
    }

    // MARK: - Channel Handler

    /// Sets up the MethodChannel handler for all Flutter → Native method calls.
    ///
    /// Supported methods:
    /// - loadAd         : Load a new ad (or reload)
    /// - disposeAd      : Destroy the current ad object
    /// - registerClickAreas : Receive slot rects from Flutter and register SDK click targets
    /// - onCTATapped    : Flutter notifies a CTA tap; we forward to SDK's registered view
    private func setupChannelHandler() {
        channel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }

            let args = call.arguments as? [String: Any]

            switch call.method {
            case "loadAd":
                let adUnitId = args?["adUnitId"] as? String ?? ""
                if adUnitId.isEmpty {
                    result(FlutterError(code: "INVALID_AD_UNIT", message: "adUnitId is blank", details: nil))
                    return
                }
                self.currentAdUnitId = adUnitId
                self.loadAd(adUnitId: adUnitId)
                result(nil)

            case "disposeAd":
                self.disposeAd()
                result(nil)

            case "registerClickAreas":
                if let slots = args?["slots"] as? [String: [String: Double]] {
                    self.registerClickAreas(slots: slots)
                    result(nil)
                } else {
                    result(FlutterError(code: "INVALID_SLOTS", message: "slots argument is null or malformed", details: nil))
                }

            case "onCTATapped":
                // Flutter notifies us the user tapped the CTA button.
                // The SDK handles the click action via the registered callToActionView.
                // sendActions triggers the SDK's internal click handler.
                if let ctaView = self.nativeAdView.callToActionView as? UIControl {
                    ctaView.sendActions(for: .touchUpInside)
                }
                result(nil)

            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    // MARK: - Ad Loading

    /// Loads a native ad from AdMob using AdLoader, or from the preload cache.
    ///
    /// PRELOAD CACHE FLOW:
    /// 1. Check `preloadedAds` for a cached ad with this adUnitId.
    /// 2. If found, use it directly — no network request needed.
    /// 3. If not found, load from network via AdLoader.
    private func loadAd(adUnitId: String) {
        // CHECK PRELOAD CACHE FIRST:
        if let cachedAd = FlutterCustomNativeAdView.getCachedAd(adUnitId: adUnitId) {
            NSLog("FlutterCustomNativeAdView: Using preloaded ad for viewId=\(viewId), adUnitId=\(adUnitId)")
            handleAdReceived(cachedAd)
            channel.invokeMethod("onAdLoaded", arguments: ["viewId": viewId])
            return
        }

        // NO CACHED AD — load from network.
        NSLog("FlutterCustomNativeAdView: No cached ad for viewId=\(viewId), loading from network for adUnitId=\(adUnitId)")

        let options = NativeAdViewAdOptions()
        options.preferredAdChoicesPosition = .topRightCorner

        let videoOptions = VideoOptions()
        videoOptions.shouldStartMuted = true

        adLoader = AdLoader(
            adUnitID: adUnitId,
            rootViewController: rootViewController,
            adTypes: [.native],
            options: [options, videoOptions]
        )
        adLoader?.delegate = self
        adLoader?.load(Request())
    }

    // MARK: - NativeAdLoaderDelegate

    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        handleAdReceived(nativeAd)
        channel.invokeMethod("onAdLoaded", arguments: ["viewId": viewId])
    }

    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        let nsError = error as NSError
        NSLog("FlutterCustomNativeAdView: Ad failed to load for viewId=\(viewId): [\(nsError.code)] \(nsError.localizedDescription)")
        channel.invokeMethod("onAdFailed", arguments: [
            "viewId": viewId,
            "errorCode": String(nsError.code),
            "errorMessage": nsError.localizedDescription
        ])
        self.adLoader = nil
    }

    // MARK: - NativeAdDelegate (Ad Event Callbacks)

    func nativeAdDidRecordClick(_ nativeAd: NativeAd) {
        channel.invokeMethod("onAdClicked", arguments: ["viewId": viewId])
    }

    func nativeAdDidRecordImpression(_ nativeAd: NativeAd) {
        channel.invokeMethod("onAdImpression", arguments: ["viewId": viewId])
    }

    func nativeAdWillPresentScreen(_ nativeAd: NativeAd) {
        channel.invokeMethod("onAdOpened", arguments: ["viewId": viewId])
    }

    func nativeAdDidDismissScreen(_ nativeAd: NativeAd) {
        channel.invokeMethod("onAdClosed", arguments: ["viewId": viewId])
    }

    // MARK: - Common Ad Handling

    /// Common handler called when a NativeAd is received — either from cache or network.
    ///
    /// Binds the ad to the NativeAdView, populates MediaView and iconImageView,
    /// and sends all text assets to Flutter.
    private func handleAdReceived(_ nativeAd: NativeAd) {
        // Destroy any previously loaded ad first to prevent memory leaks.
        self.nativeAd = nil
        nativeAdView.nativeAd = nil

        self.nativeAd = nativeAd

        // Set ourselves as the delegate to receive click/impression/open/close callbacks.
        nativeAd.delegate = self

        NSLog("FlutterCustomNativeAdView: Ad received for viewId=\(viewId). hasVideo=\(nativeAd.mediaContent.hasVideoContent), aspect=\(nativeAd.mediaContent.aspectRatio)")

        // Associate the media view with the native ad view immediately.
        nativeAdView.mediaView = mediaView

        // Associate the ad with our NativeAdView.
        // REQUIRED: without this, impression tracking and AdChoices won't work.
        nativeAdView.nativeAd = nativeAd

        // Bind the SDK's MediaView to this ad's media content.
        // This is what enables video playback inside MediaView.
        mediaView.mediaContent = nativeAd.mediaContent
        nativeAdView.mediaView = mediaView

        // Populate the icon UIImageView with the ad's icon image.
        if let iconImage = nativeAd.icon?.image {
            iconImageView.image = iconImage
        }
        nativeAdView.iconView = iconImageView

        // Send all text assets + icon bytes to Flutter.
        sendAssetsToFlutter(nativeAd: nativeAd)
        self.adLoader = nil
    }

    /// Sends all extracted ad assets to Flutter via MethodChannel.
    ///
    /// This populates Flutter's NativeAdData model. All text fields,
    /// icon PNG bytes, and media metadata are sent in one call so Flutter
    /// can build the custom UI with real ad content.
    private func sendAssetsToFlutter(nativeAd: NativeAd) {
        var assets: [String: Any?] = [
            "viewId": viewId,
            "headline": nativeAd.headline,
            "body": nativeAd.body,
            "callToAction": nativeAd.callToAction,
            "advertiser": nativeAd.advertiser,
            "store": nativeAd.store,
            "price": nativeAd.price,
            "rating": nativeAd.starRating?.doubleValue,
            "images": nativeAd.images?.compactMap { $0.imageURL?.absoluteString },
            "hasVideo": nativeAd.mediaContent.hasVideoContent,
            "duration": nativeAd.mediaContent.duration,
            "aspectRatio": Float(nativeAd.mediaContent.aspectRatio)
        ]

        // Convert the icon image to PNG bytes so Flutter can render it
        // as a Flutter Image.memory() widget.
        if let iconData = nativeAd.icon?.image?.pngData() {
            assets["iconBytes"] = FlutterStandardTypedData(bytes: iconData)
        }

        channel.invokeMethod("onAdAssetsReady", arguments: assets)
    }

    // MARK: - Click Registration

    /// Registers click areas received from Flutter as SDK-recognised asset views.
    ///
    /// Flutter measures the screen-space rectangles of each ad slot after layout,
    /// converts them to physical pixels (logical px × devicePixelRatio), and sends
    /// them here.
    ///
    /// HOW IT WORKS:
    /// - Text slots (headline, body, CTA, etc.) get invisible transparent UIView overlays
    ///   positioned at the exact pixel location Flutter reported.
    /// - The MediaView is positioned and added (once) so the SDK can render video
    ///   and track play events.
    /// - The iconImageView is handled the same way as MediaView.
    /// - After placing all views, nativeAd is re-set so the SDK re-scans the hierarchy
    ///   and renders the AdChoices badge correctly.
    ///
    /// Only overlay views are removed on re-registration. MediaView and iconImageView
    /// are repositioned in place, not detached and re-added, so video playback is not interrupted.
    ///
    /// COORDINATE NOTE:
    /// - Flutter sends coordinates in physical pixels (already multiplied by dpr).
    /// - We divide by UIScreen.main.scale to get points for UIKit.
    private func registerClickAreas(slots: [String: [String: Double]]) {
        // Remove only the text/icon overlay views we previously added.
        // Do NOT remove MediaView — removing it interrupts video playback.
        for overlay in overlayViews {
            overlay.removeFromSuperview()
        }
        overlayViews.removeAll()

        let scale = UIScreen.main.scale

        // AdMob requires MediaView to be at least 120pt for video ads.
        let minMediaSizePt: CGFloat = 120.0

        for (slotName, rect) in slots {
            let relX = CGFloat(rect["left"] ?? 0) / scale
            let relY = CGFloat(rect["top"] ?? 0) / scale
            let width = CGFloat(rect["width"] ?? 0) / scale
            let height = CGFloat(rect["height"] ?? 0) / scale

            NSLog("FlutterCustomNativeAdView: viewId=\(viewId) slot=\(slotName): pos=(\(relX), \(relY)) size=(\(width)x\(height))")

            switch slotName {
            case "media":
                // MediaView must be a child of NativeAdView.
                // We add it once and reposition it on subsequent calls.
                let mediaWidth = max(width, minMediaSizePt)
                let mediaHeight = max(height, minMediaSizePt)

                if !mediaViewAdded || mediaView.superview == nil {
                    mediaView.removeFromSuperview()
                    mediaView.frame = CGRect(x: relX, y: relY, width: mediaWidth, height: mediaHeight)
                    nativeAdView.addSubview(mediaView)
                    nativeAdView.mediaView = mediaView
                    mediaViewAdded = true
                    NSLog("FlutterCustomNativeAdView: viewId=\(viewId) added mediaView to hierarchy")
                } else {
                    mediaView.frame = CGRect(x: relX, y: relY, width: mediaWidth, height: mediaHeight)
                }

            case "icon":
                // iconImageView: Add once, reposition on subsequent calls.
                if iconImageView.superview == nil {
                    iconImageView.frame = CGRect(x: relX, y: relY, width: width, height: height)
                    iconImageView.contentMode = .scaleAspectFill
                    iconImageView.clipsToBounds = true
                    nativeAdView.addSubview(iconImageView)
                    nativeAdView.iconView = iconImageView
                    NSLog("FlutterCustomNativeAdView: viewId=\(viewId) added iconImageView to hierarchy")
                } else {
                    iconImageView.frame = CGRect(x: relX, y: relY, width: width, height: height)
                }

            default:
                // Text asset slots: invisible transparent UIView overlays.
                let overlay: UIView
                if slotName == "attribution" {
                    let label = UILabel(frame: CGRect(x: relX, y: relY, width: width, height: height))
                    label.text = "Ad"
                    label.textColor = .clear
                    label.alpha = 1.0
                    overlay = label
                } else {
                    overlay = UIView(frame: CGRect(x: relX, y: relY, width: width, height: height))
                    overlay.alpha = 0.01
                }

                overlay.backgroundColor = .clear
                overlay.isUserInteractionEnabled = true

                nativeAdView.addSubview(overlay)
                overlayViews.append(overlay) // Only text overlays go here for cleanup.

                switch slotName {
                case "headline": nativeAdView.headlineView = overlay
                case "body": nativeAdView.bodyView = overlay
                case "callToAction": nativeAdView.callToActionView = overlay
                case "advertiser": nativeAdView.advertiserView = overlay
                case "store": nativeAdView.storeView = overlay
                case "price": nativeAdView.priceView = overlay
                case "attribution": break // Label already configured above
                default:
                    NSLog("FlutterCustomNativeAdView: Unknown slot name: \(slotName) for viewId=\(viewId)")
                }
            }
        }

        // Re-associate the ad with the NativeAdView after all child views are in place.
        // This triggers the SDK to re-scan the hierarchy, validate asset registrations,
        // and render the AdChoices badge in the correct corner position.
        if let ad = nativeAd {
            nativeAdView.nativeAd = ad
        }

        NSLog("FlutterCustomNativeAdView: registerClickAreas complete for viewId=\(viewId), slots=\(Array(slots.keys))")
    }

    /// Destroys the current NativeAd object to free AdMob SDK resources.
    private func disposeAd() {
        nativeAd?.delegate = nil
        nativeAd = nil
        nativeAdView.nativeAd = nil
        mediaViewAdded = false
        overlayViews.removeAll()
        NSLog("FlutterCustomNativeAdView: Ad disposed for viewId=\(viewId)")
    }

    /// Called when this platform view is removed from the widget tree.
    /// Clean up everything to prevent memory leaks.
    deinit {
        FlutterCustomNativeAdView.registry.removeValue(forKey: viewId)
        nativeAd?.delegate = nil
        nativeAd = nil
        adLoader = nil
        overlayViews.removeAll()
        mediaViewAdded = false
        channel.setMethodCallHandler(nil)
        NSLog("FlutterCustomNativeAdView: Disposed for viewId=\(viewId)")
    }
}

// MARK: - Preload Delegate

/// Standalone delegate for preload ad requests.
/// Retained in `FlutterCustomNativeAdView.preloadDelegates` to prevent deallocation
/// during the async ad load. Automatically cleans up after load completes or fails.
private class PreloadAdLoaderDelegate: NSObject, NativeAdLoaderDelegate {
    let adUnitId: String
    let factoryId: String
    var adLoader: AdLoader?

    init(adUnitId: String, factoryId: String) {
        self.adUnitId = adUnitId
        self.factoryId = factoryId
        super.init()
    }

    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        FlutterCustomNativeAdView.cacheAd(nativeAd, forUnitId: adUnitId)
        NSLog("PreloadAdLoaderDelegate: Successfully cached preloaded ad for adUnitId=\(adUnitId)")
        PreloadGoogleAdsPlugin.sendAdAssets(factoryId: factoryId, nativeAd: nativeAd)
        cleanup()
    }

    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        let nsError = error as NSError
        NSLog("PreloadAdLoaderDelegate: Preload failed for adUnitId=\(adUnitId): [\(nsError.code)] \(nsError.localizedDescription)")
        cleanup()
    }

    private func cleanup() {
        self.adLoader?.delegate = nil
        self.adLoader = nil
        FlutterCustomNativeAdView.preloadDelegates.removeAll { $0 === self }
    }
}
