// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:recase/recase.dart';

/// The snippet for the source file
String srcSnippetWithoutCommand({required String packageName}) {
  final packageNamePascalCase = packageName.pascalCase;

  return '''
/// The main class of the package
class $packageNamePascalCase {
  /// Constructor
  const $packageNamePascalCase();

  /// A sample method
  String foo() => 'foo';
}
''';
}
