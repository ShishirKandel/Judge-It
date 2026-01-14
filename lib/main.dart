import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/swipe_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/stats_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/swipe_screen.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';
import 'services/audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize theme provider
  final themeProvider = ThemeProvider();
  await themeProvider.initialize();

  // Initialize stats provider
  final statsProvider = StatsProvider();
  await statsProvider.initialize();

  // Initialize settings provider
  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  // Initialize audio service
  await AudioService().initialize();
  
  // Auto-play music if enabled in settings
  if (settingsProvider.musicEnabled) {
    AudioService().playMusic();
  }

  // Check if onboarding is complete
  final showOnboarding = !await OnboardingHelper.isComplete();

  runApp(JudgeItApp(
    showOnboarding: showOnboarding,
    themeProvider: themeProvider,
    statsProvider: statsProvider,
    settingsProvider: settingsProvider,
  ));
}

class JudgeItApp extends StatefulWidget {
  final bool showOnboarding;
  final ThemeProvider themeProvider;
  final StatsProvider statsProvider;
  final SettingsProvider settingsProvider;

  const JudgeItApp({
    super.key,
    required this.showOnboarding,
    required this.themeProvider,
    required this.statsProvider,
    required this.settingsProvider,
  });

  @override
  State<JudgeItApp> createState() => _JudgeItAppState();
}

class _JudgeItAppState extends State<JudgeItApp> {
  late bool _showOnboarding;

  @override
  void initState() {
    super.initState();
    _showOnboarding = widget.showOnboarding;
  }

  void _completeOnboarding() {
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SwipeProvider()),
        ChangeNotifierProvider.value(value: widget.themeProvider),
        ChangeNotifierProvider.value(value: widget.statsProvider),
        ChangeNotifierProvider.value(value: widget.settingsProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Judge It',
            debugShowCheckedModeBanner: false,

            // Theme configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            home: _showOnboarding
                ? OnboardingScreen(onComplete: _completeOnboarding)
                : const SwipeScreen(),
          );
        },
      ),
    );
  }
}
