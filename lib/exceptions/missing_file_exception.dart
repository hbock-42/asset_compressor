class MissingFileException implements Exception {
  final List<String> files;

  MissingFileException(this.files);

  @override
  String toString() => 'None of this files exists when at least one should: $files';
}