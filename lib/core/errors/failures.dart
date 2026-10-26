abstract class Failure {
  const Failure({required this.errorMessage});

  final String errorMessage;
}

class ServerFailure extends Failure {
  const ServerFailure({required super.errorMessage, this.statusCode});

  /// The HTTP status code that produced this failure, when available.
  ///
  /// Used by callers that need to react to specific responses
  /// (for example GitHub rate limiting: 403 / 429).
  final int? statusCode;
}

class CacheFailure extends Failure {
  const CacheFailure({required super.errorMessage});
}
