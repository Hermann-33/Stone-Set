import 'package:flutter/material.dart';

/// Semantic colors shared by Stone Set clients.
@immutable
class StoneSetSemanticColors extends ThemeExtension<StoneSetSemanticColors> {
  const StoneSetSemanticColors({
    required this.canvas,
    required this.surface,
    required this.raisedSurface,
    required this.interactiveSurface,
    required this.outline,
    required this.textStrong,
    required this.textMuted,
    required this.disabled,
    required this.success,
    required this.warning,
    required this.destructive,
    required this.information,
    required this.focus,
    required this.authoritative,
    required this.provisional,
    required this.pending,
    required this.stale,
    required this.conflict,
  });

  final Color canvas;
  final Color surface;
  final Color raisedSurface;
  final Color interactiveSurface;
  final Color outline;
  final Color textStrong;
  final Color textMuted;
  final Color disabled;
  final Color success;
  final Color warning;
  final Color destructive;
  final Color information;
  final Color focus;
  final Color authoritative;
  final Color provisional;
  final Color pending;
  final Color stale;
  final Color conflict;

  static const dark = StoneSetSemanticColors(
    canvas: Color(0xff101214),
    surface: Color(0xff181b1f),
    raisedSurface: Color(0xff22262b),
    interactiveSurface: Color(0xff2b3036),
    outline: Color(0xff59616b),
    textStrong: Color(0xfff5f6f7),
    textMuted: Color(0xffc4c9cf),
    disabled: Color(0xff777f88),
    success: Color(0xff66d19e),
    warning: Color(0xffffc45c),
    destructive: Color(0xffff7c80),
    information: Color(0xff8fc7ff),
    focus: Color(0xffb8d9ff),
    authoritative: Color(0xffe3e7eb),
    provisional: Color(0xffa7c9ff),
    pending: Color(0xffffcc70),
    stale: Color(0xffb8bec6),
    conflict: Color(0xffff9a73),
  );

  static const light = StoneSetSemanticColors(
    canvas: Color(0xfff3f4f5),
    surface: Color(0xffffffff),
    raisedSurface: Color(0xfff9fafb),
    interactiveSurface: Color(0xffe9edf1),
    outline: Color(0xff6a727b),
    textStrong: Color(0xff17191c),
    textMuted: Color(0xff4f565e),
    disabled: Color(0xff7b828a),
    success: Color(0xff176b45),
    warning: Color(0xff815400),
    destructive: Color(0xffa8232a),
    information: Color(0xff185c91),
    focus: Color(0xff145f9b),
    authoritative: Color(0xff30353a),
    provisional: Color(0xff276aa0),
    pending: Color(0xff815400),
    stale: Color(0xff5e666e),
    conflict: Color(0xff9c3c19),
  );

  static StoneSetSemanticColors of(BuildContext context) =>
      Theme.of(context).extension<StoneSetSemanticColors>() ??
      (Theme.of(context).brightness == Brightness.dark ? dark : light);

  @override
  StoneSetSemanticColors copyWith({
    Color? canvas,
    Color? surface,
    Color? raisedSurface,
    Color? interactiveSurface,
    Color? outline,
    Color? textStrong,
    Color? textMuted,
    Color? disabled,
    Color? success,
    Color? warning,
    Color? destructive,
    Color? information,
    Color? focus,
    Color? authoritative,
    Color? provisional,
    Color? pending,
    Color? stale,
    Color? conflict,
  }) => StoneSetSemanticColors(
    canvas: canvas ?? this.canvas,
    surface: surface ?? this.surface,
    raisedSurface: raisedSurface ?? this.raisedSurface,
    interactiveSurface: interactiveSurface ?? this.interactiveSurface,
    outline: outline ?? this.outline,
    textStrong: textStrong ?? this.textStrong,
    textMuted: textMuted ?? this.textMuted,
    disabled: disabled ?? this.disabled,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    destructive: destructive ?? this.destructive,
    information: information ?? this.information,
    focus: focus ?? this.focus,
    authoritative: authoritative ?? this.authoritative,
    provisional: provisional ?? this.provisional,
    pending: pending ?? this.pending,
    stale: stale ?? this.stale,
    conflict: conflict ?? this.conflict,
  );

