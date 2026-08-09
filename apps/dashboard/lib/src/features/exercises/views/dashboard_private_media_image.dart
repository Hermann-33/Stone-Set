import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stone_set_domain/exercise_media.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

import '../controllers/dashboard_guidance_media_controller.dart';

final dashboardPrivateMediaAccessProvider = FutureProvider.autoDispose
    .family<MediaAccessUrl, GuidanceImageAsset>((ref, asset) {
      return ref
          .watch(exerciseMediaRepositoryProvider)
          .createImageAccessUrl(asset, lifetime: const Duration(minutes: 5));
    });

typedef DashboardPrivateImageProviderBuilder = ImageProvider<Object> Function(Uri url);

class DashboardPrivateMediaImage extends ConsumerWidget {
  const DashboardPrivateMediaImage({
    super.key,
    required this.asset,
    this.imageProviderBuilder = _networkImageProvider,
  });

  final GuidanceImageAsset asset;
  final DashboardPrivateImageProviderBuilder imageProviderBuilder;

  static ImageProvider<Object> _networkImageProvider(Uri url) => NetworkImage(url.toString());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(dashboardPrivateMediaAccessProvider(asset));
    final altText = asset.altText.trim().isEmpty
        ? 'Instruction image ${asset.position + 1}; alternative text required.'
        : asset.altText.trim();
    final aspectRatio = (asset.width / asset.height).clamp(0.75, 2.0).toDouble();

    return Semantics(
      container: true,
      image: true,
      label: altText,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 320),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: access.when(
            loading: () => const _PrivateImageState(
              key: Key('private-image-loading'),
              message: 'Loading private instruction image…',
              loading: true,
            ),
            error: (_, _) => _PrivateImageState(
              key: const Key('private-image-access-error'),
              message: 'Private image access could not be created.',
              actionLabel: 'Retry image',
              onAction: () => ref.invalidate(dashboardPrivateMediaAccessProvider(asset)),
            ),
            data: (accessUrl) => Image(
              key: ValueKey<String>('private-image-${asset.id}-${accessUrl.expiresAt}'),
              image: imageProviderBuilder(accessUrl.url),
              fit: BoxFit.contain,
              semanticLabel: altText,
              excludeFromSemantics: true,
              errorBuilder: (_, _, _) => _PrivateImageState(
                key: const Key('private-image-render-error'),
                message: 'The private image could not be displayed.',
                actionLabel: 'Retry image',
                onAction: () => ref.invalidate(dashboardPrivateMediaAccessProvider(asset)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PrivateImageState extends StatelessWidget {
  const _PrivateImageState({
    super.key,
    required this.message,
    this.loading = false,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final bool loading;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(StoneSetShapes.cardRadius),
    ),
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(StoneSetSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (loading) ...<Widget>[
              const SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(height: StoneSetSpacing.xs),
            ],
            Text(message, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: StoneSetSpacing.xs),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    ),
  );
}
