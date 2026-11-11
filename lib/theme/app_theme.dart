import 'package:animations/animations.dart';
import 'package:material_ui/material_ui.dart';

/// "Pastel Garden": warm cream surfaces, sage / powder blue / blush accents,
/// soft raised cards and pill-shaped controls.
abstract final class AppColors {
  // Surfaces
  static const paper = Color(0xFFF4ECE4); // page background
  static const surface = Color(0xFFFBF7F2); // raised cards
  static const sunken = Color(0xFFEFE6DC); // inset fields
  static const sand = Color(0xFFEADFD3);
  static const line = Color(0xFFE2D6C8);

  // Type
  static const ink = Color(0xFF3B3530);
  static const inkMuted = Color(0xFF6B6058);

  // Sage (primary)
  static const moss = Color(0xFF3F6B58); // accent text and icons
  static const mossDeep = Color(0xFF24352D); // text on sage
  static const mossSoft = Color(0xFFBFDCCD); // sage fill
  static const sage = mossSoft;
  static const sageLight = Color(0xFFCFE3D6);

  // Powder blue
  static const powder = Color(0xFFBCD4E2);
  static const powderLight = Color(0xFFDCE8EF);
  static const powderInk = Color(0xFF2F4F62);

  // Blush
  static const blush = Color(0xFFF2C4BD);
  static const blushLight = Color(0xFFF2D6CF);
  static const blushInk = Color(0xFF4A2C28);

  // Errors
  static const clay = Color(0xFFB4554A);
  static const claySoft = blush;

  static const shadow = Color(0xFF967D64);
}

abstract final class AppRadius {
  static const sm = 12.0;
  static const md = 18.0;
  static const lg = 28.0;
  static const pill = 999.0;
}

abstract final class AppDecor {
  /// Soft, warm drop shadow used under raised cards and controls.
  static List<BoxShadow> raised([double strength = 1]) => [
    BoxShadow(
      color: AppColors.shadow.withValues(alpha: 0.15 * strength),
      blurRadius: 28,
      offset: const Offset(0, 12),
    ),
  ];

  static BoxDecoration card({
    Color color = AppColors.surface,
    double radius = AppRadius.lg,
  }) => BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: raised(),
  );
}

abstract final class AppTheme {
  static ThemeData light() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.moss,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.moss,
          onPrimary: Colors.white,
          primaryContainer: AppColors.sage,
          onPrimaryContainer: AppColors.mossDeep,
          secondary: AppColors.blush,
          onSecondary: AppColors.blushInk,
          tertiary: AppColors.powder,
          onTertiary: AppColors.powderInk,
          error: AppColors.clay,
          surface: AppColors.paper,
          onSurface: AppColors.ink,
          onSurfaceVariant: AppColors.inkMuted,
          outline: AppColors.line,
          outlineVariant: AppColors.line,
          surfaceTint: Colors.transparent,
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
      height: 1.1,
      letterSpacing: -0.5,
      color: AppColors.ink,
    );

    final text = body.copyWith(
      displaySmall: display(36),
      headlineMedium: display(30),
      headlineSmall: display(24),
      titleLarge: body.titleLarge?.copyWith(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      titleMedium: body.titleMedium?.copyWith(
        fontSize: 15.5,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
      ),
      bodyLarge: body.bodyLarge?.copyWith(fontSize: 15.5, height: 1.55),
      bodyMedium: body.bodyMedium?.copyWith(fontSize: 14, height: 1.5),
      bodySmall: body.bodySmall?.copyWith(
        fontSize: 12.5,
        height: 1.4,
        color: AppColors.inkMuted,
      ),
      labelLarge: body.labelLarge?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
      labelMedium: body.labelMedium?.copyWith(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
      ),
      labelSmall: body.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    );

    OutlineInputBorder field([Color? color, double width = 1.5]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: color == null
              ? BorderSide.none
              : BorderSide(color: color, width: width),
        );

    const sharedAxis = SharedAxisPageTransitionsBuilder(
      transitionType: SharedAxisTransitionType.horizontal,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.paper,
      canvasColor: AppColors.paper,
      textTheme: text,
      splashFactory: InkRipple.splashFactory,
      splashColor: AppColors.moss.withValues(alpha: 0.06),
      highlightColor: Colors.transparent,
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.sage,
        indicatorShape: const StadiumBorder(),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.moss,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.sunken,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        hintStyle: text.bodyMedium?.copyWith(color: AppColors.inkMuted),
        labelStyle: text.bodyMedium?.copyWith(color: AppColors.inkMuted),
        floatingLabelStyle: text.bodyMedium?.copyWith(
          color: AppColors.moss,
          fontWeight: FontWeight.w700,
        ),
        prefixIconColor: AppColors.inkMuted,
        border: field(),
        enabledBorder: field(),
        disabledBorder: field(),
        focusedBorder: field(AppColors.moss),
        errorBorder: field(AppColors.clay, 1),
        focusedErrorBorder: field(AppColors.clay),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          backgroundColor: AppColors.sage,
          foregroundColor: AppColors.mossDeep,
          disabledBackgroundColor: AppColors.sunken,
          disabledForegroundColor: AppColors.inkMuted,
          elevation: 3,
          shadowColor: AppColors.moss.withValues(alpha: 0.5),
          textStyle: text.labelLarge,
          shape: const StadiumBorder(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          elevation: 2,
          shadowColor: AppColors.shadow.withValues(alpha: 0.4),
          side: BorderSide.none,
          textStyle: text.labelLarge,
          shape: const StadiumBorder(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.moss,
          textStyle: text.labelLarge,
          shape: const StadiumBorder(),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.moss
              : AppColors.inkMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.sage
              : AppColors.sunken,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.sage,
        foregroundColor: AppColors.mossDeep,
        elevation: 3,
        highlightElevation: 5,
        shape: StadiumBorder(),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: text.bodyMedium?.copyWith(color: AppColors.surface),
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
