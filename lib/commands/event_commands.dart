import 'dart:io';

import 'package:asset_compressor/helpers/logger.dart';
import 'package:bosun/bosun.dart';

import '../conf.dart';
import '../exceptions/exception_exports.dart';
import '../helpers/helper_exports.dart';

class EventCommand extends Command {
  EventCommand()
      : super(
          command: 'event',
          subcommands: [
            EventBuildAssetCommand(),
            EventCheckAssetCommand(),
          ],
          description: 'command to work on event assets',
        );
}

class EventBuildAssetCommand extends Command {
  EventBuildAssetCommand()
      : super(command: 'build', description: 'builds the vertical and horizontal asset of an event assets');

  @override
  void run(List<String> args, Map<String, dynamic> flags) async {
    await EventCheckAssetCommand.checkAssets();
    Logger.print('Start building event assets ...', forceVerbose: true);
    final verticalSrcPath =
        await checkFileExists(Conf.srcVerticalAssetJpg) ? Conf.srcVerticalAssetJpg : Conf.srcVerticalAssetPng;
    createDirectoryIfDoNotExists('${Conf.assetExportPath}/${Conf.eventPath}');
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
    Logger.success('Event assets built with success !', forceVerbose: true);
    Logger.success(verticalSrcPath, forceVerbose: true);
    Logger.success(horizontalSrcPath, forceVerbose: true);
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
    Logger.std(result.stdout);
    Logger.error(result.stderr);
  });
}

class EventCheckAssetCommand extends Command {
  EventCheckAssetCommand() : super(command: 'check-asset', description: 'checks asset necessary for an event');

  @override
  void run(List<String> args, Map<String, dynamic> flags) async {
    Logger.print('Start checking event assets ...', forceVerbose: true);
    await checkAssets();
    Logger.success('No error found in the event assets ...', forceVerbose: true);
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
    } else {
      if (verticalAssetPngExists) {
        throwIfImageHasAlpha(Conf.srcVerticalAssetPng);
      }
      if (verticalAssetJpgExists) {
        throwIfImageHasAlpha(Conf.srcVerticalAssetJpg);
      }
    }
    final horizontalAssetPngExists = await checkFileExists(Conf.srcHorizontalAssetPng);
    final horizontalAssetJpgExists = await checkFileExists(Conf.srcHorizontalAssetJpg);
    if (!horizontalAssetPngExists && !horizontalAssetJpgExists) {
      throw MissingFileException([Conf.srcHorizontalAssetPng, Conf.srcHorizontalAssetJpg]);
    } else {
      if (horizontalAssetPngExists) {
        throwIfImageHasAlpha(Conf.srcHorizontalAssetPng);
      }
      if (horizontalAssetJpgExists) {
        throwIfImageHasAlpha(Conf.srcHorizontalAssetJpg);
      }
    }
  }
}

