// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart';
import 'package:recase/recase.dart';

import '../snippets/bin_dart.dart';
import '../snippets/example_dart.dart';
import '../snippets/file_header.dart';
import '../snippets/launch_json.dart';
import '../snippets/lib_dart.dart';
import '../snippets/open_source_licence.dart';
import '../snippets/private_license.dart';
import '../snippets/src_dart.dart';
import '../snippets/test_dart.dart';
import '../tools.dart';

/// Creates a new package in the given directory.
class CreateDartPackage extends Command<dynamic> {
  /// The name of the package
  @override
  final name = 'createDartPackage';

  /// The description shown when running `aud help createDartPackage`.
  @override
  final description = 'Creates a new dart package for our repository';

  /// Constructor
  CreateDartPackage({
    this.log,
  }) {
    // Add the output option
    argParser.addOption(
      'output',
      abbr: 'o',
      help: 'Output directory',
      defaultsTo: '.',
    );

    // Add the package name option
    argParser.addOption(
      'name',
      abbr: 'n',
      help: 'Package name',
      mandatory: true,
    );

    // Add the package name option
    argParser.addOption(
      'description',
      abbr: 'd',
      help: 'Package description. Minimum 60 chars long.',
      mandatory: true,
    );

    // Add the isOpenSource option
    argParser.addFlag(
      'open-source',
      abbr: 's',
      help: 'Is the package open source?',
      negatable: true,
    );

    // Add the push repo option
    argParser.addFlag(
      'prepare-github',
      abbr: 'p',
      help: 'Prepares pushing the repo to GitHub.',
      negatable: true,
      defaultsTo: true,
    );

    // Force recreation
    argParser.addFlag(
      'force',
      abbr: 'f',
      help: 'Force recreation. Existing package will be deleted.',
      negatable: true,
      defaultsTo: false,
    );
  }
  // ...........................................................................
  /// The log function
  final void Function(String message)? log;

  // ...........................................................................
  /// Runs the command
  @override
  void run() async {
    // Get the output directory
    final tmp = (argResults?['output'] as String).trim();
    final outputDir = tmp == '.' ? checkoutDirectory() : tmp;

    final packageName = (argResults?['name'] as String).trim();
    final description = (argResults?['description'] as String).trim();

    var homeDirectory = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ?? // coverage:ignore-line
        ''; // coverage:ignore-line
    final isOpenSource = argResults?['open-source'] as bool;
    final pushToGitHub = argResults?['prepare-github'] as bool;
    final force = argResults?['force'] as bool;

    final updatedOutputDir = outputDir.replaceAll('~', homeDirectory);

    await _CreateDartPackage(
      outputDir: updatedOutputDir,
      packageDir: join(updatedOutputDir, packageName),
      packageName: packageName,
      description: description,
      log: log ?? (msg) {},
      isOpenSource: isOpenSource,
      prepareGitHub: pushToGitHub,
      force: force,
    ).run();
  }
}

// #############################################################################
class _CreateDartPackage {
  _CreateDartPackage({
    required this.outputDir,
    required this.packageDir,
    required this.packageName,
    required this.description,
    required this.log,
    required this.isOpenSource,
    required this.prepareGitHub,
    required this.force,
  });

  final String outputDir;
  final String packageDir;
  final String packageName;
  final String description;
  final void Function(String message) log;
  final bool isOpenSource;
  final bool prepareGitHub;
  final bool force;
  static const gitHubRepo = 'https://github.com/inlavigo';
  final formatter = DartFormatter();

  // ...........................................................................
  Future<void> run() async {
    log('\nCreate dart package...\n');

    _deleteExistingPackage();
    _checkDirectories();
    _checkPackageName();
    _checkDescription();
    await _checkGithubOrigin();
    await _createPackage();
    _copyVsCodeSettings();
    _copyGitIgnore();
    _copyAnalysisOptions();
    _copyLicense();
    _copyChecks();
    _copyGitHubActions();
    _preparePubspec();
    _prepareReadme();
    _prepareLaunchJson();
    _prepareChangeLog();
    _preapreSrc();
    _prepareLib();
    _prepareBin();
    _prepareTest();
    _prepareExample();
    _removeUnusedFiles();
    _installDevDependencies();
    _installDependencies();
    await _waitShortly();
    _fixErrorsAndWarnings();
    _initGit();
  }

