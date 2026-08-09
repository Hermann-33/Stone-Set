import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stone_set_domain/exercise_media.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

import '../controllers/dashboard_guidance_media_controller.dart';
import 'dashboard_external_url.dart';
import 'dashboard_private_media_image.dart';
import 'dashboard_youtube_preview.dart';

class DashboardGuidanceMediaEditor extends ConsumerStatefulWidget {
  const DashboardGuidanceMediaEditor({
    super.key,
    required this.request,
    required this.draftRevision,
    required this.readOnly,
  });

  final DashboardGuidanceMediaRequest request;
  final int draftRevision;
  final bool readOnly;

  @override
  ConsumerState<DashboardGuidanceMediaEditor> createState() => _DashboardGuidanceMediaEditorState();
}

class _DashboardGuidanceMediaEditorState extends ConsumerState<DashboardGuidanceMediaEditor> {
  final Map<String, TextEditingController> _altControllers = <String, TextEditingController>{};
  final TextEditingController _youtubeController = TextEditingController();

  @override
  void dispose() {
    for (final controller in _altControllers.values) {
      controller.dispose();
    }
    _youtubeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = ref.watch(dashboardGuidanceMediaControllerProvider(widget.request));
    return media.when(
      loading: () => const StoneSetDashboardStatePanel(
        state: StoneSetDashboardPanelState.loading,
        title: 'Loading Private Media',
        message: 'Reading the authoritative draft media manifest.',
      ),
      error: (error, _) => StoneSetDashboardStatePanel(
        state: StoneSetDashboardPanelState.error,
        title: 'Media Unavailable',
        message: 'Private media could not be loaded. Retry after checking the connection.',
        actionLabel: 'Retry',
        onAction: () => ref.invalidate(dashboardGuidanceMediaControllerProvider(widget.request)),
      ),
      data: _buildEditor,
    );
  }

  Widget _buildEditor(DashboardGuidanceMediaState state) {
    _synchronizeControllers(state.manifest);
    final controller = ref.read(
      dashboardGuidanceMediaControllerProvider(widget.request).notifier,
    );
    final busy =
        state.status == DashboardGuidanceMediaStatus.processing ||
        state.status == DashboardGuidanceMediaStatus.uploading ||
        state.status == DashboardGuidanceMediaStatus.saving;
    final canRetry =
        state.status == DashboardGuidanceMediaStatus.failed ||
        state.status == DashboardGuidanceMediaStatus.offline;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _MediaStatusBanner(state: state, readOnly: widget.readOnly),
        const SizedBox(height: StoneSetSpacing.md),
        StoneSetCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Semantics(
                header: true,
                child: Text('Images', style: Theme.of(context).textTheme.titleLarge),
              ),
              const SizedBox(height: StoneSetSpacing.xxs),
              Text(
                'Add up to 6 JPEG, PNG, or static WebP images. Each processed file must be '
                '5 MB or smaller, with descriptive alternative text before publication.',
                style: StoneSetTextStyles.of(context).compactBody,
              ),
              const SizedBox(height: StoneSetSpacing.md),
              Wrap(
                spacing: StoneSetSpacing.sm,
                runSpacing: StoneSetSpacing.sm,
                children: <Widget>[
                  FilledButton.icon(
                    key: const Key('media-select-images'),
                    onPressed: widget.readOnly || busy || state.manifest.images.length >= 6
                        ? null
                        : () => unawaited(
                            controller.selectAndUpload(draftRevision: widget.draftRevision),
                          ),
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: Text(
                      state.manifest.images.isEmpty ? 'Select Images' : 'Add More Images',
                    ),
                  ),
                  if (busy)
                    OutlinedButton.icon(
                      key: const Key('media-cancel-operation'),
                      onPressed: controller.cancel,
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Cancel'),
                    ),
                  if (canRetry)
                    OutlinedButton.icon(
                      key: const Key('media-retry-upload'),
                      onPressed: () => unawaited(controller.retryUpload()),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry Upload'),
                    ),
                ],
              ),
              if (state.manifest.images.isEmpty) ...<Widget>[
                const SizedBox(height: StoneSetSpacing.md),
                const Text('No Images Yet. Text-only guidance remains supported.'),
              ],
              for (var index = 0; index < state.manifest.images.length; index += 1) ...<Widget>[
                const SizedBox(height: StoneSetSpacing.md),
                _ImageAssetEditor(
                  asset: state.manifest.images[index],
                  index: index,
                  count: state.manifest.images.length,
                  altController: _altControllers[state.manifest.images[index].id]!,
                  readOnly: widget.readOnly || busy,
                  onSaveAlt: () => unawaited(_saveAltText(state.manifest, controller)),
                  onMove: (offset) => unawaited(
                    controller.updateLayout(_movedLayout(state.manifest, index, offset)),
                  ),
                  onSetCover: () => unawaited(
                    controller.updateLayout(
                      _layoutFor(
                        state.manifest,
                        coverAssetId: state.manifest.images[index].id,
                      ),
                    ),
                  ),
                  onRemove: () => unawaited(
                    _confirmRemove(context, controller, state.manifest.images[index]),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: StoneSetSpacing.md),
        _YouTubeEditor(
          manifest: state.manifest,
          inputController: _youtubeController,
          readOnly: widget.readOnly || busy,
          onSave: () => unawaited(controller.saveYouTubeInput(_youtubeController.text)),
          onRemove: () => unawaited(controller.removeYouTube()),
          onValidated: () => unawaited(controller.markYouTubePreviewValidated()),
          onInvalidated: () => unawaited(controller.markYouTubePreviewInvalidated()),
        ),
        const SizedBox(height: StoneSetSpacing.md),
        _MobileGuidancePreview(manifest: state.manifest),
      ],
    );
  }

