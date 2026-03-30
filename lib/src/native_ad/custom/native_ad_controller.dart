import '../../ad_internal.dart';

/// Possible states of a [NativeAdController].
enum NativeAdState {
  /// Initial state before any load request.
  idle,

  /// An ad is currently being loaded from the network.
  loading,

  /// An ad has been loaded and assets are available.
  loaded,

  /// The ad failed to load.
  error,

  /// The controller has been disposed.
  disposed,
}

/// Manages the lifecycle of a single custom native ad instance.
///
/// Provides [load], [dispose], [reload] methods and exposes event callbacks
/// for ad lifecycle events. Communicates with the native side via a
/// per-viewId [MethodChannel].
class NativeAdController extends ChangeNotifier {
  /// The platform view ID assigned by the native side.
  int? _viewId;

  /// The per-instance MethodChannel, created in [attach].
  MethodChannel? _instanceChannel;

  /// Current state of the controller.
  NativeAdState _state = NativeAdState.idle;

  /// Returns the current state of the ad.
  NativeAdState get state => _state;

  /// The parsed ad data, available after [NativeAdState.loaded].
  NativeAdData? _adData;

  /// Returns the ad data if loaded, otherwise null.
  NativeAdData? get adData => _adData;

  /// The ad unit ID this controller loads ads for.
  final String adUnitId;

  /// The factory ID this controller belongs to.
  final String? factoryId;

  /// The ad size category string.
  final String adSize;

  /// Optional slot keys that will be attached to the [NativeAdData].
  Map<String, GlobalKey>? slotKeys;

  /// Called when the ad has successfully loaded.
  final VoidCallback? onAdLoaded;

  /// Called when the ad fails to load.
  final void Function(String code, String message)? onAdFailedToLoad;

  /// Called when the user clicks the ad.
  final VoidCallback? onAdClicked;

  /// Called when an impression is recorded by the SDK.
  final VoidCallback? onAdImpression;

  /// Called when the ad opens a full-screen overlay.
  final VoidCallback? onAdOpened;

  /// Called when the full-screen overlay is closed.
  final VoidCallback? onAdClosed;

  /// Constructor for [NativeAdController].
  NativeAdController({
    required this.adUnitId,
    this.factoryId,
    this.adSize = 'custom',
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdClicked,
    this.onAdImpression,
    this.onAdOpened,
    this.onAdClosed,
  });

  /// Associates this controller with a platform view ID.
  void attach(int viewId) {
    _viewId = viewId;

    _instanceChannel = MethodChannel(
      '${NativeAdChannel.channelName}/$viewId',
    );

    _setupChannelHandler();

    if (factoryId != null && _adData == null) {
      final loader = DynamicNativeLoaderManager.instance.getLoader(factoryId!);
      if (loader != null && loader.adAssets.isNotEmpty) {
        final assets = loader.adAssets.removeAt(0);
        _handleAssetsReady(_adAssetsToMap(assets));

        if (loader is DynamicBuilderAdLoader) {
          loader.consumePreloadedAd();
        }

        _instanceChannel!.invokeMethod(NativeAdChannel.methodLoadAd, {
          NativeAdChannel.argViewId: _viewId,
          NativeAdChannel.argAdUnitId: loader.customAdUnitId,
          NativeAdChannel.argSize: adSize,
        });
        return;
      }
    }

    if (_state == NativeAdState.loading || _state == NativeAdState.idle) {
      load();
    }
  }

  Map<dynamic, dynamic> _adAssetsToMap(NativeAdAssets assets) {
    return {
      NativeAdChannel.assetHeadline: assets.headline,
      NativeAdChannel.assetBody: assets.body,
      NativeAdChannel.assetCallToAction: assets.callToAction,
      NativeAdChannel.assetAdvertiser: assets.advertiser,
      NativeAdChannel.assetStore: assets.store,
      NativeAdChannel.assetPrice: assets.price,
      NativeAdChannel.assetRating: assets.rating,
      NativeAdChannel.assetIconBytes: assets.iconBytes,
      NativeAdChannel.assetImages: assets.imageUrls,
      NativeAdChannel.assetHasVideo: assets.hasVideo,
      NativeAdChannel.assetDuration: assets.duration,
      NativeAdChannel.assetAspectRatio: assets.aspectRatio,
    };
  }