  // ...........................................................................
  void _deleteExistingPackage() {
    if (!force) return;

    log('Delete existing package...');
    final packageDir = join(outputDir, packageName);
    if (Directory(packageDir).existsSync()) {
      Directory(packageDir).deleteSync(recursive: true);
    }
  }

  // ...........................................................................
  void _checkDirectories() {
    log('Check directories...');

    // Target dir exists?
    if (!Directory(outputDir).existsSync()) {
      throw Exception('The directory "$outputDir" does not exist.');
    }

    // Package already exists?
    final packageDir = join(outputDir, packageName);
    if (Directory(packageDir).existsSync()) {
      throw Exception('The directory "$packageDir" already exists.');
    }
  }

  // ...........................................................................
  void _checkPackageName() {
    log('Check package names...');
    if (isOpenSource && !packageName.startsWith('gg_')) {
      throw Exception('Open source packages should start with "gg_"');
    }

    if (!isOpenSource && !packageName.startsWith('aud_')) {
      throw Exception('Non open source packages should start with "aud_"');
    }
  }

  // ...........................................................................
  void _checkDescription() {
    log('Check description ...');
    if (description.length < 60) {
      throw Exception('The description must be at least 60 characters long.');
    }
  }

  // ...........................................................................
  Future<void> _checkGithubOrigin() async {
    if (!prepareGitHub) return;

    log('Check GitHub origin...');

    final repo = 'git@github.com:inlavigo/$packageName.git';

    final result = await Process.run(
      'git',
      ['ls-remote', repo, 'origin'],
      workingDirectory: outputDir,
    );

    // coverage:ignore-start
    if (result.exitCode == 128) {
      throw Exception(
        'The github repository "$repo" does not exist. '
        'Please visit "https://github.com/inlavigo" and create the repository.',
      );
    } else if (result.exitCode != 0) {
      throw Exception('Error while running "git ls-remote $repo origin".\n'
          'Exit code: ${result.exitCode}\n'
          'Error: ${result.stderr}\n');
    }
    // coverage:ignore-end
  }

  // ...........................................................................
  Future<void> _createPackage() async {
    log('Create package...');
    // .......................
    // Create the dart package
    final result = await Process.run(
      'dart',
      ['create', '-t', 'package', packageName, '--no-pub'],
      workingDirectory: outputDir,
    );

    // Log result
    // coverage:ignore-start
    if (result.exitCode != 0 &&
        result.stderr != null &&
        (result.stderr as String).isNotEmpty) {
      log(result.stderr as String);
    }

    if (result.exitCode != 0 &&
        result.stdout != null &&
        (result.stdout as String).isNotEmpty) {
      log(result.stdout as String);
    }
    // coverage:ignore-end
  }

  // ...........................................................................
  void _copyVsCodeSettings() {
    // Copy over VScode which are located in project/.vscode
    log('Copy VSCode settings...');

    final vscodeDir = join(audCliDirectory(), '.vscode');
    final targetVscodeDir = join(packageDir, '.vscode');
    _copyDirectory(vscodeDir, targetVscodeDir);
  }

  // ...........................................................................
  void _copyDirectory(String source, String target) {
    Directory(target).createSync(recursive: true);
    final content = Directory(source).listSync(recursive: true);
    for (var entity in content) {
      if (entity is Directory) {
        Directory(join(target, basename(entity.path)))
            .createSync(recursive: true);
      } else if (entity is File) {
        final relativePath = relative(entity.path, from: source);
        final targetPath = join(target, relativePath);

        entity.copySync(targetPath);
      }
    }
  }

