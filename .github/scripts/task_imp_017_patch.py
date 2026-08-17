from pathlib import Path


def replace_once(path: str, old: str, new: str, label: str) -> None:
    file = Path(path)
    text = file.read_text()
    if old not in text:
        raise RuntimeError(f'{label}: anchor not found')
    file.write_text(text.replace(old, new, 1))


replace_once(
    'apps/dashboard/lib/src/features/exercises/controllers/dashboard_guidance_media_controller.dart',
    """const _youtubePreviewRequiredMessage =
    'YouTube preview validation is required before publication. Load the preview, '
    'play the video until Stone Set marks it validated, then publish again. '
    'Preview validation expires after one hour.';

final exerciseMediaRepositoryProvider""",
    """const _youtubePreviewRequiredMessage =
    'YouTube preview validation is required before publication. Load the preview, '
    'play the video until Stone Set marks it validated, then publish again. '
    'Preview validation expires after one hour.';

bool isGuidanceYouTubePublicationReady(
  GuidanceYouTubeReference? youtube, {
  DateTime? now,
}) {
  if (youtube == null) return true;
  if (youtube.validationStatus != YouTubeValidationStatus.validated) return false;
  final validatedAt = youtube.validatedAt;
  if (validatedAt == null) return false;
  final instant = (now ?? DateTime.now()).toUtc();
  return !validatedAt.toUtc().isBefore(
    instant.subtract(const Duration(hours: 1)),
  );
}

final exerciseMediaRepositoryProvider""",
    'controller helper',
)

replace_once(
    'apps/dashboard/lib/src/features/exercises/controllers/dashboard_guidance_media_controller.dart',
    """    if (current.manifest.youtube?.validationStatus == YouTubeValidationStatus.previewRequired) {
      state = AsyncData(""",
    """    if (!isGuidanceYouTubePublicationReady(current.manifest.youtube)) {
      state = AsyncData(""",
    'controller publication guard',
)

replace_once(
    'apps/dashboard/lib/src/features/exercises/views/dashboard_guidance_editor_view.dart',
    """          if (youtube?.validationStatus ==
              YouTubeValidationStatus.previewRequired) {
            return const _PublicationStatusCard(
              kind: StoneSetStatusKind.error,
              label: 'Publication blocked',
              message:
                  'YouTube preview validation is required. Load the preview in Media, play it until Stone Set marks it validated, then Publish. Validation expires after one hour.',
            );
          }
""",
    """          if (youtube != null && !isGuidanceYouTubePublicationReady(youtube)) {
            return _PublicationStatusCard(
              kind: StoneSetStatusKind.error,
              label: 'Publication blocked',
              message: _youtubePublicationBlockerMessage(youtube),
            );
          }
""",
    'view publication banner',
)

replace_once(
    'apps/dashboard/lib/src/features/exercises/views/dashboard_guidance_editor_view.dart',
    """  return state.manifest.youtube?.validationStatus !=
      YouTubeValidationStatus.previewRequired;
}

StoneSetStatusKind _mediaPublicationKind""",
    """  return isGuidanceYouTubePublicationReady(state.manifest.youtube);
}

String _youtubePublicationBlockerMessage(GuidanceYouTubeReference youtube) {
  if (youtube.validationStatus == YouTubeValidationStatus.unavailable) {
    return 'The YouTube preview is unavailable. Remove the reference or load a playable preview and validate it before publishing.';
  }
  if (youtube.validationStatus == YouTubeValidationStatus.validated) {
    return 'YouTube preview validation expired. Play the preview again until Stone Set marks it validated, then Publish.';
  }
  return 'YouTube preview validation is required. Load the preview in Media, play it until Stone Set marks it validated, then Publish. Validation expires after one hour.';
}

StoneSetStatusKind _mediaPublicationKind""",
    'view publication readiness helper',
)