  void _synchronizeControllers(GuidanceMediaManifest manifest) {
    final activeIds = manifest.images.map((asset) => asset.id).toSet();
    final removed = _altControllers.keys.where((id) => !activeIds.contains(id)).toList();
    for (final id in removed) {
      _altControllers.remove(id)?.dispose();
    }
    for (final asset in manifest.images) {
      final controller = _altControllers.putIfAbsent(
        asset.id,
        () => TextEditingController(text: asset.altText),
      );
      if (!controller.selection.isValid && controller.text != asset.altText) {
        controller.text = asset.altText;
      }
    }
  }

  Future<void> _saveAltText(
    GuidanceMediaManifest manifest,
    DashboardGuidanceMediaController controller,
  ) => controller.updateLayout(_layoutFor(manifest));

  List<DraftMediaLayoutItem> _layoutFor(
    GuidanceMediaManifest manifest, {
    String? coverAssetId,
  }) => <DraftMediaLayoutItem>[
    for (var index = 0; index < manifest.images.length; index += 1)
      DraftMediaLayoutItem(
        assetId: manifest.images[index].id,
        altText:
            _altControllers[manifest.images[index].id]?.text.trim() ??
            manifest.images[index].altText,
        position: index,
        isCover: coverAssetId == null
            ? manifest.images[index].isCover
            : manifest.images[index].id == coverAssetId,
      ),
  ];

  List<DraftMediaLayoutItem> _movedLayout(
    GuidanceMediaManifest manifest,
    int index,
    int offset,
  ) {
    final assets = List<GuidanceImageAsset>.of(manifest.images);
    final destination = index + offset;
    if (destination < 0 || destination >= assets.length) return _layoutFor(manifest);
    final asset = assets.removeAt(index);
    assets.insert(destination, asset);
    return <DraftMediaLayoutItem>[
      for (var position = 0; position < assets.length; position += 1)
        DraftMediaLayoutItem(
          assetId: assets[position].id,
          altText: _altControllers[assets[position].id]?.text.trim() ?? assets[position].altText,
          position: position,
          isCover: assets[position].isCover,
        ),
    ];
  }

  Future<void> _confirmRemove(
    BuildContext context,
    DashboardGuidanceMediaController controller,
    GuidanceImageAsset asset,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Draft Image?'),
        content: const Text(
          'This removes only the unreferenced draft asset. Published history remains immutable.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Image'),
          ),
          FilledButton(
            key: const Key('confirm-remove-media-image'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove Draft Image'),
          ),
        ],
      ),
    );
    if (confirmed == true) await controller.removeImage(asset.id);
  }
}