  // ...........................................................................
  void _copyFile(String source, String target) {
    File(source).copySync(target);
  }

  // ...........................................................................
  void _copyGitIgnore() {
    log('Copy .gitignore...');
    _copyFile(
      join(audCliDirectory(), '.gitignore'),
      join(packageDir, '.gitignore'),
    );
  }

  // ...........................................................................
  void _copyAnalysisOptions() {
    log('Copy analysis_options.yaml...');
    _copyFile(
      join(audCliDirectory(), 'analysis_options.yaml'),
      join(packageDir, 'analysis_options.yaml'),
    );
  }

  // ...........................................................................
  void _copyLicense() {
    log('Copy LICENSE...');
    final license = (isOpenSource ? openSourceLicense : privateLicence)
        .replaceAll('YEAR', DateTime.now().year.toString());

    File(join(packageDir, 'LICENSE')).writeAsStringSync(license);
  }

  // ...........................................................................
  void _copyChecks() {
    log('Copy checks...');
    // Get all files in the aud_cli directory starting with check
    final audCliDir = audCliDirectory();
    final files = Directory(join(audCliDir))
        .listSync()
        .whereType<File>()
        .map((e) => relative(e.path, from: audCliDir));

    // Copy over file
    final checkFiles = files
        .where(
          (item) => item.startsWith('check'),
        )
        .toList();

    for (final file in checkFiles) {
      final sourceFile = File(join(audCliDir, file));
      final targetFile = join(packageDir, basename(file));
      sourceFile.copySync(targetFile);
    }
  }

  // ...........................................................................
  void _copyGitHubActions() {
    log('Copy GitHub Actions...');
    // Copy over GitHub Actions
    final githubActionsDir = join(audCliDirectory(), '.github');
    final targetGitHubActionsDir = join(packageDir, '.github');
    _copyDirectory(githubActionsDir, targetGitHubActionsDir);
  }

  // ...........................................................................
  void _replaceInFile(String file, Map<String, String> replacements) {
    var content = File(file).readAsStringSync();

    for (final entry in replacements.entries) {
      final pattern = RegExp(entry.key, multiLine: true);
      if (!pattern.hasMatch(content)) {
        // coverage:ignore-start
        throw Exception(
          'Search string "${entry.key}" not found in file "$file"',
        );
        // coverage:ignore-end
      }

      content = content.replaceAll(pattern, entry.value);
    }

    File(file).writeAsStringSync(content);
  }

  // ...........................................................................
  void _preparePubspec() {
    log('Prepare pubspec.yaml...');
    final pubspecFile = join(packageDir, 'pubspec.yaml');

    _replaceInFile(
      pubspecFile,
      {
        r'^#\srepository:.*': 'repository: $gitHubRepo/$packageName',
        r'^description:.*': 'description: $description',
        r'^# Add regular dependencies here.\n': '',
        r'  # path:': '  path:',
      },
    );
  }

  // ...........................................................................
  void _prepareReadme() {
    log('Prepare README.md...');
    final readmeFile = join(packageDir, 'README.md');
    String content = '';
    content += '# $packageName\n\n';
    content += '$description\n';
    File(readmeFile).writeAsStringSync(content);
  }

  // ...........................................................................
  void _prepareLaunchJson() {
    log('Prepare launch.json...');
    final launchJsonFile = join(packageDir, '.vscode', 'launch.json');
    final content = launchJson(packageName: packageName);
    File(launchJsonFile).writeAsStringSync(content);
  }

  // ...........................................................................
  void _prepareChangeLog() {
    log('Prepare CHANGELOG.md...');
    final changeLogFile = File(join(packageDir, 'CHANGELOG.md'));
    String content = '';
    content += '# Change Log\n\n';
    content += '## 1.0.0\n\n';
    content += '- Initial version.\n';
    changeLogFile.writeAsStringSync(content);
  }

