// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:recase/recase.dart';

/// The snippet for the test file
String testSnippet({required String packageName}) {
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

void main() {
  final messages = <String>[];

  setUp(() {
    messages.clear();
  });

  group('$packageNamePascalCase()', () {
    // #########################################################################
    group('exec()', () {
      test('description of the test ', () async {
        final $packageNameCamelCase = $packageNamePascalCase(param: 'foo', log: (msg) => messages.add(msg));

        await $packageNameCamelCase.exec();
      });
    });

    // #########################################################################
    group('$packageNamePascalCase', () {
      final $packageNameCamelCase = ${packageNamePascalCase}Cmd(log: (msg) => messages.add(msg));

      final CommandRunner<void> runner = CommandRunner<void>(
        '$packageNameCamelCase',
        'Description goes here.',
      )..addCommand($packageNameCamelCase);

      test('should allow to run the code from command line', () async {
        await capturePrint(
          log: messages.add,
          code: () async =>
              await runner.run(['$packageNameCamelCase', 'my-command', '--input', 'foo']),
        );
        expect(messages, contains('Running my-command with param foo'));
      });

      // .......................................................................
      test('should show all sub commands', () async {
        // Iterate all files in lib/src/commands
        // and check if they are added to the command runner
        // and if they are added to the help message
        final subCommands = Directory('lib/src/commands')
            .listSync(recursive: false)
            .where(
              (file) => file.path.endsWith('.dart'),
            )
            .map(
              (e) => basename(e.path)
                  .replaceAll('.dart', '')
                  .replaceAll('_', '-')
                  .replaceAll('gg-', ''),
            )
            .toList();

        await capturePrint(
          log: messages.add,
          code: () async => await runner.run(['$packageNameCamelCase', '--help']),
        );

        for (final subCommand in subCommands) {
          final subCommandStr = '\${subCommand.pascalCase}';

          expect(
            hasLog(messages, subCommand),
            isTrue,
            reason: '\\nMissing subcommand "\$subCommandStr"\\n'
                'Please open  "lib/src/$packageNameSnakeCase.dart" and add\\n'
                '"addSubcommand(\$subCommandStr(log: log));',
          );
        }
      });
    });
  });
}

'''
      .trim();
}
