import 'dart:async';

import 'package:pull_request_coverage/src/domain/analyzer/use_case/analyze.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/get_file_report_from_diff.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/is_a_generated_file.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/is_an_ignored_file.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/set_file_line_result_data.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/should_analyze_this_line.dart';
import 'package:pull_request_coverage/src/domain/file/repository/file_repository.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/use_case/parse_git_diff.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/use_case/remove_git_root_relative_path.dart';
import 'package:pull_request_coverage/src/domain/input_reader/lcov_reader/get_uncovered_file_lines.dart';
import 'package:pull_request_coverage/src/domain/user_settings/models/user_settings.dart';

class AnalyzeModule {
  const AnalyzeModule._();

  static Future<Analyze> provideAnalyzeUseCase({
    required UserSettings userSettings,
    required List<String> lcovLines,
    required FileRepository ioRepository,
    required GetFileReportFromDiff getFileReportFromDiff,
    required Stream<List<String>> filesOnGitDiffStream,
    String? gitRootRelativePath,
  }) async {
    final isAnIgnoredFile = IsAnIgnoredFile(userSettings);
    return Analyze(
      parseGitDiff: ParseGitDiff(
        RemoveGitRootRelativePath(
          gitRootRelativePath ?? await ioRepository.getGitRootRelativePath(),
        ).call,
      ),
      filesOnGitDIffStream: filesOnGitDiffStream,
      lcovLines: lcovLines,
      setUncoveredLines: SetFileLineResultData(ShouldAnalyzeThisLine(userSettings.lineFilters), isAnIgnoredFile),
      getUncoveredFileLines: GetUncoveredFileLines(),
      isAGeneratedFile: IsAGeneratedFile(userSettings),
      isAnIgnoredFile: isAnIgnoredFile,
      getFileReportFromDiff: getFileReportFromDiff,
      userSettings: userSettings,
    );
  }
}
