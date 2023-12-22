## help - Display help about make targets for this Makefile
help:
	@cat Makefile | grep '^## ' --color=never | cut -c4- | sed -e "`printf 's/ - /\t- /;'`" | column -s "`printf '\t'`" -t

## unit_tests - Run unit tests
unit_tests:
	dart test test/tests.dart

## temp_version - Set temporary version number
temp_version:
	@sed -i 's/VERSIONADDEDBYGITHUB/1.0.0/g' pubspec.yaml


## github_version - Set version number for GitHub Actions
github_version:
	@sed -i 's/1.0.0/VERSIONADDEDBYGITHUB/g' pubspec.yaml

## pull_deps - Pull dependencies
pull_deps:
	@make temp_version
	dart pub get
	@make github_version

## update_deps - Update dependencies
update_deps:
	@make temp_version
	dart pub upgrade
	@make github_version

## outdated_deps - Check for outdated dependencies
outdated_deps:
	@make temp_version
	dart pub outdated
	@make github_version

## json_files - Generate JSON files
json_files:
	@make temp_version
	@dart run build_runner build
	@make github_version
