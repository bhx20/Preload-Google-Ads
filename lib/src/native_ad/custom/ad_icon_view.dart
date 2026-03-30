import '../../ad_internal.dart';

/// A placeholder widget that marks the location for the native SDK icon view.
///
/// In the builder pattern, this widget is measured by Flutter's layout system.
/// The main native overlay then positions the real native SDK icon view
/// at these exact coordinates.
///
/// Using this widget ensures the SDK properly registers the icon for click
/// tracking, which is required for SDK compliance.
class AdIconView extends StatelessWidget {
  /// Optional fixed width for the icon view.
  final double? width;

  /// Optional fixed height for the icon view.
  final double? height;

  /// Constructor for [AdIconView].
  const AdIconView({
    super.key,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      // Transparent placeholder to allow measurement via GlobalKey.
      child: const DecoratedBox(
        decoration: BoxDecoration(color: Color(0x00000000)),
      ),
    );
  }
}
