import 'dart:io';

import 'package:asset_compressor/helpers/check_file_exists.dart';
import 'package:bosun/bosun.dart';

import '../conf.dart';
import '../exceptions/missing_directory_exception.dart';
import '../exceptions/missing_file_exception.dart';
import '../helpers/check_directory_exists.dart';
import '../helpers/create_directory_if_do_not_exists.dart';

class EventCommand extends Command {
  EventCommand()
      : super(
          command: 'event',
          subcommands: [
            EventBuildAssetCommand(),
            EventCheckAssetCommand(),
          ],
          description: 'command to work on event',
        );
}

class EventBuildAssetCommand extends Command {
  EventBuildAssetCommand() : super(command: 'build', description: 'builds the vertical and horizontal asset of an event assets');

  @override
  void run(List<String> args, Map<String, dynamic> flags) async {
    await EventCheckAssetCommand.checkAssets();
    // This will be executed before the command above is executed
    final verticalSrcPath =
        await checkFileExists(Conf.srcVerticalAssetJpg) ? Conf.srcVerticalAssetJpg : Conf.srcVerticalAssetPng;
    createDirectoryIfDoNotExists('${Conf.assetOutputPath}/${Conf.eventPath}');
    _compressImageAsset(
      assetPath: verticalSrcPath,
      outputPath: Conf.eventVerticalAssetJpgExportPath,
      width: Conf.eventVerticalWidth,
      height: Conf.eventVerticalHeight,
    );
    final horizontalSrcPath =
        await checkFileExists(Conf.srcHorizontalAssetJpg) ? Conf.srcHorizontalAssetJpg : Conf.srcHorizontalAssetPng;
    _compressImageAsset(
      assetPath: horizontalSrcPath,
      outputPath: Conf.eventHorizontalAssetJpgExportPath,
      width: Conf.eventHorizontalWidth,
      height: Conf.eventHorizontalHeight,
    );
  }
}

void _compressImageAsset(
    {required String assetPath, required int width, required int height, required String outputPath}) {
  Process.run(
          'ffmpeg',
          [
            '-i',
            assetPath,
            '-vf',
            'scale=w=$width:h=$height:force_original_aspect_ratio=decrease',
            '-y',
            outputPath,
          ],
          workingDirectory: './')
      .then((result) {
    stdout.writeln(result.stdout);
    stderr.writeln(result.stderr);
  });
}

class EventCheckAssetCommand extends Command {
  EventCheckAssetCommand() : super(command: 'check-asset', description: 'checks asset necessary for an event');

  @override
  void run(List<String> args, Map<String, dynamic> flags) async {
    await checkAssets();
  }

  static Future<void> checkAssets() async {
    final srcDirectoryExists = await checkDirectoryExists(Conf.eventSrcPath);
    if (!srcDirectoryExists) {
      throw MissingDirectoryException(Conf.eventSrcPath);
    }
    final verticalAssetPngExists = await checkFileExists(Conf.srcVerticalAssetPng);
    final verticalAssetJpgExists = await checkFileExists(Conf.srcVerticalAssetJpg);
    if (!verticalAssetPngExists && !verticalAssetJpgExists) {
      throw MissingFileException([Conf.srcVerticalAssetPng, Conf.srcVerticalAssetJpg]);
    }
    final horizontalAssetPngExists = await checkFileExists(Conf.srcHorizontalAssetPng);
    final horizontalAssetJpgExists = await checkFileExists(Conf.srcHorizontalAssetJpg);
    if (!horizontalAssetPngExists && !horizontalAssetJpgExists) {
      throw MissingFileException([Conf.srcHorizontalAssetPng, Conf.srcHorizontalAssetJpg]);
    }
  }
}
