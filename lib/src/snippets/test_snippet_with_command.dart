// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:recase/recase.dart';

/// The snippet for the test file
String testSnippetWithCommand({required String packageName}) {
  final packageNamePascalCase = packageName.pascalCase;
  final packageNameCamelCase = packageName.camelCase;
  final packageNameSnakeCase = packageName.snakeCase;

  return '''
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:gg_capture_print/gg_capture_print.dart';
import 'package:$packageNameSnakeCase/$packageNameSnakeCase.dart';
import 'package:path/path.dart';
import 'package:recase/recase.dart';
import 'package:test/test.dart';
import 'package:gg_args/gg_args.dart';

void main() {
  final messages = <String>[];

  setUp(() {
    messages.clear();
  });

  group('$packageNamePascalCase()', () {

    // #########################################################################
    group('$packageNamePascalCase', () {
      final $packageNameCamelCase = $packageNamePascalCase(ggLog: messages.add);

      final CommandRunner<void> runner = CommandRunner<void>(
        '$packageNameCamelCase',
        'Description goes here.',
      )..addCommand($packageNameCamelCase);

      test('should allow to run the code from command line', () async {
        await capturePrint(
          ggLog: messages.add,
          code: () async =>
              await runner.run(['$packageNameCamelCase', 'my-command', '--input', 'foo']),
        );
        expect(messages, contains('Running my-command with param foo'));
      });

      // .......................................................................
      test('should show all sub commands', () async {
        final (subCommands, errorMessage) = await missingSubCommands(
          directory: Directory('lib/src/commands'),
          command: $packageNameCamelCase,
        );

        expect(subCommands, isEmpty, reason: errorMessage);
      });
    });
  });
}

'''
      .trim();
}
