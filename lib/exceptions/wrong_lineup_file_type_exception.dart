import 'package:asset_compressor/conf.dart';

class WrongLineupFileTypeException implements Exception {
  final String wrongExtension;
  final String fileWithWrongTypePath;

  WrongLineupFileTypeException({required this.wrongExtension, required this.fileWithWrongTypePath});

  @override
  String toString() =>
      'Wrong lineup file type. The file "$fileWithWrongTypePath" is of type "$wrongExtension". Allow file type -> Image: ${Conf.imageExtensions}';
}
