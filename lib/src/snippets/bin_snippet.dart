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
String binSnippet({required String packageName, required String description}) {
  final packageNameSnakeCase = packageName.snakeCase;
  final packageNamePascalCase = packageName.pascalCase;

  var descriptionMultiLine = (description.split('.')
    ..removeWhere((String e) => e.trim().isEmpty));

  description = descriptionMultiLine
      .map((String e) => '\'${e.trim()}. \'')
      .join('\n');

  return '''
import 'package:gg_args/gg_args.dart';
import 'package:gg_log/gg_log.dart';
import 'package:$packageNameSnakeCase/$packageNameSnakeCase.dart';

// .............................................................................
Future<void> run({
  required List<String> args,
  required GgLog ggLog,
}) =>
    GgCommandRunner(
      ggLog: ggLog,
      command: $packageNamePascalCase(ggLog: ggLog),
    ).run(args: args);


// .............................................................................
Future<void> main(List<String> args) async {
  await run(
    args: args,
    ggLog: print,
  );
}'''
      .trim();
}
