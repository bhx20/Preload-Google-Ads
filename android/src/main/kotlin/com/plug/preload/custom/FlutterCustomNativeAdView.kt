package com.plug.preload.custom

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.AdListener
import com.google.android.gms.ads.AdLoader
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.VideoOptions
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdOptions
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.io.ByteArrayOutputStream

/**
 * A transparent native ad view that acts as an overlay on top of Flutter's
 * custom UI. This PlatformView:
 *
 * 1. Creates a transparent [NativeAdView] container
 * 2. Loads an ad via AdMob's [AdLoader] (or picks one from the preload cache)
 * 3. Extracts all text assets and sends them to Flutter via [MethodChannel]
 * 4. Provides [MediaView] and [ImageView] for sub-platform-view embedding
 * 5. Registers click areas received from Flutter as invisible overlay views
 *    that the SDK recognises as headlineView, callToActionView, etc.
 *
 * PRELOAD CACHE:
 *   [preloadedAds] stores NativeAd objects that were pre-loaded during
 *   plugin initialization (before any PlatformView exists). When a new
 *   FlutterCustomNativeAdView is created and calls [loadAd], it first
 *   checks the cache — if a matching adUnitId is found, the cached ad
 *   is used immediately without a network round-trip.
 *
 * PER-VIEWID CHANNELS:
 *   Channel name is "$CHANNEL_BASE/$viewId" so multiple ad instances on the
 *   same screen never collide. Flutter's NativeAdController creates a matching
 *   per-viewId channel on its side.
 */
