// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:recase/recase.dart';

/// The snippet for the test file
String testDart({required String packageName}) {
  final packageNamePascalCase = packageName.pascalCase;
  final packageNameCamelCase = packageName.camelCase;
  final packageNameSnakeCase = packageName.snakeCase;

  return '''
import 'package:args/command_runner.dart';
import 'package:$packageNameSnakeCase/$packageNameSnakeCase.dart';
import 'package:test/test.dart';

void main() {
  final messages = <String>[];

  group('$packageNamePascalCase()', () {
    // #########################################################################
    group('exec()', () {
      test(
          'description of the test ', () async {
        final $packageNameCamelCase =
            $packageNamePascalCase(param: 'foo', log: (msg) => messages.add(msg));

        await $packageNameCamelCase.exec();
      });
    });

    // #########################################################################
    group('Command', () {
      test('should allow to run the code from command line',
          () async {
        final $packageNameCamelCase =
            ${packageNamePascalCase}Cmd(log: (msg) => messages.add(msg));

        final CommandRunner<void> runner = CommandRunner<void>(
          '$packageNameCamelCase',
          'Description goes here.',
        )..addCommand($packageNameCamelCase);

        await runner.run(['$packageNameCamelCase', '--param', 'foo']);
      });
    });
  });
}

'''
      .trim();
}
