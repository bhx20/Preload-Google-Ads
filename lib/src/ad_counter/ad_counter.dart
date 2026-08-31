import '../ad_internal.dart';

/// A widget that displays a draggable floating action button.
/// Tapping the button opens a clean popup overlay displaying ad metrics vertically.
class AdCounterWidget extends StatefulWidget {
  /// Whether the counter widget should be currently visible.
  final ValueNotifier<bool> showCounter;

  /// Constructor to receive a ValueNotifier to control whether the counter should be shown.
  const AdCounterWidget({super.key, required this.showCounter});

  @override
  State<AdCounterWidget> createState() => _AdCounterWidgetState();
}

class _AdCounterWidgetState extends State<AdCounterWidget> {
  Offset _position = const Offset(20, 140);
  bool _showOverlay = false;

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) return const SizedBox.shrink();

    return ValueListenableBuilder<bool>(
      valueListenable: widget.showCounter,
      builder: (_, shouldShow, __) {
        if (!shouldShow) return const SizedBox.shrink();

        final stats = AdStats.instance;

        return Stack(
          children: [
            // Popup Overlay Card when floating button is tapped
            if (_showOverlay)
              Positioned(
                left: (_position.dx + 65 > MediaQuery.of(context).size.width - 270)
                    ? MediaQuery.of(context).size.width - 280
                    : _position.dx,
                top: (_position.dy + 65 > MediaQuery.of(context).size.height - 350)
                    ? _position.dy - 340
                    : _position.dy + 60,
                child: Material(
                  elevation: 0,
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.transparent,
                  child: Container(
                    width: 270,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E293B)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.blueGrey.withValues(alpha: 0.5)
                            : const Color(0xFF6366F1).withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header Title with close button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.analytics_rounded,
                                  size: 16,
                                  color: Color(0xFF6366F1),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "Ad Metrics Lab",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _showOverlay = false),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 12),
                        // Column Headers
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Expanded(
                                flex: 3,
                                child: Text(
                                  "FORMAT",
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              _headerCell("LOAD", Colors.blue),
                              _headerCell("IMPRESSION", Colors.green),
                              _headerCell("FAILED", Colors.red),
                            ],
                          ),
                        ),
                        const Divider(height: 8),
                        // Vertical Format Table
                        _buildRowItem("Interstitial", stats.interLoad, stats.interImp, stats.interFailed, const Color(0xFF3B82F6)),
                        _buildRowItem("Rewarded", stats.rewardedLoad, stats.rewardedImp, stats.rewardedFailed, const Color(0xFFF59E0B)),
                        _buildRowItem("Reward Inter", stats.rewardedInterLoad, stats.rewardedInterImp, stats.rewardedInterFailed, const Color(0xFF8B5CF6)),
                        _buildRowItem("Banner", stats.bannerLoad, stats.bannerImp, stats.bannerFailed, const Color(0xFF10B981)),
                        _buildRowItem("Small Native", stats.nativeLoadS, stats.nativeImpS, stats.nativeFailedS, const Color(0xFF14B8A6)),
                        _buildRowItem("Medium Native", stats.nativeLoadM, stats.nativeImpM, stats.nativeFailedM, const Color(0xFF6366F1)),
                        _buildRowItem("App Open", stats.openAppLoad, stats.openAppImp, stats.openAppFailed, const Color(0xFFEC4899)),
                      ],
                    ),
                  ),
                ),
              ),

            // Floating Draggable Action Button
            Positioned(
              left: _position.dx,
              top: _position.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _position += details.delta;
                    _showOverlay = false;
                  });
                },
                onTap: () {
                  setState(() {
                    _showOverlay = !_showOverlay;
                  });
                },
                child: Material(
                  elevation: 0,
                  shape: const CircleBorder(),
                  color: Colors.transparent,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          _showOverlay ? Icons.close_rounded : Icons.analytics_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        Positioned(
                          right: 10,
                          top: 10,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF22C55E),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _headerCell(String title, Color color) {
    return Expanded(
      flex: 2,
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }

  Widget _buildRowItem(
    String label,
    ValueNotifier<int> load,
    ValueNotifier<int> imp,
    ValueNotifier<int> fail,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _badge(load, Colors.blue),
          _badge(imp, Colors.green),
          _badge(fail, Colors.red),
        ],
      ),
    );
  }

  Widget _badge(ValueNotifier<int> notifier, Color color) {
    return Expanded(
      flex: 2,
      child: ValueListenableBuilder<int>(
        valueListenable: notifier,
        builder: (_, count, __) => Center(
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
