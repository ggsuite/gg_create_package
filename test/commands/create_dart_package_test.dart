// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:aud_cli_create_dart_package/src/commands/create_dart_package.dart';
import 'package:aud_cli_create_dart_package/src/snippets.dart';
import 'package:aud_cli_create_dart_package/src/tools.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  final tempDir = Directory.systemTemp; // Directory('/tmp');
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
  )..addCommand(CreateDartPackage(log: log));

  // ...........................................................................

  group('CreateDartPackage', () {
    // #########################################################################
    test('should throw when target directory does not exist', () async {
      // Expect throws exception
      expectLater(
        r.run([
          'createDartPackage',
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
          'createDartPackage',
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
          'createDartPackage',
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
          'createDartPackage',
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
          'createDartPackage',
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
        'createDartPackage',
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
        privateLicence,
      );

      // .................................
      // Package should contain the checks
      final checkFiles = [
        'check',
        'check.yaml',
        'check_pana.dart',
        'check.dart',
        'check_coverage.dart',
      ];

      for (final checkFile in checkFiles) {
        expect(File(join(tempPackageDir.path, checkFile)).existsSync(), true);
      }

      // ...............................
      // Github actions should be copied
      final gitHubAction =
          File(join(tempPackageDir.path, '.github/workflows/check.yaml'));
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

      // Should add comment to aud_test_base.dart
      final audTestBase =
          File(join(tempPackageDir.path, 'lib', 'src', 'aud_test_base.dart'))
              .readAsStringSync();
      expect(audTestBase, contains(fileHeader));
      expect(audTestBase, contains(baseDartSnippet));

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
          contains('${greenStart}code ${tempPackageDir.path}$greenEnd\n'),
        );

        expect(
          logMessages,
          contains('To push the project to GitHub, call'),
        );

        expect(
          logMessages,
          contains('${greenStart}git push -u origin main$greenEnd\n'),
        );
      }
    });

    // #########################################################################
    test('should create open source dart package', () async {
      // Create a temporary directory
      final tempPackageDir = Directory(join(tempDir.path, 'gg_test'));

      // Expect does not throw exception
      await r.run([
        'createDartPackage',
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
        openSourceLicense,
      );
    });
  });
}
