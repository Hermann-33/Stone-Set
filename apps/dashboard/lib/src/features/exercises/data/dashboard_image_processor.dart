import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as image;
import 'package:stone_set_domain/exercise_guidance.dart';

const dashboardImageMaximumBytes = 5 * 1024 * 1024;
const dashboardImageMaximumEdge = 2400;
const dashboardImageMinimumEdge = 320;
const dashboardImagePreflightMaximumEdge = 12000;
const dashboardImagePreflightMaximumPixels = 16 * 1000 * 1000;

enum DashboardImageProcessingFailureCode {
  cancelled,
  empty,
  inputTooLarge,
  unsupportedFormat,
  mimeMismatch,
  corrupt,
  animated,
  implausibleDimensions,
  tooSmall,
  outputTooLarge,
  timedOut,
}

final class DashboardImageProcessingFailure implements Exception {
  const DashboardImageProcessingFailure(this.code, this.message);

  final DashboardImageProcessingFailureCode code;
  final String message;

  @override
  String toString() => message;
}

class DashboardImageProcessingCancellation {
  bool _cancelled = false;

  bool get isCancelled => _cancelled;

  void cancel() => _cancelled = true;
}

final class DashboardImageProcessingInput {
  const DashboardImageProcessingInput({
    required this.bytes,
    required this.fileName,
    required this.declaredMimeType,
  });

  final Uint8List bytes;
  final String fileName;
  final String declaredMimeType;
}

final class DashboardProcessedImage {
  const DashboardProcessedImage({
    required this.bytes,
    required this.mimeType,
    required this.extension,
    required this.width,
    required this.height,
    required this.sha256,
  });

  final Uint8List bytes;
  final String mimeType;
  final String extension;
  final int width;
  final int height;
  final String sha256;
}

/// Browser-side preprocessing. `compute` uses a worker isolate where the
/// platform supports it. Flutter Web runs this work on its current event loop,
/// so the conservative preflight cap is the hard memory bound there;
/// cancellation is cooperative at phase boundaries and cannot interrupt a
/// synchronous Web decode already in progress.
final class DashboardImageProcessor {
  const DashboardImageProcessor();

  Future<DashboardProcessedImage> process(
    DashboardImageProcessingInput input, {
    DashboardImageProcessingCancellation? cancellation,
  }) async {
    _throwIfCancelled(cancellation);
    final result = await compute(_processImage, input);
    _throwIfCancelled(cancellation);
    return result;
  }
}

