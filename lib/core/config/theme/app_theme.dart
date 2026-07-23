import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// Design Tokens - Placeholder constants for theming
/// TODO: Replace with actual design system values from design team
class DesignTokens {
  // ===== Color Palette =====
  // Primary colors - Đỏ Cố Đô (Imperial Crimson)
  static const Color primaryLight = Color(0xFFE57373);
  static const Color primaryMain = Color(0xFF9B1B30);
  static const Color primaryDark = Color(0xFF7B0020);
  static const Color primaryContrast = Color(0xFFFFFFFF);

  // Secondary colors - Vàng Hoàng Gia (Royal Gold)
  static const Color secondaryLight = Color(0xFFFFD700);
  static const Color secondaryMain = Color(0xFFDAA520);
  static const Color secondaryDark = Color(0xFFB8860B);
  static const Color secondaryContrast = Color(0xFF000000);

  // Tertiary colors
  static const Color tertiaryLight = Color(0xFF81C784);
  static const Color tertiaryMain = Color(0xFF4CAF50);
  static const Color tertiaryDark = Color(0xFF388E3C);

  // Semantic colors
  static const Color errorMain = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color errorDark = Color(0xFFD32F2F);

  static const Color successMain = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF66BB6A);
  static const Color successDark = Color(0xFF388E3C);

  static const Color warningMain = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);

  static const Color infoMain = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF42A5F5);
  static const Color infoDark = Color(0xFF1976D2);

  // Neutral colors (Light theme)
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF5F5F5);
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color onSurfaceLight = Color(0xFF1C1B1F);
  static const Color onBackgroundLight = Color(0xFF1C1B1F);
  static const Color outlineLight = Color(0xFF757575);
  static const Color outlineVariantLight = Color(0xFFBDBDBD);

  // Neutral colors (Dark theme)
  static const Color surfaceDark = Color(0xFF1C1B1F);
  static const Color surfaceVariantDark = Color(0xFF2B2A2E);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color onSurfaceDark = Color(0xFFE6E1E5);
  static const Color onBackgroundDark = Color(0xFFE6E1E5);
  static const Color outlineDark = Color(0xFF908D93);
  static const Color outlineVariantDark = Color(0xFF49454F);

  // ===== Typography Scale =====
  static const String fontFamilyPrimary = 'Roboto'; // TODO: Replace with brand font
  static const String fontFamilySecondary = 'Roboto'; // TODO: Replace with brand font
  static const String fontFamilyMono = 'RobotoMono'; // TODO: Replace with brand mono font

  // Heading styles
  static const TextStyle heading1 = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
  );

  static const TextStyle heading4 = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.15,
  );

  static const TextStyle heading5 = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.15,
  );

  static const TextStyle heading6 = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.15,
  );

  // Body styles
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.25,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.4,
  );

  // Label styles
  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
  );

  // ===== Spacing Scale =====
  static const double spaceXs = 4;    // 0.25rem
  static const double spaceSm = 8;    // 0.5rem
  static const double spaceMd = 16;   // 1rem
  static const double spaceLg = 24;   // 1.5rem
  static const double spaceXl = 32;   // 2rem
  static const double space2xl = 40;  // 2.5rem
  static const double space3xl = 48;  // 3rem
  static const double space4xl = 64;  // 4rem

  // Semantic spacing
  static const double spacingInline = spaceSm;
  static const double spacingStack = spaceMd;
  static const double spacingSection = spaceLg;
  static const double spacingScreen = spaceXl;

  // ===== Border Radius =====
  static const double radiusNone = 0;
  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusFull = 9999;

  // ===== Elevation / Shadows =====
  static const double elevation0 = 0;
  static const double elevation1 = 1;
  static const double elevation2 = 3;
  static const double elevation3 = 6;
  static const double elevation4 = 10;
  static const double elevation5 = 15;

  // ===== Breakpoints (for responsive) =====
  static const double breakpointSm = 600;
  static const double breakpointMd = 900;
  static const double breakpointLg = 1200;
  static const double breakpointXl = 1800;

  // ===== Animation =====
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 350);
  static const Curve curveDefault = Curves.easeInOut;
  static const Curve curveEmphasized = Curves.easeInOutCubic;
  static const Curve curveDecelerated = Curves.decelerate;
  static const Curve curveAccelerated = Curves.easeIn;
}