  @override
  StoneSetSemanticColors lerp(covariant StoneSetSemanticColors? other, double t) {
    if (other == null) return this;
    return StoneSetSemanticColors(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      raisedSurface: Color.lerp(raisedSurface, other.raisedSurface, t)!,
      interactiveSurface: Color.lerp(interactiveSurface, other.interactiveSurface, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      textStrong: Color.lerp(textStrong, other.textStrong, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      destructive: Color.lerp(destructive, other.destructive, t)!,
      information: Color.lerp(information, other.information, t)!,
      focus: Color.lerp(focus, other.focus, t)!,
      authoritative: Color.lerp(authoritative, other.authoritative, t)!,
      provisional: Color.lerp(provisional, other.provisional, t)!,
      pending: Color.lerp(pending, other.pending, t)!,
      stale: Color.lerp(stale, other.stale, t)!,
      conflict: Color.lerp(conflict, other.conflict, t)!,
    );
  }
}

@immutable
class StoneSetTextStyles extends ThemeExtension<StoneSetTextStyles> {
  const StoneSetTextStyles({
    required this.rankDisplay,
    required this.pageTitle,
    required this.sectionTitle,
    required this.cardTitle,
    required this.body,
    required this.compactBody,
    required this.dataValue,
    required this.tableValue,
    required this.label,
    required this.caption,
    required this.button,
    required this.identifier,
  });

  final TextStyle rankDisplay;
  final TextStyle pageTitle;
  final TextStyle sectionTitle;
  final TextStyle cardTitle;
  final TextStyle body;
  final TextStyle compactBody;
  final TextStyle dataValue;
  final TextStyle tableValue;
  final TextStyle label;
  final TextStyle caption;
  final TextStyle button;
  final TextStyle identifier;

  static const standard = StoneSetTextStyles(
    rankDisplay: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
    ),
    pageTitle: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.12),
    sectionTitle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.2),
    cardTitle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.3),
    body: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.45),
    compactBody: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.4),
    dataValue: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
    ),
    tableValue: TextStyle(
      fontSize: 14,
      fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
    ),
    label: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.25, height: 1.25),
    caption: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.35),
    button: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.15),
    identifier: TextStyle(
      fontFamily: 'monospace',
      fontSize: 13,
      fontWeight: FontWeight.w500,
      height: 1.35,
      fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
    ),
  );

  static const mobile = StoneSetTextStyles(
    rankDisplay: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.1,
      height: 1.1,
    ),
    pageTitle: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.12),
    sectionTitle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.2),
    cardTitle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.25),
    body: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.45),
    compactBody: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.42),
    dataValue: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      height: 1.15,
      fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
    ),
    tableValue: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
    ),
    label: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.25,
      height: 1.25,
    ),
    caption: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.4),
    button: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.15),
    identifier: TextStyle(
      fontFamily: 'monospace',
      fontSize: 13,
      fontWeight: FontWeight.w500,
      height: 1.35,
      fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
    ),
  );

  static StoneSetTextStyles of(BuildContext context) =>
      Theme.of(context).extension<StoneSetTextStyles>() ?? standard;

  @override
  StoneSetTextStyles copyWith({
    TextStyle? rankDisplay,
    TextStyle? pageTitle,
    TextStyle? sectionTitle,
    TextStyle? cardTitle,
    TextStyle? body,
    TextStyle? compactBody,
    TextStyle? dataValue,
    TextStyle? tableValue,
    TextStyle? label,
    TextStyle? caption,
    TextStyle? button,
    TextStyle? identifier,
  }) => StoneSetTextStyles(
    rankDisplay: rankDisplay ?? this.rankDisplay,
    pageTitle: pageTitle ?? this.pageTitle,
    sectionTitle: sectionTitle ?? this.sectionTitle,
    cardTitle: cardTitle ?? this.cardTitle,
    body: body ?? this.body,
    compactBody: compactBody ?? this.compactBody,
    dataValue: dataValue ?? this.dataValue,
    tableValue: tableValue ?? this.tableValue,
    label: label ?? this.label,
    caption: caption ?? this.caption,
    button: button ?? this.button,
    identifier: identifier ?? this.identifier,
  );

  @override
  StoneSetTextStyles lerp(covariant StoneSetTextStyles? other, double t) {
    if (other == null) return this;
    return StoneSetTextStyles(
      rankDisplay: TextStyle.lerp(rankDisplay, other.rankDisplay, t)!,
      pageTitle: TextStyle.lerp(pageTitle, other.pageTitle, t)!,
      sectionTitle: TextStyle.lerp(sectionTitle, other.sectionTitle, t)!,
      cardTitle: TextStyle.lerp(cardTitle, other.cardTitle, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      compactBody: TextStyle.lerp(compactBody, other.compactBody, t)!,
      dataValue: TextStyle.lerp(dataValue, other.dataValue, t)!,
      tableValue: TextStyle.lerp(tableValue, other.tableValue, t)!,
      label: TextStyle.lerp(label, other.label, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
      button: TextStyle.lerp(button, other.button, t)!,
      identifier: TextStyle.lerp(identifier, other.identifier, t)!,
    );
  }
}

@immutable
class StoneSetPresentationProfile extends ThemeExtension<StoneSetPresentationProfile> {
  const StoneSetPresentationProfile({required this.mobile});

  final bool mobile;

  static bool mobileOf(BuildContext context) =>
      Theme.of(context).extension<StoneSetPresentationProfile>()?.mobile ?? false;

  @override
  StoneSetPresentationProfile copyWith({bool? mobile}) =>
      StoneSetPresentationProfile(mobile: mobile ?? this.mobile);

  @override
  StoneSetPresentationProfile lerp(
    covariant StoneSetPresentationProfile? other,
    double t,
  ) => t < 0.5 ? this : (other ?? this);
}

abstract final class StoneSetSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const section = 48.0;
  static const minimumTouchTarget = 48.0;
}

