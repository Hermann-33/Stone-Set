import 'package:flutter/material.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

import '../models/home_view_models.dart';

class HomeStateBanner extends StatelessWidget {
  const HomeStateBanner({required this.data, super.key});

  final HomeBannerViewData data;

  @override
  Widget build(BuildContext context) {
    return StoneSetStatusBanner(
      key: const Key('home-state-banner'),
      kind: switch (data.kind) {
        HomeBannerKind.information => StoneSetStatusKind.information,
        HomeBannerKind.provisional => StoneSetStatusKind.provisional,
        HomeBannerKind.pending => StoneSetStatusKind.pending,
        HomeBannerKind.stale => StoneSetStatusKind.stale,
        HomeBannerKind.offline => StoneSetStatusKind.offline,
        HomeBannerKind.error => StoneSetStatusKind.error,
      },
      message: data.message,
    );
  }
}
