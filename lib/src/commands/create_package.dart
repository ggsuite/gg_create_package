// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:gg_console_colors/gg_console_colors.dart';
import 'package:gg_create_package/src/snippets/bin_test_snippet.dart';
import 'package:gg_create_package/src/snippets/install_snippet.dart';
import 'package:gg_create_package/src/snippets/launch_json_test_snippet.dart';
import 'package:gg_create_package/src/snippets/make_executable_snippet.dart';
import 'package:gg_create_package/src/snippets/src_my_command_snippet.dart';
import 'package:gg_create_package/src/snippets/src_snippet_with_command.dart';
import 'package:gg_create_package/src/snippets/test_my_command_test_snippet.dart';
import 'package:gg_create_package/src/snippets/test_snippet_with_command.dart';
import 'package:gg_create_package/src/tools/gg_directory.dart';
import 'package:gg_create_package/src/tools/checkout_directory.dart';
import 'package:gg_create_package/src/tools/is_github_action.dart';
import 'package:dart_style/dart_style.dart';
import 'package:gg_log/gg_log.dart';
import 'package:path/path.dart';
import 'package:recase/recase.dart';
import 'package:pubspec/pubspec.dart';

import '../snippets/bin_snippet.dart';
import '../snippets/example_snippet.dart';
import '../snippets/file_header_snippet.dart';
import '../snippets/launch_json_snippet.dart';
import '../snippets/lib_snippet.dart';
import '../snippets/open_source_licence_snippet.dart';
import '../snippets/private_license_snippet.dart';
import '../snippets/src_snippet_without_command.dart';
import '../snippets/test_snippet_without_command.dart';

/// Creates a new package in the given directory.
class CreatePackage extends Command<dynamic> {
  /// The dart SDK constraint
  static const dartSdkConstraint = '>=3.3.0 <4.0.0';

  /// The flutter SDK constraint
  static const flutterSdkConstraint = '>=3.19.0';

  /// The name of the package
  @override
  final name = 'cp';

  /// The description shown when running `aud help createDartPackage`.
  @override
  final description = 'Creates a new dart package.';

  /// Constructor
  CreatePackage({
    required this.ggLog,
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

    // Force recreation
    argParser.addFlag(
      'enforce-prefix',
      help: 'Enforces prefix aud or private and gg for open source projects.',
      negatable: true,
      defaultsTo: true,
    );

    // Add the cli option
    argParser.addFlag(
      'cli',
      abbr: 'c',
      help: 'Do (not) create a command line interface.',
      negatable: true,
      defaultsTo: true,
    );

    // Add the example option
    argParser.addFlag(
      'example',
      abbr: 'e',
      help: 'Do (not) create an example.',
      negatable: true,
      defaultsTo: true,
    );

    // Add the example option
    argParser.addFlag(
      'flutter',
      abbr: 'l',
      help: 'Create a flutter package',
      negatable: false,
      defaultsTo: false,
    );

    // Add dry-run option
    argParser.addFlag(
      'dry-run',
      help: 'Do not execute the command.',
      negatable: true,
      defaultsTo: false,
    );
  }
  // ...........................................................................
  /// The log function
  final GgLog ggLog;

  // ...........................................................................
  /// Runs the command
  @override
  Future<void> run() async {
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
    final enforcePrefix = argResults?['enforce-prefix'] as bool;
    final createCli = argResults?['cli'] as bool;
    final createExample = argResults?['example'] as bool;
    final createFlutterPackage = argResults?['flutter'] as bool;
    final dryRun = argResults?['dry-run'] as bool;

    final updatedOutputDir = outputDir.replaceAll('~', homeDirectory);

    if (!testReallyExecute) {
      return;
    }

    await _CreateDartPackage(
      outputDir: updatedOutputDir,
      packageDir: join(updatedOutputDir, packageName),
      packageName: packageName,
      description: description,
      ggLog: ggLog,
      isOpenSource: isOpenSource,
      prepareGitHub: pushToGitHub,
      force: force,
      createCli: createCli,
      createExample: createExample,
      createFlutterPackage: createFlutterPackage,
      enforcePrefix: enforcePrefix,
      dryRun: dryRun,
    ).run();
  }

  // ...........................................................................
  /// Use this to suppress execution of the command.
  static bool testReallyExecute = true;
}

// #############################################################################
class _CreateDartPackage {
  _CreateDartPackage({
    required this.outputDir,
    required this.packageDir,
    required this.packageName,
    required this.description,
    required this.ggLog,
    required this.isOpenSource,
    required this.enforcePrefix,
    required this.prepareGitHub,
    required this.force,
    required this.createCli,
    required this.createExample,
    required this.createFlutterPackage,
    required this.dryRun,
  });

