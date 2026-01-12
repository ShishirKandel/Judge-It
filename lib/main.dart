import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/swipe_provider.dart';
import 'screens/swipe_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const JudgeItApp());
}

class JudgeItApp extends StatelessWidget {
  const JudgeItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SwipeProvider()),
      ],
      child: MaterialApp(
        title: 'Judge It',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.dark(
            primary: Colors.amber,
            secondary: Colors.amberAccent,
            surface: const Color(0xFF1E1E2E),
          ),
          scaffoldBackgroundColor: const Color(0xFF0D0D14),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          fontFamily: 'Roboto',
        ),
        home: const SwipeScreen(),
      ),
    );
  }
}
