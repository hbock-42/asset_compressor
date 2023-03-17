class ImageHasAlphaException {
  final String imagePath;

  ImageHasAlphaException(this.imagePath);

  @override
  String toString() =>
      'Image "$imagePath" has alpha (transparent) pixel. This is forbidden !';
}
