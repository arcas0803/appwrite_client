import 'dart:async';
import 'dart:developer';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite_client/src/appwrite_client.dart';
import 'package:appwrite_client/src/appwrite_failure.dart';
import 'package:common_classes/common_classes.dart';
import 'package:connectivity_client/connectivity_client.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

/// Implementation of [AppwriteClient] that uses [appwrite] to communicate with
/// the server.
///
class AppwriteClientImpl<T> implements AppwriteClient<T> {
  final Logger? _logger;

  final FutureOr<void> Function(Failure)? _telemetryOnError;

  final FutureOr<void> Function()? _telemetryOnSuccess;

  final Databases _db;

  final String _databaseId;

  final String _collectionId;

  final T Function(Map<String, dynamic> json) _fromJson;

  final Map<String, dynamic> Function(T document) _toJson;

  final ConnectivityClient _connectivityClient;

  AppwriteClientImpl({
    required Databases db,
    required String databaseId,
    required String collectionId,
    required T Function(Map<String, dynamic> json) fromJson,
    required Map<String, dynamic> Function(T document) toJson,
    Logger? logger,
    FutureOr<void> Function(Failure)? telemetryOnError,
    FutureOr<void> Function()? telemetryOnSuccess,
  })  : _logger = logger,
        _telemetryOnError = telemetryOnError,
        _telemetryOnSuccess = telemetryOnSuccess,
        _db = db,
        _databaseId = databaseId,
        _collectionId = collectionId,
        _fromJson = fromJson,
        _toJson = toJson,
        _connectivityClient = ConnectivityClientImpl(
          logger: logger,
          telemetryOnError: telemetryOnError,
          telemetryOnSuccess: telemetryOnSuccess,
        );

  Future<Result<T>> _jsonParser(Map<String, dynamic> data) {
    return Result.asyncGuard(
      () async {
        _logger?.d('[START] Parsing json data: $data');

        final parsed = await compute(_fromJson, data);

        _logger?.d('[SUCCESS] Parsed json data: ${parsed.toString()}');

        _telemetryOnSuccess?.call();

        return parsed;
      },
      onError: (e, s) {
        final failure = FromJsonFailure(
          error: e.toString(),
          stackTrace: s,
        );

        _logger?.e(
          '[ERROR] Error while parsing json data: $data',
          time: DateTime.now(),
          error: e,
          stackTrace: s,
        );

        _telemetryOnError?.call(failure);

        return failure;
      },
    );
  }

  Future<Result<Map<String, dynamic>>> _jsonSerializer(T document) {
    return Result.asyncGuard(
      () async {
        _logger?.d('[START] Serializing json data: $document');

        final parsed = await compute(_toJson, document);

        _logger?.d('[SUCCESS] Serialized json data: ${parsed.toString()}');

        _telemetryOnSuccess?.call();

        return parsed;
      },
      onError: (e, s) {
        final failure = ToJsonFailure(
          error: e.toString(),
          stackTrace: s,
        );

        _logger?.e(
          '[ERROR] Error while serializing json data: $document',
          time: DateTime.now(),
          error: e,
          stackTrace: s,
        );

        _telemetryOnError?.call(failure);

        return failure;
      },
    );
  }

  Failure _onAppwriteException(e, s) {
    if (e.code != null) {
      _logger?.e(
        '[ERROR] AppWrite error code: ${e.code}',
        time: DateTime.now(),
        error: e,
        stackTrace: s,
      );
      switch (e.code) {
        case 401:
          return UnauthorizedFailure(
            error: e.toString(),
            stackTrace: s,
          );

        case 403:
          return ForbiddenFailure(
            error: e.toString(),
            stackTrace: s,
          );

        case 404:
          return NotFoundFailure(
            error: e.toString(),
            stackTrace: s,
          );
        default:
          return ServerFailure(
            error: e.toString(),
            stackTrace: s,
          );
      }
    }
    return ServerFailure(
      error: e.toString(),
      stackTrace: s,
    );
  }