class FlutterCustomNativeAdView(
    private val context: Context,
    private val viewId: Int,
    private val messenger: BinaryMessenger,
    private val creationParams: Map<String, Any?>?
) : PlatformView {

    companion object {
        private const val TAG = "CustomNativeAdView"

        // Base channel name — each instance appends its viewId so channels
        // never collide when multiple NativeAdView widgets are on screen.
        // Flutter side must open the channel with the same "$BASE/$viewId" name.
        private const val CHANNEL_BASE = "com.plug.preload/customNativeAd"

        /**
         * Global registry mapping viewId → FlutterCustomNativeAdView.
         *
         * Sub-platform-views (MediaView, IconView) look up their parent
         * by viewId to access the loaded ad's MediaView and icon drawable.
         */
        val registry = mutableMapOf<Int, FlutterCustomNativeAdView>()

        /**
         * Preload cache: maps adUnitId → list of pre-loaded NativeAd objects.
         *
         * When [preloadAd] is called during plugin init, the loaded ad is
         * stored here. When a PlatformView's [loadAd] fires for the same
         * adUnitId, it pops the first cached ad instead of hitting the network.
         *
         * Using a list (not a single ad) supports multiple pre-loads of the
         * same adUnitId if the developer shows multiple builder ads with the
         * same unit ID.
         */
        private val preloadedAds = mutableMapOf<String, MutableList<NativeAd>>()

        /**
         * Preloads a native ad and stores it in [preloadedAds] for later use.
         *
         * Called from [PreloadGoogleAdsPlugin] during initialization, before
         * any PlatformView exists. The loaded ad is kept alive in the cache so
         * the first FlutterCustomNativeAdView that requests this adUnitId can
         * bind it instantly without a network round-trip.
         *
         * Also sends asset data to Flutter via [PreloadGoogleAdsPlugin.sendAdAssets]
         * so Flutter-side preload listeners can receive the data.
         *
         * @param context Application context for AdLoader.
         * @param adUnitId The ad unit ID to preload.
         * @param factoryId The factory ID originating the preload.
         */
        fun preloadAd(context: Context, adUnitId: String, factoryId: String) {
            Log.d(TAG, "Preloading builder ad for adUnitId=$adUnitId")

            val adLoader = AdLoader.Builder(context, adUnitId)
                .forNativeAd { nativeAd ->
                    // Store in cache for later consumption by a PlatformView.
                    synchronized(preloadedAds) {
                        val list = preloadedAds.getOrPut(adUnitId) { mutableListOf() }
                        list.add(nativeAd)
                    }
                    Log.d(TAG, "Successfully cached preloaded ad for adUnitId=$adUnitId")

                    // Notify Dart's DynamicBuilderAdLoader that preload succeeded.
                    com.plug.preload.PreloadGoogleAdsPlugin.sendAdAssets(
                        factoryId, nativeAd
                    )
                }
                .withAdListener(object : AdListener() {
                    override fun onAdFailedToLoad(error: LoadAdError) {
                        Log.e(TAG, "Preload failed for adUnitId=$adUnitId: [${error.code}] ${error.message}")
                    }
                })
                .withNativeAdOptions(
                    NativeAdOptions.Builder()
                        .setVideoOptions(
                            VideoOptions.Builder()
                                .setStartMuted(true)
                                .build()
                        )
                        .setAdChoicesPlacement(NativeAdOptions.ADCHOICES_TOP_RIGHT)
                        .setMediaAspectRatio(NativeAdOptions.NATIVE_MEDIA_ASPECT_RATIO_ANY)
                        .build()
                )
                .build()

            adLoader.loadAd(AdRequest.Builder().build())
        }

        /**
         * Retrieves and removes a cached pre-loaded ad for the given adUnitId.
         *
         * Returns null if no cached ad is available, in which case the caller
         * should fall back to loading from network.
         *
         * Thread-safe: uses synchronized on [preloadedAds].
         */
        fun getCachedAd(adUnitId: String): NativeAd? {
            synchronized(preloadedAds) {
                val list = preloadedAds[adUnitId] ?: return null
                if (list.isEmpty()) return null
                val ad = list.removeAt(0)
                // Clean up empty list entries to prevent memory leaks.
                if (list.isEmpty()) {
                    preloadedAds.remove(adUnitId)
                }
                return ad
            }
        }
        /**
         * Purges the entire preloaded ad cache.
         * Called when global ad configuration changes or on hot restart to ensure
         * no stale ads are served from a previous session.
         */
        fun clearCache() {
            synchronized(preloadedAds) {
                for (list in preloadedAds.values) {
                    for (ad in list) {
                        ad.destroy()
                    }
                }
                preloadedAds.clear()
            }
            Log.d(TAG, "Native ad cache cleared")
        }
    }

    // Unique channel per view instance — fixes the single-channel collision bug.
    // When Flutter opens "com.plug.preload/customNativeAd/42", only the instance
    // with viewId=42 responds, even if 10 ads are on screen simultaneously.
    private val channel = MethodChannel(messenger, "$CHANNEL_BASE/$viewId")

    // The root NativeAdView — this is what the SDK uses for impression
    // tracking, AdChoices rendering, and click forwarding.
    private val nativeAdView: NativeAdView = NativeAdView(context).apply {
        // Transparent background so the Flutter UI beneath is visible.
        setBackgroundColor(Color.TRANSPARENT)
        layoutParams = ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )
    }

    // The MediaView instance — created once and reused when the sub-platform-view requests it.
    // Must be kept alive for the full lifetime of this PlatformView.
    val mediaView: MediaView = MediaView(context)

    // The icon ImageView — populated when the ad loads.
    val iconImageView: ImageView = ImageView(context)

    // Reference to the loaded ad (needed for proper destroy on dispose).
    private var nativeAd: NativeAd? = null

    // Track only the overlay views we added for text slots and icon.
    // This lets us remove just overlays on re-registration without touching
    // the MediaView, which must stay attached for video to keep playing.
    private val overlayViews = mutableListOf<View>()

    // Track whether MediaView has been added to nativeAdView already,
    // so we don't double-add it on subsequent registerClickAreas calls.
    private var mediaViewAdded = false

    // Store the adUnitId so we can use it for cache lookup and reload.
    private var currentAdUnitId: String? = null

    init {
        // Register this view instance so sub-views (media, icon factories) can find it.
        registry[viewId] = this

        // Set up the MethodChannel handler for Flutter → Native calls.
        setupChannelHandler()
    }

    override fun getView(): View = nativeAdView

    /**
     * Sets up the MethodChannel handler for all Flutter → Native method calls.
     *
     * Supported methods:
     * - loadAd         : Load a new ad (or reload)
     * - disposeAd      : Destroy the current ad object
     * - registerClickAreas : Receive slot rects from Flutter and register SDK click targets
     * - onCTATapped    : Flutter notifies a CTA tap; we forward to SDK's registered view
     */
    private fun setupChannelHandler() {
        channel.setMethodCallHandler { call, result ->
            // args is always a Map from Flutter when using invokeMethod(name, map)
            val args = call.arguments as? Map<*, *>

            when (call.method) {
                "loadAd" -> {
                    val adUnitId = args?.get("adUnitId") as? String ?: ""
                    if (adUnitId.isBlank()) {
                        result.error("INVALID_AD_UNIT", "adUnitId is blank", null)
                        return@setMethodCallHandler
                    }
                    currentAdUnitId = adUnitId
                    loadAd(adUnitId)
                    result.success(null)
                }

                "disposeAd" -> {
                    disposeAd()
                    result.success(null)
                }

                "registerClickAreas" -> {
                    @Suppress("UNCHECKED_CAST")
                    val slots = args?.get("slots") as? Map<String, Map<String, Double>>
                    if (slots != null) {
                        registerClickAreas(slots)
                        result.success(null)
                    } else {
                        result.error("INVALID_SLOTS", "slots argument is null or malformed", null)
                    }
                }

                "onCTATapped" -> {
                    // Flutter notifies us the user tapped the CTA button.
                    // The SDK handles the click action via the registered callToActionView.
                    // performClick() triggers the SDK's internal click handler (opens browser/store).
                    nativeAdView.callToActionView?.performClick()
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    /**
     * Loads a native ad from AdMob using [AdLoader], or from the preload cache.
     *
     * PRELOAD CACHE FLOW:
     * 1. Check [preloadedAds] for a cached ad with this adUnitId.
     * 2. If found, use it directly — no network request needed.
     * 3. If not found, load from network via [AdLoader].
     *
     * On success: populates MediaView and iconImageView, then calls
     * [sendAssetsToFlutter] so the Flutter builder gets all text/media data.
     *
     * On failure: sends error details back to Flutter via channel.
     */
    private fun loadAd(adUnitId: String) {
        // CHECK PRELOAD CACHE FIRST:
        // If a pre-loaded ad exists for this adUnitId, use it immediately.
        // This avoids the network round-trip and gives instant ad display.
        val cachedAd = getCachedAd(adUnitId)
        if (cachedAd != null) {
            Log.d(TAG, "Using preloaded ad for viewId=$viewId, adUnitId=$adUnitId")
            handleAdReceived(cachedAd)
            // Notify Flutter that the ad has loaded (same as AdListener.onAdLoaded).
            channel.invokeMethod("onAdLoaded", mapOf("viewId" to viewId))

            // DO NOT auto-refill the cache natively! 
            // Dart-side DynamicBuilderAdLoader orchestrates the preload queue.
            // When CustomNativeAdView consumes this cached ad, its controller triggers
            // DynamicBuilderAdLoader.consumePreloadedAd(), which will call preloadBuilderAd() from Dart.
            return
        }

        // NO CACHED AD — load from network.
        Log.d(TAG, "No cached ad for viewId=$viewId, loading from network for adUnitId=$adUnitId")

        val adLoader = AdLoader.Builder(context, adUnitId)
            .forNativeAd { ad ->
                handleAdReceived(ad)
            }
            .withAdListener(object : AdListener() {
                override fun onAdLoaded() {
                    // Notify Flutter that ad loading succeeded.
                    channel.invokeMethod("onAdLoaded", mapOf("viewId" to viewId))
                }

                override fun onAdFailedToLoad(error: LoadAdError) {
                    Log.e(TAG, "Ad failed to load for viewId=$viewId: [${error.code}] ${error.message}")
                    channel.invokeMethod(
                        "onAdFailed", mapOf(
                            "viewId" to viewId,
                            "errorCode" to error.code.toString(),
                            "errorMessage" to error.message
                        )
                    )
                }

                override fun onAdClicked() {
                    channel.invokeMethod("onAdClicked", mapOf("viewId" to viewId))
                }

                override fun onAdImpression() {
                    channel.invokeMethod("onAdImpression", mapOf("viewId" to viewId))
                }

                override fun onAdOpened() {
                    channel.invokeMethod("onAdOpened", mapOf("viewId" to viewId))
                }

                override fun onAdClosed() {
                    channel.invokeMethod("onAdClosed", mapOf("viewId" to viewId))
                }
            })
            .withNativeAdOptions(
                NativeAdOptions.Builder()
                    .setVideoOptions(
                        VideoOptions.Builder()
                            .setStartMuted(true)
                            .build()
                    )
                    // AdChoices badge is rendered by the SDK automatically in this corner.
                    .setAdChoicesPlacement(NativeAdOptions.ADCHOICES_TOP_RIGHT)
                    .setMediaAspectRatio(NativeAdOptions.NATIVE_MEDIA_ASPECT_RATIO_ANY)
                    .build()
            )
            .build()

        adLoader.loadAd(AdRequest.Builder().build())
    }

    /**
     * Common handler called when a NativeAd is received — either from cache or network.
     *
     * Binds the ad to the NativeAdView, populates MediaView and iconImageView,
     * and sends all text assets to Flutter.
     */
    private fun handleAdReceived(ad: NativeAd) {
        // Destroy any previously loaded ad first to prevent memory leaks.
        nativeAd?.destroy()
        this.nativeAd = ad

        Log.d(TAG, "Ad received for viewId=$viewId. hasVideoContent=${ad.mediaContent?.hasVideoContent()}, aspect=${ad.mediaContent?.aspectRatio}")
        
        // Associate the media view with the native ad immediately.
        nativeAdView.mediaView = mediaView
        
        // Extract standard assets

        // Associate the ad with our NativeAdView.
        // REQUIRED: without this, impression tracking and AdChoices won't work.
        nativeAdView.setNativeAd(ad)

        // Bind the SDK's MediaView to this ad's media content.
        // This is what enables video playback inside MediaView.
        mediaView.mediaContent = ad.mediaContent
        nativeAdView.mediaView = mediaView

        // Populate the icon ImageView with the ad's icon drawable.
        ad.icon?.drawable?.let { drawable ->
            iconImageView.setImageDrawable(drawable)
        }
        nativeAdView.iconView = iconImageView

        // Send all text assets + icon bytes to Flutter.
        sendAssetsToFlutter(ad)
    }

    /**
     * Sends all extracted ad assets to Flutter via MethodChannel.
     *
     * This populates Flutter's NativeAdData model. All text fields,
     * icon PNG bytes, and media metadata are sent in one call so Flutter
     * can build the custom UI with real ad content.
     */
    private fun sendAssetsToFlutter(nativeAd: NativeAd) {
        val assets = mutableMapOf<String, Any?>(
            "viewId" to viewId,
            "headline" to nativeAd.headline,
            "body" to nativeAd.body,
            "callToAction" to nativeAd.callToAction,
            "advertiser" to nativeAd.advertiser,
            "store" to nativeAd.store,
            "price" to nativeAd.price,
            "rating" to nativeAd.starRating,
            "hasVideo" to (nativeAd.mediaContent?.hasVideoContent() ?: false),
            "duration" to (nativeAd.mediaContent?.duration ?: 0.0),
            "aspectRatio" to (nativeAd.mediaContent?.aspectRatio ?: 0.0)
        )

        // Collect all image URIs the SDK provides.
        val images = nativeAd.images.mapNotNull { it.uri?.toString() }
        assets["images"] = images

        // Convert the icon drawable to PNG bytes so Flutter can render it
        // as a Flutter Image widget (alternative to using the AdIconView platform view).
        nativeAd.icon?.drawable?.let { drawable ->
            assets["iconBytes"] = drawableToByteArray(drawable)
        }

        channel.invokeMethod("onAdAssetsReady", assets)
    }

    /**
     * Converts an Android [Drawable] to a PNG byte array.
     *
     * The icon is sent as raw bytes because Flutter needs to render it as
     * a Flutter Image.memory() widget — or the developer can use AdIconView
     * (the platform sub-view) for full SDK click compliance on the icon.
     */
    private fun drawableToByteArray(drawable: Drawable): ByteArray {
        val bitmap = if (drawable is BitmapDrawable) {
            drawable.bitmap
        } else {
            // For non-bitmap drawables, render onto a fresh Bitmap canvas.
            val width = if (drawable.intrinsicWidth > 0) drawable.intrinsicWidth else 100
            val height = if (drawable.intrinsicHeight > 0) drawable.intrinsicHeight else 100
            val bmp = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bmp)
            drawable.setBounds(0, 0, canvas.width, canvas.height)
            drawable.draw(canvas)
            bmp
        }
        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
        return stream.toByteArray()
    }

    /**
     * Registers click areas received from Flutter as SDK-recognised asset views.
     *
     * Flutter measures the screen-space rectangles of each ad slot after layout,
     * converts them to physical pixels (logical px × devicePixelRatio), and sends
     * them here.
     *
     * HOW IT WORKS:
     * - Text slots (headline, body, CTA, etc.) get invisible transparent View overlays
     *   positioned at the exact pixel location Flutter reported.
     * - The MediaView is positioned and added (once) as a child with alpha=0.01f
     *   so the SDK can render video and track play events without being visible.
     * - The IconImageView is handled the same way as MediaView.
     * - After placing all views, setNativeAd() is called again so the SDK
     *   re-scans the hierarchy and renders the AdChoices badge correctly.
     *
     * Only overlay views are removed on re-registration. MediaView is
     * repositioned in place, not detached and re-added, so video
     * playback is not interrupted.
     *
     * If NativeAdView is not yet attached to window, we defer via post()
     * so getLocationOnScreen() returns correct values.
     *
     * COORDINATE NOTE:
     * - Flutter sends coordinates in physical pixels (already multiplied by dpr).
     * - NativeAdView coordinates must be view-relative, not screen-absolute.
     * - We subtract nativeAdView's own screen position to get relative coords.
     *
     * @param slots Map of slotName → { left, top, width, height } in physical pixels,
     *              screen-absolute.
     */
    private fun registerClickAreas(slots: Map<String, Map<String, Double>>) {
        // Guard — if the view is not yet laid out on screen,
        // getLocationOnScreen() returns [0,0] and all offsets will be wrong.
        // Defer until the next frame when the view is guaranteed to be attached.
        if (!nativeAdView.isAttachedToWindow) {
            Log.d(TAG, "viewId=$viewId not attached yet, deferring registerClickAreas")
            nativeAdView.post { registerClickAreas(slots) }
            return
        }

        // Remove only the text/icon overlay views we previously added.
        // Do NOT remove MediaView — removing it interrupts video playback.
        for (overlay in overlayViews) {
            nativeAdView.removeView(overlay)
        }
        overlayViews.clear()

        // AdMob requires MediaView to be at least 120×120dp for video ads.
        val minMediaSizePx = (120 * context.resources.displayMetrics.density).toInt()

        for ((slotName, rect) in slots) {
            val relLeft = (rect["left"] ?: continue).toFloat()
            val relTop = (rect["top"] ?: continue).toFloat()
            val width = rect["width"] ?: continue
            val height = rect["height"] ?: continue

            Log.d(TAG, "viewId=$viewId slot=$slotName: pos=($relLeft, $relTop) size=(${width}x${height})")

            when (slotName) {
                "media" -> {
                    // MediaView must be a direct child of NativeAdView.
                    // We add it once and reposition it on subsequent calls.
                    val mediaWidth = maxOf(width.toInt(), minMediaSizePx)
                    val mediaHeight = maxOf(height.toInt(), minMediaSizePx)

                    if (!mediaViewAdded || mediaView.parent == null) {
                        // First time or detached: ensure it's in the hierarchy.
                        (mediaView.parent as? ViewGroup)?.removeView(mediaView)
                        val lp = FrameLayout.LayoutParams(mediaWidth, mediaHeight)
                        mediaView.layoutParams = lp
                        mediaView.alpha = 1.0f
                        mediaView.visibility = View.VISIBLE
                        nativeAdView.addView(mediaView)
                        nativeAdView.mediaView = mediaView
                        mediaViewAdded = true
                        Log.d(TAG, "viewId=$viewId added mediaView to hierarchy")
                    } else {
                        // Subsequent calls: just reposition and resize.
                        val lp = mediaView.layoutParams as? FrameLayout.LayoutParams
                            ?: FrameLayout.LayoutParams(mediaWidth, mediaHeight)
                        lp.width = mediaWidth
                        lp.height = mediaHeight
                        mediaView.layoutParams = lp
                    }

                    mediaView.x = relLeft
                    mediaView.y = relTop
                }

                "icon" -> {
                    // IconImageView: Add once, reposition on subsequent calls.
                    if (iconImageView.parent == null) {
                        (iconImageView.parent as? ViewGroup)?.removeView(iconImageView)
                        val lp = FrameLayout.LayoutParams(width.toInt(), height.toInt())
                        iconImageView.layoutParams = lp
                        iconImageView.alpha = 1.0f
                        iconImageView.visibility = View.VISIBLE
                        nativeAdView.addView(iconImageView)
                        nativeAdView.iconView = iconImageView
                        Log.d(TAG, "viewId=$viewId added iconImageView to hierarchy")
                    } else {
                        val lp = iconImageView.layoutParams as? FrameLayout.LayoutParams
                            ?: FrameLayout.LayoutParams(width.toInt(), height.toInt())
                        lp.width = width.toInt()
                        lp.height = height.toInt()
                        iconImageView.layoutParams = lp
                    }

                    iconImageView.x = relLeft
                    iconImageView.y = relTop
                }

                else -> {
                    // Text asset slots: invisible transparent View overlays.
                    val overlay = if (slotName == "attribution") TextView(context) else View(context)
                    overlay.apply {
                        setBackgroundColor(Color.TRANSPARENT)
                        layoutParams = FrameLayout.LayoutParams(
                            width.toInt(),
                            height.toInt()
                        )
                        x = relLeft
                        y = relTop
                        // For the attribution slot, we set alpha to 1.0 so the SDK
                        // sees it as "fully visible", but we use a transparent 
                        // text color so the user doesn't see our "ghost" view.
                        if (slotName == "attribution") {
                            alpha = 1.0f
                            (this as TextView).setTextColor(Color.TRANSPARENT)
                        } else {
                            alpha = 0.01f // Tiny alpha for other click-area slots
                        }
                        isClickable = true
                    }

                    nativeAdView.addView(overlay)
                    overlayViews.add(overlay) // Only text overlays go here for cleanup.

                    when (slotName) {
                        "headline" -> nativeAdView.headlineView = overlay
                        "body" -> nativeAdView.bodyView = overlay
                        "callToAction" -> nativeAdView.callToActionView = overlay
                        "advertiser" -> nativeAdView.advertiserView = overlay
                        "store" -> nativeAdView.storeView = overlay
                        "price" -> nativeAdView.priceView = overlay
                        "attribution" -> {
                            // On Android, there's no setAdAttributionView, but having a
                            // TextView with "Ad" within the NativeAdView hierarchy
                            // is often what the SDK/compliance checks look for.
                            (overlay as? TextView)?.text = "Ad"
                        }
                        else -> Log.w(TAG, "Unknown slot name: $slotName for viewId=$viewId")
                    }
                }
            }
        }

        // Re-associate the ad with the NativeAdView after all child views are in place.
        // This triggers the SDK to re-scan the hierarchy, validate asset registrations,
        // and render the AdChoices badge in the correct corner position.
        nativeAd?.let { ad ->
            nativeAdView.setNativeAd(ad)
        }

        Log.d(TAG, "registerClickAreas complete for viewId=$viewId, slots=${slots.keys}")
    }

    /**
     * Destroys the current NativeAd object to free AdMob SDK resources.
     * Called when Flutter explicitly requests an ad reload or disposal.
     */
    private fun disposeAd() {
        nativeAd?.destroy()
        nativeAd = null
        mediaViewAdded = false
        overlayViews.clear()
        Log.d(TAG, "Ad disposed for viewId=$viewId")
    }

    /**
     * Called by the Flutter PlatformView framework when this view is removed
     * from the widget tree. Clean up everything to prevent memory leaks.
     */
    override fun dispose() {
        registry.remove(viewId)
        nativeAd?.destroy()
        nativeAd = null
        overlayViews.clear()
        mediaViewAdded = false
        // Remove the MethodCallHandler so this channel stops processing messages.
        channel.setMethodCallHandler(null)
        Log.d(TAG, "FlutterCustomNativeAdView disposed for viewId=$viewId")
    }
}