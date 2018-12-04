//  Copyright (c) 2016, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//
import 'dart:io' show Platform;

import 'package:args/args.dart';
import 'package:core/core.dart';

class JobArgs {
  /// The location to put error log files
  String inputDir;

  /// The location to put error log files
  String outputDir;

  /// The location of the log file, which describes the results.
  String logPath;

  /// The location of the summary file, which describes the results.
  String summary;

  /// Print a short message every [shortMsgInterval] files processed.
  int shortMsgInterval;

  /// Print a long message every [longMsgInterval] files processed.
  int longMsgInterval;

  /// The log Level for first run
  Level logLevel = Level.warn;

  /// The name of the program that is running
  String program;

  /// The argument processor for Job arguments.
  ArgParser parser;

  /// The parser's [ArgResults].
  ArgResults argResults;

  /// If true displays a help message and exits.
  bool showHelp = false;

  JobArgs(List<String> args) {
    program = programName;
    parser = getParser();
    argResults = parser.parse(args);
    inputDir = argResults.rest[0];
  }

  int get length => argResults.arguments.length;

  String get programName {
    final path = Platform.script.pathSegments;
    final end = path.last.lastIndexOf('.');
    final name = path.last.substring(0, end);
    return name;
  }

  String get help => parser.usage;

  String get info => '''JobArgs:
    inputDir: '$inputDir'
   outputDir: '$outputDir'
     logPath: '$logPath'
     summary: '$summary'
       short: $shortMsgInterval
        long: $longMsgInterval
   baseLevel: $logLevel
     program: $program
  argResults: ${argResults.arguments}
    showHelp: $showHelp
  ''';

//  void _setLogPath(Object path) => (path is String) ? logPath = path : null;

  void _setSummary(Object results) =>
      (results is String) ? summary = results : null;

  void _setOutDir(Object dir) => (dir is String) ? outputDir = dir : null;

//  void _setShortInterval(Object count) =>
//      (count is String) ? shortMsgInterval = _parseInt(count) : null;

//  void _setLongInterval(Object count) =>
//      (count is String) ? longMsgInterval = _parseInt(count) : null;

  void _setDebugLevel(Object mode) => logLevel = Level.lookup(mode);

  int _parseInt(String s) {
    final n = int.tryParse(s);
    return (n == null) ? 100 : n;
  }

  void _setMsgLevels(String msg) {
    print('msg: $msg');
    if (msg == '') return;
    final colon = msg.indexOf(':');
    if (colon == -1) {
      shortMsgInterval = _parseInt(msg);
    } else {
      shortMsgInterval = _parseInt(msg.substring(0, colon));
      longMsgInterval = _parseInt(msg.substring(colon + 1));
      print('shortMsg: $shortMsgInterval');
      print('longMsg: $longMsgInterval');
    }
  }

/*
  void _setLogLevel(String v) {
    switch (v) {
      case 's':
        logLevel = Level.off;
        break;
      case 'c':
        logLevel = Level.config;
        break;
      case 'w':
        logLevel = Level.warn1;
        break;
      case 'd':
        logLevel = Level.debug;
        break;
      case 'v':
        logLevel = Level.debug3;
        break;
      default:
        logLevel = Level.info;
    }
  }
*/

  ArgParser getParser() => new ArgParser()
    ..addOption('results',
        abbr: 'r',
        defaultsTo: './results.txt',
        callback: _setSummary,
        help: 'The results file')
    ..addOption('outDir',
        abbr: 'o',
        defaultsTo: './output',
        callback: _setOutDir,
        help: 'The output directory - created files have same name as source')
    ..addOption('msg',
        abbr: 'm',
        defaultsTo: '1000:10000',
        callback: _setMsgLevels,
        help: 'm:n - print a short:long progress message every m:n files '
            'processed"')
    // These next options are for the logger Level
    ..addOption('Level',
        abbr: 'l',
        allowed: [
          'error', 'config', 'warn0', 'warn1', 'info0', 'info1',
          'debug', 'debug1', 'debug2', 'debug3' //No Reformat
        ],
        defaultsTo: 'error',
        callback: _setDebugLevel,
        help: 'The logging mode - defaults to info')
    ..addFlag('silent',
        abbr: 's',
        defaultsTo: false,
        callback: (v) => v ? logLevel = Level.severe : false,
        help: 'Silent mode - mode is set to "error"')
    ..addFlag('config',
        abbr: 'c',
        defaultsTo: false,
        callback: (v) => v ? logLevel = Level.config : false,
        help: 'mode is set to "config"')
    ..addFlag('warn',
        abbr: 'w',
        defaultsTo: false,
        callback: (v) => v ? logLevel = Level.warn1 : false,
        help: 'mode is set to "warn"')
    ..addFlag('info',
        abbr: 'i',
        defaultsTo: false,
        callback: (v) => v ? logLevel = Level.info1 : false,
        help: 'mode is set to "info"')
    ..addFlag('debug',
        abbr: 'd',
        defaultsTo: false,
        callback: (v) => v ? logLevel = Level.debug : false,
        help: 'mode is set to "debug"')
    ..addFlag('verbose',
        abbr: 'v',
        defaultsTo: false,
        callback: (v) => v ? logLevel = Level.all : false,
        help: 'mode is set to "all"')
    // Usage option
    ..addFlag('help',
        abbr: 'h',
        defaultsTo: false,
        callback: (v) => v ? showHelp = true : showHelp = false,
        help: 'prints some helpful information about this program');

  @override
  String toString() => '$runtimeType: $argResults';

  static JobArgs parse(List<String> args) => new JobArgs(args);

  static List<String> makeJobArgs(String dir,
          [String logPath = './logger.log',
          String summary = 'summary.txt',
          String outDir = '.',
          String shortMsgEvery = '1000',
          String logMsgEvery = '10000',
          Level baseLevel,
          Level errorLevel]) =>
      ['$dir', '-f $logPath', '-r ./results.txt', 'Level=$baseLevel'];
}