abstract final class StoneSetShapes {
  static const structuralRadius = 24.0;
  static const cardRadius = 16.0;
  static const controlRadius = 12.0;
  static const mobileCardRadius = 18.0;
  static const mobileControlRadius = 14.0;
  static const compactRadius = 10.0;
  static const pillRadius = 999.0;
  static const thinBorder = 1.0;
  static const strongBorder = 2.0;
}

abstract final class StoneSetMotion {
  static const micro = Duration(milliseconds: 140);
  static const standard = Duration(milliseconds: 240);
  static const emphasized = Duration(milliseconds: 420);
  static const reduced = Duration(milliseconds: 120);
  static const standardCurve = Curves.easeOutCubic;
  static const entranceCurve = Curves.easeOutQuart;
  static const exitCurve = Curves.easeInCubic;

  static bool reducedMotionOf(BuildContext context) {
    final media = MediaQuery.maybeOf(context);
    return (media?.disableAnimations ?? false) || (media?.accessibleNavigation ?? false);
  }
}

enum StoneSetRankFamily {
  bronze,
  silver,
  gold,
  platinum,
  diamond,
  elite,
  champion,
  apex,
  prodigy,
  adonis,
}

@immutable
class StoneSetRankPalette {
  const StoneSetRankPalette(this.base, this.highlight);

  final Color base;
  final Color highlight;

  static StoneSetRankPalette forFamily(StoneSetRankFamily family) => switch (family) {
    StoneSetRankFamily.bronze => const StoneSetRankPalette(Color(0xffa96f45), Color(0xffe1a676)),
    StoneSetRankFamily.silver => const StoneSetRankPalette(Color(0xff89939e), Color(0xffd9e0e7)),
    StoneSetRankFamily.gold => const StoneSetRankPalette(Color(0xffbd8618), Color(0xffffd66b)),
    StoneSetRankFamily.platinum => const StoneSetRankPalette(Color(0xff45929d), Color(0xffa7edf2)),
    StoneSetRankFamily.diamond => const StoneSetRankPalette(Color(0xff567fca), Color(0xffb8d4ff)),
    StoneSetRankFamily.elite => const StoneSetRankPalette(Color(0xff8155b7), Color(0xffd9b9ff)),
    StoneSetRankFamily.champion => const StoneSetRankPalette(Color(0xffa8497c), Color(0xffffb7db)),
    StoneSetRankFamily.apex => const StoneSetRankPalette(Color(0xffa54444), Color(0xffffaaa1)),
    StoneSetRankFamily.prodigy => const StoneSetRankPalette(Color(0xff377c63), Color(0xff91e4bc)),
    StoneSetRankFamily.adonis => const StoneSetRankPalette(Color(0xffad8c35), Color(0xffffe8a1)),
  };
}

