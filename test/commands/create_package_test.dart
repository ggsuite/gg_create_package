// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:gg_console_colors/gg_console_colors.dart';
import 'package:gg_create_package/src/commands/create_package.dart';
import 'package:gg_create_package/src/snippets/file_header_snippet.dart';
import 'package:gg_create_package/src/snippets/install_snippet.dart';
import 'package:gg_create_package/src/snippets/open_source_licence_snippet.dart';
import 'package:gg_create_package/src/snippets/private_license_snippet.dart';
import 'package:gg_create_package/src/tools/is_github_action.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

String ps = Platform.pathSeparator;

void main() {
  final tempDir =
      Directory('/tmp').existsSync() ? Directory('/tmp') : Directory.systemTemp;
  final logMessages = <String>[];
  const String description = 'This is a description of the package. '
      'It should be at least 60 characters long.';

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
  )..addCommand(CreatePackage(ggLog: logMessages.add));

  // ...........................................................................

  group('gg_create_package', () {
    group('should create', () {
      group('full', () {
        test('private package with CLI',
            timeout: const Timeout(Duration(minutes: 2)), () async {
          // Create a temporary directory
          final tempPackageDir = Directory(join(tempDir.path, 'aud_test'));

          // Create the package directory
          tempPackageDir.createSync();

          // Add some sample content into the directory
          File(join(tempPackageDir.path, 'sample.txt')).writeAsStringSync(
            'This is a sample file.',
          );
          Directory(join(tempPackageDir.path, 'sample_dir')).createSync();
          File(join(tempPackageDir.path, 'sample_dir', 'sample.txt'))
              .writeAsStringSync('This is a sample file.');

          // Expect does not throw exception because --force is given
          try {
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
          } catch (e) {
            print(
              blue(
                'Please open "${yellow(tempPackageDir.path)}" '
                'in visual studio code '
                'to analyze the errors in detail.',
              ),
            );
            rethrow;
          }

          // The package should exist
          expect(tempPackageDir.existsSync(), true);

          // The package should contain a lib directory
          expect(
            Directory(join(tempPackageDir.path, 'lib')).existsSync(),
            true,
          );

          // The package should contain a test directory
          expect(
            Directory(join(tempPackageDir.path, 'test')).existsSync(),
            true,
          );

          // The package should contain a pubspec.yaml file
          expect(
            File(join(tempPackageDir.path, 'pubspec.yaml')).existsSync(),
            true,
          );

          // The package should contain a .gitignore file
          expect(
            File(join(tempPackageDir.path, '.gitignore')).existsSync(),
            true,
          );

          // The package should contain a .vscode directory
          expect(
            Directory(join(tempPackageDir.path, '.vscode')).existsSync(),
            true,
          );

          // .....................................................
          // The package should contain a .vscode/launch.json file
          expect(
            File(join(tempPackageDir.path, '.vscode', 'launch.json'))
                .existsSync(),
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
            File(join(tempPackageDir.path, '.vscode', 'tasks.json'))
                .existsSync(),
            true,
          );

          // The package should contain a .vscode/extensions.json file
          expect(
            File(join(tempPackageDir.path, '.vscode', 'extensions.json'))
                .existsSync(),
            true,
          );

          // .....................................................
          // The package should contain a test testing .launch.json file
          final launchJsonTestFile = File(
            join(
              tempPackageDir.path,
              'test',
              'vscode',
              'launch_json_test.dart',
            ),
          );

          expect(
            launchJsonTestFile.existsSync(),
            true,
          );

          final launchJsonTestFileContent =
              launchJsonTestFile.readAsStringSync();
          expect(launchJsonTestFileContent, contains('bin/aud_test.dart'));

          // .......................................................
          // The package should contain a analysis_options.yaml file
          expect(
            File(join(tempPackageDir.path, 'analysis_options.yaml'))
                .existsSync(),
            true,
          );

          // ............................................
          // The package should contain a .gitignore file
          expect(
            File(join(tempPackageDir.path, '.gitignore')).existsSync(),
            true,
          );

          // .............................................
          // The package should contain a private LICENSE file
          // because it is not open source
          expect(
            File(join(tempPackageDir.path, 'LICENSE')).readAsStringSync(),
            privateLicenceSnippet,
          );

          // ...............................
          // Github actions should be copied
          final gitHubAction = File(
            join(tempPackageDir.path, '.github/workflows/pipeline.yaml'),
          );
          expect(gitHubAction.existsSync(), isTrue);

          // ..........................
          // Should update pubspec.yaml

          // Write repository
          final pubspec = File(join(tempPackageDir.path, 'pubspec.yaml'))
              .readAsStringSync();
          final pattern = RegExp(
            r'^repository: https://github.com/inlavigo/aud_test.git$',
            multiLine: true,
          );
          expect(pubspec.contains(pattern), isTrue);

          // Add »publish_to: none« to pubspec.yaml
          expect(pubspec.contains('\npublish_to: none\n'), isTrue);

          // ..............................
          // Should prepare launch.json
          final launchJson =
              File(join(tempPackageDir.path, '.vscode', 'launch.json'))
                  .readAsStringSync();

          expect(launchJson, contains(r'"name": "aud_test.dart"'));
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
          final changeLog = File(join(tempPackageDir.path, 'CHANGELOG.md'))
              .readAsStringSync();
          expect(
            changeLog,
            '# Changelog\n\n## Unreleased\n\n### Added\n\n- Initial '
            'boilerplate.\n',
          );

          // .......................................
          // Should init executable in bin directory
          final binFile =
              File(join(tempPackageDir.path, 'bin', 'aud_test.dart'));
          expect(binFile.existsSync(), isTrue);
          final binFileContent = binFile.readAsStringSync();
          expect(binFileContent, startsWith('#!/usr/bin/env dart\n'));
          expect(binFileContent, contains(fileHeaderSnippet));
          expect(
            binFileContent,
            contains('import \'package:aud_test/aud_test.dart\';'),
          );
          expect(binFileContent, contains('Future<void> run({'));
          expect(binFileContent, contains('command: AudTest(ggLog: ggLog),'));

          // ..............................
          // Should create a install script
          final installScript =
              File(join(tempPackageDir.path, 'install')).readAsStringSync();
          expect(
            installScript,
            contains(installSnippet),
          );

          // ...........................
          // Should delete aud_test_base
          final audTestBaseFile = File(
            join(tempPackageDir.path, 'lib', 'src', 'aud_test_base.dart'),
          );
          expect(audTestBaseFile.existsSync(), isFalse);

          // .........................................
          // Should create test/bin/aud_test_test.dart
          final testFile = File(
            join(tempPackageDir.path, 'test', 'bin', 'aud_test_test.dart'),
          );
          expect(testFile.existsSync(), isTrue);

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
              contains('${green('code ${tempPackageDir.path}')}\n'),
            );

            expect(
              logMessages,
              contains('To push the project to GitHub, call'),
            );

            expect(
              logMessages,
              contains('${green('git push -u origin main')}\n'),
            );
          }
        });

        test('open source package with CLI',
            timeout: const Timeout(Duration(minutes: 2)), () async {
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
          // because it is open source
          expect(
            File(join(tempPackageDir.path, 'LICENSE')).readAsStringSync(),
            openSourceLicenseSnippet,
          );

          // Do not add »publish_to: none« to pubspec.yaml
          final pubspec = await File(join(tempPackageDir.path, 'pubspec.yaml'))
              .readAsString();
          expect(pubspec.contains('publish_to: none'), isFalse);
        });
      });

      group('package without CLI and example', () {
        test('when options --no-cli and --no-example are provided', () async {
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
            '--no-cli',
            '--no-example',
          ]);

          // The package should exist
          expect(tempPackageDir.existsSync(), true);

          // The package contains an pubspec.yaml file
          expect(
            await File(join(tempPackageDir.path, 'pubspec.yaml')).exists(),
            true,
          );

          // The package should not contain an example folder
          expect(
            Directory(join(tempPackageDir.path, 'example')).existsSync(),
            false,
          );

          // The package should not contain an bin folder
          expect(
            Directory(join(tempPackageDir.path, 'example')).existsSync(),
            false,
          );

          // The package should not contain an example folder
          expect(
            Directory(join(tempPackageDir.path, 'example')).existsSync(),
            false,
          );
        });
      });

      group('package with flutter', () {
        test('when options --flutter are provided', () async {
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
            '--flutter',
            '--no-cli',
            '--no-example',
            '--no-prepare-github',
          ]);

          // The package should exist
          expect(tempPackageDir.existsSync(), true);

          // The package contains an pubspec.yaml file
          expect(
            await File(join(tempPackageDir.path, 'pubspec.yaml')).exists(),
            true,
          );

          // Pubspec.yaml should contain the flutter dependency
          final pubspec = await File(join(tempPackageDir.path, 'pubspec.yaml'))
              .readAsString();
          expect(pubspec.contains('  flutter: \''), isTrue);
          expect(pubspec.contains('sdk: flutter'), isTrue);
          expect(pubspec.contains('flutter_test:'), isTrue);

          // Test files should import the flutter_test package
          final testFile = File(
            join(tempPackageDir.path, 'test', 'gg_test_test.dart'),
          );
          expect(testFile.existsSync(), isTrue);
          final testFileContent = testFile.readAsStringSync();
          expect(testFileContent, contains('import \'package:flutter_test/'));
        });
      });

      group('package without prefix', () {
        test('when option --no-prefix is provided', () async {
          // Expect does not throw exception
          await r.run([
            'cp',
            '-o',
            tempDir.path,
            '-n',
            'test',
            '--open-source',
            '-d',
            description,
            '--no-prepare-github',
            '--dry-run',
            '--no-enforce-prefix',
          ]);
        });
      });
    });

    group('should throw', () {
      test('when target directory does not exist', () async {
        // Expect throws exception
        await expectLater(
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
              'Exception: The directory "some unknown directory" does not '
                  'exist.',
            ),
          ),
        );
      });

      test('when description is less then 60 characters', () {
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

      test('when the package directory already exists', () {
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
              'Exception: The directory "${tempDir.path}${ps}aud_test" already '
                  'exists.',
            ),
          ),
        );
      });

      test('when is not open source and the name not starts with "aud_"', () {
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

      test('when open source and the name not starts with "gg_"', () {
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
    });
  });
}
