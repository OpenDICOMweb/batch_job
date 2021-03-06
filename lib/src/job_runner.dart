//  Copyright (c) 2016, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//
import 'dart:async' hide Timer;
import 'dart:io';

import 'package:core/core.dart';
import 'package:io_extended/io_extended.dart';

import 'package:batch_job/src/job_args.dart';
import 'package:batch_job/src/job_reporter.dart';

// ignore_for_file: avoid_catches_without_on_clauses

// **** change this name when testing
const String defaultDirName = 'C:/acr/odw/test_data/6684';

/// Get target directory and validate it.
Directory getDirectory(JobArgs args) {
  String dirName;
  if (args.length == 0) {
    stderr
        .write('No Directory name supplied - defaulting to $defaultDirName\n');
    dirName = defaultDirName;
  } else {
    dirName = args.argResults.arguments[0];
  }

  final dir = pathToDirectory(dirName);
  if (dir == null) {
    if (dirName[0] == '-') {
      stderr.write('Error: Missing directory argument - "$dir"');
    } else {
      stderr.write('Error: $dirName does not exist');
    }
    exit(-1);
  }
  return dir;
}

JobReporter getJobReporter(int fileCount, String path, int interval) =>
    JobReporter(fileCount, from: path, short: interval);

typedef DoFile = Future<bool> Function(File f);

class JobRunner {
  static const int defaultInterval = 1;
  Directory directory;
  List files;
  DoFile doFile;
  JobReporter reporter;
  List<String> failures = <String>[];
  //TODO: figure out the best way to handle this.
  bool throwOnError;

  factory JobRunner(JobArgs jobArgs, DoFile doFile,
      {int interval = defaultInterval,
      Level level = Level.info0,
      bool throwOnError = true}) {
    final dir = getDirectory(jobArgs);
    final reporter = getJobReporter(fileCount(dir), dir.path, interval);
    return JobRunner._(dir, null, doFile, reporter,
        level: level, throwOnError: throwOnError);
  }

  factory JobRunner.list(List<File> files, DoFile doFile,
      {int interval = defaultInterval,
      Level level = Level.info0,
      bool throwOnError = true}) {
    final reporter = getJobReporter(files.length, 'FileList', interval);
    return JobRunner._(null, files, doFile, reporter,
        level: level, throwOnError: throwOnError);
  }

  JobRunner._(this.directory, this.files, this.doFile, this.reporter,
      {Level level = Level.info0, this.throwOnError = true}) {
    global.log.level = level;
    _greeting();
  }

  Future<void> run() async {
    reporter.startReport;
    await walkDirectoryFiles(directory, runFile);
    reporter.endReport;
  }

  Future<void> runList() async {
    reporter.startReport;
    await walkPathList(files, runFile);
    reporter.endReport;
  }

  Future<String> runFile(File f, [int indent]) async {
    final path = cleanPath(f.path);
    bool success;
    try {
      success = await doFile(f);
      if (!success) failures.add(path);
    } catch (e) {
      if (throwOnError) rethrow;
    }
    return reporter.report(path, wasSuccessful: success);
  }

  static void _greeting() => stdout.writeln('Job Runner:');

  static void job(JobArgs jobArgs, DoFile doFile,
          {int interval, Level level = Level.info, bool throwOnError = true}) =>
      JobRunner(jobArgs, doFile, interval: interval)..run();

  static void fileList(List<File> files, DoFile doFile,
          {int interval,
          Level level = Level.debug,
          bool throwOnError = true}) =>
      JobRunner.list(files, doFile, interval: interval)..runList();
}