abstract final class StoneSetTheme {
  static ThemeData light() => _build(Brightness.light, StoneSetSemanticColors.light);
  static ThemeData dark() => _build(Brightness.dark, StoneSetSemanticColors.dark);

  static ThemeData mobileLight() => _build(
    Brightness.light,
    const StoneSetSemanticColors(
      canvas: Color(0xfff3f5f7),
      surface: Color(0xffffffff),
      raisedSurface: Color(0xfff8fafb),
      interactiveSurface: Color(0xffe8edf2),
      outline: Color(0xff66717c),
      textStrong: Color(0xff15191d),
      textMuted: Color(0xff505b65),
      disabled: Color(0xff7c858e),
      success: Color(0xff176847),
      warning: Color(0xff7a5200),
      destructive: Color(0xffa52b31),
      information: Color(0xff205f8c),
      focus: Color(0xff165f96),
      authoritative: Color(0xff273038),
      provisional: Color(0xff286c9e),
      pending: Color(0xff7a5200),
      stale: Color(0xff59636c),
      conflict: Color(0xff983f1d),
    ),
    mobile: true,
  );

  static ThemeData mobileDark() => _build(
    Brightness.dark,
    const StoneSetSemanticColors(
      canvas: Color(0xff090b0d),
      surface: Color(0xff111417),
      raisedSurface: Color(0xff181c20),
      interactiveSurface: Color(0xff222830),
      outline: Color(0xff47515c),
      textStrong: Color(0xfff3f6f8),
      textMuted: Color(0xffadb6c0),
      disabled: Color(0xff737d87),
      success: Color(0xff67d5a1),
      warning: Color(0xffffc764),
      destructive: Color(0xffff8186),
      information: Color(0xff91c9f4),
      focus: Color(0xffb3d9f5),
      authoritative: Color(0xffdbe3e9),
      provisional: Color(0xff9ecbf0),
      pending: Color(0xffffca70),
      stale: Color(0xffaab3bc),
      conflict: Color(0xffff9a72),
    ),
    mobile: true,
  );

