// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// ignore_for_file: public_member_api_docs

// Create variables for the most used console colors
const String redStart = '\x1B[31m';
const String end = '\x1B[0m';
const String greenStart = '\x1B[32m';
const String yellowStart = '\x1B[33m';
const String blueStart = '\x1B[34m';
const String magentaStart = '\x1B[35m';
const String cyanStart = '\x1B[36m';
const String whiteStart = '\x1B[37m';
const String grayStart = '\x1B[90m';
const String brightRedStart = '\x1B[91m';
const String brightGreenStart = '\x1B[92m';
const String brightYellowStart = '\x1B[93m';
const String brightBlueStart = '\x1B[94m';
const String brightMagentaStart = '\x1B[95m';
const String brightCyanStart = '\x1B[96m';
const String brightWhiteStart = '\x1B[97m';
const String brightGrayStart = '\x1B[37m';
const String brightBlackStart = '\x1B[30m';
const String brightDefaultStart = '\x1B[39m';

/// Colorize a text with a given color
String colorize(String text, String start) {
  return start + text + end;
}
