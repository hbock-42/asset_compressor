import 'dart:io';

import 'package:asset_compressor/extensions/extensions_on_file_system_entity.dart';
import 'package:bosun/bosun.dart';
import 'package:fpdart/fpdart.dart';

import '../conf.dart';
import '../exceptions/exception_exports.dart';
import '../helpers/helper_exports.dart';
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

enum TicketBuildCommandFlags {
  eventId('eventid'),
  webpQuality('webpquality');

  final String value;

  const TicketBuildCommandFlags(this.value);
}

class TicketCommandsFlagsValues {
  final Option<String> eventIdOption;
  final Option<int> webpQualityOption;

  TicketCommandsFlagsValues({
    required this.eventIdOption,
    required this.webpQualityOption,
  });

  factory TicketCommandsFlagsValues.fromJson(Map<String, dynamic> flags) {
    final Option<String> eventIdOption = Option.tryCatch(() => flags[TicketBuildCommandFlags.eventId.value]);
    final Option<int> webpQualityOption =
    Option.tryCatch(() => int.parse(flags[TicketBuildCommandFlags.webpQuality.value]));
    // todo: show found flags and their values
    // todo: raise if an unknown flag is used
    final flagValues = TicketCommandsFlagsValues(
      eventIdOption: eventIdOption,
      webpQualityOption: webpQualityOption,
    );
    return flagValues;
  }
}

class TicketBuildCommand extends Command {
  TicketBuildCommand()
      : super(
          command: 'build',
          description: 'build the asset for every tickets',
          supportedFlags: {
            TicketBuildCommandFlags.eventId.value: 'id of the event -> will be used in the final asset name',
            TicketBuildCommandFlags.webpQuality.value:
                'quality of the output webp -> must be between 0 and 100. 100 is the best quality. Default value -> 80'
          },
        );

  @override
  void run(List<String> args, Map<String, dynamic> flags) async {
    final flagsValues = TicketCommandsFlagsValues.fromJson(flags);
    await build(
        flagValues: flagsValues,
        eventId: flags.containsKey(TicketBuildCommandFlags.eventId.value)
            ? flags[TicketBuildCommandFlags.eventId.value]
            : null);
  }

  static Future<void> build({
    required TicketCommandsFlagsValues flagValues,
    String? eventId,
  }) async {
    Logger.print('Start building tickets assets ...', forceVerbose: true);
    final tickets = await TicketCheckAssetCommand.checkAssets(eventId: eventId, flagsValues: flagValues);
    for (final ticket in tickets) {
      ticket.build();
    }
  }
}

class TicketCheckAssetCommand extends Command {
  TicketCheckAssetCommand()
      : super(
          command: 'check-asset',
          description: 'checks asset necessary for a ticket',
        );

  @override
  void run(List<String> args, Map<String, dynamic> flags) async {
    Logger.print('Start checking tickets assets ...', forceVerbose: true);
    final flagsValues = TicketCommandsFlagsValues.fromJson(flags);
    await checkAssets(flagsValues: flagsValues);
    Logger.success('No error found in the tickets assets ...', forceVerbose: true);
  }

  static Future<List<Ticket>> checkAssets({
    required TicketCommandsFlagsValues flagsValues,
    String? eventId,
  }) async {
    final ticketSrcDirectoryExists = await checkDirectoryExists(Conf.ticketsFolderSourcePath);
    if (!ticketSrcDirectoryExists) {
      throw MissingDirectoryException(Conf.ticketsFolderSourcePath);
    }
    return _getTickets(
      Conf.ticketsFolderSourcePath,
      eventId: eventId,
      flagsValues: flagsValues,
    );
  }
}

Future<List<Ticket>> _getTickets(
  String ticketsFolderSourcePath, {
  required TicketCommandsFlagsValues flagsValues,
  String? eventId,
}) async {
  final dir = Directory(ticketsFolderSourcePath);
  final List<FileSystemEntity> entities = await dir.list().toList();
  List<Ticket> tickets = [];
  for (final entity in entities) {
    if (entity is File) {
      if (entity.name != '.DS_Store') {
        Logger.warning(
            'The asset "${entity.path}" will not be treated. Every ticket asset should be in a directory which name will be used to name the resulting assets base name.',
            forceVerbose: true);
      }
    } else if (entity is Directory) {
      final ticket = await _getTicket(
        entity.path,
        entity.name,
        eventId: eventId,
        flagsValues: flagsValues,
      );
      tickets.add(ticket);
    }
  }
  if (tickets.isEmpty) {
    throw MissingTicketFolderException();
  } else {
    Logger.std(
        'The ticket build command should result in the creation of ${tickets.length} ticket${tickets.length > 1 ? 's' : ''}.',
        forceVerbose: true);
    return tickets;
  }
}

Future<Ticket> _getTicket(
  String ticketPath,
  String baseName, {
  required TicketCommandsFlagsValues flagsValues,
  String? eventId,
}) async {
  final ticket = Ticket(
    folderPath: ticketPath,
    baseName: baseName,
    eventId: eventId,
    webpQualityOption: flagsValues.webpQualityOption,
  );
  final dir = Directory(ticketPath);
  final List<FileSystemEntity> entities = await dir.list().toList();
  for (final entity in entities) {
    if (entity is File) {
      if (Conf.threeDExtensions.contains(entity.extension)) {
        if (ticket.has3D == true) {
          throw AlreadyPresentFileTypeException(
              fileType: '3D', extensions: Conf.threeDExtensions, directoryPath: ticketPath);
        }
        ticket.threeDPath = entity.path;
        ticket.has3D = true;
      } else if (Conf.imageExtensions.contains(entity.extension)) {
        if (ticket.hasImage == true) {
          throw AlreadyPresentFileTypeException(
              fileType: 'Image', extensions: Conf.imageExtensions, directoryPath: ticketPath);
        }
        throwIfImageHasAlpha(entity.path);
        ticket.imagePath = entity.path;
        ticket.hasImage = true;
      } else if (Conf.videoExtensions.contains(entity.extension)) {
        if (ticket.hasVideo == true) {
          throw AlreadyPresentFileTypeException(
              fileType: 'Video', extensions: Conf.videoExtensions, directoryPath: ticketPath);
        }
        ticket.videoPath = entity.path;
        ticket.hasVideo = true;
      }
    }
  }
  ticket.validate();
  Logger.std('A ticket with base name "${ticket.baseName}" will be created.', forceVerbose: true);
  return ticket;
}
