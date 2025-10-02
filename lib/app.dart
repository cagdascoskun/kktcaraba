import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/auth/auth_screen.dart';
import 'screens/main_shell.dart';
import 'state/app_state.dart';

class KKTCMarketplaceApp extends StatelessWidget {
  const KKTCMarketplaceApp({super.key});

  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver _observer =
      FirebaseAnalyticsObserver(analytics: _analytics);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final ThemeData lightTheme = ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00ADEF),
            primary: const Color(0xFF004C6D),
            secondary: const Color(0xFF21B573),
            surface: const Color(0xFFF7F7F7),
          ),
          scaffoldBackgroundColor: const Color(0xFFF7F7F7),
          useMaterial3: true,
          textTheme: TextTheme(
            headlineLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: const Color(0xFF00263A),
            ),
            headlineMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              color: const Color(0xFF00263A),
            ),
            headlineSmall: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              color: const Color(0xFF00263A),
            ),
            titleLarge: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF00263A),
            ),
            titleMedium: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF00263A),
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: const Color(0xFF334E68),
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: const Color(0xFF334E68),
            ),
            labelLarge: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00263A),
            ),
            iconTheme: IconThemeData(color: const Color(0xFF00263A)),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.transparent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: const Color(0xFF00ADEF), width: 1.6),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: Colors.white,
            margin: EdgeInsets.zero,
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedItemColor: const Color(0xFF00ADEF),
            unselectedItemColor: const Color(0xFF90A4AE),
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 8,
          ),
        );

        final ThemeData darkTheme = ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00ADEF),
            brightness: Brightness.dark,
          ),
          textTheme: ThemeData.dark().textTheme,
        );

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'KKTC Araba',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: appState.themeMode,
          home:
              appState.isAuthenticated ? const MainShell() : const AuthScreen(),
          navigatorObservers: <NavigatorObserver>[_observer],
        );
      },
    );
  }
}
