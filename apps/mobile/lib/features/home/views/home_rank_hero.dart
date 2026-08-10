import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

import '../models/home_view_models.dart';

enum HomeRankTransitionKind { initial, ratingChange, rankUp, rankDown, none }

class HomeRankHero extends StatefulWidget {
  const HomeRankHero({
    required this.snapshot,
    required this.onTap,
    super.key,
  });

  final HomeRankViewData snapshot;
  final VoidCallback onTap;

  @override
  State<HomeRankHero> createState() => _HomeRankHeroState();
}

class _HomeRankHeroState extends State<HomeRankHero> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Animation<double> _progress = const AlwaysStoppedAnimation<double>(0);
  Animation<double> _rating = const AlwaysStoppedAnimation<double>(0);
  HomeRankViewData? _fromSnapshot;
  late HomeRankViewData _toSnapshot;
  HomeRankTransitionKind _transitionKind = HomeRankTransitionKind.none;
  var _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _toSnapshot = widget.snapshot;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _startTransition(widget.snapshot, firstRender: true);
    }
  }

  @override
  void didUpdateWidget(HomeRankHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    final old = oldWidget.snapshot;
    final next = widget.snapshot;
    if (old.rankId != next.rankId ||
        old.rankRating != next.rankRating ||
        old.progress != next.progress) {
      _startTransition(next, from: old);
    }
  }

  void _startTransition(
    HomeRankViewData target, {
    HomeRankViewData? from,
    bool firstRender = false,
  }) {
    final reduceMotion = StoneSetMotion.reducedMotionOf(context);
    final begin = firstRender ? 0.0 : (from?.progress ?? _progress.value);
    final fromRating = from?.rankRating ?? target.rankRating;
    final rankComparison = from == null
        ? 0
        : StoneSetRankAssets.byId(target.rankId).order.compareTo(
            StoneSetRankAssets.byId(from.rankId).order,
          );
    _transitionKind = firstRender
        ? HomeRankTransitionKind.initial
        : rankComparison > 0
        ? HomeRankTransitionKind.rankUp
        : rankComparison < 0
        ? HomeRankTransitionKind.rankDown
        : HomeRankTransitionKind.ratingChange;
    _fromSnapshot = from;
    _toSnapshot = target;
    _controller
      ..stop()
      ..duration = reduceMotion
          ? Duration.zero
          : Duration(
              milliseconds: switch (_transitionKind) {
                HomeRankTransitionKind.initial => 760,
                HomeRankTransitionKind.ratingChange => _deltaDuration(
                  begin,
                  target.progress,
                ),
                HomeRankTransitionKind.rankUp => 1280,
                HomeRankTransitionKind.rankDown => 520,
                HomeRankTransitionKind.none => 0,
              },
            )
      ..value = 0;
    _progress = switch (_transitionKind) {
      HomeRankTransitionKind.rankUp => TweenSequence<double>(
        <TweenSequenceItem<double>>[
          TweenSequenceItem(
            tween: Tween<double>(begin: begin, end: 1).chain(
              CurveTween(curve: Curves.easeOutCubic),
            ),
            weight: 35,
          ),
          TweenSequenceItem(tween: ConstantTween<double>(1), weight: 10),
          TweenSequenceItem(
            tween: Tween<double>(begin: 0, end: target.progress).chain(
              CurveTween(curve: Curves.easeOutCubic),
            ),
            weight: 55,
          ),
        ],
      ).animate(_controller),
      HomeRankTransitionKind.rankDown => TweenSequence<double>(
        <TweenSequenceItem<double>>[
          TweenSequenceItem(
            tween: Tween<double>(begin: begin, end: 0).chain(
              CurveTween(curve: Curves.easeInOutCubic),
            ),
            weight: 35,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 0, end: target.progress).chain(
              CurveTween(curve: Curves.easeOutCubic),
            ),
            weight: 65,
          ),
        ],
      ).animate(_controller),
      _ => Tween<double>(begin: begin, end: target.progress).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      ),
    };
    _rating = Tween<double>(
      begin: fromRating.toDouble(),
      end: target.rankRating.toDouble(),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    if (reduceMotion || (begin == target.progress && fromRating == target.rankRating)) {
      _progress = AlwaysStoppedAnimation<double>(target.progress);
      _rating = AlwaysStoppedAnimation<double>(target.rankRating.toDouble());
      _transitionKind = HomeRankTransitionKind.none;
      return;
    }
    unawaited(_controller.forward());
  }

  int _deltaDuration(double begin, double end) {
    final scaled = 320 + ((end - begin).abs() * 480).round();
    return scaled.clamp(320, 800).toInt();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = StoneSetMotion.reducedMotionOf(context);
    return RepaintBoundary(
      key: const Key('home-rank-hero-repaint-boundary'),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final useTarget = switch (_transitionKind) {
            HomeRankTransitionKind.rankUp => _controller.value >= 0.45,
            HomeRankTransitionKind.rankDown => _controller.value >= 0.35,
            _ => true,
          };
          final snapshot = useTarget ? _toSnapshot : (_fromSnapshot ?? _toSnapshot);
          final asset = StoneSetRankAssets.byId(snapshot.rankId);
          final nextName = snapshot.nextRankId == null
              ? null
              : StoneSetRankAssets.byId(snapshot.nextRankId!).displayName;
          final showRankUp =
              !reducedMotion &&
              _transitionKind == HomeRankTransitionKind.rankUp &&
              _controller.isAnimating;
          return Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              AnimatedSwitcher(
                duration: reducedMotion ? Duration.zero : StoneSetMotion.emphasized,
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: reducedMotion
                      ? child
                      : ScaleTransition(
                          scale: Tween<double>(begin: 0.97, end: 1).animate(animation),
                          child: child,
                        ),
                ),
                child: KeyedSubtree(
                  key: ValueKey<StoneSetRankPresentationId>(snapshot.rankId),
                  child: RankProgressHero(
                    key: const Key('home-rank-hero'),
                    data: RankProgressHeroData(
                      asset: asset,
                      rankRating: _rating.value.round(),
                      progressFraction: _progress.value,
                      nextRankName: nextName,
                      nextRankThreshold: snapshot.nextMinimum,
                      isMaxRank: snapshot.nextRankId == null,
                    ),
                    provisionalProgress: snapshot.provisionalProgress,
                    pendingLabel: snapshot.pendingLabel,
                    onTap: widget.onTap,
                  ),
                ),
              ),
              if (showRankUp)
                const Positioned(
                  top: StoneSetSpacing.sm,
                  child: StoneSetStatusChip(
                    key: Key('home-rank-up-treatment'),
                    kind: StoneSetStatusKind.success,
                    label: 'Rank up',
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
