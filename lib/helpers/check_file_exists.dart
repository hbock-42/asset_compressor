import 'dart:io';

Future<bool> checkFileExists(String pathToTest) async {
    return await File(pathToTest).exists();
}