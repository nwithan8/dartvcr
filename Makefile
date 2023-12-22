## help - Display help about make targets for this Makefile
help:
	@cat Makefile | grep '^## ' --color=never | cut -c4- | sed -e "`printf 's/ - /\t- /;'`" | column -s "`printf '\t'`" -t

## unit_tests - Run unit tests
unit_tests:
	dart test test/tests.dart

## version - Update version number
# param: number - Version number
version:
	@sed -i 's/version: VERSIONADDEDBYGITHUB/version: $(number)/g' pubspec.yaml
	@sed -i 's/version: 1.0.0/version: $(number)/g' pubspec.yaml # In case never got reset from temp_version

## temp_version - Set temporary version number
temp_version:
	@make version number=1.0.0

## github_version - Set version number for GitHub Actions
github_version:
	@make version number=VERSIONADDEDBYGITHUB

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

## docs - Generate documentation
docs:
	@make temp_version
	@dart doc
	@make github_version

## test_publish - Test publishing to pub.dev
test_publish:
	@make temp_version
	@dart pub publish --dry-run
	@make github_version

## publish - Publish to pub.dev
# param: number - Version number
publish:
	@make version number=$(number)
	@dart pub publish -f
	@make github_version
