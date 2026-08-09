import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';

final class DashboardSelectedImage {
  const DashboardSelectedImage({
    required this.fileName,
    required this.declaredMimeType,
    required this.bytes,
  });

  final String fileName;
  final String declaredMimeType;
  final Uint8List bytes;
}

abstract interface class DashboardImagePicker {
  Future<List<DashboardSelectedImage>> pick({required int maximumCount});
}

final class FileSelectorDashboardImagePicker implements DashboardImagePicker {
  const FileSelectorDashboardImagePicker();

  static const _acceptedImages = XTypeGroup(
    label: 'JPEG, PNG, or static WebP images',
    extensions: <String>['jpg', 'jpeg', 'png', 'webp'],
    mimeTypes: <String>['image/jpeg', 'image/png', 'image/webp'],
  );

  @override
  Future<List<DashboardSelectedImage>> pick({required int maximumCount}) async {
    if (maximumCount <= 0) return const <DashboardSelectedImage>[];
    final files = await openFiles(acceptedTypeGroups: const <XTypeGroup>[_acceptedImages]);
    final bounded = files.take(maximumCount);
    return Future.wait(<Future<DashboardSelectedImage>>[
      for (final file in bounded)
        () async {
          final mime = file.mimeType;
          if (mime == null || mime.isEmpty) {
            throw const FormatException('The browser did not provide a file MIME type.');
          }
          return DashboardSelectedImage(
            fileName: file.name,
            declaredMimeType: mime,
            bytes: await file.readAsBytes(),
          );
        }(),
    ]);
  }
}
