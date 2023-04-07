![flutter-ci](https://github.com/talesbarreto/pull_request_coverage/actions/workflows/flutter-ci.yml/badge.svg)

This is a tool intended to analyze the coverage rate of a pull request, ignoring lines that were not changed.

## Motivation

The coverage rate threshold on CI tools is a common approach to encourage developers to write tests. Unfortunately, judging a pull request by
analyzing the coverage rate of the entire project is not always fair, especially on big refactor tasks, witch may naturally decrease the coverage rate.

This package tries a different approach to analyze the test coverage: we only check lines that have been added in the pull request. The coverage rate will be calculated by dividing the number of
uncovered new lines by the number of new lines.

You can set thresholds to make tests fail on a CI tool. This package can also print those lines that were not covered by any test, making it easier to identify missing tests.

## Installing

There are two ways install this `pull_request_coverage`. Since it is a binary package, you can activate it from the command line using `dart pub global activate pull_request_coverage` and use it as an ordinary program on your CLI or you can add it to the `pubspec.yaml` of your project, on the `dev_dependencies` section.

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

If you want to analyze a Dart project rather than Flutter, use the [coverage package](https://pub.dev/packages/coverage)

### Running pull_request_coverage

To check the PR's code, pull_request_coverage needs a diff between its branch and the target one. The diff is read from the `STDIN` input.

You can pipe the STDIN to `pull_request_coverage` using bash's `|` operator, like this:

```bash
git diff repository/main | flutter pub run pull_request_coverage
```

If you activate `pull_request_coverage` using `dart pub global activate`, you can invoke directly it:
```bash
git diff repository/main | pull_request_coverage
```

See [Example](https://github.com/talesbarreto/pull_request_coverage/tree/main/example) tab to check an output example out

# Settings
There are two ways to configure `pull_request_coverage` execution: using CLI args or a yaml config file. 
Using a `yaml` file is better for large teams since those settings will be the same used by your CI script. Therefore, there is no need for each developer to copy and paste the args to analyze the coverage locally

By default, `pull_request_coverage` will look for `./pull_request_coverage.yaml` file to load its settings. You can override this using `config-file` argument

Both methods have the same settings available. If the same setting is set on both, the CLI arg value will be used.

#### Examples
##### CLI args
```bash
git diff origin/main | flutter pub run pull_request_coverage  --maximum-uncovered-lines 5 --ignore '/lib/di/**','**/gen.dart' --ignore-lines "^.*@override.*$"
```

##### yaml config file
```yaml
maximum-uncovered-lines: 5
ignore:
  - /lib/di/**
  - "**/gen.dart"
ignore-lines:
  - "^.*@override.*$"
```

## Settings available
Default value within parenthesis

### Input

- **lcov-file** (`coverage/lcov.info`): The path to the lcov.info file generated by the `flutter test --coverage` command.
- **config-file** (`pull_request_coverage.yaml`): The `yaml` settings file path

### Threshold

- **minimum-coverage** : Fail test if the coverage rate is below this value

- **maximum-uncovered-lines** : Fail test if the the number of uncovered lines is greater than this value

### Filters

- **ignore**: list of files that should be ignored, using the [widely-known Bash glob syntax](https://pub.dev/packages/glob#syntax). The total of ignored files and lines will be shown on the report for statistics purposes only.

- **ignore-lines**: list of regex expressions to filter lines on source code

- **ignore-known-generated-files** (`true`) : Ignore file paths that ends with `.g.dart`, `.pb.dart`, `.pbenum.dart`, `.pbserver.dart` or `.pbjson.dart`

- **add-to-known-generated-files**: list of [glob matchers](https://pub.dev/packages/glob#syntax) to extend the given list on `ignore-known-generated-files`. Those lines, differently from `ignore`, will be completely ignored in the report.

#### Presentation

Check [example](https://github.com/talesbarreto/pull_request_coverage/tree/main/example) out to see how those params can change the output

- **output-mode** (`cli`): The output format
  - cli: The output format intent to be read on cli
  - markdown: The output formatted using markdown syntax. This is useful to be used on a pull request comment, posted by a bot, for example.

- **markdown-mode** (`diff`): The markdown output format (see example)
  - diff: Use diff syntax to highlight the uncovered lines
  - dart: use dart syntax to show codes with appropriate color scheme, adding a comment at the and of uncovered lines

- **report-fully-covered-files** (`true`): The file path of each fully covered file will be printed, as a celebrating message =)

- **show-uncovered-code** (`true`): The source code of the uncovered lines will be printed, with a red font color, to make it easier to identify the missing tests.
  If this parameter is set to `false`, only the file path will be shown on the log.

- **use-colorful-output** (`true`): pull_request_coverage uses a colorful font to highlight uncovered lines. You can disable this by setting this parameter to `false`. Only available when output mode is set to `cli`

- **fraction-digits** (`2`): The number of digits after the decimal point to be used on the coverage rate

- **fully-tested-message** : Set a custom output message to be displayed when there is no untested lines

#### Under the hood

- **stdin-timeout** (`1`): `pull_request_coverage` read diff from stdin. In some cases, it never closes and the analysis will be stuck. By default, if no data comes in one second, `pull_request_coverage` will assume that it reached `EOF`

# Exit code

| Code | Description                                       |
|------|---------------------------------------------------|
| 0    | Tests passed.                                     |
| 1    | Tests failed (only when thresholds are set).      |
| 255  | Execution has failed and tests were not executed. |
