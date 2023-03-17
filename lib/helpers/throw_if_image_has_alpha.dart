import 'package:asset_compressor/parameters_from_args.dart';
import 'package:image/image.dart' as img;

import 'dart:io';

import '../exceptions/exception_exports.dart';

void throwIfImageHasAlpha(String path) {
  if (ParametersFromArgs.allowAlpha) return;
  final imageFile = File(path).readAsBytesSync();
  final image = img.decodeImage(imageFile);
  if (image != null) {
    if (image.hasAlpha) {
      throw ImageHasAlphaException(path);
    }
  }
}