  final String outputDir;
  final String packageDir;
  final String packageName;
  final String description;
  final GgLog ggLog;
  final bool isOpenSource;
  final bool enforcePrefix;
  final bool prepareGitHub;
  final bool force;
  final bool createCli;
  final bool createExample;
  final bool createFlutterPackage;
  final bool dryRun;
  static const gitHubRepo = 'https://github.com/inlavigo';
  final formatter = DartFormatter();

  // ...........................................................................
  Future<void> run() async {
    ggLog('\nCreate dart package...\n');

    await _deleteExistingPackage();
    _checkDirectories();
    _checkPackageName();
    _checkDescription();
    await _checkGithubOrigin();
    await _createPackage();
    _copyVsCodeSettings();
    _copyGitIgnore();
    _copyAnalysisOptions();
    _copyLicense();
    _copyGitHubActions();
    _preparePubspec();
    _prepareReadme();

    if (createCli) {
      _prepareLaunchJson();
      _prepareLaunchJsonTest();
    }

    _prepareChangeLog();
    _prepareMainSrcFile();

    if (createCli) {
      _prepareSubCommand();
    }

    _prepareLib();

    if (createCli) {
      _prepareBin();
      _prepareBinTest();
      _prepareSubCommandTest();
    }

    _prepareMainSrcFileTest();

    if ((createExample)) {
      _prepareExample();
    } else {
      await _removeExample();
    }

    if (createCli) {
      _prepareInstallScript();
    }

    if (createFlutterPackage) {
      await _addFlutterSdk();
    }

    _removeUnusedFiles();
    _installDevDependencies();
    _installDependencies();
    _runDartPubGet();
    await _waitShortly();
    _fixErrorsAndWarnings();
    _initGit();
  }

  // ...........................................................................
  Future<void> _deleteExistingPackage() async {
    if (!force) return;
    if (dryRun) return;

    ggLog('Delete existing package...');
    final packageDir = Directory(join(outputDir, packageName));
    if (await packageDir.exists()) {
      await for (final entity in packageDir.list(recursive: false)) {
        if (entity is File) {
          await entity.delete();
        } else if (entity is Directory) {
          await entity.delete(recursive: true);
        }
      }
    }
  }

  // ...........................................................................
  void _checkDirectories() {
    ggLog('Check directories...');

    // Target dir exists?
    if (!Directory(outputDir).existsSync()) {
      throw Exception('The directory "$outputDir" does not exist.');
    }

    // Package already exists?
    final packageDir = join(outputDir, packageName);
    if (!force && Directory(packageDir).existsSync()) {
      throw Exception('The directory "$packageDir" already exists.');
    }
  }

  // ...........................................................................
  void _checkPackageName() {
    if (!enforcePrefix) {
      return;
    }

    ggLog('Check package names...');
    if (isOpenSource && !packageName.startsWith('gg_')) {
      throw Exception('Open source packages should start with "gg_"');
    }

    if (!isOpenSource && !packageName.startsWith('aud_')) {
      throw Exception('Non open source packages should start with "aud_"');
    }
  }

  // ...........................................................................
  void _checkDescription() {
    ggLog('Check description ...');
    if (description.length < 60) {
      throw Exception('The description must be at least 60 characters long.');
    }
  }

  // ...........................................................................
  Future<void> _checkGithubOrigin() async {
    if (!prepareGitHub) return;

    ggLog('Check GitHub origin...');

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
    ggLog('Create package...');
    if (dryRun) return;

    // .......................
    // Create the dart package
    final result = await Process.run(
      'dart',
      [
        'create',
        '-t',
        'package',
        packageName,
        '--no-pub',
        force ? '--force' : '',
      ],
      workingDirectory: outputDir,
    );

    // Log result
    // coverage:ignore-start
    if (result.exitCode != 0 &&
        result.stderr != null &&
        (result.stderr as String).isNotEmpty) {
      ggLog(result.stderr as String);
    }

    if (result.exitCode != 0 &&
        result.stdout != null &&
        (result.stdout as String).isNotEmpty) {
      ggLog(result.stdout as String);
    }
    // coverage:ignore-end
  }