  void _setupChannelHandler() {
    _instanceChannel?.setMethodCallHandler((call) async {
      if (_state == NativeAdState.disposed) return;

      final args = call.arguments as Map<dynamic, dynamic>?;

      switch (call.method) {
        case NativeAdChannel.methodOnAdAssetsReady:
          _handleAssetsReady(args!);
          break;
        case NativeAdChannel.methodOnAdLoaded:
          _state = NativeAdState.loaded;
          notifyListeners();
          onAdLoaded?.call();
          break;
        case NativeAdChannel.methodOnAdFailed:
          if (_adData != null) return;
          _state = NativeAdState.error;
          notifyListeners();
          onAdFailedToLoad?.call(
            args?[NativeAdChannel.argErrorCode]?.toString() ?? 'UNKNOWN',
            args?[NativeAdChannel.argErrorMessage]?.toString() ??
                'Unknown error',
          );
          break;
        case NativeAdChannel.methodOnAdClicked:
          onAdClicked?.call();
          break;
        case NativeAdChannel.methodOnAdImpression:
          onAdImpression?.call();
          break;
        case NativeAdChannel.methodOnAdOpened:
          onAdOpened?.call();
          break;
        case NativeAdChannel.methodOnAdClosed:
          onAdClosed?.call();
          break;
      }
    });
  }

  void _handleAssetsReady(Map<dynamic, dynamic> args) {
    _adData = NativeAdData(
      headline: args[NativeAdChannel.assetHeadline] as String?,
      body: args[NativeAdChannel.assetBody] as String?,
      callToAction: args[NativeAdChannel.assetCallToAction] as String?,
      advertiser: args[NativeAdChannel.assetAdvertiser] as String?,
      store: args[NativeAdChannel.assetStore] as String?,
      price: args[NativeAdChannel.assetPrice] as String?,
      rating: (args[NativeAdChannel.assetRating] as num?)?.toDouble(),
      iconBytes: args[NativeAdChannel.assetIconBytes] as Uint8List?,
      imageUrls: args[NativeAdChannel.assetImages] != null
          ? List<String>.from(args[NativeAdChannel.assetImages] as List)
          : const [],
      hasVideo: args[NativeAdChannel.assetHasVideo] as bool? ?? false,
      duration: (args[NativeAdChannel.assetDuration] as num?)?.toDouble(),
      aspectRatio:
          (args[NativeAdChannel.assetAspectRatio] as num?)?.toDouble(),
      mediaView: NativeAdSlot(
        slotName: 'media',
        slotKeys: slotKeys ?? const {},
        child: const AdMediaView(),
      ),
      iconView: NativeAdSlot(
        slotName: 'icon',
        slotKeys: slotKeys ?? const {},
        child: const AdIconView(),
      ),
      slotKeys: slotKeys ?? const {},
      onCTAPressed: () {
        if (_viewId != null) {
          _instanceChannel?.invokeMethod('onCTATapped', {
            NativeAdChannel.argViewId: _viewId,
          });
        }
      },
    );
    _state = NativeAdState.loaded;
    notifyListeners();
    onAdLoaded?.call();
  }

  /// Requests the native side to load an ad.
  Future<void> load() async {
    if (_viewId == null || _state == NativeAdState.disposed) return;
    if (_instanceChannel == null) return;

    _state = NativeAdState.loading;
    _adData = null;
    notifyListeners();

    await _instanceChannel!.invokeMethod(NativeAdChannel.methodLoadAd, {
      NativeAdChannel.argViewId: _viewId,
      NativeAdChannel.argAdUnitId: adUnitId,
      NativeAdChannel.argSize: adSize,
    });
  }

  /// Disposes the current ad and loads a fresh one.
  Future<void> reload() async {
    if (_viewId == null || _state == NativeAdState.disposed) return;
    if (_instanceChannel == null) return;

    await _instanceChannel!.invokeMethod(
      NativeAdChannel.methodDisposeAd,
      {NativeAdChannel.argViewId: _viewId},
    );

    await load();
  }

  /// Sends measured click-area rects to native for SDK asset view registration.
  Future<void> registerClickAreas(
    Map<String, Rect> slots,
    double devicePixelRatio,
  ) async {
    if (_viewId == null || _state == NativeAdState.disposed) return;
    if (_instanceChannel == null) return;

    final physicalSlots = <String, Map<String, double>>{};
    for (final entry in slots.entries) {
      physicalSlots[entry.key] = NativeAdChannel.rectToPhysicalMap(
        entry.value,
        devicePixelRatio,
      );
    }

    await _instanceChannel!.invokeMethod(
      NativeAdChannel.methodRegisterClickAreas,
      {
        NativeAdChannel.argViewId: _viewId,
        NativeAdChannel.argSlots: physicalSlots,
      },
    );
  }

  @override
  void dispose() {
    if (_state != NativeAdState.disposed) {
      _state = NativeAdState.disposed;

      if (_viewId != null && _instanceChannel != null) {
        _instanceChannel!.invokeMethod(
          NativeAdChannel.methodDisposeAd,
          {NativeAdChannel.argViewId: _viewId},
        );
      }

      _instanceChannel?.setMethodCallHandler(null);
      _instanceChannel = null;
    }
    super.dispose();
  }
}
