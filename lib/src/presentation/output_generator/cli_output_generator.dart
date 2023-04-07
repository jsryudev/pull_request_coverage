import 'package:pull_request_coverage/src/domain/analyzer/models/analysis_result.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/user_options.dart';
import 'package:pull_request_coverage/src/presentation/output_generator/get_result_table.dart';
import 'package:pull_request_coverage/src/presentation/output_generator/plain_text_output_generator.dart';
import 'package:pull_request_coverage/src/presentation/use_case/colorize_cli_text.dart';

class CliOutputGenerator with PlainTextOutputGenerator {
  @override
  final ColorizeCliText colorizeCliText;
  @override
  final UserOptions userOptions;
  final GetResultTable getResultTable;

  const CliOutputGenerator({
    required this.colorizeCliText,
    required this.userOptions,
    required this.getResultTable,
    required this.print,
  });

  @override
  final void Function(String message) print;

  @override
  bool get showUncoveredCode => userOptions.showUncoveredCode;

  @override
  String? getSourceCodeHeader() => null;

  @override
  String? getSourceCodeFooter() => null;

  @override
  String? getSourceCodeBlocDivider() => "......\n\n";

  @override
  String? getLine(String line, int lineNumber, bool isANewLine, bool isUntested) {
    if (isANewLine && isUntested) {
      return "${colorizeCliText("[$lineNumber]: ${line.replaceFirst("+", "→")}", TextColor.red)}\n";
    } else {
      return " $lineNumber : $line\n";
    }
  }

  @override
  String getReport(AnalysisResult analysisResult) {
    if (analysisResult.linesMissingTests == 0 && userOptions.fullyTestedMessage != null) {
      return userOptions.fullyTestedMessage!;
    }

    return "\n${getResultTable(analysisResult)}";
  }

  @override
  String formatFileHeader(String text) => text;
}