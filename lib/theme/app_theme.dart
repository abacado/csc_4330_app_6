import 'package:animations/animations.dart';
import 'package:material_ui/material_ui.dart';

/// Dark forest surfaces, warm ivory type, and fresh sprout accents.
abstract final class AppColors {
  static const paper = Color(0xFF0D1511);
  static const surface = Color(0xFF18271F);
  static const sunken = Color(0xFF24382B);
  static const line = Color(0xFF354738);
  static const ink = Color(0xFFF0EDE2);
  static const inkMuted = Color(0xFFB4C0AE);
  static const moss = Color(0xFFC3DB87);
  static const mossSoft = Color(0xFF2A3E29);
  static const clay = Color(0xFFC18F6C);
  static const claySoft = Color(0xFF3E2B21);
}

abstract final class AppRadius {
  static const sm = 2.0;
  static const md = 4.0;
  static const lg = 6.0;
}

abstract final class AppTheme {
  static ThemeData light() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.moss,
          brightness: Brightness.dark,
        ).copyWith(
          primary: AppColors.moss,
          onPrimary: AppColors.paper,
          secondary: AppColors.clay,
          onSecondary: AppColors.paper,
          surface: AppColors.paper,
          onSurface: AppColors.ink,
          onSurfaceVariant: AppColors.inkMuted,
          outline: AppColors.line,
          outlineVariant: AppColors.line,
          surfaceContainerLowest: AppColors.surface,
          surfaceContainerLow: AppColors.surface,
          surfaceContainer: AppColors.surface,
          surfaceContainerHigh: AppColors.surface,
          surfaceContainerHighest: AppColors.sunken,
        );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final body = base.textTheme.apply(
      fontFamily: 'DMSans',
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    );

    TextStyle display(double size) => TextStyle(
      fontFamily: 'Fraunces',
      fontSize: size,
      fontWeight: FontWeight.w600,
      height: 1.12,
      letterSpacing: -0.4,
      color: AppColors.ink,
    );

    final text = body.copyWith(
      displaySmall: display(36),
      headlineMedium: display(28),
      headlineSmall: display(23),
      titleLarge: body.titleLarge?.copyWith(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      titleMedium: body.titleMedium?.copyWith(
        fontSize: 15.5,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
      bodyLarge: body.bodyLarge?.copyWith(fontSize: 15.5, height: 1.5),
      bodyMedium: body.bodyMedium?.copyWith(fontSize: 14, height: 1.45),
      bodySmall: body.bodySmall?.copyWith(
        fontSize: 12.5,
        height: 1.4,
        color: AppColors.inkMuted,
      ),
      labelLarge: body.labelLarge?.copyWith(
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: body.labelMedium?.copyWith(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: body.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );

    OutlineInputBorder outline(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: color, width: width),
        );

    const sharedAxis = SharedAxisPageTransitionsBuilder(
      transitionType: SharedAxisTransitionType.horizontal,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.paper,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.mossSoft,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      canvasColor: AppColors.paper,
      textTheme: text,
      splashFactory: InkRipple.splashFactory,
      splashColor: AppColors.ink.withValues(alpha: 0.04),
      highlightColor: Colors.transparent,
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        hintStyle: text.bodyMedium?.copyWith(color: AppColors.inkMuted),
        labelStyle: text.bodyMedium?.copyWith(color: AppColors.inkMuted),
        border: outline(AppColors.line),
        enabledBorder: outline(AppColors.line),
        focusedBorder: outline(AppColors.moss, 1.5),
        errorBorder: outline(AppColors.clay),
        focusedErrorBorder: outline(AppColors.clay, 1.5),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: AppColors.moss,
          foregroundColor: AppColors.paper,
          disabledBackgroundColor: AppColors.sunken,
          disabledForegroundColor: AppColors.inkMuted,
          textStyle: text.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.line),
          textStyle: text.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.moss,
          textStyle: text.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.paper,
        elevation: 2,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: text.bodyMedium?.copyWith(color: AppColors.paper),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: AppColors.line,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: sharedAxis,
          TargetPlatform.iOS: sharedAxis,
          TargetPlatform.macOS: sharedAxis,
          TargetPlatform.windows: sharedAxis,
          TargetPlatform.linux: sharedAxis,
          TargetPlatform.fuchsia: sharedAxis,
        },
      ),
    );
  }
}
