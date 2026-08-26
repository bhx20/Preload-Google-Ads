import 'package:flutter/material.dart';
import 'package:preload_google_ads/preload_google_ads.dart';

class NativeListScreen extends StatefulWidget {
  const NativeListScreen({super.key});

  @override
  State<NativeListScreen> createState() => _NativeListScreenState();
}

class _NativeListScreenState extends State<NativeListScreen> {
  final List<String> _items = List.generate(15, (index) => "Feed Article Item #${index + 1}");
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
      _loadMoreItems();
    }
  }

  Future<void> _loadMoreItems() async {
    setState(() => _isLoadingMore = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() {
        final currentLength = _items.length;
        _items.addAll(List.generate(10, (index) => "Feed Article Item #${currentLength + index + 1}"));
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Native Ads in ListView"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() {
                _items.clear();
                _items.addAll(List.generate(15, (index) => "Feed Article Item #${index + 1}"));
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _items.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Insert a Small Native Ad every 5th item (e.g. index 3, 8, 13...)
          final bool isAdPosition = (index % 5 == 3);

          return Column(
            children: [
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    child: Text(
                      "${index + 1}",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    _items[index],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text("Discover trending news, insights, and stories curated for you."),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              ),
              if (isAdPosition) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: PreloadGoogleAds.instance.showNativeAd(
                      nativeADType: NativeADType.small,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