  @override
  Future<Result<T>> create(
      {String? documentId,
      required T document,
      List<String>? permissions}) async {
    _logger?.d('[START] Creating document: $document');

    final connectivityResult =
        await _connectivityClient.checkInternetConnection();

    if (connectivityResult.isError) {
      return Result.error(
        NoInternetConnectionFailure(),
      );
    }

    final jsonResult = await _jsonSerializer(document);

    switch (jsonResult) {
      case Success<Map<String, dynamic>>(value: final data):
        try {
          final result = await _db.createDocument(
            databaseId: _databaseId,
            collectionId: _collectionId,
            documentId: documentId ?? const Uuid().v4(),
            permissions: permissions ??
                [
                  Permission.create('any'),
                  Permission.read('any'),
                  Permission.update('any'),
                  Permission.delete('any'),
                ],
            data: data,
          );

          _logger?.d('[SUCCESS] Created document: ${result.data.toString()}');

          _telemetryOnSuccess?.call();

          return _jsonParser(result.data);
        } on AppwriteException catch (e, s) {
          final failure = _onAppwriteException(e, s);

          Logger().e(
            '[ERROR] Error while creating document: $document',
            time: DateTime.now(),
            error: e,
            stackTrace: s,
          );

          _telemetryOnError?.call(failure);

          return Result.error(failure);
        } catch (e, s) {
          final failure = ServerFailure(
            error: e.toString(),
            stackTrace: s,
          );

          Logger().e(
            '[ERROR] Error while creating document: $document',
            time: DateTime.now(),
            error: e,
            stackTrace: s,
          );

          _telemetryOnError?.call(failure);

          return Result.error(failure);
        }
      case Error<Map<String, dynamic>>(exception: final failure):
        return Result.error(failure);
    }
  }

  @override
  Future<Result<void>> delete({required String documentId}) async {
    _logger?.d('[START] Deleting document: $documentId');

    final connectivityResult =
        await _connectivityClient.checkInternetConnection();

    if (connectivityResult.isError) {
      return Result.error(
        NoInternetConnectionFailure(),
      );
    }

    try {
      await _db.deleteDocument(
          databaseId: _databaseId,
          collectionId: _collectionId,
          documentId: documentId);

      _logger?.d('[SUCCESS] Deleted document: ${documentId.toString()}');

      _telemetryOnSuccess?.call();

      return Result.success(null);
    } on AppwriteException catch (e, s) {
      final failure = _onAppwriteException(e, s);

      Logger().e(
        '[ERROR] Error while deleting document: $documentId',
        time: DateTime.now(),
        error: e,
        stackTrace: s,
      );

      _telemetryOnError?.call(failure);

      return Result.error(failure);
    } catch (e, s) {
      final failure = ServerFailure(
        error: e.toString(),
        stackTrace: s,
      );

      Logger().e(
        '[ERROR] Error while deleting document: $documentId',
        time: DateTime.now(),
        error: e,
        stackTrace: s,
      );

      _telemetryOnError?.call(failure);

      return Result.error(failure);
    }
  }

  @override
  Future<Result<T>> get(
      {required String documentId, List<String>? queries}) async {
    _logger?.d('[START] Getting document: $documentId');

    final connectivityResult =
        await _connectivityClient.checkInternetConnection();

    if (connectivityResult.isError) {
      return Result.error(
        NoInternetConnectionFailure(),
      );
    }

    try {
      final result = await _db.getDocument(
          databaseId: _databaseId,
          collectionId: _collectionId,
          documentId: documentId,
          queries: queries);

      _logger?.d('[SUCCESS] Got document: ${result.data.toString()}');

      _telemetryOnSuccess?.call();

      return _jsonParser(result.data);
    } on AppwriteException catch (e, s) {
      final failure = _onAppwriteException(e, s);

      Logger().e(
        '[ERROR] Error while getting document: $documentId',
        time: DateTime.now(),
        error: e,
        stackTrace: s,
      );

      _telemetryOnError?.call(failure);

      return Result.error(failure);
    } catch (e, s) {
      final failure = ServerFailure(
        error: e.toString(),
        stackTrace: s,
      );

      Logger().e(
        '[ERROR] Error while getting document: $documentId',
        time: DateTime.now(),
        error: e,
        stackTrace: s,
      );

      _telemetryOnError?.call(failure);

      return Result.error(failure);
    }
  }

