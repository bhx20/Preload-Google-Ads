import 'package:flutter/material.dart';
import 'package:preload_google_ads/preload_google_ads.dart';
import '../theme/theme_provider.dart';

class CustomStyleScreen extends StatefulWidget {
  final ThemeProvider? themeProvider;

  const CustomStyleScreen({super.key, this.themeProvider});

  @override
  State<CustomStyleScreen> createState() => _CustomStyleScreenState();
}

class _CustomStyleScreenState extends State<CustomStyleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Light Mode Tokens
  Color lightTitleColor = const Color(0xFF0F172A);
  Color lightBodyColor = const Color(0xFF64748B);
  Color lightButtonBg = const Color(0xFF6366F1);
  Color lightTagBg = const Color(0xFFF19938);
  double lightButtonRadius = 10.0;

  // Dark Mode Tokens
  Color darkTitleColor = const Color(0xFFF8FAFC);
  Color darkBodyColor = const Color(0xFF94A3B8);
  Color darkButtonBg = const Color(0xFF818CF8);
  Color darkTagBg = const Color(0xFFF59E0B);
  double darkButtonRadius = 10.0;

  NativeADType selectedType = NativeADType.medium;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final targetMode = _tabController.index == 1 ? ThemeMode.dark : ThemeMode.light;
        if (widget.themeProvider != null) {
          widget.themeProvider!.setThemeMode(targetMode);
        } else {
          PreloadGoogleAds.instance.setThemeMode(_tabController.index == 1 ? AdThemeMode.dark : AdThemeMode.light);
        }
        // Reload ad on tab switch so new mode styling takes immediate effect
        PreloadGoogleAds.instance.reloadNativeAd(nativeADType: selectedType);
        setState(() {});
      }
    });
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
        title: const Text("Native Style Customizer"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.light_mode_rounded), text: "Light Mode View"),
            Tab(icon: Icon(Icons.dark_mode_rounded), text: "Dark Mode View"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildThemeCustomizerView(isDarkModeView: false),
          _buildThemeCustomizerView(isDarkModeView: true),
        ],
      ),
    );
  }

  // Dedicated view per theme mode (Contains dedicated Ad Preview + Token Customization Form)
  Widget _buildThemeCustomizerView({required bool isDarkModeView}) {
    final titleColor = isDarkModeView ? darkTitleColor : lightTitleColor;
    final bodyColor = isDarkModeView ? darkBodyColor : lightBodyColor;
    final buttonBg = isDarkModeView ? darkButtonBg : lightButtonBg;
    final tagBg = isDarkModeView ? darkTagBg : lightTagBg;
    final radiusVal = isDarkModeView ? darkButtonRadius : lightButtonRadius;

    return Theme(
      data: isDarkModeView ? ThemeData.dark() : ThemeData.light(),
      child: Builder(
        builder: (ctx) {
          return Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isDarkModeView ? "🌙 DARK THEME PREVIEW" : "☀️ LIGHT THEME PREVIEW",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: isDarkModeView ? Colors.indigoAccent : Colors.indigo,
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SegmentedButton<NativeADType>(
                        segments: const [
                          ButtonSegment(value: NativeADType.small, label: Text("Small", style: TextStyle(fontSize: 12))),
                          ButtonSegment(value: NativeADType.medium, label: Text("Medium", style: TextStyle(fontSize: 12))),
                        ],
                        selected: {selectedType},
                        onSelectionChanged: (set) {
                          setState(() => selectedType = set.first);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Dedicated Preview Box for current Mode
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkModeView ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(radiusVal),
                      border: Border.all(
                        color: isDarkModeView ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDarkModeView ? 0.4 : 0.06),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: PreloadGoogleAds.instance.showNativeAd(
                      nativeADType: selectedType,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Customization Tokens Form Card
                  Card(
                    elevation: 2,
                    color: isDarkModeView ? const Color(0xFF0F172A) : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isDarkModeView ? "DARK THEME DESIGN TOKENS" : "LIGHT THEME DESIGN TOKENS",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const Divider(height: 16),

                          // Title Text Color
                          _buildColorSelectorRow(
                            label: "Title Color",
                            currentColor: titleColor,
                            presets: isDarkModeView
                                ? const [Color(0xFFF8FAFC), Color(0xFFCBD5E1), Colors.amber, Colors.cyanAccent]
                                : const [Color(0xFF0F172A), Color(0xFF334155), Colors.indigo, Colors.deepPurple],
                            onColorSelected: (c) => _updateColor(isDarkModeForm: isDarkModeView, field: 'title', color: c),
                          ),
                          const SizedBox(height: 14),

                          // Body Text Color
                          _buildColorSelectorRow(
                            label: "Body Color",
                            currentColor: bodyColor,
                            presets: isDarkModeView
                                ? const [Color(0xFF94A3B8), Color(0xFF64748B), Colors.tealAccent, Colors.orangeAccent]
                                : const [Color(0xFF64748B), Color(0xFF475569), Colors.teal, Colors.brown],
                            onColorSelected: (c) => _updateColor(isDarkModeForm: isDarkModeView, field: 'body', color: c),
                          ),
                          const SizedBox(height: 14),

                          // Button Primary Color
                          _buildColorSelectorRow(
                            label: "Button Primary",
                            currentColor: buttonBg,
                            presets: isDarkModeView
                                ? const [Color(0xFF818CF8), Color(0xFF6366F1), Colors.pinkAccent, Colors.greenAccent]
                                : const [Color(0xFF6366F1), Colors.blue, Colors.deepOrange, Colors.green],
                            onColorSelected: (c) => _updateColor(isDarkModeForm: isDarkModeView, field: 'button', color: c),
                          ),
                          const SizedBox(height: 14),

                          // Tag Background Color
                          _buildColorSelectorRow(
                            label: "Ad Tag Background",
                            currentColor: tagBg,
                            presets: const [
                              Color(0xFFF19938),
                              Color(0xFFF59E0B),
                              Colors.deepOrange,
                              Colors.purple,
                            ],
                            onColorSelected: (c) => _updateColor(isDarkModeForm: isDarkModeView, field: 'tag', color: c),
                          ),
                          const SizedBox(height: 14),

                          // Border Radius Slider
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Button / Container Radius", style: TextStyle(fontSize: 13)),
                              Text("${radiusVal.toInt()} px", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                            ],
                          ),
                          Slider(
                            value: radiusVal,
                            min: 0,
                            max: 24,
                            divisions: 12,
                            onChanged: (val) {
                              setState(() {
                                if (isDarkModeView) {
                                  darkButtonRadius = val;
                                } else {
                                  lightButtonRadius = val;
                                }
                              });
                              _syncConfigLive();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorSelectorRow({
    required String label,
    required Color currentColor,
    required List<Color> presets,
    required Function(Color) onColorSelected,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13)),
        Row(
          children: [
            ...presets.map(
              (c) => Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: _colorCircle(c, currentColor, onColorSelected),
              ),
            ),
            // Custom Color Picker Dialog Button
            GestureDetector(
              onTap: () => _showColorPickerDialog(label, currentColor, onColorSelected),
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: const Icon(Icons.colorize_rounded, size: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showColorPickerDialog(String label, Color initialColor, Function(Color) onSelect) {
    final List<Color> palette = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
      Colors.black,
      Colors.white,
      const Color(0xFF6366F1),
      const Color(0xFF818CF8),
      const Color(0xFF0F172A),
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Select $label"),
          content: SizedBox(
            width: 280,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: palette.map((c) {
                final isSelected = c.value == initialColor.value;
                return GestureDetector(
                  onTap: () {
                    onSelect(c);
                    Navigator.of(ctx).pop();
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.amber : Colors.black26,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _updateColor({required bool isDarkModeForm, required String field, required Color color}) {
    setState(() {
      if (isDarkModeForm) {
        if (field == 'title') darkTitleColor = color;
        if (field == 'body') darkBodyColor = color;
        if (field == 'button') darkButtonBg = color;
        if (field == 'tag') darkTagBg = color;
      } else {
        if (field == 'title') lightTitleColor = color;
        if (field == 'body') lightBodyColor = color;
        if (field == 'button') lightButtonBg = color;
        if (field == 'tag') lightTagBg = color;
      }
    });
    _syncConfigLive();
  }

  Widget _colorCircle(Color color, Color currentColor, Function(Color) onSelect) {
    final isSelected = currentColor.value == color.value;
    return GestureDetector(
      onTap: () => onSelect(color),
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.white24,
            width: isSelected ? 2.5 : 1,
          ),
        ),
      ),
    );
  }

  Future<void> _syncConfigLive() async {
    final adMode = _tabController.index == 1 ? AdThemeMode.dark : AdThemeMode.light;

    await PreloadGoogleAds.instance.initialize(
      adConfigData: AdConfigData(
        themeMode: adMode,
        nativeADLayout: NativeADLayout(
          customNativeADStyle: CustomNativeADStyle(
            titleColor: lightTitleColor,
            bodyColor: lightBodyColor,
            buttonBackground: lightButtonBg,
            tagBackground: lightTagBg,
            buttonRadius: lightButtonRadius.toInt(),
          ),
          darkCustomNativeADStyle: CustomNativeADStyle.dark(
            titleColor: darkTitleColor,
            bodyColor: darkBodyColor,
            buttonBackground: darkButtonBg,
            tagBackground: darkTagBg,
            buttonRadius: darkButtonRadius.toInt(),
          ),
        ),
      ),
    );

    if (widget.themeProvider != null) {
      widget.themeProvider!.setThemeMode(_tabController.index == 1 ? ThemeMode.dark : ThemeMode.light);
    } else {
      await PreloadGoogleAds.instance.setThemeMode(adMode);
    }
  }
}