replace_once(
    'apps/dashboard/test/src/features/exercises/dashboard_guidance_media_controller_test.dart',
    """  test('maps stale media writes to an explicit conflict state', () async {
""",
    """  test('publication preflight rejects unavailable or expired YouTube evidence', () async {
    final now = DateTime.now().toUtc();
    final blocked = <GuidanceYouTubeReference>[
      GuidanceYouTubeReference(
        videoId: 'dQw4w9WgXcQ',
        canonicalWatchUrl: Uri.parse('https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
        validationStatus: YouTubeValidationStatus.unavailable,
        validatedAt: now,
      ),
      GuidanceYouTubeReference(
        videoId: 'dQw4w9WgXcQ',
        canonicalWatchUrl: Uri.parse('https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
        validationStatus: YouTubeValidationStatus.validated,
        validatedAt: now.subtract(const Duration(hours: 2)),
      ),
    ];

    for (final youtube in blocked) {
      final repository = FakeExerciseMediaRepository(
        manifest: _manifestWithYouTube(youtube),
      );
      final container = ProviderContainer(
        overrides: [exerciseMediaRepositoryProvider.overrideWithValue(repository)],
      );
      final provider = dashboardGuidanceMediaControllerProvider(request);
      final subscription = container.listen(provider, (_, _) {});
      await container.read(provider.future);

      final result = await container.read(provider.notifier).publish(
        exerciseRevision: 1,
        draftRevision: 1,
      );

      expect(result, isNull);
      expect(container.read(provider).requireValue.status, DashboardGuidanceMediaStatus.failed);
      expect(container.read(provider).requireValue.message, contains('preview validation'));
      expect(repository.copiedReservations, isEmpty);
      subscription.close();
      container.dispose();
    }
  });

  test('maps stale media writes to an explicit conflict state', () async {
""",
    'controller regression test',
)

replace_once(
    'apps/dashboard/test/src/features/exercises/dashboard_guidance_media_controller_test.dart',
    """ProviderContainer _mediaContainer(FakeExerciseMediaRepository repository) => ProviderContainer(
""",
    """GuidanceMediaManifest _manifestWithYouTube(GuidanceYouTubeReference youtube) =>
    GuidanceMediaManifest(
      exerciseId: '20000000-0000-4000-8000-000000000001',
      ownerId: '00000000-0000-4000-8000-000000000001',
      draftId: '40000000-0000-4000-8000-000000000001',
      mediaRevision: 1,
      images: const <GuidanceImageAsset>[],
      youtube: youtube,
    );

ProviderContainer _mediaContainer(FakeExerciseMediaRepository repository) => ProviderContainer(
""",
    'controller regression helper',
)

replace_once(
    'apps/dashboard/test/src/features/exercises/dashboard_guidance_publication_boundary_test.dart',
    """  testWidgets(
    'Publish confirmation explains activation and active-session pinning',
""",
    """  testWidgets('expired YouTube validation blocks Publish before confirmation', (
    tester,
  ) async {
    final media = FakeExerciseMediaRepository(
      manifest: _expiredValidatedManifest(),
    );
    await _pumpGuidanceEditor(tester, media: media);

    expect(find.text('Publication blocked'), findsOneWidget);
    expect(find.textContaining('validation expired'), findsOneWidget);

    final publish = find.byKey(const Key('dashboard-toolbar-publish-guidance'));
    expect(publish, findsOneWidget);
    await tester.tap(publish, warnIfMissed: false);
    await tester.pump();

    expect(find.text('Publish immutable guidance?'), findsNothing);
  });

  testWidgets(
    'Publish confirmation explains activation and active-session pinning',
""",
    'boundary regression test',
)

replace_once(
    'apps/dashboard/test/src/features/exercises/dashboard_guidance_publication_boundary_test.dart',
    """Future<void> _pumpGuidanceEditor(
""",
    """GuidanceMediaManifest _expiredValidatedManifest() => GuidanceMediaManifest(
  exerciseId: '20000000-0000-4000-8000-000000000001',
  ownerId: testUserId,
  draftId: '40000000-0000-4000-8000-000000000001',
  mediaRevision: 1,
  images: const <GuidanceImageAsset>[],
  youtube: GuidanceYouTubeReference(
    videoId: 'dQw4w9WgXcQ',
    canonicalWatchUrl: Uri.https('www.youtube.com', '/watch', <String, String>{
      'v': 'dQw4w9WgXcQ',
    }),
    validationStatus: YouTubeValidationStatus.validated,
    validatedAt: DateTime.now().toUtc().subtract(const Duration(hours: 2)),
  ),
);

Future<void> _pumpGuidanceEditor(
""",
    'boundary regression helper',
)
