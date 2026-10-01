import 'package:flutter/material.dart';
import 'home_page.dart';

void main() => runApp(const TimeZoneApp());

class TimeZoneApp extends StatelessWidget {
  const TimeZoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0F6E8C),
      brightness: Brightness.light,
    );
    return MaterialApp(
      title: 'Time Zone Converter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xFFF6F8F9),
        appBarTheme: AppBarTheme(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: scheme.outlineVariant),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}
