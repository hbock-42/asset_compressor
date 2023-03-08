import 'dart:io';

import 'check_directory_exists.dart';

Future<void> createDirectoryIfDoNotExists(String path) async {
  if (! await checkDirectoryExists(path)) {
  await Directory(path).create(recursive: true);
  }
}