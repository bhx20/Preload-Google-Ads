import '../../ad_internal.dart';

/// A placeholder widget that marks the location for the native SDK MediaView.
///
/// In the builder pattern, this widget is measured by Flutter's layout system.
/// The main native overlay then positions the real native SDK MediaView
/// at these exact coordinates.
///
/// IMPORTANT: This widget MUST be placed in the ad builder's widget tree
/// for video ads to render and for the SDK to track media interactions.
class AdMediaView extends StatelessWidget {
  /// Optional fixed width for the media view.
  final double? width;

  /// Optional fixed height for the media view.
  final double? height;

  /// Constructor for [AdMediaView].
  const AdMediaView({
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
