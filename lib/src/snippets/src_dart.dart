// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:recase/recase.dart';

/// The snippet for the source file
String srcDart({required String packageName}) {
  final packageNameTitleCase = packageName.titleCase;
  final packageNamePascalCase = packageName.pascalCase;
  final packageNameCamelCase = packageName.camelCase;

  return '''

// #############################################################################
import 'package:args/command_runner.dart';

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
    log('Executing $packageNamePascalCase with param \$param');
  }
}

// #############################################################################
/// The command line interface for $packageNamePascalCase
class ${packageNamePascalCase}Cmd extends Command<dynamic> {
  /// Constructor
  ${packageNamePascalCase}Cmd({required this.log}) {
    _addArgs();
  }

  /// The log function
  final void Function(String message) log;

  // ...........................................................................
  @override
  final name = '$packageNameCamelCase';
  @override
  final description = 'Add your description here.';

  // ...........................................................................
  @override
  Future<void> run() async {
    var param = argResults?['param'] as String;
    $packageNamePascalCase(
      param: param,
      log: log,
    );

    await $packageNamePascalCase(
      param: param,
      log: log,
    ).exec();
  }

  // ...........................................................................
  void _addArgs() {
    argParser.addOption(
      'param',
      abbr: 'p',
      help: 'The param to work with',
      valueHelp: 'param',
      defaultsTo: '.',
    );
  }
}
''';
}
