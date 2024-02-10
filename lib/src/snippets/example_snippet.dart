// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:recase/recase.dart';

/// The snippet for the example file
String exampleSnippet({required String packageName}) {
  final packageNamePascalCase = packageName.pascalCase;
  final packageNameCamelCase = packageName.camelCase;
  final packageNameSnakeCase = packageName.snakeCase;

  return '''
import 'package:$packageNameSnakeCase/$packageNameSnakeCase.dart';

Future<void> main() async {
  const param = 'foo';

  final $packageNameCamelCase = $packageNamePascalCase(
    param: param,
    log: (msg) {},
  );

  print('Executing with param \$param');
  await $packageNameCamelCase.exec();

  print('Done.');
}
'''
      .trim();
}