  // ...........................................................................
  void _preapreSrc() {
    log('Prepare src ...');
    final implementationFile =
        join(packageDir, 'lib', 'src', '$packageName.dart');
    final implementationSnippet = srcDart(packageName: packageName);
    final content = formatter.format('$fileHeader\n\n$implementationSnippet\n');
    File(implementationFile).writeAsStringSync(content);
  }

  // ...........................................................................
  void _prepareBin() {
    log('Prepare bin ...');
    final binFolder = join(packageDir, 'bin');
    Directory(binFolder).createSync();
    final binFile = join(binFolder, '$packageName.dart');
    var binFileContent = binDart(
      packageName: packageName,
      description: description,
    );
    const makeExecutable = '#!/usr/bin/env dart\n';

    binFileContent = '$makeExecutable$fileHeader\n\n$binFileContent\n';
    binFileContent = formatter.format(binFileContent);

    File(binFile).writeAsStringSync(binFileContent);

    // Execute chmod +x bin/$packageName.dart
    final result = Process.runSync(
      'chmod',
      ['+x', binFile],
    );

    if (result.exitCode != 0) {
      // coverage:ignore-start
      throw Exception('Error while running "chmod +x $binFile"');
      // coverage:ignore-end
    }
  }

  // ...........................................................................
  void _prepareTest() {
    log('Prepare test folder...');
    final testFolder = join(packageDir, 'test');
    Directory(testFolder).createSync();
    final testFile = join(testFolder, '${packageName}_test.dart');
    final testFileContent = testDart(packageName: packageName);
    final content = formatter.format('$fileHeader\n\n$testFileContent\n');
    File(testFile).writeAsStringSync(content);
  }

  // ...........................................................................
  void _prepareExample() {
    log('Prepare example folder...');
    final exampleFolder = join(packageDir, 'example');
    Directory(exampleFolder).createSync();
    final exampleFile =
        join(exampleFolder, '${packageName.snakeCase}_example.dart');

    final exampleFileContent = exampleDart(packageName: packageName);
    final content = formatter.format('$fileHeader\n\n$exampleFileContent\n');
    File(exampleFile).writeAsStringSync(content);
  }

  // ...........................................................................
  void _removeUnusedFiles() {
    log('Remove unused files...');
    final packageNameSnakeCase = packageName.snakeCase;
    final files = [
      join(packageDir, 'lib', 'src', '${packageNameSnakeCase}_base.dart'),
    ];

    for (final file in files) {
      if (File(file).existsSync()) {
        File(file).deleteSync();
      }
    }
  }

  // ...........................................................................
  void _prepareLib() {
    log('Prepare lib folder...');
    final libFolder = join(packageDir, 'lib');
    final libDartFile = join(libFolder, '$packageName.dart');
    final libDartContent = libDart(packageName: packageName);
    final content = formatter.format('$fileHeader\n\n$libDartContent\n');
    File(libDartFile).writeAsStringSync(content);
  }

  // ...........................................................................
  void _installDependencies() {
    log('Install dependencies...');
    final result = Process.runSync(
      'dart',
      ['pub', 'add', 'args', 'colorize'],
      workingDirectory: packageDir,
    );

    if (result.exitCode != 0) {
      // coverage:ignore-start
      throw Exception(
        'Error while running "dart pub add args colorize"',
      );
      // coverage:ignore-end
    }
  }

  // ...........................................................................
  void _installDevDependencies() {
    log('Install dev dependencies...');
    final result = Process.runSync(
      'dart',
      ['pub', 'add', '--dev', 'coverage', 'pana', 'yaml'],
      workingDirectory: packageDir,
    );

    if (result.exitCode != 0) {
      // coverage:ignore-start
      throw Exception(
        'Error while running "dart pub add --dev coverage pana yaml"',
      );
      // coverage:ignore-end
    }
  }

