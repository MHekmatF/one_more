// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

// Define your custom green color
const Color kPrimaryGreen = Color(0xFF618e32); // Your specific green
const Color kLightGreen = Color(0xFF8DC04C); // A lighter shade for accents
const Color kDarkGreen = Color(0xFF4A6B25);  // A darker shade for contrast

// Grey shades
const Color kCharcoal = Color(0xFF333333);
const Color kDarkGrey = Color(0xFF555555);
const Color kMediumGrey = Color(0xFF888888);
const Color kLightGrey = Color(0xFFCCCCCC);
const Color kOffWhite = Color(0xFFF0F0F0); // A soft white/very light grey

ThemeData appTheme(BuildContext context) {
  return ThemeData(
    // Primary Color Family (Green and greys)
    primaryColor: kPrimaryGreen,
    primaryColorLight: kLightGreen,
    primaryColorDark: kDarkGreen,
    colorScheme: ColorScheme.light(
      primary: kPrimaryGreen,
      primaryContainer: kDarkGreen, // Darker green for containers like AppBar
      secondary: kLightGreen, // Lighter green for accents, FABs
      secondaryContainer: kLightGreen,
      surface: kOffWhite, // Background for cards, sheets
      background: kOffWhite, // Main scaffold background
      error: Colors.red.shade700,
      onPrimary: Colors.white,
      onSecondary: kCharcoal,
      onSurface: kCharcoal,
      onBackground: kCharcoal,
      onError: Colors.white,
      brightness: Brightness.light, // Or dark if you prefer a dark theme initially
    ),

    // Text Theme (using shades of grey for text)
    textTheme: TextTheme(
      displayLarge: TextStyle(color: kCharcoal, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: kCharcoal, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: kCharcoal, fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(color: kCharcoal, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: kCharcoal, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: kCharcoal, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: kCharcoal, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: kDarkGrey, fontWeight: FontWeight.w500),
      titleSmall: TextStyle(color: kDarkGrey),
      bodyLarge: TextStyle(color: kCharcoal),
      bodyMedium: TextStyle(color: kDarkGrey),
      bodySmall: TextStyle(color: kMediumGrey),
      labelLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // For buttons
      labelMedium: TextStyle(color: kMediumGrey),
      labelSmall: TextStyle(color: kMediumGrey),
    ),

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: kDarkGreen, // Dark green for app bars
      foregroundColor: Colors.white, // White text/icons on dark green
      elevation: 4,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(color: Colors.white),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(8.0),
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, // Text color
        backgroundColor: kPrimaryGreen, // Button background
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: kPrimaryGreen, // Text color
        textStyle: const TextStyle(fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kPrimaryGreen, // Text color
        side: const BorderSide(color: kPrimaryGreen),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 16),
      ),
    ),

    // Input Decoration Theme (for TextFields)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kOffWhite, // Light background for input fields
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none, // Initially no border to make it cleaner
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: kLightGrey, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: kPrimaryGreen, width: 2.0), // Green on focus
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.red.shade700, width: 2.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.red.shade900, width: 2.0),
      ),
      labelStyle: TextStyle(color: kDarkGrey),
      hintStyle: TextStyle(color: kMediumGrey),
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
    ),

    // Dialog Theme
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      titleTextStyle: TextStyle(color: kCharcoal, fontSize: 22, fontWeight: FontWeight.bold),
      contentTextStyle: TextStyle(color: kDarkGrey, fontSize: 16),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: kCharcoal, // Default icon color
    ),

    // Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: kLightGreen,
      foregroundColor: Colors.white,
      elevation: 6,
    ),

    // Navigation Rail Theme
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: kCharcoal, // Dark background for rail
      indicatorColor: kPrimaryGreen.withOpacity(0.2), // Light green highlight
      selectedIconTheme: const IconThemeData(color: kLightGreen, size: 28),
      unselectedIconTheme: IconThemeData(color: kLightGrey.withOpacity(0.7), size: 24),
      selectedLabelTextStyle: const TextStyle(color: kLightGreen, fontWeight: FontWeight.bold),
      unselectedLabelTextStyle: TextStyle(color: kLightGrey.withOpacity(0.7)),
      elevation: 8,
      groupAlignment: -1.0, // Aligns items to top
      labelType: NavigationRailLabelType.all,
    ),

    // Divider Theme
    dividerTheme: DividerThemeData(
      color: kLightGrey.withOpacity(0.7),
      thickness: 1,
      space: 1,
    ),

    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: kPrimaryGreen,
      linearTrackColor: kLightGrey,
      circularTrackColor: kLightGrey,
    ),
  );
}