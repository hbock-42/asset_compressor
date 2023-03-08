import 'dart:io';

extension FileExtention on FileSystemEntity{
  String get name {
    return path.split("/").last;
  }

  String get nameWithoutExtension {
    return path.split("/").last.split('.').first;
  }

  String get extension {
    return path.split(".").last;
  }
}