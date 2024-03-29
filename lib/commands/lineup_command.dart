import 'dart:io';

import 'package:asset_compressor/extensions/extensions_on_file_system_entity.dart';
import 'package:asset_compressor/lineup.dart';
import 'package:bosun/bosun.dart';

import '../conf.dart';
import '../exceptions/exception_exports.dart';
import '../helpers/helper_exports.dart';

class LineupCommand extends Command {
  LineupCommand()
      : super(
          command: 'lineup',
          description: 'command to work on lineup assets',
          subcommands: [
            LineupCheckAssetCommand(),
            LineupBuildCommand(),
          ],
        );
}

class LineupBuildCommand extends Command {
  LineupBuildCommand()
      : super(
          command: 'build',
          description: 'build the asset for every lineup',
          supportedFlags: {'eventid': 'id of the event -> will be used in the final asset name'},
        );

  @override
  void run(List<String> args, Map<String, dynamic> flags) async {
    await build(eventId: flags.containsKey('eventid') ? flags['eventid'] : null);
  }

  static Future<void> build({String? eventId}) async {
    final lineups = await LineupCheckAssetCommand.checkAssets(eventId: eventId);
    for (final lineup in lineups) {
      lineup.build();
    }
  }
}

class LineupCheckAssetCommand extends Command {
  LineupCheckAssetCommand()
      : super(
          command: 'check-asset',
          description: 'checks asset necessary for a lineup',
        );

  @override
  void run(List<String> args, Map<String, dynamic> flags) async {
    Logger.print('Start checking lineup assets ...', forceVerbose: true);
    try {
      await checkAssets();
    }
    catch (e) {
      Logger.error(e.toString());
      rethrow;
    }
    Logger.success('No error found in the lineup assets ...', forceVerbose: true);
  }

  static Future<List<Lineup>> checkAssets({String? eventId}) async {
    final srcDirectoryExists = await checkDirectoryExists(Conf.lineupSrcFolderPath);
    if (!srcDirectoryExists) {
      throw MissingDirectoryException(Conf.lineupSrcFolderPath);
    }
    return _getLineups(Conf.lineupSrcFolderPath, eventId: eventId);
  }
}

Future<List<Lineup>> _getLineups(String lineupFolderSourcePath, {String? eventId}) async {
  final dir = Directory(lineupFolderSourcePath);
  final List<FileSystemEntity> entities = await dir.list().toList();
  List<Lineup> lineups = [];
  for (final entity in entities) {
    if (entity is File) {
      if (entity.name != '.DS_Store') {
        final lineup = await _getLineup(entity, eventId: eventId);
        lineups.add(lineup);
      }
    } else if (entity is Directory) {
      Logger.warning('The asset "${entity.path}" will not be treated. Only files should be in the lineup folder "$lineupFolderSourcePath".', forceVerbose: true);
    }
  }
  if (lineups.isEmpty) {
    Logger.error('No lineup file found in the lineup folder "$lineupFolderSourcePath".', forceVerbose: true);
  } else {
    Logger.std('${lineups.length} items found in the lineup folder "$lineupFolderSourcePath".', forceVerbose: true);
  }
  return lineups;
}

Future<Lineup> _getLineup(FileSystemEntity entity, {String? eventId}) async {
  if (Conf.imageExtensions.contains(entity.extension)) {
    final lineup = Lineup(path: entity.path, baseName: entity.nameWithoutExtension, eventId: eventId);
    Logger.std('A lineup with base name "${lineup.baseName}" will be created.', forceVerbose: true);
    return lineup;
  }
  throw WrongLineupFileTypeException(wrongExtension: entity.extension, fileWithWrongTypePath: entity.path);
}
