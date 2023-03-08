class AlreadyPresentFileType implements Exception {
  final String fileType;
  final List<String> extensions;
  final String directoryPath;

  AlreadyPresentFileType({
    required this.fileType,
    required this.extensions,
    required this.directoryPath,
  });

  @override
  String toString() => 'There is already a file of type "$fileType" (with extension $extensions) in the directory $directoryPath';
}