/// Helper to get light color scheme from design tokens
ColorScheme get lightColorScheme => ColorScheme.light(
  primary: DesignTokens.primaryMain,
  onPrimary: DesignTokens.primaryContrast,
  primaryContainer: DesignTokens.primaryLight,
  onPrimaryContainer: DesignTokens.onSurfaceLight,
  secondary: DesignTokens.secondaryMain,
  onSecondary: DesignTokens.secondaryContrast,
  secondaryContainer: DesignTokens.secondaryLight,
  onSecondaryContainer: DesignTokens.onSurfaceLight,
  tertiary: DesignTokens.tertiaryMain,
  onTertiary: DesignTokens.tertiaryDark,
  tertiaryContainer: DesignTokens.tertiaryLight,
  onTertiaryContainer: DesignTokens.onSurfaceLight,
  error: DesignTokens.errorMain,
  onError: Colors.white,
  errorContainer: DesignTokens.errorLight,
  onErrorContainer: DesignTokens.errorDark,
  surface: DesignTokens.surfaceLight,
  onSurface: DesignTokens.onSurfaceLight,
  surfaceContainerHighest: DesignTokens.surfaceVariantLight,
  onSurfaceVariant: DesignTokens.onSurfaceLight.withValues(alpha: 0.7),
  outline: DesignTokens.outlineLight,
  outlineVariant: DesignTokens.outlineVariantLight,
  surfaceTint: DesignTokens.primaryMain,
);

/// Helper to get dark color scheme from design tokens
ColorScheme get darkColorScheme => ColorScheme.dark(
  primary: DesignTokens.primaryMain,
  onPrimary: DesignTokens.primaryContrast,
  primaryContainer: DesignTokens.primaryDark,
  onPrimaryContainer: DesignTokens.onSurfaceDark,
  secondary: DesignTokens.secondaryMain,
  onSecondary: DesignTokens.secondaryContrast,
  secondaryContainer: DesignTokens.secondaryDark,
  onSecondaryContainer: DesignTokens.onSurfaceDark,
  tertiary: DesignTokens.tertiaryMain,
  onTertiary: DesignTokens.tertiaryDark,
  tertiaryContainer: DesignTokens.tertiaryDark,
  onTertiaryContainer: DesignTokens.onSurfaceDark,
  error: DesignTokens.errorMain,
  onError: Colors.white,
  errorContainer: DesignTokens.errorDark,
  onErrorContainer: DesignTokens.errorLight,
  surface: DesignTokens.surfaceDark,
  onSurface: DesignTokens.onSurfaceDark,
  surfaceContainerHighest: DesignTokens.surfaceVariantDark,
  onSurfaceVariant: DesignTokens.onSurfaceDark.withValues(alpha: 0.7),
  outline: DesignTokens.outlineDark,
  outlineVariant: DesignTokens.outlineVariantDark,
  surfaceTint: DesignTokens.primaryMain,
);

