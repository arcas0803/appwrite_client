import 'package:common_classes/common_classes.dart';

sealed class AppwriteFailure extends Failure {
  AppwriteFailure(
      {required super.message,
      required super.error,
      required super.stackTrace});
}

final class FromJsonFailure extends AppwriteFailure {
  FromJsonFailure({
    required String error,
    required StackTrace stackTrace,
  }) : super(
          message: 'Error while parsing json data',
          error: error,
          stackTrace: stackTrace,
        );
}

final class ToJsonFailure extends AppwriteFailure {
  ToJsonFailure({
    required String error,
    required StackTrace stackTrace,
  }) : super(
          message: 'Error while converting data to json',
          error: error,
          stackTrace: stackTrace,
        );
}

final class UnauthorizedFailure extends AppwriteFailure {
  UnauthorizedFailure({
    required String error,
    required StackTrace stackTrace,
  }) : super(
          message: 'Unauthorized',
          error: error,
          stackTrace: stackTrace,
        );
}

final class NotFoundFailure extends AppwriteFailure {
  NotFoundFailure({
    required String error,
    required StackTrace stackTrace,
  }) : super(
          message: 'Not found',
          error: error,
          stackTrace: stackTrace,
        );
}

final class ForbiddenFailure extends AppwriteFailure {
  ForbiddenFailure({
    required String error,
    required StackTrace stackTrace,
  }) : super(
          message: 'Forbidden',
          error: error,
          stackTrace: stackTrace,
        );
}

final class ServerFailure extends AppwriteFailure {
  ServerFailure({
    required String error,
    required StackTrace stackTrace,
  }) : super(
          message: 'Server error',
          error: error,
          stackTrace: stackTrace,
        );
}
