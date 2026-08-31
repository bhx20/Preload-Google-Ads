import 'package:flutter/material.dart';
import 'custom_style_screen.dart';
import 'native_list_screen.dart';
import '../theme/theme_provider.dart';

class NativeAdHubScreen extends StatefulWidget {
  final ThemeProvider themeProvider;

  const NativeAdHubScreen({super.key, required this.themeProvider});

  @override
  State<NativeAdHubScreen> createState() => _NativeAdHubScreenState();
}

class _NativeAdHubScreenState extends State<NativeAdHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Native Ads Hub"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.tune_rounded), text: "Style Customizer"),
            Tab(icon: Icon(Icons.view_list_rounded), text: "ListView Feed"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          CustomStyleScreen(themeProvider: widget.themeProvider),
          const NativeListScreen(),
        ],
      ),
    );
  }
}
