import 'package:flutter/material.dart';

import 'models/ai_models.dart';
import 'pages/dashboard_page.dart';
import 'pages/ai_strategy_center_page.dart';
import 'pages/video_optimizer_page.dart';
import 'pages/settings_page.dart';
import 'services/settings_service.dart';
import 'services/youtube_service.dart';
import 'services/ai_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsService = SettingsService();
  await settingsService.init();
  final initialSettings = settingsService.loadSettings();
  
  final youtubeService = YoutubeService();
  await youtubeService.init(initialSettings);

  runApp(PeerStudioApp(
    initialSettings: initialSettings,
    settingsService: settingsService,
    youtubeService: youtubeService,
  ));
}

class PeerStudioApp extends StatefulWidget {
  final UserSettings initialSettings;
  final SettingsService settingsService;
  final YoutubeService youtubeService;

  const PeerStudioApp({
    super.key,
    required this.initialSettings,
    required this.settingsService,
    required this.youtubeService,
  });

  @override
  State<PeerStudioApp> createState() => _PeerStudioAppState();
}

class _PeerStudioAppState extends State<PeerStudioApp> {
  late UserSettings _userSettings;
  late AiService _aiService;

  @override
  void initState() {
    super.initState();
    _userSettings = widget.initialSettings;
    _aiService = AiService(settings: _userSettings);
  }

  void _updateSettings(UserSettings settings) {
    setState(() {
      _userSettings = settings;
      _aiService = AiService(settings: settings);
    });
    widget.settingsService.saveSettings(settings);
    widget.youtubeService.init(settings); // Re-init on settings change if clientId changed
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI YouTube Studio',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark, // Force Dark Mode
      theme: AppTheme.darkTheme,
      home: AppShell(
        settings: _userSettings,
        settingsService: widget.settingsService,
        youtubeService: widget.youtubeService,
        aiService: _aiService,
        onSettingsChanged: _updateSettings,
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  final UserSettings settings;
  final SettingsService settingsService;
  final YoutubeService youtubeService;
  final AiService aiService;
  final ValueChanged<UserSettings> onSettingsChanged;

  const AppShell({
    super.key,
    required this.settings,
    required this.settingsService,
    required this.youtubeService,
    required this.aiService,
    required this.onSettingsChanged,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardPage(youtubeService: widget.youtubeService, aiService: widget.aiService),
      const AiStrategyCenterPage(),
      VideoOptimizerPage(aiService: widget.aiService, youtubeService: widget.youtubeService),
      SettingsPage(
        settings: widget.settings,
        settingsService: widget.settingsService,
        onSettingsChanged: widget.onSettingsChanged,
      ),
    ];

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 600) {
            // Wide screen: use NavigationRail (sidebar)
            return Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: Text('Dashboard'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.lightbulb_outline),
                      selectedIcon: Icon(Icons.lightbulb),
                      label: Text('Strategy'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.video_settings_outlined),
                      selectedIcon: Icon(Icons.video_settings),
                      label: Text('Optimizer'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: Text('Settings'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.05, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                          child: child,
                        ),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey<int>(_selectedIndex),
                      child: pages[_selectedIndex],
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Narrow screen: use NavigationBar (bottom bar)
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey<int>(_selectedIndex),
                child: pages[_selectedIndex],
              ),
            );
          }
        },
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width < 600
          ? NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.lightbulb_outline),
                  selectedIcon: Icon(Icons.lightbulb),
                  label: 'Strategy',
                ),
                NavigationDestination(
                  icon: Icon(Icons.video_settings_outlined),
                  selectedIcon: Icon(Icons.video_settings),
                  label: 'Optimizer',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            )
          : null,
    );
  }
}
