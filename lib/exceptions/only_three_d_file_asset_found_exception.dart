import '../conf.dart';

class OnlyThreeDFileAssetFoundException implements Exception {
  final String ticketFolderPath;

  OnlyThreeDFileAssetFoundException(this.ticketFolderPath);

  @override
  String toString() =>
      'Only 3D asset has been found in the ticket folder "$ticketFolderPath". You must at least have 1 asset of type Image (${Conf.imageExtensions}) or Video (${Conf.videoExtensions}).';
}
