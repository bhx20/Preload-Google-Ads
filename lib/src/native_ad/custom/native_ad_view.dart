import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import '../../ad_internal.dart';

/// Possible native ad size categories.
///
/// Maps to native ad request configuration on Android/iOS.
enum NativeAdSize {
  /// Developer-defined custom size.
  custom,
}

/// Builder function type for custom ad UI.
///
/// Receives the [BuildContext] and a populated [NativeAdData] containing
/// all ad assets and platform-view widgets for media/icon.
typedef NativeAdBuilder = Widget Function(
  BuildContext context,
  NativeAdData adData,
);

/// A widget that enables fully customisable native ad rendering in Flutter.
class CustomNativeAdView extends StatefulWidget {
  /// The ad unit ID to load.
  final String? adUnitId;

  /// Factory ID for this ad.
  final String? factoryId;

  /// The requested ad size category.
  final NativeAdSize size;

  /// Builder callback invoked with populated [NativeAdData] when the ad loads.
  final NativeAdBuilder? builder;

  /// Widget to show while the ad is loading or if no ad is available.
  final Widget? fallback;

  /// Called when the ad has successfully loaded.
  final VoidCallback? onAdLoaded;

  /// Called when the ad fails to load.
  final void Function(String code, String message)? onAdFailedToLoad;

  /// Called when the user clicks the ad.
  final VoidCallback? onAdClicked;

  /// Called when an impression is recorded.
  final VoidCallback? onAdImpression;

  /// Called when the ad opens a full-screen overlay.
  final VoidCallback? onAdOpened;

  /// Called when the full-screen overlay closes.
  final VoidCallback? onAdClosed;

  /// Optional external controller.
  final NativeAdController? controller;

  /// The slot keys to use for this ad.
  final Map<String, GlobalKey>? slotKeys;

  /// Constructor for [CustomNativeAdView].
  const CustomNativeAdView({
    super.key,
    this.adUnitId,
    this.factoryId,
    this.size = NativeAdSize.custom,
    this.builder,
    this.fallback,
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdClicked,
    this.onAdImpression,
    this.onAdOpened,
    this.onAdClosed,
    this.controller,
    this.slotKeys,
  }) : assert(
          adUnitId != null || factoryId != null,
          'Either adUnitId or factoryId must be provided',
        );

  @override
  State<CustomNativeAdView> createState() => _CustomNativeAdViewState();
}

class _CustomNativeAdViewState extends State<CustomNativeAdView> {
  late NativeAdController _controller;
  bool _ownsController = false;
  late Map<String, GlobalKey> _slotKeys;

  static const String _viewType = 'com.plug.preload/customNativeAd';

  @override
  void initState() {
    super.initState();

    final resolvedAdUnitId = _resolveAdUnitId();

    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = NativeAdController(
        adUnitId: resolvedAdUnitId,
        factoryId: widget.factoryId,
        adSize: widget.size.name,
        onAdLoaded: widget.onAdLoaded,
        onAdFailedToLoad: widget.onAdFailedToLoad,
        onAdClicked: widget.onAdClicked,
        onAdImpression: widget.onAdImpression,
        onAdOpened: widget.onAdOpened,
        onAdClosed: widget.onAdClosed,
      );
      _ownsController = true;
    }

    _slotKeys = widget.slotKeys ??
        {
          'headline': GlobalKey(debugLabel: 'slot_headline'),
          'body': GlobalKey(debugLabel: 'slot_body'),
          'callToAction': GlobalKey(debugLabel: 'slot_callToAction'),
          'advertiser': GlobalKey(debugLabel: 'slot_advertiser'),
          'store': GlobalKey(debugLabel: 'slot_store'),
          'price': GlobalKey(debugLabel: 'slot_price'),
          'media': GlobalKey(debugLabel: 'slot_media'),
          'icon': GlobalKey(debugLabel: 'slot_icon'),
          'attribution': GlobalKey(debugLabel: 'slot_attribution'),
        };