  @override
  Future<Result<List<T>>> list({
    List<String>? queries,
  }) async {
    _logger?.d('''
        [START] Listing documents 
        with queries: $queries
        databaseId: $_databaseId
        collectionId: $_collectionId

      ''');

    final connectivityResult =
        await _connectivityClient.checkInternetConnection();

    if (connectivityResult.isError) {
      _logger?.d('[ERROR] Error while listing documents');

      return Result.error(
        NoInternetConnectionFailure(),
      );
    }

    try {
      final result = await _db.listDocuments(
        databaseId: _databaseId,
        collectionId: _collectionId,
        queries: queries,
      );

      _logger?.d('[SUCCESS] Listed documents: ${result.documents.toString()}');

      _telemetryOnSuccess?.call();

      _logger?.d('[PARSING] Parsing documents: ${result.documents.toString()}');

      return Result.guard(
          () => result.documents.map((e) => _fromJson(e.data)).toList(),
          onError: (e, s) {
        final failure = FromJsonFailure(
          error: e.toString(),
          stackTrace: s,
        );

        _logger?.e(
          '[ERROR] Error while parsing documents: ${result.documents.toString()}',
          time: DateTime.now(),
          error: e,
          stackTrace: s,
        );

        _telemetryOnError?.call(failure);

        return failure;
      });
    } on AppwriteException catch (e, s) {
      final failure = _onAppwriteException(e, s);

      log('AppWriteException: ${e.toString()}');

      Logger().e(
        '[ERROR] AppwriteError while listing documents',
        time: DateTime.now(),
        error: e,
        stackTrace: s,
      );

      _telemetryOnError?.call(failure);

      return Result.error(failure);
    } catch (e, s) {
      final failure = ServerFailure(
        error: e.toString(),
        stackTrace: s,
      );

      log('Exception: ${e.toString()}');

      Logger().e(
        '[ERROR] Error while listing documents',
        time: DateTime.now(),
        error: e,
        stackTrace: s,
      );

      _telemetryOnError?.call(failure);

      return Result.error(failure);
    }
  }

  @override
  Future<Result<T>> update(
      {required String documentId,
      required T document,
      List<String>? permissions}) async {
    _logger?.d('[START] Updating document: $documentId');

    final connectivityResult =
        await _connectivityClient.checkInternetConnection();

    if (connectivityResult.isError) {
      return Result.error(
        NoInternetConnectionFailure(),
      );
    }

    final jsonResult = await _jsonSerializer(document);

    switch (jsonResult) {
      case Success<Map<String, dynamic>>(value: final data):
        try {
          final result = await _db.updateDocument(
            databaseId: _databaseId,
            collectionId: _collectionId,
            documentId: documentId,
            data: data,
            permissions: permissions,
          );

          _logger?.d('[SUCCESS] Updated document: ${result.data.toString()}');

          _telemetryOnSuccess?.call();

          return _jsonParser(result.data);
        } on AppwriteException catch (e, s) {
          final failure = _onAppwriteException(e, s);

          Logger().e(
            '[ERROR] Error while updating document: $documentId',
            time: DateTime.now(),
            error: e,
            stackTrace: s,
          );

          _telemetryOnError?.call(failure);

          return Result.error(failure);
        } catch (e, s) {
          final failure = ServerFailure(
            error: e.toString(),
            stackTrace: s,
          );

          Logger().e(
            '[ERROR] Error while updating document: $documentId',
            time: DateTime.now(),
            error: e,
            stackTrace: s,
          );

          _telemetryOnError?.call(failure);

          return Result.error(failure);
        }
      case Error<Map<String, dynamic>>(exception: final failure):
        return Result.error(failure);
    }
  }

