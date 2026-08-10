import 'package:flutter/material.dart';

import '../theme/stone_set_theme.dart';
import 'rank_progress_ring_painter.dart';
import 'stone_set_rank_asset.dart';

@immutable
class RankProgressHeroData {
  const RankProgressHeroData({
    required this.asset,
    required this.rankRating,
    required this.progressFraction,
    this.nextRankName,
    this.nextRankThreshold,
    this.isMaxRank = false,
  }) : assert(rankRating >= 0),
       assert(
         isMaxRank || (nextRankName != null && nextRankThreshold != null),
         'A non-maximum rank requires its next rank and threshold.',
       );

  final StoneSetRankAsset asset;
  final int rankRating;
  final double progressFraction;
  final String? nextRankName;
  final int? nextRankThreshold;
  final bool isMaxRank;

  int get percentage => (RankProgressRingGeometry.clamp(progressFraction) * 100).round();
}

class RankEmblem extends StatelessWidget {
  const RankEmblem({required this.asset, required this.size, super.key});

  final StoneSetRankAsset asset;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: Image.asset(
      asset.assetKey,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: size * 0.35,
          color: StoneSetSemanticColors.of(context).textMuted,
        ),
      ),
    ),
  );
}

/// Final-frame rank presentation.
///
/// Animation coordination belongs to the consuming application. This widget
/// owns no ticker and schedules no frames while idle.
class RankProgressHero extends StatelessWidget {
  const RankProgressHero({
    required this.data,
    this.provisionalProgress,
    this.pendingLabel,
    this.onTap,
    super.key,
  });

  final RankProgressHeroData data;
  final double? provisionalProgress;
  final String? pendingLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final semanticLabel = _semanticLabel(data, provisionalProgress, pendingLabel);
    return Semantics(
      container: true,
      button: onTap != null,
      label: semanticLabel,
      onTap: onTap,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(StoneSetShapes.mobileCardRadius),
          child: Padding(
            padding: const EdgeInsets.all(StoneSetSpacing.xs),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final available = constraints.maxWidth.isFinite ? constraints.maxWidth : 320.0;
                final diameter = (available * 0.72).clamp(160.0, 296.0).toDouble();
                final palette = StoneSetRankPalette.forFamily(data.asset.family);
                final colors = StoneSetSemanticColors.of(context);
                return DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(StoneSetShapes.structuralRadius),
                    border: Border.all(color: palette.base.withValues(alpha: 0.36)),
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.34),
                      radius: 1.08,
                      colors: <Color>[
                        palette.base.withValues(alpha: 0.12),
                        colors.raisedSurface.withValues(alpha: 0.96),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      StoneSetSpacing.md,
                      StoneSetSpacing.lg,
                      StoneSetSpacing.md,
                      StoneSetSpacing.xl,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        RepaintBoundary(
                          child: SizedBox.square(
                            dimension: diameter + 20,
                            child: Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  CustomPaint(
                                    size: Size.square(diameter),
                                    painter: RankProgressRingPainter(
                                      progress: data.isMaxRank ? 1 : data.progressFraction,
                                      trackColor: colors.outline.withValues(alpha: 0.48),
                                      trackHighlightColor: colors.textStrong.withValues(
                                        alpha: 0.08,
                                      ),
                                      activeStartColor: palette.base,
                                      activeColor: palette.highlight,
                                      provisionalProgress: provisionalProgress,
                                      provisionalColor: colors.provisional,
                                      strokeWidth: (diameter / 26).clamp(8.0, 12.0),
                                    ),
                                  ),
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                          color: palette.base.withValues(alpha: 0.18),
                                          blurRadius: 28,
                                          spreadRadius: -4,
                                        ),
                                      ],
                                    ),
                                    child: RankEmblem(
                                      asset: data.asset,
                                      size: diameter * 0.58,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: StoneSetSpacing.sm),
                        Text(
                          data.asset.displayName.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: StoneSetTextStyles.of(context).rankDisplay.copyWith(
                            color: Color.lerp(colors.textStrong, palette.highlight, 0.24),
                          ),
                        ),
                        const SizedBox(height: StoneSetSpacing.xs),
                        Text(
                          data.isMaxRank
                              ? '${_formatNumber(data.rankRating)}+ RR'
                              : '${_formatNumber(data.rankRating)} / ${_formatNumber(data.nextRankThreshold!)} RR',
                          textAlign: TextAlign.center,
                          style: StoneSetTextStyles.of(context).dataValue,
                        ),
                        const SizedBox(height: StoneSetSpacing.xxs),
                        Text(
                          data.isMaxRank
                              ? 'MAX RANK'
                              : '${data.percentage}% to ${data.nextRankName}',
                          textAlign: TextAlign.center,
                          style: StoneSetTextStyles.of(
                            context,
                          ).compactBody.copyWith(color: colors.textMuted),
                        ),
                        if (pendingLabel != null) ...<Widget>[
                          const SizedBox(height: StoneSetSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: StoneSetSpacing.sm,
                              vertical: StoneSetSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: colors.pending.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(StoneSetShapes.pillRadius),
                              border: Border.all(
                                color: colors.pending.withValues(alpha: 0.54),
                              ),
                            ),
                            child: Text(
                              pendingLabel!,
                              textAlign: TextAlign.center,
                              style: StoneSetTextStyles.of(
                                context,
                              ).caption.copyWith(color: colors.pending),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

String _semanticLabel(
  RankProgressHeroData data,
  double? provisionalProgress,
  String? pendingLabel,
) {
  final buffer = StringBuffer(
    'Current rank ${data.asset.displayName}. ${_formatNumber(data.rankRating)} rank rating. ',
  );
  if (data.isMaxRank) {
    buffer.write('Maximum rank.');
  } else {
    buffer.write(
      '${data.percentage} percent toward ${data.nextRankName} at '
      '${_formatNumber(data.nextRankThreshold!)} rank rating.',
    );
  }
  if (provisionalProgress != null) {
    buffer.write(' Provisional progress is shown separately.');
  }
  if (pendingLabel != null) {
    buffer.write(' Pending. $pendingLabel');
  }
  return buffer.toString();
}

String _formatNumber(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) buffer.write(',');
    buffer.write(digits[index]);
  }
  return buffer.toString();
}