    _controller.slotKeys = _slotKeys;
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
      if (_controller.state == NativeAdState.loaded &&
          _controller.adData != null) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _measureAndRegisterClickAreas();
        });
      }
    }
  }

  void _measureAndRegisterClickAreas() {
    if (!mounted || _controller.state != NativeAdState.loaded) return;

    final adViewBox = context.findRenderObject() as RenderBox?;
    if (adViewBox == null || !adViewBox.hasSize) return;

    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final slots = <String, ui.Rect>{};

    for (final entry in _slotKeys.entries) {
      final key = entry.value;
      final renderObject = key.currentContext?.findRenderObject();

      if (renderObject is RenderBox && renderObject.hasSize) {
        final localOffset =
            renderObject.localToGlobal(Offset.zero, ancestor: adViewBox);
        final size = renderObject.size;

        slots[entry.key] = ui.Rect.fromLTWH(
          localOffset.dx,
          localOffset.dy,
          size.width,
          size.height,
        );
      }
    }

    if (slots.isNotEmpty) {
      _controller.registerClickAreas(slots, devicePixelRatio);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  String _resolveAdUnitId() {
    if (widget.adUnitId != null) return widget.adUnitId!;

    if (widget.factoryId != null) {
      final loader = DynamicNativeLoaderManager.instance
          .getLoader(widget.factoryId!);
      if (loader != null) {
        return loader.customAdUnitId;
      }
      return AdManager.instance.config.adIDs?.nativeId ?? '';
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    final resolvedAdUnitId = _resolveAdUnitId();

    final creationParams = <String, dynamic>{
      NativeAdChannel.argAdUnitId: resolvedAdUnitId,
      NativeAdChannel.argSize: widget.size.name,
    };

    return Stack(
      children: [
        _buildAdContent(),
        Positioned.fill(
          child: IgnorePointer(
            ignoring: false,
            child: _buildPlatformView(creationParams),
          ),
        ),
      ],
    );
  }

  Widget _buildAdContent() {
    final adData = _controller.adData;

    if (adData == null || _controller.state != NativeAdState.loaded) {
      if (widget.fallback != null) return widget.fallback!;

      double height = 100;
      double? width = double.infinity;

      return SizedBox(
        height: height,
        width: width,
        child: const Center(
          child: CircularProgressIndicator.adaptive(strokeWidth: 2),
        ),
      );
    }

    if (widget.builder == null) {
      return widget.fallback ?? const SizedBox.shrink();
    }

    return _SlotRegistry(
      child: widget.builder!(context, adData),
    );
  }

  Widget _buildPlatformView(Map<String, dynamic> creationParams) {
    if (!kIsWeb && Platform.isAndroid) {
      return PlatformViewLink(
        viewType: _viewType,
        surfaceFactory: (context, controller) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.transparent,
          );
        },
        onCreatePlatformView: (params) {
          return PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            viewType: _viewType,
            layoutDirection: TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onFocus: () => params.onFocusChanged(true),
          )
            ..addOnPlatformViewCreatedListener((id) {
              params.onPlatformViewCreated(id);
              _onPlatformViewCreated(id);
            })
            ..create();
        },
      );
    } else if (!kIsWeb && Platform.isIOS) {
      return UiKitView(
        viewType: _viewType,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }

    return const SizedBox.shrink();
  }

  void _onPlatformViewCreated(int viewId) {
    _controller.attach(viewId);
  }
}

/// A wrapper widget that registers a specific ad slot with a GlobalKey.
class NativeAdSlot extends StatelessWidget {
  /// The name of the slot (e.g., 'headline', 'body').
  final String slotName;

  /// The map of slot keys from [NativeAdData].
  final Map<String, GlobalKey> slotKeys;

  /// The child widget to wrap.
  final Widget child;

  /// Constructor for [NativeAdSlot].
  const NativeAdSlot({
    super.key,
    required this.slotName,
    required this.slotKeys,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final registry = _SlotRegistry.of(context);
    if (registry != null) {
      assert(
        !registry.registeredSlots.contains(slotName),
        'Duplicate slot registration detected: "$slotName"',
      );
      registry.registeredSlots.add(slotName);
    }

    final key = slotKeys[slotName];
    if (key != null) {
      return KeyedSubtree(key: key, child: child);
    }
    return child;
  }
}

class _SlotRegistry extends InheritedWidget {
  final Set<String> registeredSlots = <String>{};
  _SlotRegistry({required super.child});

