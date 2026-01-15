import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Configure system UI for immersive judicial experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  // Enable edge-to-edge for modern immersive look
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );

  // Lock to portrait for optimal swipe experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize providers with proper lifecycle
  final themeProvider = ThemeProvider();
  await themeProvider.initialize();

  final statsProvider = StatsProvider();
  await statsProvider.initialize();

  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  // Initialize audio service
  await AudioService().initialize();

  // Auto-play background music if enabled
  if (settingsProvider.musicEnabled) {
    AudioService().playMusic();
  }

  // Check onboarding completion status
  final showOnboarding = !await OnboardingHelper.isComplete();

  runApp(
    JudgeItApp(
      showOnboarding: showOnboarding,
      themeProvider: themeProvider,
      statsProvider: statsProvider,
      settingsProvider: settingsProvider,
    ),
  );
}

/// Root widget for the Judge It app.
///
/// Design: Modern Courtroom Drama aesthetic with judicial gold accents.
/// Uses Provider for state management and Material 3 theming.
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

class _JudgeItAppState extends State<JudgeItApp> with WidgetsBindingObserver {
  late bool _showOnboarding;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _showOnboarding = widget.showOnboarding;
    WidgetsBinding.instance.addObserver(this);
    // Mark user as active when app starts
    _firestoreService.markUserActive();
  }

  @override
  void dispose() {
    // Mark user as inactive when app closes
    _firestoreService.markUserInactive();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle audio when app goes to background/foreground
    final audioService = AudioService();
    final settingsProvider = widget.settingsProvider;
    final firestoreService = FirestoreService();

    if (state == AppLifecycleState.paused) {
      audioService.pauseMusic();
      // Mark user as inactive for live count
      firestoreService.markUserInactive();
    } else if (state == AppLifecycleState.resumed) {
      if (settingsProvider.musicEnabled) {
        audioService.resumeMusic();
      }
      // Mark user as active for live count
      firestoreService.markUserActive();
    }
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
          // Dynamically update system UI based on current theme
          final isDark = themeProvider.isDarkMode;
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: isDark
                  ? Brightness.light
                  : Brightness.dark,
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarIconBrightness: isDark
                  ? Brightness.light
                  : Brightness.dark,
              systemNavigationBarDividerColor: Colors.transparent,
            ),
          );

          return MaterialApp(
            title: 'Judge It',
            debugShowCheckedModeBanner: false,

            // Theme configuration - Modern Courtroom Drama
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            // Initial route based on onboarding status
            home: _showOnboarding
                ? OnboardingScreen(onComplete: _completeOnboarding)
                : const SwipeScreen(),

            // Global builder for consistent UI behavior
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  // Prevent system font scaling for consistent UI
                  textScaler: TextScaler.noScaling,
                ),
                child: GestureDetector(
                  // Dismiss keyboard on tap outside
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: child!,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
