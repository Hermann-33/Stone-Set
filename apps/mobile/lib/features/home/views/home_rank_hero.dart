import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

import '../models/home_view_models.dart';

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
  var _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _animateTo(widget.snapshot.progress, firstRender: true);
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
      _animateTo(next.progress);
    }
  }

  void _animateTo(double target, {bool firstRender = false}) {
    final reduceMotion = StoneSetMotion.reducedMotionOf(context);
    final begin = firstRender ? 0.0 : _progress.value;
    _controller
      ..stop()
      ..duration = reduceMotion
          ? Duration.zero
          : Duration(milliseconds: firstRender ? 760 : _deltaDuration(begin, target))
      ..value = 0;
    _progress = Tween<double>(begin: begin, end: target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    if (reduceMotion || begin == target) {
      _progress = AlwaysStoppedAnimation<double>(target);
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
    final snapshot = widget.snapshot;
    final asset = StoneSetRankAssets.byId(snapshot.rankId);
    final nextName = snapshot.nextRankId == null
        ? null
        : StoneSetRankAssets.byId(snapshot.nextRankId!).displayName;
    final reducedMotion = StoneSetMotion.reducedMotionOf(context);
    return RepaintBoundary(
      key: const Key('home-rank-hero-repaint-boundary'),
      child: AnimatedBuilder(
        animation: _progress,
        builder: (context, _) => AnimatedSwitcher(
          duration: reducedMotion ? Duration.zero : StoneSetMotion.emphasized,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.94, end: 1).animate(animation),
              child: child,
            ),
          ),
          child: KeyedSubtree(
            key: ValueKey<StoneSetRankPresentationId>(snapshot.rankId),
            child: RankProgressHero(
              key: const Key('home-rank-hero'),
              data: RankProgressHeroData(
                asset: asset,
                rankRating: snapshot.rankRating,
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
      ),
    );
  }
}
