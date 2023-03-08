import 'dart:io';

import 'conf.dart';
import 'helpers/helper_exports.dart';

class Lineup {
  final String path;
  final String baseName;
  final String? eventId;

  Lineup({
    required this.path,
    required this.baseName,
    this.eventId,
  });

  String get exportFolderPath => Conf.lineupExportFolderPath;

  Future<void> build() async {
    await createDirectoryIfDoNotExists(exportFolderPath);
    _cropAndScale(Conf.lineupAssetSize);
  }

  void _cropAndScale(int size) {
    // ffmpeg -i src/lineup/vert.jpg  -vf "crop='min(iw, ih)':'min(iw, ih)':'(iw/2
    // )-min(iw, ih)/2':'(ih/2)-min(iw, ih)/2',scale=w=200:h=200:force_original_aspect_ratio=increase" -y resized_verti.jpg
    Process.run(
      'ffmpeg',
      [
        '-i',
        path,
        '-vf',
        "crop='min(iw, ih)':'min(iw, ih)':'(iw/2)-min(iw, ih)/2':'(ih/2)-min(iw, ih)/2',scale=w=$size:h=$size:force_original_aspect_ratio=increase",
        '-y',
        '$exportFolderPath/${eventId != null ? '${eventId}_' : ''}$baseName.jpg'
      ],
      workingDirectory: './',
    ).then((result) {
      print(result.stdout);
      stdout.write(result.stdout);
      stderr.write(result.stderr);
    });
  }
}
