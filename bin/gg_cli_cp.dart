#!/usr/bin/env dart
// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:args/command_runner.dart';
import 'package:gg_cli_cp/create_dart_package.dart';
import 'package:colorize/colorize.dart';

// .............................................................................
Future<void> runCreatePackage({
  required List<String> args,
  required void Function(String msg) log,
}) async {
  try {
    final cp = CreatePackage(log: log);

    // Create a command runner
    final CommandRunner<void> runner = CommandRunner<void>(
      'GgCliCp',
      cp.description,
    );

    runner.addCommand(cp);

    // Run the command
    await runner.run(args);
  }

  // Print errors in red
  catch (e) {
    final msg = e.toString().replaceAll('Exception: ', '');
    log(Colorize(msg).red().toString());
    log('Error: $e');
  }
}

// .............................................................................
Future<void> main(List<String> args) async {
  await runCreatePackage(
    args: args,
    log: (msg) => print(msg),
  );
}