DashboardProcessedImage _processImage(DashboardImageProcessingInput input) {
  final bytes = input.bytes;
  if (bytes.isEmpty) {
    throw const DashboardImageProcessingFailure(
      DashboardImageProcessingFailureCode.empty,
      'The selected file is empty. Choose a JPEG, PNG, or static WebP image.',
    );
  }
  if (bytes.length > dashboardImageMaximumBytes) {
    throw const DashboardImageProcessingFailure(
      DashboardImageProcessingFailureCode.inputTooLarge,
      'The selected file is larger than 5 MB. Choose a smaller image.',
    );
  }

  final decoder = image.findDecoderForData(bytes);
  final format = decoder?.format;
  final formatEvidence = switch (format) {
    image.ImageFormat.jpg => (mime: 'image/jpeg', extensions: const <String>{'jpg', 'jpeg'}),
    image.ImageFormat.png => (mime: 'image/png', extensions: const <String>{'png'}),
    image.ImageFormat.webp => (mime: 'image/webp', extensions: const <String>{'webp'}),
    _ => null,
  };
  if (decoder == null || formatEvidence == null) {
    throw const DashboardImageProcessingFailure(
      DashboardImageProcessingFailureCode.unsupportedFormat,
      'Only JPEG, PNG, and static WebP images are supported.',
    );
  }

  final extension = input.fileName.split('.').last.toLowerCase();
  if (input.declaredMimeType.toLowerCase() != formatEvidence.mime ||
      !formatEvidence.extensions.contains(extension)) {
    throw const DashboardImageProcessingFailure(
      DashboardImageProcessingFailureCode.mimeMismatch,
      'The file type, extension, and decoded image format do not agree.',
    );
  }

  try {
    final info = decoder.startDecode(bytes);
    if (info == null || info.width <= 0 || info.height <= 0) {
      throw const DashboardImageProcessingFailure(
        DashboardImageProcessingFailureCode.corrupt,
        'The image header is corrupt or incomplete.',
      );
    }
    final isAnimated = decoder is image.WebPDecoder
        ? decoder.info?.hasAnimation == true
        : decoder.numFrames() != 1 || info.numFrames != 1;
    if (isAnimated) {
      throw const DashboardImageProcessingFailure(
        DashboardImageProcessingFailureCode.animated,
        'Animated and multi-frame images are not supported.',
      );
    }
    if (info.width > dashboardImagePreflightMaximumEdge ||
        info.height > dashboardImagePreflightMaximumEdge ||
        info.width * info.height > dashboardImagePreflightMaximumPixels) {
      throw const DashboardImageProcessingFailure(
        DashboardImageProcessingFailureCode.implausibleDimensions,
        'The image dimensions are too large to process safely.',
      );
    }

    final decoded = decoder.decodeFrame(0);
    if (decoded == null) {
      throw const DashboardImageProcessingFailure(
        DashboardImageProcessingFailureCode.corrupt,
        'The image could not be decoded. Choose another file.',
      );
    }
    var raster = image.bakeOrientation(decoded);
    if (raster.width < dashboardImageMinimumEdge || raster.height < dashboardImageMinimumEdge) {
      throw const DashboardImageProcessingFailure(
        DashboardImageProcessingFailureCode.tooSmall,
        'The image must be at least 320 pixels on its shortest edge.',
      );
    }
    if (raster.width > dashboardImageMaximumEdge || raster.height > dashboardImageMaximumEdge) {
      raster = raster.width >= raster.height
          ? image.copyResize(raster, width: dashboardImageMaximumEdge)
          : image.copyResize(raster, height: dashboardImageMaximumEdge);
    }

    // Orientation has already been baked into the pixels. Clear all decoded
    // metadata before encoding so EXIF/GPS, comments and color-profile payloads
    // cannot be copied into the uploaded object.
    raster
      ..exif = image.ExifData()
      ..iccProfile = null
      ..textData = null;

    final encoded = switch (format) {
      image.ImageFormat.jpg => image.encodeJpg(raster, quality: 90),
      image.ImageFormat.png => image.encodePng(raster, level: 6),
      image.ImageFormat.webp => image.encodeWebP(raster),
      _ => throw StateError('Unsupported format passed validated preflight.'),
    };
    if (encoded.length > dashboardImageMaximumBytes) {
      throw const DashboardImageProcessingFailure(
        DashboardImageProcessingFailureCode.outputTooLarge,
        'The processed image is still larger than 5 MB. Choose a simpler image.',
      );
    }
    return DashboardProcessedImage(
      bytes: encoded,
      mimeType: formatEvidence.mime,
      extension: format == image.ImageFormat.jpg ? 'jpg' : extension,
      width: raster.width,
      height: raster.height,
      sha256: sha256Hex(encoded),
    );
  } on DashboardImageProcessingFailure {
    rethrow;
  } on Object {
    throw const DashboardImageProcessingFailure(
      DashboardImageProcessingFailureCode.corrupt,
      'The image is corrupt or uses unsupported encoding features.',
    );
  }
}

void _throwIfCancelled(DashboardImageProcessingCancellation? cancellation) {
  if (cancellation?.isCancelled == true) {
    throw const DashboardImageProcessingFailure(
      DashboardImageProcessingFailureCode.cancelled,
      'Image processing was cancelled.',
    );
  }
}
