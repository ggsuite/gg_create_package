// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:gg_cli_cp/src/commands/create_package.dart';
import 'package:gg_cli_cp/src/snippets/file_header_snippet.dart';
import 'package:gg_cli_cp/src/snippets/open_source_licence_snippet.dart';
import 'package:gg_cli_cp/src/snippets/private_license_snippet.dart';
import 'package:gg_cli_cp/src/tools/color.dart';
import 'package:gg_cli_cp/src/tools/is_github_action.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  final tempDir =
      Directory('/tmp').existsSync() ? Directory('/tmp') : Directory.systemTemp;
  final logMessages = <String>[];
  const String description = 'This is a description of the package. '
      'It should be at least 60 characters long.';

  void log(String message) {
    logMessages.add(message);
  }

  // ...........................................................................
  setUp(() {
    logMessages.clear();
    final audTestDir = Directory(join(tempDir.path, 'aud_test'));
    if (audTestDir.existsSync()) {
      audTestDir.deleteSync(recursive: true);
    }

    final ggTestDir = Directory(join(tempDir.path, 'gg_test'));
    if (ggTestDir.existsSync()) {
      ggTestDir.deleteSync(recursive: true);
    }
  });

  // ...........................................................................
  final r = CommandRunner<dynamic>(
    'aud',
    'Our cli to manage many tasks about audanika software development.',
  )..addCommand(CreatePackage(log: log));

  // ...........................................................................

  group('cp', () {
    // #########################################################################
    test('should throw when target directory does not exist', () async {
      // Expect throws exception
      expectLater(
        r.run([
          'cp',
          '-o',
          'some unknown directory',
          '-n',
          'aud_test',
          '-d',
          description,
          '--no-prepare-github',
        ]),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            'Exception: The directory "some unknown directory" does not exist.',
          ),
        ),
      );
    });

    // #########################################################################
    test('should throw when description is less then 60 characters', () {
      // Expect throws exception
      expectLater(
        r.run([
          'cp',
          '-o',
          tempDir.path,
          '-n',
          'aud_test',
          '-d',
          'This description is less then 60 chars.',
          '--no-prepare-github',
        ]),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            'Exception: The description must be at least 60 characters long.',
          ),
        ),
      );
    });

    // #########################################################################
    test('should throw when the package directory already exists', () {
      // Create a temporary directory
      final tempPackageDir = Directory(join(tempDir.path, 'aud_test'));

      // Create the package directory
      tempPackageDir.createSync();

      // Expect throws exception
      expect(
        r.run([
          'cp',
          '-o',
          tempDir.path,
          '-n',
          'aud_test',
          '-d',
          description,
          '--no-prepare-github',
        ]),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            'Exception: The directory "${tempDir.path}/aud_test" already '
                'exists.',
          ),
        ),
      );
    });

    // #########################################################################
    test(
        'should throw when the package is not open source '
        'and the name does not start with "aud_"', () {
      // Expect throws exception
      expect(
        r.run([
          'cp',
          '-o',
          tempDir.path,
          '-n',
          'xyz_test',
          '--no-open-source',
          '-d',
          '--no-prepare-github',
          description,
        ]),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            'Exception: Non open source packages should start with "aud_"',
          ),
        ),
      );
    });

    // #########################################################################
    test(
        'should throw when the package is open source '
        'and the name does not start with "gg_"', () {
      // Expect throws exception
      expect(
        r.run([
          'cp',
          '-o',
          tempDir.path,
          '-n',
          'xyz_test',
          '--open-source',
          '-d',
          '--no-prepare-github',
          description,
        ]),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            'Exception: Open source packages should start with "gg_"',
          ),
        ),
      );
    });

    // #########################################################################
    test('should create a private dart package', () async {
      // Create a temporary directory
      final tempPackageDir = Directory(join(tempDir.path, 'aud_test'));

      // Create the package directory
      tempPackageDir.createSync();

      // Expect does not throw exception because --force is given
      await r.run([
        'cp',
        '-o',
        tempDir.path,
        '-n',
        'aud_test',
        '-d',
        description,
        '--prepare-github',
        '--force',
      ]);

      // The package should exist
      expect(tempPackageDir.existsSync(), true);

      // The package should contain a lib directory
      expect(Directory(join(tempPackageDir.path, 'lib')).existsSync(), true);

      // The package should contain a test directory
      expect(Directory(join(tempPackageDir.path, 'test')).existsSync(), true);

      // The package should contain a pubspec.yaml file
      expect(
        File(join(tempPackageDir.path, 'pubspec.yaml')).existsSync(),
        true,
      );

      // The package should contain a .gitignore file
      expect(File(join(tempPackageDir.path, '.gitignore')).existsSync(), true);

      // The package should contain a .vscode directory
      expect(
        Directory(join(tempPackageDir.path, '.vscode')).existsSync(),
        true,
      );

      // .....................................................
      // The package should contain a .vscode/launch.json file
      expect(
        File(join(tempPackageDir.path, '.vscode', 'launch.json')).existsSync(),
        true,
      );

      // The package should contain a .vscode/settings.json file
      expect(
        File(join(tempPackageDir.path, '.vscode', 'settings.json'))
            .existsSync(),
        true,
      );

      // The package should contain a .vscode/tasks.json file
      expect(
        File(join(tempPackageDir.path, '.vscode', 'tasks.json')).existsSync(),
        true,
      );

      // The package should contain a .vscode/extensions.json file
      expect(
        File(join(tempPackageDir.path, '.vscode', 'extensions.json'))
            .existsSync(),
        true,
      );

      // .......................................................
      // The package should contain a analysis_options.yaml file
      expect(
        File(join(tempPackageDir.path, 'analysis_options.yaml')).existsSync(),
        true,
      );

      // ............................................
      // The package should contain a .gitignore file
      expect(File(join(tempPackageDir.path, '.gitignore')).existsSync(), true);

      // .............................................
      // The package should contain a private LICENSE file
      // because it is not open source
      expect(
        File(join(tempPackageDir.path, 'LICENSE')).readAsStringSync(),
        privateLicenceSnippet,
      );

      // .................................
      // Package should contain the checks
      final checkFiles = [
        'check',
        'check.yaml',
      ];

      for (final checkFile in checkFiles) {
        expect(File(join(tempPackageDir.path, checkFile)).existsSync(), true);
      }

      // ...............................
      // Github actions should be copied
      final gitHubAction =
          File(join(tempPackageDir.path, '.github/workflows/pipeline.yaml'));
      expect(gitHubAction.existsSync(), isTrue);

      // ..........................
      // Should update pubspec.yaml

      // Write repository
      final pubspec =
          File(join(tempPackageDir.path, 'pubspec.yaml')).readAsStringSync();
      final pattern = RegExp(
        r'^repository: https://github.com/inlavigo/aud_test$',
        multiLine: true,
      );
      expect(pubspec.contains(pattern), isTrue);

      // Should add gg command line to repo
      expect(pubspec, contains(RegExp(r'gg:')));
      expect(pubspec, contains('git: https://github.com/inlavigo/gg.git'));

      // ..............................
      // Should prepare launch.json
      final launchJson =
          File(join(tempPackageDir.path, '.vscode', 'launch.json'))
              .readAsStringSync();

      expect(launchJson, contains(r'"name": "Run AudTest"'));
      expect(
        launchJson,
        contains(r'"program": "${workspaceFolder}/bin/aud_test.dart"'),
      );
      expect(
        launchJson,
        contains(r'"program": "${workspaceFolder}/bin/aud_test.dart"'),
      );

      // ....................
      // Should update README
      final readme =
          File(join(tempPackageDir.path, 'README.md')).readAsStringSync();

      expect(
          readme,
          '# aud_test\n\nThis is a description of the package. '
          'It should be at least 60 characters long.\n');

      // ......................
      // Should init change log
      final changeLog =
          File(join(tempPackageDir.path, 'CHANGELOG.md')).readAsStringSync();
      expect(changeLog, '# Change Log\n\n## 1.0.0\n\n- Initial version.\n');

      // .......................................
      // Should init executable in bin directory
      final binFile = File(join(tempPackageDir.path, 'bin', 'aud_test.dart'));
      expect(binFile.existsSync(), isTrue);
      final binFileContent = binFile.readAsStringSync();
      expect(binFileContent, startsWith('#!/usr/bin/env dart\n'));
      expect(binFileContent, contains(fileHeaderSnippet));
      expect(
        binFileContent,
        contains('import \'package:aud_test/aud_test.dart\';'),
      );
      expect(binFileContent, contains('Future<void> runAudTest({'));
      expect(binFileContent, contains('addCommand(AudTestCmd(log: log)'));

      // ..............................
      // Should create a install script
      final installScript =
          File(join(tempPackageDir.path, 'install.dart')).readAsStringSync();
      expect(
        installScript,
        contains('const exe = \'audTest\';'),
      );

      // ...........................
      // Should delete aud_test_base
      final audTestBaseFile =
          File(join(tempPackageDir.path, 'lib', 'src', 'aud_test_base.dart'));
      expect(audTestBaseFile.existsSync(), isFalse);

      // ...............
      // Should init git
      if (!isGitHubAction) {
        final gitDir = Directory(join(tempPackageDir.path, '.git'));
        expect(gitDir.existsSync(), isTrue);

        final result = Process.runSync(
          'git',
          ['status'],
          workingDirectory: tempPackageDir.path,
        );
        expect(
          result.stdout,
          contains('nothing to commit, working tree clean'),
        );

        expect(
          logMessages,
          contains(
            '\nSuccess! To open the project with visual studio code, call ',
          ),
        );

        expect(
          logMessages,
          contains('${greenStart}code ${tempPackageDir.path}$end\n'),
        );

        expect(
          logMessages,
          contains('To push the project to GitHub, call'),
        );

        expect(
          logMessages,
          contains('${greenStart}git push -u origin main$end\n'),
        );
      }
    });

    // #########################################################################
    test('should create open source dart package', () async {
      // Create a temporary directory
      final tempPackageDir = Directory(join(tempDir.path, 'gg_test'));

      // Expect does not throw exception
      await r.run([
        'cp',
        '-o',
        tempDir.path,
        '-n',
        'gg_test',
        '--open-source',
        '-d',
        description,
        '--no-prepare-github',
      ]);

      // The package should exist
      expect(tempPackageDir.existsSync(), true);

      // .............................................
      // The package should contain an open source LICENSE file
      // because it is not open source
      expect(
        File(join(tempPackageDir.path, 'LICENSE')).readAsStringSync(),
        openSourceLicenseSnippet,
      );
    });
  });
}
