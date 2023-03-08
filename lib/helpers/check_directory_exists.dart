import 'dart:io';

Future<bool> checkDirectoryExists(String pathToTest) async {
  try {
    return await Directory(pathToTest).exists();
  } catch (e) {
    return false;
  }
}