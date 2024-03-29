import 'dart:io';

import 'package:asset_compressor/extensions/extensions_on_file_system_entity.dart';
import 'package:fpdart/fpdart.dart';

import 'conf.dart';
import 'exceptions/exception_exports.dart';
import 'helpers/helper_exports.dart';

class Ticket {
  final String folderPath;
  final String baseName;
  final String? eventId;
  final Option<int> webpQualityOption;

  Ticket({
    required this.folderPath,
    required this.baseName,
    required this.webpQualityOption,
    this.eventId,
  }) : assert(webpQualityOption.fold(() => true, (webpQuality) => webpQuality >= 0 && webpQuality <= 100));

  String get exportFolderPath => '${Conf.assetExportPath}/${Conf.ticketPath}/$baseName';

  bool has3D = false;
  bool hasImage = false;
  bool hasVideo = false;
  String? imagePath;
  String? videoPath;
  String? threeDPath;

  void validate() {
    if (!hasImage && !hasVideo && !has3D) {
      throw MissingComputableTicketAssetsException(folderPath);
    }
    if (has3D && !hasImage && !hasVideo) {
      throw OnlyThreeDFileAssetFoundException(folderPath);
    }
  }

  Future<void> build() async {
    await buildDestinationFolder();
    if (hasImage) {
      _buildImages();
    }
    if (hasVideo) {
      _buildWebP();
      if (!hasImage) {
        _createThumbnailFromVideo();
      }
      if (!has3D) {
        _buildVideoArtifact();
      }
    }
    if (has3D) {
      _build3D();
    }
  }

  Future<void> buildDestinationFolder() async {
    await createDirectoryIfDoNotExists(exportFolderPath);
  }

  void _buildImages() {
    _resizeImage(maxWidth: Conf.thumbnailMaxWidth, maxHeight: Conf.thumbnailMaxHeight, assetTypeName: 'thumbnail');
    _resizeImage(maxWidth: Conf.displayMaxWidth, maxHeight: Conf.displayMaxHeight, assetTypeName: 'display');
    _resizeImage(maxWidth: Conf.artifactMaxWidth, maxHeight: Conf.artifactMaxHeight, assetTypeName: 'artifact');
  }

  /// [assetTypeName] is added after the name of the asset. It can be something like 'artifact', 'display', etc ...
  void _resizeImage({required int maxWidth, required int maxHeight, required String assetTypeName}) {
    Process.run(
      'ffmpeg',
      [
        '-i',
        imagePath!,
        '-vf',
        'scale=w=$maxWidth:h=$maxHeight:force_original_aspect_ratio=decrease',
        '-y',
        '$exportFolderPath/${eventId != null ? '${eventId}_' : ''}${baseName}_$assetTypeName.jpg'
      ],
      workingDirectory: './',
    ).then((result) {
      Logger.std(result.stdout);
      Logger.error(result.stderr);
    });
  }

  void _buildWebP() {
    _convertVideoToWebp(maxWidth: Conf.displayMaxWidth, maxHeight: Conf.displayMaxHeight, assetTypeName: 'display');
  }

  /// [assetTypeName] is added after the name of the asset. It can be something like 'artifact', 'display', etc ...
  void _convertVideoToWebp({required int maxWidth, required int maxHeight, required String assetTypeName}) {
    Process.run(
      'ffmpeg',
      [
        '-i',
        videoPath!,
        '-vf',
        'scale=w=$maxWidth:h=$maxHeight:force_original_aspect_ratio=decrease',
        '-lossless',
        '0',
        '-compression_level',
        '6',
        '-quality',
        webpQualityOption.fold(() => '80', (webpQuality) => webpQuality.toString()),
        '-loop',
        '0',
        '-y',
        '$exportFolderPath/${eventId != null ? '${eventId}_' : ''}${baseName}_$assetTypeName.webp'
      ],
      workingDirectory: './',
    ).then((result) {
      Logger.std(result.stdout);
      Logger.error(result.stderr);
    });
  }

  void _build3D() {
    final file = File(threeDPath!);
    file.copySync('$exportFolderPath/${eventId != null ? '${eventId}_' : ''}${baseName}_artifact.${file.extension}');
  }

  void _createThumbnailFromVideo() {
    _extractFirstFrame(
        maxWidth: Conf.thumbnailMaxWidth, maxHeight: Conf.thumbnailMaxHeight, assetTypeName: 'thumbnail');
  }

  void _extractFirstFrame({required int maxWidth, required int maxHeight, required String assetTypeName}) {
    Process.run(
      'ffmpeg',
      [
        '-i',
        videoPath!,
        '-vf',
        'select=eq(n,0)',
        '-vframes',
        '1',
        '-vf',
        'scale=w=$maxWidth:h=$maxHeight:force_original_aspect_ratio=decrease',
        '-y',
        '$exportFolderPath/${eventId != null ? '${eventId}_' : ''}${baseName}_$assetTypeName.jpg'
      ],
      workingDirectory: './',
    ).then((result) {
      Logger.std(result.stdout);
      Logger.error(result.stderr);
    });
  }

  void _buildVideoArtifact() {
    _buildVideo(
      maxWidth: Conf.artifactMaxWidth,
      maxHeight: Conf.artifactMaxHeight,
      assetTypeName: 'artifact',
      compressionStrength: 24,
    );
  }

  void _buildVideo({
    required int maxWidth,
    required int maxHeight,
    required String assetTypeName,
    int compressionStrength = 28,
  }) {
    Process.run(
      'ffmpeg',
      [
        '-i',
        videoPath!,
        '-vf',
        'scale=w=$maxWidth:h=$maxHeight:force_original_aspect_ratio=decrease',
        '-vcodec',
        'libx264',
        '-crf',
        compressionStrength.toString(),
        '-y',
        '$exportFolderPath/${eventId != null ? '${eventId}_' : ''}${baseName}_$assetTypeName.mp4'
      ],
      workingDirectory: './',
    ).then((result) {
      Logger.std(result.stdout);
      Logger.error(result.stderr);
    });
  }
}
