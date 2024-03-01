// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:recase/recase.dart';

/// The snippet for the source file
String srcSnippet({required String packageName}) {
  final packageNameTitleCase = packageName.titleCase;
  final packageNamePascalCase = packageName.pascalCase;
  final packageNameCamelCase = packageName.camelCase;

  return '''

// #############################################################################
import 'package:args/command_runner.dart';
import './commands/my_command.dart';

/// $packageNameTitleCase
class $packageNamePascalCase {
  /// Constructor
  $packageNamePascalCase({
    required this.param,
    required this.log,
  });

  /// The param to work with
  final String param;

  /// The log function
  final void Function(String msg) log;

  /// The function to be executed
  Future<void> exec() async {
    log('Executing $packageNameCamelCase with param \$param');
  }
}

// #############################################################################
/// The command line interface for $packageNamePascalCase
class ${packageNamePascalCase}Cmd extends Command<dynamic> {
  /// Constructor
  ${packageNamePascalCase}Cmd({required this.log}) {
    addSubcommand(MyCommand(log: log));
  }

  /// The log function
  final void Function(String message) log;

  // ...........................................................................
  @override
  final name = '$packageNameCamelCase';
  @override
  final description = 'Add your description here.';
}
''';
}
