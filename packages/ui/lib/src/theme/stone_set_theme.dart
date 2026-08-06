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
    required this.cardTitle,
    required this.compactBody,
    required this.dataValue,
    required this.tableValue,
    required this.caption,
  });

  final TextStyle rankDisplay;
  final TextStyle cardTitle;
  final TextStyle compactBody;
  final TextStyle dataValue;
  final TextStyle tableValue;
  final TextStyle caption;

  static const standard = StoneSetTextStyles(
    rankDisplay: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: 1.2),
    cardTitle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.3),
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
    caption: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.35),
  );

  static StoneSetTextStyles of(BuildContext context) =>
      Theme.of(context).extension<StoneSetTextStyles>() ?? standard;

  @override
  StoneSetTextStyles copyWith({
    TextStyle? rankDisplay,
    TextStyle? cardTitle,
    TextStyle? compactBody,
    TextStyle? dataValue,
    TextStyle? tableValue,
    TextStyle? caption,
  }) => StoneSetTextStyles(
    rankDisplay: rankDisplay ?? this.rankDisplay,
    cardTitle: cardTitle ?? this.cardTitle,
    compactBody: compactBody ?? this.compactBody,
    dataValue: dataValue ?? this.dataValue,
    tableValue: tableValue ?? this.tableValue,
    caption: caption ?? this.caption,
  );

  @override
  StoneSetTextStyles lerp(covariant StoneSetTextStyles? other, double t) {
    if (other == null) return this;
    return StoneSetTextStyles(
      rankDisplay: TextStyle.lerp(rankDisplay, other.rankDisplay, t)!,
      cardTitle: TextStyle.lerp(cardTitle, other.cardTitle, t)!,
      compactBody: TextStyle.lerp(compactBody, other.compactBody, t)!,
      dataValue: TextStyle.lerp(dataValue, other.dataValue, t)!,
      tableValue: TextStyle.lerp(tableValue, other.tableValue, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
    );
  }
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
  static const cardRadius = 16.0;
  static const controlRadius = 12.0;
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

  static ThemeData _build(Brightness brightness, StoneSetSemanticColors colors) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xff5d6874),
      brightness: brightness,
      surface: colors.surface,
      error: colors.destructive,
    );
    return ThemeData(
      brightness: brightness,
      colorScheme: scheme,
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
}
