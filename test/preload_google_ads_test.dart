import 'package:flutter_test/flutter_test.dart';
import 'package:preload_google_ads/preload_google_ads.dart';
import 'package:preload_google_ads/preload_google_ads_platform_interface.dart';
import 'package:preload_google_ads/preload_google_ads_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPreloadGoogleAdsPlatform
    with MockPlatformInterfaceMixin
    implements PreloadGoogleAdsPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PreloadGoogleAdsPlatform initialPlatform = PreloadGoogleAdsPlatform.instance;

  test('$MethodChannelPreloadGoogleAds is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPreloadGoogleAds>());
  });

  test('getPlatformVersion', () async {
    PreloadGoogleAds preloadGoogleAdsPlugin = PreloadGoogleAds();
    MockPreloadGoogleAdsPlatform fakePlatform = MockPreloadGoogleAdsPlatform();
    PreloadGoogleAdsPlatform.instance = fakePlatform;

    expect(await preloadGoogleAdsPlugin.getPlatformVersion(), '42');
  });
}
