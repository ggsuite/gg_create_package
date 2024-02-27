// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:recase/recase.dart';

/// The snippet for the example file
String exampleSnippet({required String packageName}) {
  final packageNameCamelCase = packageName.camelCase;

  return '''
Future<void> main() async {
  print('Look into tests, to see $packageNameCamelCase in action.');
}

'''
      .trim();
}
