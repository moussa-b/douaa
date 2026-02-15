import 'package:flutter/material.dart';
import 'screens/app_shell.dart';

const Color _kSecondaryColor = Color(0xFF0F3057);
const Color _kInputFillColor = Color(0xFFFAFAFA); // Very light grey for form fields

class DouaaApp extends StatelessWidget {
  const DouaaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Douaa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
          brightness: Brightness.light,
        ).copyWith(
          primary: _kSecondaryColor,
          secondary: _kSecondaryColor,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFFEBFFFD),
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) return _kSecondaryColor;
            return null;
          }),
          trackColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return _kSecondaryColor.withValues(alpha: 0.5);
            }
            return null;
          }),
        ),
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: _kSecondaryColor,
          iconTheme: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Colors.white);
            }
            return null;
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(
                color: _kSecondaryColor,
                fontWeight: FontWeight.w500,
              );
            }
            return null;
          }),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 4,
          backgroundColor: _kSecondaryColor,
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _kSecondaryColor, width: 2),
          ),
          filled: true,
          fillColor: _kInputFillColor,
        ),
      ),
      home: const AppShell(),
    );
  }
}