class AppTheme {
  static ThemeData get lightTheme {
    final colorScheme = lightColorScheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: DesignTokens.fontFamilyPrimary,
      textTheme: _buildTextTheme(colorScheme, Brightness.light),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: DesignTokens.elevation0,
        scrolledUnderElevation: DesignTokens.elevation1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: DesignTokens.heading5.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: DesignTokens.elevation1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        ),
        color: colorScheme.surface,
        shadowColor: colorScheme.shadow,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceLg,
            vertical: DesignTokens.spaceMd,
          ),
          textStyle: DesignTokens.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceLg,
            vertical: DesignTokens.spaceMd,
          ),
          textStyle: DesignTokens.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceLg,
            vertical: DesignTokens.spaceMd,
          ),
          textStyle: DesignTokens.labelLarge,
          side: BorderSide(
            color: colorScheme.outline,
            width: 1,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(88, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceMd,
            vertical: DesignTokens.spaceSm,
          ),
          textStyle: DesignTokens.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceMd,
          vertical: DesignTokens.spaceMd,
        ),
        labelStyle: DesignTokens.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        hintStyle: DesignTokens.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
        errorStyle: DesignTokens.bodySmall.copyWith(
          color: colorScheme.error,
        ),
        floatingLabelStyle: DesignTokens.bodyMedium.copyWith(
          color: colorScheme.primary,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        backgroundColor: colorScheme.surface,
        elevation: DesignTokens.elevation3,
        selectedLabelStyle: DesignTokens.labelSmall,
        unselectedLabelStyle: DesignTokens.labelSmall,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return DesignTokens.labelSmall.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            );
          }
          return DesignTokens.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
          );
        }),
        height: 70,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: DesignTokens.spaceMd,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: DesignTokens.labelMedium,
        padding: EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceSm,
          vertical: DesignTokens.spaceXs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
        ),
        side: BorderSide.none,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        ),
        elevation: DesignTokens.elevation4,
        titleTextStyle: DesignTokens.heading5.copyWith(
          color: colorScheme.onSurface,
        ),
        contentTextStyle: DesignTokens.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(DesignTokens.radiusXl),
          ),
        ),
        elevation: DesignTokens.elevation4,
        modalBackgroundColor: colorScheme.surface,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
        ),
        elevation: DesignTokens.elevation3,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
        circularTrackColor: colorScheme.surfaceContainerHighest,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.surfaceContainerHighest,
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withValues(alpha: 0.12),
        valueIndicatorColor: colorScheme.primary,
        valueIndicatorTextStyle: DesignTokens.labelSmall.copyWith(
          color: colorScheme.onPrimary,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelStyle: DesignTokens.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: DesignTokens.labelLarge,
        indicatorColor: colorScheme.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceMd,
          vertical: DesignTokens.spaceXs,
        ),
        titleTextStyle: DesignTokens.bodyLarge.copyWith(
          color: colorScheme.onSurface,
        ),
        subtitleTextStyle: DesignTokens.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        leadingAndTrailingTextStyle: DesignTokens.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
        tileColor: Colors.transparent,
        selectedTileColor: colorScheme.primaryContainer,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
        ),
        textStyle: DesignTokens.labelSmall.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceSm,
          vertical: DesignTokens.spaceXs,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: DesignTokens.bodyMedium.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        actionTextColor: colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: DesignTokens.elevation3,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = darkColorScheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: DesignTokens.fontFamilyPrimary,
      textTheme: _buildTextTheme(colorScheme, Brightness.dark),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: DesignTokens.elevation0,
        scrolledUnderElevation: DesignTokens.elevation1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: DesignTokens.heading5.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: DesignTokens.elevation1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        ),
        color: colorScheme.surface,
        shadowColor: colorScheme.shadow,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceLg,
            vertical: DesignTokens.spaceMd,
          ),
          textStyle: DesignTokens.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceLg,
            vertical: DesignTokens.spaceMd,
          ),
          textStyle: DesignTokens.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceLg,
            vertical: DesignTokens.spaceMd,
          ),
          textStyle: DesignTokens.labelLarge,
          side: BorderSide(
            color: colorScheme.outline,
            width: 1,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(88, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceMd,
            vertical: DesignTokens.spaceSm,
          ),
          textStyle: DesignTokens.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceMd,
          vertical: DesignTokens.spaceMd,
        ),
        labelStyle: DesignTokens.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        hintStyle: DesignTokens.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
        errorStyle: DesignTokens.bodySmall.copyWith(
          color: colorScheme.error,
        ),
        floatingLabelStyle: DesignTokens.bodyMedium.copyWith(
          color: colorScheme.primary,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        backgroundColor: colorScheme.surface,
        elevation: DesignTokens.elevation3,
        selectedLabelStyle: DesignTokens.labelSmall,
        unselectedLabelStyle: DesignTokens.labelSmall,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return DesignTokens.labelSmall.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            );
          }
          return DesignTokens.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
          );
        }),
        height: 70,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: DesignTokens.spaceMd,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: DesignTokens.labelMedium,
        padding: EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceSm,
          vertical: DesignTokens.spaceXs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
        ),
        side: BorderSide.none,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        ),
        elevation: DesignTokens.elevation4,
        titleTextStyle: DesignTokens.heading5.copyWith(
          color: colorScheme.onSurface,
        ),
        contentTextStyle: DesignTokens.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(DesignTokens.radiusXl),
          ),
        ),
        elevation: DesignTokens.elevation4,
        modalBackgroundColor: colorScheme.surface,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
        ),
        elevation: DesignTokens.elevation3,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
        circularTrackColor: colorScheme.surfaceContainerHighest,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.surfaceContainerHighest,
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withValues(alpha: 0.12),
        valueIndicatorColor: colorScheme.primary,
        valueIndicatorTextStyle: DesignTokens.labelSmall.copyWith(
          color: colorScheme.onPrimary,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelStyle: DesignTokens.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: DesignTokens.labelLarge,
        indicatorColor: colorScheme.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceMd,
          vertical: DesignTokens.spaceXs,
        ),
        titleTextStyle: DesignTokens.bodyLarge.copyWith(
          color: colorScheme.onSurface,
        ),
        subtitleTextStyle: DesignTokens.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        leadingAndTrailingTextStyle: DesignTokens.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
        tileColor: Colors.transparent,
        selectedTileColor: colorScheme.primaryContainer,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
        ),
        textStyle: DesignTokens.labelSmall.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceSm,
          vertical: DesignTokens.spaceXs,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: DesignTokens.bodyMedium.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        actionTextColor: colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: DesignTokens.elevation3,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  static TextTheme _buildTextTheme(ColorScheme colorScheme, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final onSurface = colorScheme.onSurface;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;

    return TextTheme(
      displayLarge: DesignTokens.heading1.copyWith(
        color: onSurface,
      ),
      displayMedium: DesignTokens.heading2.copyWith(
        color: onSurface,
      ),
      displaySmall: DesignTokens.heading3.copyWith(
        color: onSurface,
      ),
      headlineLarge: DesignTokens.heading4.copyWith(
        color: onSurface,
      ),
      headlineMedium: DesignTokens.heading5.copyWith(
        color: onSurface,
      ),
      headlineSmall: DesignTokens.heading6.copyWith(
        color: onSurface,
      ),
      titleLarge: DesignTokens.heading5.copyWith(
        color: onSurface,
      ),
      titleMedium: DesignTokens.heading6.copyWith(
        color: onSurface,
      ),
      titleSmall: DesignTokens.labelLarge.copyWith(
        color: onSurface,
      ),
      bodyLarge: DesignTokens.bodyLarge.copyWith(
        color: onSurface,
      ),
      bodyMedium: DesignTokens.bodyMedium.copyWith(
        color: onSurface,
      ),
      bodySmall: DesignTokens.bodySmall.copyWith(
        color: onSurfaceVariant,
      ),
      labelLarge: DesignTokens.labelLarge.copyWith(
        color: onSurface,
      ),
      labelMedium: DesignTokens.labelMedium.copyWith(
        color: onSurfaceVariant,
      ),
      labelSmall: DesignTokens.labelSmall.copyWith(
        color: onSurfaceVariant,
      ),
    );
  }
}