  static _SlotRegistry? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_SlotRegistry>();
  }

  @override
  bool updateShouldNotify(_SlotRegistry oldWidget) => false;
}

/// A convenience widget for the ad headline.
class PreloadHeadline extends StatelessWidget {
  /// The loaded ad data.
  final NativeAdData adData;

  /// Builder for the headline text.
  final Widget Function(String headline) builder;

  /// Constructor for [PreloadHeadline].
  const PreloadHeadline({
    super.key,
    required this.adData,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final text = adData.headline;
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    return NativeAdSlot(
      slotName: 'headline',
      slotKeys: adData.slotKeys,
      child: builder(text),
    );
  }
}

/// A convenience widget for the ad body.
class PreloadBody extends StatelessWidget {
  /// The loaded ad data.
  final NativeAdData adData;

  /// Builder for the body text.
  final Widget Function(String body) builder;

  /// Constructor for [PreloadBody].
  const PreloadBody({
    super.key,
    required this.adData,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final text = adData.body;
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    return NativeAdSlot(
      slotName: 'body',
      slotKeys: adData.slotKeys,
      child: builder(text),
    );
  }
}

/// A convenience widget for the ad call to action.
class PreloadCallToAction extends StatelessWidget {
  /// The loaded ad data.
  final NativeAdData adData;

  /// Builder for the CTA text.
  final Widget Function(String cta) builder;

  /// Constructor for [PreloadCallToAction].
  const PreloadCallToAction({
    super.key,
    required this.adData,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final text = adData.callToAction;
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    return NativeAdSlot(
      slotName: 'callToAction',
      slotKeys: adData.slotKeys,
      child: builder(text),
    );
  }
}

/// A convenience widget for the ad advertiser.
class PreloadAdvertiser extends StatelessWidget {
  /// The loaded ad data.
  final NativeAdData adData;

  /// Builder for the advertiser text.
  final Widget Function(String advertiser) builder;

  /// Constructor for [PreloadAdvertiser].
  const PreloadAdvertiser({
    super.key,
    required this.adData,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final text = adData.advertiser;
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    return NativeAdSlot(
      slotName: 'advertiser',
      slotKeys: adData.slotKeys,
      child: builder(text),
    );
  }
}

/// A convenience widget for the ad price.
class PreloadPrice extends StatelessWidget {
  /// The loaded ad data.
  final NativeAdData adData;

  /// Builder for the price text.
  final Widget Function(String price) builder;

  /// Constructor for [PreloadPrice].
  const PreloadPrice({
    super.key,
    required this.adData,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final text = adData.price;
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    return NativeAdSlot(
      slotName: 'price',
      slotKeys: adData.slotKeys,
      child: builder(text),
    );
  }
}

/// A convenience widget for the ad store.
class PreloadStore extends StatelessWidget {
  /// The loaded ad data.
  final NativeAdData adData;

  /// Builder for the store text.
  final Widget Function(String store) builder;

  /// Constructor for [PreloadStore].
  const PreloadStore({
    super.key,
    required this.adData,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final text = adData.store;
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    return NativeAdSlot(
      slotName: 'store',
      slotKeys: adData.slotKeys,
      child: builder(text),
    );
  }
}

/// A convenience widget for the ad attribution badge.
class PreloadAttribution extends StatelessWidget {
  /// The loaded ad data.
  final NativeAdData adData;

  /// Optional custom builder for the attribution badge.
  final Widget Function()? builder;

  /// Constructor for [PreloadAttribution].
  const PreloadAttribution({
    super.key,
    required this.adData,
    this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return NativeAdSlot(
      slotName: 'attribution',
      slotKeys: adData.slotKeys,
      child: builder?.call() ?? const PreloadAdBadge(),
    );
  }
}
