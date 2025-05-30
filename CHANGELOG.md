# Changelog

## \[4.0.0\] - 2024-10-01

### Added

- Add option `--dry-run`, add option --no-enforce-prefix
- Add option `--github-org` to specify the Github Organization to be used
- Remove option `--enfore-prefix`

## [Unreleased]

### Changed

- Cleanup

## [2.0.1] - 2024-05-03

### Added

- Add --flutter option to create flutter packages

## [2.0.0] - 2024-04-27

### Added

- Add options --no-cli and --no-example to create a package without CLI and without example

### Changed

- Increase version

### Removed

- `./check` script. Use `gg can commit` instead

## [1.0.3] - 2024-04-13

### Changed

- Upgraded gg\_args

### Removed

- dependency to gg\_install\_gg, remove ./check script
- dependency pana

## [1.0.2] - 2024-04-10

### Fixed

- CHANGELOG.md boilerplate is not 100% cider compatible

## [1.0.1] - 2024-04-10

### Removed

- 'Pipline: Disable cache'

## [1.0.0] - 2024-04-09

### Changed

- Rework changelog
- 'Github Actions Pipeline'
- 'Github Actions Pipeline: Add SDK file containing flutter into
.github/workflows to make github installing flutter and not dart SDK'
- Prepare publish

[Unreleased]: https://github.com/ggsuite/gg_create_package/compare/2.0.1...HEAD
[2.0.1]: https://github.com/ggsuite/gg_create_package/compare/2.0.0...2.0.1
[2.0.0]: https://github.com/ggsuite/gg_create_package/compare/1.0.3...2.0.0
[1.0.3]: https://github.com/ggsuite/gg_create_package/compare/1.0.2...1.0.3
[1.0.2]: https://github.com/ggsuite/gg_create_package/compare/1.0.1...1.0.2
[1.0.1]: https://github.com/ggsuite/gg_create_package/compare/1.0.0...1.0.1
[1.0.0]: https://github.com/ggsuite/gg_create_package/tag/%tag