  // ...........................................................................
  void _copyVsCodeSettings() {
    // Copy over VScode which are located in project/.vscode
    ggLog('Copy VSCode settings...');
    if (dryRun) return;

    final vscodeDir = join(ggDirectory(), '.vscode');
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
    ggLog('Copy .gitignore...');
    if (dryRun) return;
    _copyFile(
      join(ggDirectory(), '.gitignore'),
      join(packageDir, '.gitignore'),
    );
  }

  // ...........................................................................
  void _copyAnalysisOptions() {
    ggLog('Copy analysis_options.yaml...');
    if (dryRun) return;
    _copyFile(
      join(ggDirectory(), 'analysis_options.yaml'),
      join(packageDir, 'analysis_options.yaml'),
    );
  }

  // ...........................................................................
  void _copyLicense() {
    ggLog('Copy LICENSE...');
    if (dryRun) return;
    final license =
        (isOpenSource ? openSourceLicenseSnippet : privateLicenceSnippet)
            .replaceAll('YEAR', DateTime.now().year.toString());

    File(join(packageDir, 'LICENSE')).writeAsStringSync(license);
  }

  // ...........................................................................
  void _copyGitHubActions() {
    ggLog('Copy GitHub Actions...');
    if (dryRun) return;
    // Copy over GitHub Actions
    final githubActionsDir = join(ggDirectory(), '.github');
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
  void _appendInFile(String file, String text) {
    var content = File(file).readAsStringSync();
    content += text;
    File(file).writeAsStringSync(content);
  }

  // ...........................................................................
  void _makeFileExecutable(String filePath) {
    if (dryRun) return;
    // Execute chmod +x bin/$packageName.dart
    if (Platform.isWindows) {
      return;
    }
    // coverage:ignore-start
    final result = Process.runSync(
      'chmod',
      ['+x', filePath],
    );

    if (result.exitCode != 0) {
      throw Exception('Error while running "chmod +x $filePath"');
    }
    // coverage:ignore-end
  }

  // ...........................................................................
  void _preparePubspec() {
    ggLog('Prepare pubspec.yaml...');
    if (dryRun) return;
    final pubspecFile = join(packageDir, 'pubspec.yaml');

    final publishTo = isOpenSource ? '' : '\npublish_to: none';

    _replaceInFile(
      pubspecFile,
      {
        r'sdk:.*': 'sdk: "${CreatePackage.dartSdkConstraint}"',
        r'^#\srepository:.*':
            'repository: $gitHubRepo/$packageName.git' '$publishTo',
        r'^description:.*': 'description: $description',
        r'^# Add regular dependencies here.\n': '',
        r'  # path:': '  path:',
      },
    );

    if (createCli) {
      _appendInFile(pubspecFile, '\nexecutables:\n $packageName:');
    }
  }

  // ...........................................................................
  void _prepareReadme() {
    ggLog('Prepare README.md...');
    if (dryRun) return;
    final readmeFile = join(packageDir, 'README.md');
    String content = '';
    content += '# $packageName\n\n';
    content += '$description\n';
    File(readmeFile).writeAsStringSync(content);
  }

  // ...........................................................................
  void _prepareLaunchJson() {
    ggLog('Prepare launch.json...');
    if (dryRun) return;
    final launchJsonFile = join(packageDir, '.vscode', 'launch.json');
    final content = launchJsonSnippet(packageName: packageName);
    File(launchJsonFile).writeAsStringSync(content);
  }

  // ...........................................................................
  void _prepareLaunchJsonTest() {
    ggLog('Prepare launch.json test...');
    if (dryRun) return;
    final launchJsonTestDirectory = join(packageDir, 'test', 'vscode');
    Directory(launchJsonTestDirectory).createSync(recursive: true);

    final launchJsonTestFile =
        join(packageDir, 'test', 'vscode', 'launch_json_test.dart');
    final snippet = launchJsonTestSnippet(
      packageName: packageName,
      isFlutter: createFlutterPackage,
    );
    final content = formatter.format('$fileHeaderSnippet\n\n$snippet\n');
    File(launchJsonTestFile).writeAsStringSync(content);
  }

  // ...........................................................................
  void _prepareChangeLog() {
    ggLog('Prepare CHANGELOG.md...');
    if (dryRun) return;
    final changeLogFile = File(join(packageDir, 'CHANGELOG.md'));
    String content = '';
    content += '# Changelog\n\n';
    content += '## Unreleased\n\n';
    content += '### Added\n\n';
    content += '- Initial boilerplate.\n';
    changeLogFile.writeAsStringSync(content);
  }

  // ...........................................................................
  void _prepareMainSrcFile() {
    ggLog('Prepare src ...');
    if (dryRun) return;
    final implementationFile =
        join(packageDir, 'lib', 'src', '$packageName.dart');
    final implementationSnippet =
        (createCli ? srcSnippetWithCommand : srcSnippetWithoutCommand)
            .call(packageName: packageName);

    final content =
        formatter.format('$fileHeaderSnippet\n\n$implementationSnippet\n');
    File(implementationFile).writeAsStringSync(content);
  }

  // ...........................................................................
  void _prepareSubCommand() {
    ggLog('Prepare src/commands ...');
    if (dryRun) return;

    final commandDir = join(packageDir, 'lib', 'src', 'commands');
    Directory(commandDir).createSync(recursive: true);

    final implementationFile = join(commandDir, 'my_command.dart');
    final implementationSnippet = srcCommandsMyCommandSnippet;
    final content =
        formatter.format('$fileHeaderSnippet\n\n$implementationSnippet\n');
    File(implementationFile).writeAsStringSync(content);
  }

  // ...........................................................................
  void _prepareBin() {
    ggLog('Prepare bin ...');
    if (dryRun) return;
    final binFolder = join(packageDir, 'bin');
    Directory(binFolder).createSync();
    final binFile = join(binFolder, '$packageName.dart');
    var binFileContent = binSnippet(
      packageName: packageName,
      description: description,
    );

    binFileContent =
        '$makeExecutableSnippet' '$fileHeaderSnippet\n\n' '$binFileContent\n';
    binFileContent = formatter.format(binFileContent);

    File(binFile).writeAsStringSync(binFileContent);
    _makeFileExecutable(binFile);
  }

  // ...........................................................................
  void _prepareBinTest() {
    ggLog('Prepare bin ...');
    if (dryRun) return;
    final binTestFolder = join(packageDir, 'test', 'bin');
    Directory(binTestFolder).createSync();
    final binTestFile = join(binTestFolder, '${packageName}_test.dart');
    var fileContent = binTestSnippet(
      packageName: packageName,
      isFlutter: createFlutterPackage,
    );

    fileContent = '$fileHeaderSnippet\n\n' '$fileContent\n';
    fileContent = formatter.format(fileContent);

    File(binTestFile).writeAsStringSync(fileContent);
  }

  // ...........................................................................
  void _prepareMainSrcFileTest() {
    ggLog('Prepare test folder...');
    if (dryRun) return;
    final testFolder = join(packageDir, 'test');
    Directory(testFolder).createSync();
    final testFile = join(testFolder, '${packageName}_test.dart');
    final testFileContent =
        (createCli ? testSnippetWithCommand : testSnippetWithoutCommand).call(
      packageName: packageName,
      isFlutter: createFlutterPackage,
    );

    final content =
        formatter.format('$fileHeaderSnippet\n\n$testFileContent\n');
    File(testFile).writeAsStringSync(content);
  }

  // ...........................................................................
  void _prepareSubCommandTest() {
    ggLog('Prepare test folder...');
    if (dryRun) return;
    final testFolder = join(packageDir, 'test', 'commands');
    Directory(testFolder).createSync(recursive: true);
    final testFile = join(testFolder, 'my_command_test.dart');
    final testFileContent = testMyCommandTestSnippet(
      packageName: packageName,
      isFlutter: createFlutterPackage,
    );
    final content =
        formatter.format('$fileHeaderSnippet\n\n$testFileContent\n');
    File(testFile).writeAsStringSync(content);
  }

  // ...........................................................................
  void _prepareExample() {
    ggLog('Prepare example folder...');
    if (dryRun) return;
    final exampleFolder = join(packageDir, 'example');
    Directory(exampleFolder).createSync();
    final exampleFile =
        join(exampleFolder, '${packageName.snakeCase}_example.dart');

    final exampleFileContent = exampleSnippet(packageName: packageName);
    final content = '$makeExecutableSnippet'
        '$fileHeaderSnippet\n\n'
        '$exampleFileContent\n';

    File(exampleFile).writeAsStringSync(content);
    _makeFileExecutable(exampleFile);
  }

  // ...........................................................................
  Future<void> _removeExample() async {
    ggLog('Remove example folder...');
    if (dryRun) return;
    final exampleFolder = join(packageDir, 'example');
    if (await Directory(exampleFolder).exists()) {
      await Directory(exampleFolder).delete(recursive: true);
    }
  }

  // ...........................................................................
  void _prepareInstallScript() {
    ggLog('Prepare install script...');
    if (dryRun) return;
    final installFile = join(packageDir, 'install');
    final content = installSnippet;
    File(installFile).writeAsStringSync(content);
    _makeFileExecutable(installFile);
  }

  // ...........................................................................
  void _removeUnusedFiles() {
    ggLog('Remove unused files...');
    if (dryRun) return;
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
    ggLog('Prepare lib folder...');
    if (dryRun) return;
    final libFolder = join(packageDir, 'lib');
    final libDartFile = join(libFolder, '$packageName.dart');
    final libDartContent = libSnippet(packageName: packageName);
    final content = formatter.format('$fileHeaderSnippet\n\n$libDartContent\n');
    File(libDartFile).writeAsStringSync(content);
  }

  // ######################
  // Flutter
  // ######################

  Future<void> _addFlutterSdk() async {
    if (dryRun) return;

    // specify the directory
    var myDirectory = Directory(packageDir);

    // Add flutter SDK
    var pubSpec = (await PubSpec.load(myDirectory)).copy(
      dependencies: {
        'flutter': const SdkReference('flutter'),
      },
    ).copy(
      devDependencies: {
        'flutter_lints': DependencyReference.fromJson('^3.0.0'),
        'flutter_test': const SdkReference('flutter'),
      },
    ).copy(
      environment: Environment.fromJson(
        {
          'flutter': CreatePackage.flutterSdkConstraint,
          'sdk': CreatePackage.dartSdkConstraint,
        },
      ),
    );

    // save it
    await pubSpec.save(myDirectory);
  }

  // ######################
  // Dependencies
  // ######################

  // ...........................................................................
  void _installDependencies() {
    ggLog('Install dependencies...');
    if (dryRun) return;
    final packages = [
      if (createCli) 'args',
      if (createCli) 'gg_console_colors',
      if (createCli) 'gg_process',
      if (createCli) 'gg_args',
      if (createCli) 'gg_log',
    ];

    if (packages.isEmpty) return;

    final options = ['pub', 'add', ...packages];
    final result = Process.runSync(
      'dart',
      options,
      workingDirectory: packageDir,
    );

    if (result.exitCode != 0) {
      // coverage:ignore-start
      throw Exception(
        'Error while running "dart ${options.join(' ')}"',
      );
      // coverage:ignore-end
    }
  }

  // ...........................................................................
  void _installDevDependencies() {
    ggLog('Install dev dependencies...');
    if (dryRun) return;
    final packages = [
      if (createCli) 'gg_capture_print',
    ];

    if (packages.isEmpty) {
      return;
    }

    final options = ['pub', 'add', '--dev', ...packages];

    final result = Process.runSync(
      'dart',
      options,
      workingDirectory: packageDir,
    );

    if (result.exitCode != 0) {
      // coverage:ignore-start
      throw Exception(
        'Error while running "dart ${options.join(' ')}"',
      );
      // coverage:ignore-end
    }
  }

  // ...........................................................................
  void _runDartPubGet() {
    ggLog('Run dart pub get ...');
    if (dryRun) return;

    final result = Process.runSync(
      'dart',
      ['pub', 'get'],
      workingDirectory: packageDir,
    );

    if (result.exitCode != 0) {
      // coverage:ignore-start
      throw Exception(
        'Error while running "dart pub get"',
      );
      // coverage:ignore-end
    }
  }

  // ...........................................................................
  Future<void> _waitShortly() async {
    ggLog('Wait a moment...');
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  // ######################
  // Fix stuff
  // ######################

  // ...........................................................................
  void _fixErrorsAndWarnings() {
    ggLog('Fix errors and warnings...');
    if (dryRun) return;
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

  // ######################
  // Prepare Git
  // ######################

  // ...........................................................................
  void _initGit() {
    if (isGitHubAction) return;
    if (dryRun) return;

    // coverage:ignore-start

    ggLog('Init git...');
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

    ggLog('\nSuccess! To open the project with visual studio code, call ');
    ggLog('${green('code $packageDir')}\n');

    if (prepareGitHub) {
      ggLog('To push the project to GitHub, call');
      ggLog('${green('git push -u origin main')}\n');
      ggLog('Happy coding!');
    }

    // coverage:ignore-end
  }
}
