import '../conf.dart';

class MissingTicketFolderException implements Exception {
  MissingTicketFolderException();

  @override
  String toString() => 'No folder(s) has been found inside the ticket folder (${Conf.ticketSrcPath}) ! You should have at least one folder, containing the assets of your first ticket. The resulting assets will be named from the directory name containing this assets. You must create as many folder as the total number of tickets.';
}