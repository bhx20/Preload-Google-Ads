import 'package:flutter/material.dart';
import 'package:preload_google_ads/preload_google_ads.dart';

class NativeGridScreen extends StatefulWidget {
  const NativeGridScreen({super.key});

  @override
  State<NativeGridScreen> createState() => _NativeGridScreenState();
}

class _NativeGridScreenState extends State<NativeGridScreen> {
  int _columnCount = 2; // Default to 2-column grid
  final List<String> _products = List.generate(18, (index) => "Product #${index + 1}");
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoadingMore) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadMoreProducts() async {
    setState(() => _isLoadingMore = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() {
        final currentLength = _products.length;
        _products.addAll(List.generate(12, (index) => "Product #${currentLength + index + 1}"));
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine how many grid items appear before an inline native ad is inserted
    final int adInterval = _columnCount * 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Native Ads in GridView"),
        actions: [
          // Segmented Button to switch between 1, 2, and 3 Columns
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: SegmentedButton<int>(
              style: SegmentedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                visualDensity: VisualDensity.compact,
              ),
              segments: const [
                ButtonSegment(value: 1, label: Text("1 Grid")),
                ButtonSegment(value: 2, label: Text("2 Grid")),
                ButtonSegment(value: 3, label: Text("3 Grid")),
              ],
              selected: {_columnCount},
              onSelectionChanged: (selected) {
                setState(() {
                  _columnCount = selected.first;
                });
              },
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: _columnCount == 1
                ? _buildListLayout(adInterval)
                : _buildGridLayout(adInterval),
          ),
          if (_isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 1-Column List Layout with Medium Native Ads
  Widget _buildListLayout(int adInterval) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final bool isAdPos = (index > 0 && index % adInterval == 0);
          if (isAdPos) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                clipBehavior: Clip.hardEdge,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PreloadGoogleAds.instance.showNativeAd(
                    nativeADType: NativeADType.medium,
                  ),
                ),
              ),
            );
          }

          final int adsBefore = index ~/ adInterval;
          final int pIndex = index - adsBefore;
          if (pIndex >= _products.length) return const SizedBox.shrink();

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.shopping_bag_outlined, color: Theme.of(context).primaryColor),
              ),
              title: Text(_products[pIndex], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("\$49.99 • Free Shipping"),
              trailing: const Icon(Icons.add_shopping_cart_rounded),
            ),
          );
        },
        childCount: _products.length + (_products.length ~/ adInterval),
      ),
    );
  }

  // Multi-Column (2 or 3) Grid Layout with Inline Native Ads
  Widget _buildGridLayout(int adInterval) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _columnCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: _columnCount == 2 ? 0.72 : 0.65,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final bool isAdPos = (index > 0 && index % adInterval == 0);

          if (isAdPos) {
            return Card(
              clipBehavior: Clip.hardEdge,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: PreloadGoogleAds.instance.showNativeAd(
                  nativeADType: NativeADType.small,
                ),
              ),
            );
          }

          final int adsBefore = index ~/ adInterval;
          final int pIndex = index - adsBefore;
          if (pIndex >= _products.length) return const SizedBox.shrink();

          return Card(
            clipBehavior: Clip.hardEdge,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      size: 36,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _products[pIndex],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "\$29.99",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 11.5,
                            ),
                          ),
                          Icon(
                            Icons.add_circle_outline_rounded,
                            size: 18,
                            color: Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        childCount: _products.length + (_products.length ~/ adInterval),
      ),
    );
  }
}
