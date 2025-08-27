import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker',
      theme: ThemeData(
        // Define a custom color scheme
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          accentColor: Colors.orangeAccent, // Accent color for highlights
          backgroundColor: Colors.blueGrey.shade50, // Light background for the whole app
          cardColor: Colors.white, // Card background color
          errorColor: Colors.red,
        ).copyWith(
          secondary: Colors.orangeAccent, // Explicitly define secondary color
          onPrimary: Colors.white, // Text color on primary background
          onSecondary: Colors.black, // Text color on secondary background
          onSurface: Colors.blueGrey.shade900, // General text color on surfaces
          onSurfaceVariant: Colors.blueGrey.shade800, // Text color on surface variants (like Analyzer card)
          surfaceContainerHighest: Colors.blue.shade50, // For analyzer card background
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade700, // Darker blue for app bar
          foregroundColor: Colors.white, // White text on app bar
          elevation: 4,
          titleTextStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.orangeAccent, // Eye-catching FAB
          foregroundColor: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        ),
        // --- FIX APPLIED HERE ---
        cardTheme: CardThemeData( // Changed from CardTheme to CardThemeData
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          color: Colors.white, // Default card color
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600, // Themed elevated button
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        textTheme: TextTheme(
          headlineSmall: TextStyle(color: Colors.blueGrey.shade900),
          titleLarge: TextStyle(color: Colors.blueGrey.shade800),
          bodyLarge: TextStyle(color: Colors.blueGrey.shade700),
          bodyMedium: TextStyle(color: Colors.blueGrey.shade600),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