  // ...........................................................................
  Future<void> _waitShortly() async {
    log('Wait a moment...');
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  // ...........................................................................
  void _fixErrorsAndWarnings() {
    log('Fix errors and warnings...');
    // Execute dart fix
    final result = Process.runSync(
      'dart',
      ['fix', '--apply', packageDir],
    );

    if (result.exitCode != 0) {
      // coverage:ignore-start
      throw Exception('Error while running dart fix');
      // coverage:ignore-end
    }

    // Execute dart analyze
    final result2 = Process.runSync(
      'dart',
      ['analyze', packageDir],
    );
    if (result2.exitCode != 0) {
      // coverage:ignore-start
      throw Exception(
        'Error while running dart analyze:\n'
        '${result2.stderr}\n'
        '${result2.stdout}\n'
        'Please adapt "create_dart_package.dart" to fix the issues.',
      );
      // coverage:ignore-end
    }
    // Format code
    final result3 = Process.runSync('dart', [
      'format',
      packageDir,
    ]);

    if (result3.exitCode != 0) {
      // coverage:ignore-start
      throw Exception('Error while running dart format. ${result3.stdout}');
      // coverage:ignore-end
    }

    // Check that no formatting is left
    final result4 = Process.runSync(
      'dart',
      ['format', packageDir, '--set-exit-if-changed'],
    );

    if (result4.exitCode != 0) {
      // coverage:ignore-start
      throw Exception('Error while running dart format. ${result4.stdout}');
      // coverage:ignore-end
    }
  }

  // ...........................................................................
  void _initGit() {
    if (isGitHubAction) return;

    // coverage:ignore-start

    log('Init git...');
    // Execute git init
    final result = Process.runSync(
      'git',
      ['init'],
      workingDirectory: packageDir,
    );

    if (result.exitCode != 0) {}

    // Execute git branch -M main
    final result2 = Process.runSync(
      'git',
      ['branch', '-M', 'main'],
      workingDirectory: packageDir,
    );

    if (result2.exitCode != 0) {
      throw Exception('Error while running git branch -M main');
    }

    // Execute git config advice.addIgnoredFile false
    final result3 = Process.runSync(
      'git',
      ['config', 'advice.addIgnoredFile', 'false'],
      workingDirectory: packageDir,
    );

    if (result3.exitCode != 0) {
      throw Exception(
        'Error while running git config advice.addIgnoredFile false',
      );
    }

    // Execute git add *
    final result4 = Process.runSync(
      'git',
      ['add', '*'],
      workingDirectory: packageDir,
    );

    if (result4.exitCode != 0) {}

    // Execute git commit -m"Initial boylerplate"
    final result5 = Process.runSync(
      'git',
      ['commit', '-m"Initial boylerplate"'],
      workingDirectory: packageDir,
    );

    if (result5.exitCode != 0) {
      throw Exception('Error while running git commit -m"Initial boylerplate"');
    }

    // Push repo to GitHub
    if (prepareGitHub) {
      final gitHubOrigin = 'git@github.com:inlavigo/$packageName.git';

      final result6 = Process.runSync(
        'git',
        ['remote', 'add', 'origin', gitHubOrigin],
        workingDirectory: packageDir,
      );

      if (result6.exitCode != 0) {
        throw Exception(
          'Error add GitHub origin "$gitHubOrigin" ',
        );
      }

      // Execute git push -u origin main --dry-run

      final result7 = Process.runSync(
        'git',
        ['push', '-u', 'origin', 'main', '--dry-run'],
        workingDirectory: packageDir,
      );

      if (result7.exitCode != 0) {
        throw Exception(
          'Error while running "git push -u origin main --dry-run". \n '
          '${result7.stderr}',
        );
      }
    }

    log('\nSuccess! To open the project with visual studio code, call ');
    log('${greenStart}code $packageDir$greenEnd\n');

    if (prepareGitHub) {
      log('To push the project to GitHub, call');
      log('${greenStart}git push -u origin main$greenEnd\n');
      log('Happy coding!');
    }

    // coverage:ignore-end
  }
}
