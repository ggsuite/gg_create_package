#!/usr/bin/env dart
// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:args/command_runner.dart';
import 'package:aud_cli_create_dart_package/create_dart_package.dart';
import 'package:colorize/colorize.dart';

// #############################################################################
Future<void> main(List<String> arguments) async {
  try {
    final r = CommandRunner<dynamic>(
      'aud',
      'Our cli to manage many tasks about audanika software development.',
    )..addCommand(CreateDartPackage(log: print));

    await r.run(arguments);
  } catch (e) {
    final msg = e.toString().replaceAll('Exception: ', '');
    print(Colorize(msg).red());
  }
}
