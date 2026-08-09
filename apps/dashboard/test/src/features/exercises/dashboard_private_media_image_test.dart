import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:stone_set_dashboard/src/features/exercises/views/dashboard_private_media_image.dart';
import 'package:stone_set_domain/exercise_media.dart';

void main() {
  testWidgets('shows bounded loading then a semantic private image without URL text', (
    tester,
  ) async {
    final access = Completer<MediaAccessUrl>();
    final asset = _asset();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardPrivateMediaAccessProvider.overrideWith((_, _) => access.future),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: DashboardPrivateMediaImage(
              asset: asset,
              imageProviderBuilder: (_) => MemoryImage(
                Uint8List.fromList(
                  image.encodePng(image.Image(width: 8, height: 8)),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('private-image-loading')), findsOneWidget);
    access.complete(_accessUrl());
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Keep the spine neutral.'), findsOneWidget);
    expect(find.textContaining('storage.invalid'), findsNothing);
    final size = tester.getSize(find.byType(Image));
    expect(size.width, lessThanOrEqualTo(420));
    expect(size.height, lessThanOrEqualTo(320));
  });

  testWidgets('shows retry when signed access cannot be created', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardPrivateMediaAccessProvider.overrideWith(
            (_, _) => Future<MediaAccessUrl>.error(StateError('denied')),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: DashboardPrivateMediaImage(asset: _asset())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('private-image-access-error')), findsOneWidget);
    expect(find.text('Retry image'), findsOneWidget);
    expect(find.textContaining('storage.invalid'), findsNothing);
  });

  testWidgets('handles decoded network-image failure without exposing the URL', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardPrivateMediaAccessProvider.overrideWith((_, _) async => _accessUrl()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: DashboardPrivateMediaImage(
              asset: _asset(),
              imageProviderBuilder: (_) => MemoryImage(Uint8List.fromList(<int>[1, 2, 3])),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('private-image-render-error')), findsOneWidget);
    expect(find.text('Retry image'), findsOneWidget);
    expect(find.textContaining('storage.invalid'), findsNothing);
  });
}

MediaAccessUrl _accessUrl() => MediaAccessUrl(
  url: Uri.parse('https://storage.invalid/media/asset.png'),
  expiresAt: DateTime.utc(2026, 8, 8, 1),
);

GuidanceImageAsset _asset() => GuidanceImageAsset(
  id: '82000000-0000-4000-8000-000000000001',
  ownerId: '00000000-0000-4000-8000-000000000001',
  exerciseId: '20000000-0000-4000-8000-000000000001',
  draftId: '40000000-0000-4000-8000-000000000001',
  bucketId: GuidanceMediaManifest.bucketId,
  objectPath: 'owner/exercise/drafts/draft/asset.png',
  mimeType: GuidanceMediaMimeType.png,
  byteSize: 1024,
  width: 640,
  height: 480,
  sha256Hex: 'a' * 64,
  altText: 'Keep the spine neutral.',
  position: 0,
  isCover: true,
  lifecycle: GuidanceMediaLifecycle.ready,
  createdAt: DateTime.utc(2026, 8, 8),
  updatedAt: DateTime.utc(2026, 8, 8),
);
