import 'package:google_fonts/google_fonts.dart';
import 'package:preload_google_ads/preload_google_ads.dart';

/// A helper class to build custom native ads using the builder pattern.
class AdBuilderPreview {
  /// Builds a custom native ad view with a fully custom Flutter UI.
  static Widget buildCustomNativeAdView(BuildContext context) {
    return PreloadGoogleAds.instance.showBuilderNativeAd(
      factoryId: 'builder_custom',
      size: NativeAdSize.custom,
      adUnitId: AdTestIds.nativeVideo,
      builder: (context, adData) {
        final theme = Theme.of(context);
        return Container(
          padding: const EdgeInsets.all(16),
          decoration:BoxDecoration(
            image: DecorationImage(image: NetworkImage("https://picsum.photos/id/1/200/300"),fit: BoxFit.cover)
          ) ,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: adData.iconView,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PreloadHeadline(
                          adData: adData,
                          builder: (headline) => Text(
                            headline.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.sixCaps(
                              fontSize: 32,
                              height: 0.9,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        PreloadAdvertiser(
                          adData: adData,
                          builder: (advertiser) => Text(
                            advertiser,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.black.withValues(alpha: 0.6),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                   PreloadAttribution(adData: adData),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: adData.mediaView,
                ),
              ),
              const SizedBox(height: 16),
              PreloadBody(
                adData: adData,
                builder: (body) => Text(
                  body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.sixCaps(
                    fontSize: 18,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      const Shadow(
                        color: Colors.black,
                        offset: Offset(0, 1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (adData.rating != null && adData.rating! > 0)
                        PreloadStarRating(
                          rating: adData.rating!,
                          size: 14,
                          color: Colors.white,
                        ),
                      const SizedBox(width: 8),
                      PreloadPrice(
                        adData: adData,
                        builder: (price) => Text(
                          price,
                          style: GoogleFonts.sixCaps(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              const Shadow(
                                color: Colors.black,
                                offset: Offset(0, 1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  PreloadCallToAction(
                    adData: adData,
                    builder: (cta) => ElevatedButton(
                      onPressed: adData.onCTAPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        cta.toUpperCase(),
                        style: GoogleFonts.sixCaps(
                          fontSize: 24,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A utility class for ad unit IDs used in the example app.
class AdTestIds {
  /// Selects platform-specific Ad ID.
  static String get nativeVideo => _getId(
        androidId: 'ca-app-pub-3940256099942544/1044960115',
        iosId: 'ca-app-pub-3940256099942544/2521693316',
      );

  static String _getId({required String androidId, required String iosId}) {
    // In a real app, you'd use dart:io.Platform.isIOS.
    // For this example, we assume it's correctly handled or use a mock.
    return androidId; // Simplified for extraction
  }
}
