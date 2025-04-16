import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../preload_ad.dart';

class AdCounterWidget extends StatelessWidget {
  final ValueNotifier<bool> showCounter;

  /// Constructor to receive a ValueNotifier<bool> to control whether the counter should be shown
  const AdCounterWidget({super.key, required this.showCounter});

  /// Define custom colors for different themes (light or dark)
  Color _getTitleColor(BuildContext context) {
    /// Return title color depending on the current theme (light or dark)
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.white;
  }

  Color _getBackgroundColor(BuildContext context) {
    /// Return background color depending on the current theme (light or dark)
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[850]!
        : Colors.white;
  }

  Color _getBorderColor(BuildContext context) {
    /// Return border color depending on the current theme (light or dark)
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.blueGrey
        : Colors.blue;
  }

  Color _getTextColor(BuildContext context) {
    /// Return text color depending on the current theme (light or dark)
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white60
        : Colors.black87;
  }

  /// Custom widget to build title with a specific color for each theme
  Widget _buildTitleCell(BuildContext context, String title) {
    /// Get the title color and background color based on the current theme
    final titleColor = _getTitleColor(context);
    final backgroundColor =
        Theme.of(context).brightness == Brightness.dark
            ? Colors.blueGrey
            : Colors.blue;

    /// Return a container with title text and background
    return Container(
      width: double.infinity,
      height: 30,
      color: backgroundColor,
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
      ),
    );
  }

  /// Custom widget to build stat value text with specific colors for each theme
  Widget _buildStatValue(BuildContext context, ValueNotifier<int> notifier) {
    /// Get the text color based on the current theme
    final textColor = _getTextColor(context);

    /// Use ValueListenableBuilder to listen to changes in the stat value (int)
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ValueListenableBuilder<int>(
        valueListenable: notifier,
        builder:
            (_, value, __) => Text(
              value.toString(),
              style: TextStyle(fontSize: 10, color: textColor),
            ),
      ),
    );
  }

  /// Custom widget to build each stat column (for Interstitial, Rewarded, etc.)
  Widget _buildStatColumn(
    BuildContext context,
    String title,
    ValueNotifier<int> load,
    ValueNotifier<int> imp,
    ValueNotifier<int> fail,
  ) {
    return Expanded(
      child: Column(
        children: [
          /// Title cell with the given title (like "Inter")
          _buildTitleCell(context, title),
          // Stat values for Load, Imp, and Failed
          _buildStatValue(context, load),
          const Divider(height: 1),
          _buildStatValue(context, imp),
          const Divider(height: 1),
          _buildStatValue(context, fail),
        ],
      ),
    );
  }

  /// Custom widget to build the label column (e.g., 'LOAD', 'SHOW', 'FAILED')
  Widget _buildLabelColumn(BuildContext context) {
    final labels = ['LOAD', 'SHOW', 'FAILED'];

    /// Get the text color based on the current theme
    final textColor = _getTextColor(context);

    return Expanded(
      child: Column(
        children: [
          /// Title cell for the 'STATES' label
          _buildTitleCell(context, 'STATES'),

          /// Loop through the labels and build corresponding text with dividers
          ...List.generate(labels.length, (index) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    labels[index],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),

                /// Add divider between each label except the last one
                if (index < labels.length - 1) const Divider(height: 1),
              ],
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    /// Skip widget rendering in release mode
    if (kReleaseMode) return const SizedBox.shrink();

    /// Get the border and background colors based on the current theme
    final borderColor = _getBorderColor(context);
    final backgroundColor = _getBackgroundColor(context);

    return Material(
      child: Container(
        margin: const EdgeInsets.all(5),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: borderColor),
        ),
        child: ValueListenableBuilder<bool>(
          valueListenable: showCounter,
          builder: (_, shouldShow, __) {
            /// If the counter should not be shown, return an empty widget
            if (!shouldShow) return const SizedBox.shrink();

            final stats = AdStats.instance;

            return Row(
              children: [
                /// Build the label column (e.g., LOAD, SHOW, FAILED)
                _buildLabelColumn(context),

                /// Build stat columns for various ad types (Inter, Reward, etc.)
                _buildStatColumn(
                  context,
                  "Inter",
                  stats.interLoad,
                  stats.interImp,
                  stats.interFailed,
                ),
                _buildStatColumn(
                  context,
                  "Reward",
                  stats.rewardedLoad,
                  stats.rewardedImp,
                  stats.rewardedFailed,
                ),
                _buildStatColumn(
                  context,
                  "Banner",
                  stats.bannerLoad,
                  stats.bannerImp,
                  stats.bannerFailed,
                ),
                _buildStatColumn(
                  context,
                  "SNative",
                  stats.nativeLoadS,
                  stats.nativeImpS,
                  stats.nativeFailedS,
                ),
                _buildStatColumn(
                  context,
                  "MNative",
                  stats.nativeLoadM,
                  stats.nativeImpM,
                  stats.nativeFailedM,
                ),
                _buildStatColumn(
                  context,
                  "OpenApp",
                  stats.openAppLoad,
                  stats.openAppImp,
                  stats.openAppFailed,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
