class Conf {
  static const String assetSrcPath = 'src';
  static const String assetOutputPath = 'ready-to-deploy';
  static const String eventPath = 'event';
  static const String lineUpPath = 'lineUp';
  static const String ticketPath = 'ticket';
  static const String srcVerticalAssetName = 'vertical';
  static const String srcHorizontalAssetName = 'horizontal';
  static const int eventVerticalHeight = 500;
  static const int eventVerticalWidth = 1000;
  static const int eventHorizontalHeight = 1080;
  static const int eventHorizontalWidth = 1980;
  static const List<String> imageExtensions = ['jpg', 'jpeg', 'png'];
  static const List<String> videoExtensions = ['mov', 'mp4'];
  static const List<String> threeDExtensions = ['glb'];
  static const double ticketImageAspectRatio = 9 / 16;
  static const int thumbnailMaxHeight = 200;
  static const int displayMaxHeight = 780;
  static const int artifactMaxHeight = 2400;

  static int get thumbnailMaxWidth => (thumbnailMaxHeight * ticketImageAspectRatio).round();

  static int get displayMaxWidth => (displayMaxHeight * ticketImageAspectRatio).round();

  static int get artifactMaxWidth => (artifactMaxHeight * ticketImageAspectRatio).round();


  static List<String> get computableTicketAssetExtensions =>
      [...imageExtensions, ...videoExtensions, ...threeDExtensions];

  static String get eventSrcPath => '$assetSrcPath/$eventPath';

  static String get srcVerticalAssetPng => '$eventSrcPath/$srcVerticalAssetName.png';

  static String get srcVerticalAssetJpg => '$eventSrcPath/$srcVerticalAssetName.jpg';

  static String get eventVerticalAssetJpgExportPath => '$assetOutputPath/$eventPath/$srcVerticalAssetName.jpg';

  static String get srcHorizontalAssetPng => '$eventSrcPath/$srcHorizontalAssetName.png';

  static String get srcHorizontalAssetJpg => '$eventSrcPath/$srcHorizontalAssetName.jpg';

  static String get eventHorizontalAssetJpgExportPath => '$assetOutputPath/$eventPath/$srcHorizontalAssetName.jpg';

  static String get ticketSrcPath => '$assetSrcPath/$ticketPath';
}
