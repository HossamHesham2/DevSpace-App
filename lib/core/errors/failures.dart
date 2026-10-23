abstract class Failure {
  final String errorMessage;

  new({required this.errorMessage});
}

class ServerFailure extends Failure {
  new({required super.errorMessage});
}

class CacheFailure extends Failure {
  new({required super.errorMessage});
}