  @override
  Future<Result<List<T>>> paginatedList(
      {required int offset, required int limit, List<String>? queries}) async {
    _logger?.d('[START] Paginated listing documents');

    final connectivityResult =
        await _connectivityClient.checkInternetConnection();

    if (connectivityResult.isError) {
      _logger?.d('[ERROR] Error while paginated listing documents');

      return Result.error(
        NoInternetConnectionFailure(),
      );
    }

    try {
      final result = await _db.listDocuments(
          databaseId: _databaseId,
          collectionId: _collectionId,
          queries: queries != null
              ? [
                  ...queries,
                  Query.limit(limit),
                  Query.offset(offset),
                ]
              : [
                  Query.limit(limit),
                  Query.offset(offset),
                ]);

      _logger?.d(
          '[SUCCESS] Paginated listed documents: ${result.documents.toString()}');

      _telemetryOnSuccess?.call();

      _logger?.d('[PARSING] Parsing documents: ${result.documents.toString()}');

      return Result.guard(
          () => result.documents.map((e) => _fromJson(e.data)).toList(),
          onError: (e, s) {
        final failure = FromJsonFailure(
          error: e.toString(),
          stackTrace: s,
        );

        _logger?.e(
          '[ERROR] Error while parsing documents: ${result.documents.toString()}',
          time: DateTime.now(),
          error: e,
          stackTrace: s,
        );

        _telemetryOnError?.call(failure);

        return failure;
      });
    } on AppwriteException catch (e, s) {
      final failure = _onAppwriteException(e, s);

      Logger().e(
        '[ERROR] Error while paginated listing documents',
        time: DateTime.now(),
        error: e,
        stackTrace: s,
      );

      _telemetryOnError?.call(failure);

      return Result.error(failure);
    } catch (e, s) {
      final failure = ServerFailure(
        error: e.toString(),
        stackTrace: s,
      );

      Logger().e(
        '[ERROR] Error while paginated listing documents',
        time: DateTime.now(),
        error: e,
        stackTrace: s,
      );

      _telemetryOnError?.call(failure);

      return Result.error(failure);
    }
  }

  @override
  Future<Result<void>> deleteMany({required List<String> documentIds}) async {
    _logger?.d('[START] Deleting documents: $documentIds');

    final connectivityResult =
        await _connectivityClient.checkInternetConnection();

    if (connectivityResult.isError) {
      return Result.error(
        NoInternetConnectionFailure(),
      );
    }

    try {
      await Future.wait(
        [
          for (var documentId in documentIds)
            _db.deleteDocument(
                databaseId: _databaseId,
                collectionId: _collectionId,
                documentId: documentId)
        ],
        eagerError: true,
      );

      _logger?.d('[SUCCESS] Deleted documents: ${documentIds.toString()}');

      _telemetryOnSuccess?.call();

      return Result.success(null);
    } on AppwriteException catch (e, s) {
      final failure = _onAppwriteException(e, s);

      Logger().e(
        '[ERROR] Error while deleting documents: $documentIds',
        time: DateTime.now(),
        error: e,
        stackTrace: s,
      );

      _telemetryOnError?.call(failure);

      return Result.error(failure);
    } catch (e, s) {
      final failure = ServerFailure(
        error: e.toString(),
        stackTrace: s,
      );

      Logger().e(
        '[ERROR] Error while deleting documents: $documentIds',
        time: DateTime.now(),
        error: e,
        stackTrace: s,
      );

      _telemetryOnError?.call(failure);

      return Result.error(failure);
    }
  }
}
