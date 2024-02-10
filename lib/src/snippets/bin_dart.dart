// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:recase/recase.dart';

/// The snippet for the bin/dart file
String binDart({
  required String packageName,
  required String description,
}) {
  final packageNameSnakeCase = packageName.snakeCase;
  final packageNamePascalCase = packageName.pascalCase;

  var descriptionMultiLine =
      (description.split('.')..removeWhere((String e) => e.trim().isEmpty));

  description =
      descriptionMultiLine.map((String e) => '\'${e.trim()}. \'').join('\n');

  return '''

import 'package:args/command_runner.dart';
import 'package:colorize/colorize.dart';
import 'package:$packageNameSnakeCase/$packageNameSnakeCase.dart';

// .............................................................................
Future<void> run$packageNamePascalCase({
  required List<String> args,
  required void Function(String msg) log,
}) async {
  try {
    // Create a command runner
    final CommandRunner<void> runner = CommandRunner<void>(
      '$packageNamePascalCase',
       $description,
    )..addCommand(${packageNamePascalCase}Cmd(log: log));

    // Run the command
    await runner.run(args);
  }

  // Print errors in red
  catch (e) {
    final msg = e.toString().replaceAll('Exception: ', '');
    log(Colorize(msg).red().toString());
    log('Error: \$e');
  }
}

// .............................................................................
Future<void> main(List<String> args) async {
  await run$packageNamePascalCase(
    args: args,
    log: (msg) => print(msg),
  );
}'''
      .trim();
}
