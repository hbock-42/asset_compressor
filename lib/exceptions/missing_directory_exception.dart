class MissingDirectoryException implements Exception {
  final String missingDirectoryPath;
  MissingDirectoryException(this.missingDirectoryPath);

  @override
  String toString() => 'Directory "$missingDirectoryPath" does not exist';
}