class _MediaStatusBanner extends StatelessWidget {
  const _MediaStatusBanner({required this.state, required this.readOnly});

  final DashboardGuidanceMediaState state;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final status = readOnly ? DashboardGuidanceMediaStatus.readOnly : state.status;
    final label = switch (status) {
      DashboardGuidanceMediaStatus.loading => 'Loading Private Media',
      DashboardGuidanceMediaStatus.ready => 'Media Draft Ready',
      DashboardGuidanceMediaStatus.processing => 'Processing Image…',
      DashboardGuidanceMediaStatus.uploading => 'Uploading Private Image…',
      DashboardGuidanceMediaStatus.saving => 'Saving Media Draft…',
      DashboardGuidanceMediaStatus.cancelled => 'Media Operation Cancelled',
      DashboardGuidanceMediaStatus.offline => 'Media Requires a Connection',
      DashboardGuidanceMediaStatus.permissionDenied => 'Media Permission Denied',
      DashboardGuidanceMediaStatus.conflict => 'Media Conflict Requires Reload',
      DashboardGuidanceMediaStatus.failed => 'Media Operation Failed',
      DashboardGuidanceMediaStatus.readOnly => 'Media Is Read Only',
    };
    final isBusy =
        status == DashboardGuidanceMediaStatus.processing ||
        status == DashboardGuidanceMediaStatus.uploading ||
        status == DashboardGuidanceMediaStatus.saving;
    return Semantics(
      liveRegion: status != DashboardGuidanceMediaStatus.ready,
      label: '$label. ${state.message ?? ''}',
      child: StoneSetCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(label, style: Theme.of(context).textTheme.titleSmall),
            if (state.message case final message?) ...<Widget>[
              const SizedBox(height: StoneSetSpacing.xxs),
              Text(message),
            ],
            if (isBusy) ...<Widget>[
              const SizedBox(height: StoneSetSpacing.sm),
              LinearProgressIndicator(
                value: state.progress?.phase == MediaUploadPhase.uploaded ? 1 : null,
                semanticsLabel: label,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ImageAssetEditor extends StatelessWidget {
  const _ImageAssetEditor({
    required this.asset,
    required this.index,
    required this.count,
    required this.altController,
    required this.readOnly,
    required this.onSaveAlt,
    required this.onMove,
    required this.onSetCover,
    required this.onRemove,
  });

  final GuidanceImageAsset asset;
  final int index;
  final int count;
  final TextEditingController altController;
  final bool readOnly;
  final VoidCallback onSaveAlt;
  final ValueChanged<int> onMove;
  final VoidCallback onSetCover;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: 'Image ${index + 1} of $count${asset.isCover ? ', cover image' : ''}',
    child: DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(StoneSetSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Image ${index + 1}${asset.isCover ? ' · Cover' : ''}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: StoneSetSpacing.xxs),
            Text(
              '${asset.width} × ${asset.height} · ${asset.mimeType.wireValue} · '
              '${(asset.byteSize / 1024).ceil()} KB',
              style: StoneSetTextStyles.of(context).caption,
            ),
            const SizedBox(height: StoneSetSpacing.sm),
            TextFormField(
              key: Key('media-alt-${asset.id}'),
              controller: altController,
              enabled: !readOnly,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Alternative Text',
                helperText: 'Describe the position or movement this image demonstrates.',
              ),
              onFieldSubmitted: (_) => onSaveAlt(),
            ),
            Wrap(
              spacing: StoneSetSpacing.xs,
              runSpacing: StoneSetSpacing.xs,
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: readOnly || index == 0 ? null : () => onMove(-1),
                  icon: const Icon(Icons.arrow_upward),
                  label: const Text('Move Earlier'),
                ),
                OutlinedButton.icon(
                  onPressed: readOnly || index == count - 1 ? null : () => onMove(1),
                  icon: const Icon(Icons.arrow_downward),
                  label: const Text('Move Later'),
                ),
                OutlinedButton.icon(
                  onPressed: readOnly || asset.isCover ? null : onSetCover,
                  icon: const Icon(Icons.photo_outlined),
                  label: const Text('Set as Cover'),
                ),
                TextButton.icon(
                  onPressed: readOnly ? null : onRemove,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Remove'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _YouTubeEditor extends StatelessWidget {
  const _YouTubeEditor({
    required this.manifest,
    required this.inputController,
    required this.readOnly,
    required this.onSave,
    required this.onRemove,
    required this.onValidated,
    required this.onInvalidated,
  });

  final GuidanceMediaManifest manifest;
  final TextEditingController inputController;
  final bool readOnly;
  final VoidCallback onSave;
  final VoidCallback onRemove;
  final VoidCallback onValidated;
  final VoidCallback onInvalidated;

  @override
  Widget build(BuildContext context) {
    final reference = manifest.youtube;
    return StoneSetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text('Optional YouTube Video', style: Theme.of(context).textTheme.titleLarge),
          ),
          const SizedBox(height: StoneSetSpacing.xxs),
          Text(
            'Paste one supported HTTPS video URL. Stone Set contacts YouTube only after you load '
            'the preview. A playable preview is required before publication.',
            style: StoneSetTextStyles.of(context).compactBody,
          ),
          const SizedBox(height: StoneSetSpacing.md),
          TextFormField(
            key: const Key('youtube-url-field'),
            controller: inputController,
            enabled: !readOnly,
            keyboardType: TextInputType.url,
            autofillHints: const <String>[],
            decoration: const InputDecoration(
              labelText: 'YouTube Video URL',
              hintText: 'https://www.youtube.com/watch?v=…',
            ),
          ),
          const SizedBox(height: StoneSetSpacing.sm),
          Wrap(
            spacing: StoneSetSpacing.sm,
            runSpacing: StoneSetSpacing.sm,
            children: <Widget>[
              FilledButton(
                key: const Key('youtube-save-reference'),
                onPressed: readOnly ? null : onSave,
                child: Text(reference == null ? 'Normalize URL' : 'Replace Video'),
              ),
              if (reference != null)
                OutlinedButton.icon(
                  key: const Key('youtube-remove-reference'),
                  onPressed: readOnly ? null : onRemove,
                  icon: const Icon(Icons.remove_circle_outline),
                  label: const Text('Remove Video'),
                ),
            ],
          ),
          if (reference != null) ...<Widget>[
            const SizedBox(height: StoneSetSpacing.md),
            Text(
              reference.validationStatus == YouTubeValidationStatus.validated
                  ? 'Playable preview validated for this draft revision.'
                  : 'Preview required before publication.',
            ),
            const SizedBox(height: StoneSetSpacing.sm),
            DashboardYouTubePreview(
              key: ValueKey<String>('youtube-preview-${reference.videoId}'),
              videoId: reference.videoId,
              canonicalWatchUrl: reference.canonicalWatchUrl.toString(),
              startSeconds: reference.startSeconds,
              onValidated: readOnly ? null : onValidated,
              onInvalidated: readOnly ? null : onInvalidated,
              onOpenExternal: () => openDashboardExternalUrl(
                reference.startSeconds == null
                    ? reference.canonicalWatchUrl
                    : reference.canonicalWatchUrl.replace(
                        queryParameters: <String, String>{
                          ...reference.canonicalWatchUrl.queryParameters,
                          't': '${reference.startSeconds}s',
                        },
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MobileGuidancePreview extends StatelessWidget {
  const _MobileGuidancePreview({required this.manifest});

  final GuidanceMediaManifest manifest;

  @override
  Widget build(BuildContext context) => StoneSetCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(
          header: true,
          child: Text('Mobile-Shaped Preview', style: Theme.of(context).textTheme.titleLarge),
        ),
        const SizedBox(height: StoneSetSpacing.xxs),
        const Text('Authoring preview only. It does not represent Android playback or caching.'),
        const SizedBox(height: StoneSetSpacing.md),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(StoneSetSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text('Exercise Guidance', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: StoneSetSpacing.sm),
                    if (manifest.images.isEmpty)
                      const Text('No instruction images.')
                    else
                      for (final image in manifest.images)
                        Padding(
                          padding: const EdgeInsets.only(bottom: StoneSetSpacing.xs),
                          child: DashboardPrivateMediaImage(asset: image),
                        ),
                    if (manifest.youtube != null) const Text('YouTube demonstration · Online only'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
