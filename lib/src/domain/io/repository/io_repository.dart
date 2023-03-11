abstract class IoRepository {
  /// Reads a single line from [stdin] asynchronously.
  Future<String?> readStdinLine();

  /// Example:
  /// Considering the existing file structure:
  ///   /repositories/repoA/.git
  ///   /repositories/repoA/projects/projectA/lib
  /// When pull_request_coverage is run from `/repositories/repoA/projects/projectA/lib`
  /// [getGitRootRelativePath] will return  `projects/projectA/`
  Future<String?> getGitRootRelativePath();

  /// pull_request_coverage should run in the root of a dart project.
  /// [doesLibDirectoryExist] is used to check if `./lib` exists
  Future<bool> doesLibDirectoryExist();
}