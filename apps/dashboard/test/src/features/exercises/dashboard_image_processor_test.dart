import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:stone_set_dashboard/src/features/exercises/data/dashboard_image_processor.dart';

void main() {
  group('DashboardImageProcessor', () {
    test('processes a static PNG and hashes the exact metadata-free output', () async {
      final source = image.Image(width: 480, height: 320)..setPixelRgb(0, 0, 10, 20, 30);
      final result = await const DashboardImageProcessor().process(
        DashboardImageProcessingInput(
          bytes: image.encodePng(source),
          fileName: 'setup.png',
          declaredMimeType: 'image/png',
        ),
      );

      expect(result.mimeType, 'image/png');
      expect(result.extension, 'png');
      expect(result.width, 480);
      expect(result.height, 320);
      expect(result.bytes, isNotEmpty);
      expect(result.sha256, hasLength(64));
      expect(result.sha256, matches(RegExp(r'^[0-9a-f]{64}$')));
    });

    test('resizes the longest edge while preserving a useful shortest edge', () async {
      final source = image.Image(width: 3000, height: 1500);
      final result = await const DashboardImageProcessor().process(
        DashboardImageProcessingInput(
          bytes: image.encodeJpg(source),
          fileName: 'movement.jpeg',
          declaredMimeType: 'image/jpeg',
        ),
      );

      expect(result.width, 2400);
      expect(result.height, 1200);
      expect(result.extension, 'jpg');
    });

    test('bakes JPEG orientation and strips decoded metadata before re-encoding', () async {
      final source = image.Image(width: 480, height: 320)
        ..exif.imageIfd.orientation = 6
        ..exif.imageIfd['ImageDescription'] = 'private-location-marker'
        ..textData = <String, String>{'Comment': 'private-location-marker'};
      final result = await const DashboardImageProcessor().process(
        DashboardImageProcessingInput(
          bytes: image.encodeJpg(source),
          fileName: 'oriented.jpg',
          declaredMimeType: 'image/jpeg',
        ),
      );

      expect((result.width, result.height), (320, 480));
      final decoded = image.decodeJpg(result.bytes)!;
      expect(decoded.exif.isEmpty, isTrue);
      expect(decoded.textData, isNull);
      expect(String.fromCharCodes(result.bytes), isNot(contains('private-location-marker')));
    });

    test('rejects an empty selection before decode', () async {
      await expectLater(
        const DashboardImageProcessor().process(
          DashboardImageProcessingInput(
            bytes: Uint8List(0),
            fileName: 'empty.png',
            declaredMimeType: 'image/png',
          ),
        ),
        throwsA(
          isA<DashboardImageProcessingFailure>().having(
            (failure) => failure.code,
            'code',
            DashboardImageProcessingFailureCode.empty,
          ),
        ),
      );
    });

    test('rejects declared MIME and extension mismatch', () async {
      final bytes = image.encodePng(image.Image(width: 320, height: 320));
      await expectLater(
        const DashboardImageProcessor().process(
          DashboardImageProcessingInput(
            bytes: bytes,
            fileName: 'deceptive.jpg',
            declaredMimeType: 'image/jpeg',
          ),
        ),
        throwsA(
          isA<DashboardImageProcessingFailure>().having(
            (failure) => failure.code,
            'code',
            DashboardImageProcessingFailureCode.mimeMismatch,
          ),
        ),
      );
    });

    test('rejects undersized images', () async {
      final bytes = image.encodeWebP(image.Image(width: 319, height: 640));
      await expectLater(
        const DashboardImageProcessor().process(
          DashboardImageProcessingInput(
            bytes: bytes,
            fileName: 'narrow.webp',
            declaredMimeType: 'image/webp',
          ),
        ),
        throwsA(
          isA<DashboardImageProcessingFailure>().having(
            (failure) => failure.code,
            'code',
            DashboardImageProcessingFailureCode.tooSmall,
          ),
        ),
      );
    });

    test('honors cancellation before processing starts', () async {
      final cancellation = DashboardImageProcessingCancellation()..cancel();
      await expectLater(
        const DashboardImageProcessor().process(
          DashboardImageProcessingInput(
            bytes: image.encodePng(image.Image(width: 320, height: 320)),
            fileName: 'cancelled.png',
            declaredMimeType: 'image/png',
          ),
          cancellation: cancellation,
        ),
        throwsA(
          isA<DashboardImageProcessingFailure>().having(
            (failure) => failure.code,
            'code',
            DashboardImageProcessingFailureCode.cancelled,
          ),
        ),
      );
    });
  });
}