  static ThemeData _build(
    Brightness brightness,
    StoneSetSemanticColors colors, {
    bool mobile = false,
  }) {
    if (!mobile) {
      final legacyScheme = ColorScheme.fromSeed(
        seedColor: const Color(0xff5d6874),
        brightness: brightness,
        surface: colors.surface,
        error: colors.destructive,
      );
      return ThemeData(
        brightness: brightness,
        colorScheme: legacyScheme,
        scaffoldBackgroundColor: colors.canvas,
        useMaterial3: true,
        extensions: <ThemeExtension<dynamic>>[
          StoneSetTextStyles.standard,
          colors,
        ],
        visualDensity: VisualDensity.standard,
        materialTapTargetSize: MaterialTapTargetSize.padded,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(StoneSetShapes.controlRadius),
          ),
        ),
      );
    }
    final primary = brightness == Brightness.dark
        ? const Color(0xff9bc8e8)
        : const Color(0xff2e668f);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: brightness,
          surface: colors.surface,
          error: colors.destructive,
        ).copyWith(
          primary: primary,
          onPrimary: brightness == Brightness.dark ? const Color(0xff082131) : Colors.white,
          secondary: brightness == Brightness.dark
              ? const Color(0xffaebdca)
              : const Color(0xff526a7c),
          surfaceContainerLowest: colors.canvas,
          surfaceContainerLow: colors.surface,
          surfaceContainer: colors.raisedSurface,
          surfaceContainerHigh: colors.interactiveSurface,
          outline: colors.outline,
          onSurface: colors.textStrong,
          onSurfaceVariant: colors.textMuted,
        );
    final mobileBase = ThemeData(
      brightness: brightness,
      colorScheme: scheme,
      useMaterial3: true,
    );
    final controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(StoneSetShapes.mobileControlRadius),
    );
    return ThemeData(
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.canvas,
      useMaterial3: true,
      extensions: <ThemeExtension<dynamic>>[
        StoneSetTextStyles.mobile,
        colors,
        const StoneSetPresentationProfile(mobile: true),
      ],
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colors.textStrong,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: StoneSetTextStyles.mobile.sectionTitle.copyWith(
          color: colors.textStrong,
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.raisedSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StoneSetShapes.mobileCardRadius),
          side: BorderSide(color: colors.outline.withValues(alpha: 0.72)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: colors.surface.withValues(alpha: 0.98),
        surfaceTintColor: Colors.transparent,
        indicatorColor: primary.withValues(alpha: brightness == Brightness.dark ? 0.20 : 0.14),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StoneSetShapes.mobileControlRadius),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            size: states.contains(WidgetState.selected) ? 25 : 23,
            color: states.contains(WidgetState.selected) ? primary : colors.textMuted,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return StoneSetTextStyles.mobile.caption.copyWith(
            color: states.contains(WidgetState.selected) ? colors.textStrong : colors.textMuted,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w600,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(StoneSetSpacing.minimumTouchTarget, 52),
          shape: controlShape,
          textStyle: StoneSetTextStyles.mobile.button,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(StoneSetSpacing.minimumTouchTarget, 52),
          shape: controlShape,
          side: BorderSide(color: colors.outline),
          textStyle: StoneSetTextStyles.mobile.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(StoneSetSpacing.minimumTouchTarget, 48),
          shape: controlShape,
          textStyle: StoneSetTextStyles.mobile.button,
        ),
      ),
      chipTheme: mobileBase.chipTheme.copyWith(
        backgroundColor: colors.interactiveSurface.withValues(alpha: 0.72),
        selectedColor: primary.withValues(alpha: 0.16),
        side: BorderSide(color: colors.outline.withValues(alpha: 0.8)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StoneSetShapes.pillRadius),
        ),
        labelStyle: StoneSetTextStyles.mobile.caption.copyWith(color: colors.textStrong),
        padding: const EdgeInsets.symmetric(horizontal: StoneSetSpacing.xs),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.interactiveSurface.withValues(alpha: 0.72),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: StoneSetSpacing.md,
          vertical: StoneSetSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(StoneSetShapes.mobileControlRadius),
          borderSide: BorderSide(color: colors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(StoneSetShapes.mobileControlRadius),
          borderSide: BorderSide(color: colors.outline.withValues(alpha: 0.82)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(StoneSetShapes.mobileControlRadius),
          borderSide: BorderSide(color: colors.focus, width: StoneSetShapes.strongBorder),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(StoneSetShapes.mobileControlRadius),
          borderSide: BorderSide(color: colors.destructive),
        ),
        labelStyle: StoneSetTextStyles.mobile.compactBody.copyWith(color: colors.textMuted),
        floatingLabelStyle: StoneSetTextStyles.mobile.label.copyWith(color: primary),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: StoneSetSpacing.md,
          vertical: StoneSetSpacing.xxs,
        ),
        iconColor: colors.textMuted,
        textColor: colors.textStrong,
        titleTextStyle: StoneSetTextStyles.mobile.cardTitle.copyWith(
          color: colors.textStrong,
          fontSize: 16,
        ),
        subtitleTextStyle: StoneSetTextStyles.mobile.compactBody.copyWith(
          color: colors.textMuted,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.outline.withValues(alpha: 0.58),
        thickness: StoneSetShapes.thinBorder,
        space: StoneSetSpacing.md,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: brightness == Brightness.dark
            ? const Color(0xff293038)
            : const Color(0xff202a32),
        contentTextStyle: StoneSetTextStyles.mobile.compactBody.copyWith(color: Colors.white),
        shape: controlShape,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        modalBackgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(StoneSetShapes.structuralRadius),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.raisedSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StoneSetShapes.structuralRadius),
          side: BorderSide(color: colors.outline),
        ),
      ),
    );
  }
}
