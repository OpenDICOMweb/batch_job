//  Copyright (c) 2016, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//
import 'package:batch_job/batch_job.dart';
import 'package:core/core.dart' hide group;
import 'package:test/test.dart';

//Urgent: implement test of JobArgParser

void main() {
  const args0 = <String>['foo/bar -o foo/bar/output/ -d'];

  group('Test Job ArgParser', () {
    const inputDir = 'foo/bar/';

    test('basic test input dir and defaults', () {
      final args = JobArgs(['foo/bar/']);
      expect(args.shortMsgInterval == 1000, true);
      expect(args.longMsgInterval == 10000, true);
      expect(args.argResults.rest[0], equals(inputDir));
    });

    test('test default message intervals', () {
      const input = 'foo/bar/bas/';
      final jArgs = JobArgs([input]);
      expect(jArgs.shortMsgInterval == 1000, true);
      expect(jArgs.longMsgInterval == 10000, true);
      expect(jArgs.inputDir == input, true);
    });

    test('test message intervals', () {
      const inputDir = 'foo/bar/bas/';
      final args = JobArgs(['-m', '10:100', inputDir]);
      expect(args.shortMsgInterval == 10, true);
      expect(args.longMsgInterval == 100, true);
      expect(args.inputDir == inputDir, true);
    });

    test('test output directory', () {
      const outdir = 'foo/bar/output/';
      final args = JobArgs(['-o', outdir, '-d', 'foo/bar']);
      expect(args.outputDir, equals(outdir));
      expect(args.logLevel, equals(Level.debug));
      expect(args.argResults.rest[0], equals('foo/bar'));
    });

    test('test Arg0', () {
      const outdir = 'foo/bar/output/';
      final args = JobArgs(args0);
      expect(args.outputDir, equals(outdir));
      expect(args.logLevel, equals(Level.debug));
      expect(args.argResults.rest[0], equals('foo/bar'));
    });
  });
}
