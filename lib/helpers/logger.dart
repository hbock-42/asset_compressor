import 'dart:io';

import 'package:chalk/chalk.dart';

import '../parameters_from_args.dart';

class Logger {
  static void success(
    String str, {
    bool forceVerbose = false,
  }) {
    if (forceVerbose || ParametersFromArgs.verbose) {
      stdout.writeln(chalk.green(str));
    }
  }

  static void print(String str, {bool forceVerbose = false}) {
    if (forceVerbose || ParametersFromArgs.verbose) {
      stdout.writeln(chalk.blue(str));
    }
  }
  static void warning(String str, {bool forceVerbose = false}) {
    if (forceVerbose || ParametersFromArgs.verbose) {
      stdout.writeln(chalk.yellow(str));
    }
  }

  static void std(String str, {bool forceVerbose = false}) {
    if (forceVerbose || ParametersFromArgs.verbose) {
      stdout.writeln(str);
    }
  }

  static void error(String str, {bool forceVerbose = false}) {
    if (forceVerbose || ParametersFromArgs.verbose) {
      stderr.writeln(chalk.red(str));
    }
  }
}
