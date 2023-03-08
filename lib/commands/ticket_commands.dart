import 'dart:io';

import 'package:asset_compressor/extensions/extensions_on_file_system_entity.dart';
import 'package:bosun/bosun.dart';

import '../conf.dart';
import '../exceptions/already_present_file_type.dart';
import '../exceptions/missing_directory_exception.dart';
import '../exceptions/missing_ticket_folder_exception.dart';
import '../helpers/check_directory_exists.dart';
import '../ticket.dart';

class TicketCommand extends Command {
  TicketCommand()
      : super(
          command: 'ticket',
          description: 'command to work on ticket assets',
          subcommands: [
            TicketCheckAssetCommand(),
            TicketBuildCommand(),
          ],
        );
}

class TicketBuildCommand extends Command {
  TicketBuildCommand()
      : super(
            command: 'build',
            description: 'build the asset for every tickets',
            supportedFlags: {'eventid': 'id of the event -> will be used in the final asset name'});

  @override
  void run(List<String> args, Map<String, dynamic> flags) async {
    await build(eventId: flags.containsKey('eventid') ? flags['eventid'] : null);
  }

  static Future<void> build({String? eventId}) async {
    final tickets = await _verifyTicketAssets(eventId: eventId);
    for (final ticket in tickets) {
      ticket.build();
    }
  }
}

class TicketCheckAssetCommand extends Command {
  TicketCheckAssetCommand() : super(command: 'check-asset', description: 'checks asset necessary for a ticket');

  @override
  void run(List<String> args, Map<String, dynamic> flags) async {
    await _verifyTicketAssets();
  }
}

Future<List<Ticket>> _verifyTicketAssets({String? eventId}) async {
  final ticketSrcDirectoryExists = await checkDirectoryExists(Conf.ticketSrcPath);
  if (!ticketSrcDirectoryExists) {
    throw MissingDirectoryException(Conf.ticketSrcPath);
  }
  return _getTickets(Conf.ticketSrcPath, eventId: eventId);
}

Future<List<Ticket>> _getTickets(String ticketsSrcPath, {String? eventId}) async {
  final dir = Directory(ticketsSrcPath);
  final List<FileSystemEntity> entities = await dir.list().toList();
  List<Ticket> tickets = [];
  for (final entity in entities) {
    if (entity is File) {
      if (entity.name != '.DS_Store') {
        stdout.writeln(
            'The asset "${entity.path}" will not be treated. Every ticket asset should be in a directory which name will be used to name the resulting assets base name.');
      }
    } else if (entity is Directory) {
      final ticket = await _getTicket(entity.path, entity.name, eventId: eventId);
      tickets.add(ticket);
    }
  }
  if (tickets.isEmpty) {
    throw MissingTicketFolderException();
  } else {
    stdout.writeln(
        'The ticket build command should result in the creation of ${tickets.length} ticket${tickets.length > 1 ? 's' : ''}.');
    return tickets;
  }
}

Future<Ticket> _getTicket(String ticketPath, String baseName, {String? eventId}) async {
  final ticket = Ticket(ticketFolderPath: ticketPath, baseName: baseName, eventId: eventId);
  final dir = Directory(ticketPath);
  final List<FileSystemEntity> entities = await dir.list().toList();
  for (final entity in entities) {
    if (entity is File) {
      if (Conf.threeDExtensions.contains(entity.extension)) {
        if (ticket.has3D == true) {
          throw AlreadyPresentFileType(fileType: '3D', extensions: Conf.threeDExtensions, directoryPath: ticketPath);
        }
        ticket.threeDPath = entity.path;
        ticket.has3D = true;
      } else if (Conf.imageExtensions.contains(entity.extension)) {
        if (ticket.hasImage == true) {
          throw AlreadyPresentFileType(fileType: 'Image', extensions: Conf.imageExtensions, directoryPath: ticketPath);
        }
        ticket.imagePath = entity.path;
        ticket.hasImage = true;
      } else if (Conf.videoExtensions.contains(entity.extension)) {
        if (ticket.hasVideo == true) {
          throw AlreadyPresentFileType(fileType: 'Video', extensions: Conf.videoExtensions, directoryPath: ticketPath);
        }
        ticket.videoPath = entity.path;
        ticket.hasVideo = true;
      }
    }
  }
  ticket.validate();
  stdout.writeln('A ticket with base name "${ticket.baseName}" will be created.');
  return ticket;
}
