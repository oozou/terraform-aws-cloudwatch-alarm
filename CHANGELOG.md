# Change Log

All notable changes to this module will be documented in this file.

## [v2.0.1] - 2023-06-15

### Changed

- When running with a provider version of 6 or higher, certain modules may not function properly. However, we can address the modules that are not compatible with version 6 to ensure compatibility. This way, we don't need to edit all the modules. So we update the constraint to `>= 5.0.0` at the module level.

## [v2.0.0] - 2023-06-08

### BREAKING CHANGES

- Upgrade the AWS provider to version 5 with the constraint of `>= 5.0.0, < 6.0.0`.

## [1.0.0] - 2022-07-21

### Added

- init terraform-aws-cloudwatch-alarm module
