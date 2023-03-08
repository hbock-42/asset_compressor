import 'package:asset_compressor/conf.dart';

class MissingComputableTicketAssetsException {
  final String ticketFolderPath;

  MissingComputableTicketAssetsException(this.ticketFolderPath);

  @override
  String toString() =>
      'No file with extension ${Conf.computableTicketAssetExtensions} found in the ticket folder "$ticketFolderPath"';
}
