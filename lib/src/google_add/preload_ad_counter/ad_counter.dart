import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../preload_google_ads.dart';

class AdCounterWidget extends StatelessWidget {
  final ValueNotifier<bool> showCounter;

  const AdCounterWidget({super.key, required this.showCounter});

  Widget _buildStatColumn(
    String title,
    ValueNotifier<int> load,
    ValueNotifier<int> imp,
    ValueNotifier<int> fail,
  ) {
    return Expanded(
      child: Column(
        children: [
          Text(title),
          ValueListenableBuilder<int>(
            valueListenable: load,
            builder: (_, l, __) => Text('L: $l'),
          ),
          ValueListenableBuilder<int>(
            valueListenable: imp,
            builder: (_, i, __) => Text('I: $i'),
          ),
          ValueListenableBuilder<int>(
            valueListenable: fail,
            builder: (_, f, __) => Text('F: $f'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) return const SizedBox.shrink();
    return Material(
      child: ValueListenableBuilder<bool>(
        valueListenable: showCounter,
        builder: (_, shouldShow, __) {
          if (!shouldShow) return const SizedBox.shrink();

          final stats = AdStats.instance;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn(
                  "Inter",
                  stats.interLoad,
                  stats.interImp,
                  stats.interFailed,
                ),
                _buildStatColumn(
                  "SNative",
                  stats.nativeLoadS,
                  stats.nativeImpS,
                  stats.nativeFailedS,
                ),
                _buildStatColumn(
                  "MNative",
                  stats.nativeLoadM,
                  stats.nativeImpM,
                  stats.nativeFailedM,
                ),
                _buildStatColumn(
                  "OpenApp",
                  stats.openAppLoad,
                  stats.openAppImp,
                  stats.openAppFailed,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
