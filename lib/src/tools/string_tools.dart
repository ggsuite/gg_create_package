// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

/// Some nice extensions for strings
extension StringTools on String {
  /// Returns the string with first letter lower case
  String get firstLetterLowerCase => this[0].toLowerCase() + substring(1);

  /// Returns the string with first letter upper case
  String get firstLetterUpperCase => this[0].toUpperCase() + substring(1);
}
