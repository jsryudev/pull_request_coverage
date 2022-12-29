![flutter-ci](https://github.com/talesbarreto/pull_request_coverage/actions/workflows/flutter-ci.yml/badge.svg)

This is a tool intended to analyze the coverage rate of a pull request, ignoring the lines that were not changed in the PR.

## Motivation

The coverage rate threshold on CI tools is a common approach to encourage developers to write tests and keep improving the whole project's quality. Unfortunately, judging a pull request coverage by
analyzing the coverage of the entire project is not always fair, especially on big refactor tasks, witch may naturally decrease the coverage rate.

This package tries a different approach to analyse the test coverage: we only check lines that have been added in the pull request. The coverage rate will be calculated by dividing the number of
uncovered new lines by the number of new lines.

You can set thresholds to make tests fail on a CI. This package can also print those lines that were not covered, making it easier to identify the missing tests.

## Installing

Add this line to your package's pubspec.yaml under the `dev_dependencies` section:

```yaml
dev_dependencies:
  pull_request_coverage:
```

You should specify the version to avoid breaking changes

## Usage

This package uses two information to generate its report:

- A `lcov.info` file, generated by the `flutter test --coverage` command
- A diff between the current branch and the main one, generated by the `git diff` command

#### Generating the lcov.info file

There is a known issue with the `flutter test --coverage` command. It may not report untested files. There is a workaround for it, described in
this [issue](https://github.com/flutter/flutter/issues/27997#issuecomment-1144247839)

Run the following command to generate the `coverage/lcov.info` file:

```bash
flutter test --coverage
```

### Running pull_request_coverage

To check the PR's code, pull_request_coverage needs a diff between its branch and the target one. The diff is read from the `STDIN` input.

You can feed the STDIN using bash's `|` operator, like this:

```bash
git diff repository/main | flutter pub run pull_request_coverage
```

See [Example](https://github.com/talesbarreto/pull_request_coverage/tree/main/example) tab to check an output example out

## Exit code

| Code | Description                                       |
|------|---------------------------------------------------|
| 0    | Tests passed.                                     |
| 1    | Tests failed (only when thresholds are set).      |
| 255  | Execution has failed and tests were not executed. |

## Parameters

Default value within parenthesis

- **lcov-file** (`coverage/lcov.info`): The path to the lcov.info file generated by the `flutter test --coverage` command.

### Threshold

- **minimum-coverage** : Fail test if the coverage rate is below this value
g
- **maximum-uncovered-lines** : Fail the if the the number of uncovered lines is greater than this value

### File filter

- **exclude-suffix** (`.g.dart,.pb.dart,.pbenum.dart,.pbserver.dart,.pbjson.dart`): Exclude all file paths that end with those suffixes, separated by commas

- **exclude-prefix** : Exclude all paths that start with those prefixes, separated by commas

#### Presentation

Check [example](https://github.com/talesbarreto/pull_request_coverage/tree/main/example) out to see how this params can change the output

- **output-mode** (`cli`): The output format
  - cli: The output format intent to be read on a terminal
  - markdown: The output formatted using markdown syntax. This is useful to be used on a pull request comment, posted by a bot, for example.

- **markdown-mode** (`diff`): The markdown output format (see example)
  - diff: Use diff syntax to highlight the uncovered lines
  - dart: use the dart syntax to show codes, adding a comment at the and of uncovered lines

- **report-fully-covered-files** (`true`): The file path of each fully covered file will be printed, as a celebrating message =)

- **show-uncovered-code** (`true`): The source code of the uncovered lines will be printed, with a red font color, to make it easier to identify the missing tests.
  If this parameter is set to `false`, only the file path will be shown on the log.

- **use-colorful-output** (`true`): pull_request_coverage uses a colorful font to highlight uncovered lines. You can disable this by setting this parameter to `false`

- **fraction-digits** (`2`): The number of digits after the decimal point to be used on the coverage rate

