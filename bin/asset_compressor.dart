import 'dart:io';

import 'package:asset_compressor/commands/event_commands.dart';
import 'package:asset_compressor/commands/lineup_command.dart';
import 'package:asset_compressor/commands/ticket_commands.dart';

import 'package:bosun/bosun.dart';

void main(List<String> args) {
  execute(
    BosunCommand('asset-compressor', subcommands: [
      EventCommand(),
      TicketCommand(),
      LineupCommand(),
    ]),
    args,
  );
}

// void main(List<String> arguments) {
//   print('Hello world: ${asset_compressor.calculate()}!');
//   // Process.run('grep', ['-i', 'main', 'test.dart']).then((result) {
//   Process.run('ls -la', ['.']).then((result) {
//     stdout.write(result.stdout);
//     stderr.write(result.stderr);
//   });
//   print('Hello worlddd: ${asset_compressor.calculate()}!');
//
// }

/// The src folder must contain source assets
/// vertical.[png,jpg] for event image
///
/// horizontal.[png,jpg] for event image
///
/// ticket.[png,jpg] for event artifact, display and thumbnail image generation
// main(List<String> args) async {
//   if (args.length != 2) {
//     print('oups');
//     return;
//   }
//    else if (args[0] != '--event-id'){
//      print('missing command parameter --event-id');
//      return;
//   } else {
//      final eventId  = args[1];
//      print('Your event id is $eventId');
//      // final workingDirectory = '/Users/hugo/projects/dart/test_data';
//      final workingDirectory = './';
//      _createHorizontalAsset(eventId, workingDirectory);
//      _createVerticalAsset(eventId, workingDirectory);
//      _createTicketFromImageAsset(eventId, workingDirectory);
//   }
//   // args.forEach(print);
//   // var process = await Process.start('cat', []);
//   // process.stdout
//   //     .transform(utf8.decoder)
//   //     .forEach(print);
//   // process.stdin.writeln('Hello, world!');
//   // process.stdin.writeln('Hello, galaxy!');
//   // process.stdin.writeln('Hello, universe!');
//   //
//   // process.kill();
//
//
//   Process.run('ls', ['-la'], workingDirectory: '/Users/hugo/projects/dart/test_data').then((result) {
//     print('ls:');
//     print(result.stdout);
//     // stdout.write(result.stdout);
//     // stderr.write(result.stderr);
//   });
// }

void _createTicketFromImageAsset(String eventId, String workingDirectory) {
  final assetBaseName = 'ticket';
  final aspectRatio = 9 / 16;
  final thumbnailMaxHeight = 200;
  final thumbnailMaxWidth = thumbnailMaxHeight * aspectRatio;
  final displayMaxHeight = 780;
  final displayMaxWidth = displayMaxHeight * aspectRatio;
  final artifactMaxHeight = 2400;
  final artifactMaxWidth = artifactMaxHeight * aspectRatio;
  Process.run(
          'ffmpeg',
          [
            '-i',
            'src/$assetBaseName.png',
            '-vf',
            'scale=w=$thumbnailMaxWidth:h=$thumbnailMaxHeight:force_original_aspect_ratio=decrease',
            '-y',
            'ticket/${eventId}_thumbnail.jpg'
          ],
          workingDirectory: workingDirectory)
      .then((result) {
    print(result.stdout);
    stdout.write(result.stdout);
    stderr.write(result.stderr);
  });
  Process.run(
          'ffmpeg',
          [
            '-i',
            'src/$assetBaseName.jpg',
            '-vf',
            'scale=w=$thumbnailMaxWidth:h=$thumbnailMaxHeight:force_original_aspect_ratio=decrease',
            '-y',
            'ticket/${eventId}_thumbnail.jpg'
          ],
          workingDirectory: workingDirectory)
      .then((result) {
    print(result.stdout);
    stdout.write(result.stdout);
    stderr.write(result.stderr);
  });

  Process.run(
          'ffmpeg',
          [
            '-i',
            'src/$assetBaseName.png',
            '-vf',
            'scale=w=$displayMaxWidth:h=$displayMaxHeight:force_original_aspect_ratio=decrease',
            '-y',
            'ticket/${eventId}_display.jpg'
          ],
          workingDirectory: workingDirectory)
      .then((result) {
    print(result.stdout);
    stdout.write(result.stdout);
    stderr.write(result.stderr);
  });
  Process.run(
          'ffmpeg',
          [
            '-i',
            'src/$assetBaseName.jpg',
            '-vf',
            'scale=w=$displayMaxWidth:h=$displayMaxHeight:force_original_aspect_ratio=decrease',
            '-y',
            'ticket/${eventId}_display.jpg'
          ],
          workingDirectory: workingDirectory)
      .then((result) {
    print(result.stdout);
    stdout.write(result.stdout);
    stderr.write(result.stderr);
  });

  Process.run(
          'ffmpeg',
          [
            '-i',
            'src/$assetBaseName.png',
            '-vf',
            'scale=w=$artifactMaxWidth:h=$artifactMaxHeight:force_original_aspect_ratio=decrease',
            '-y',
            'ticket/${eventId}_artifact.jpg'
          ],
          workingDirectory: workingDirectory)
      .then((result) {
    print(result.stdout);
    stdout.write(result.stdout);
    stderr.write(result.stderr);
  });
  Process.run(
          'ffmpeg',
          [
            '-i',
            'src/$assetBaseName.jpg',
            '-vf',
            'scale=w=$artifactMaxWidth:h=$artifactMaxHeight:force_original_aspect_ratio=decrease',
            '-y',
            'ticket/${eventId}_artifact.jpg'
          ],
          workingDirectory: workingDirectory)
      .then((result) {
    print(result.stdout);
    stdout.write(result.stdout);
    stderr.write(result.stderr);
  });
}
