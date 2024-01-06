import 'package:appwrite_client/src/appwrite_failure.dart';
import 'package:common_classes/common_classes.dart';

/// Base class for all Appwrite clients
///
/// [T] is the type of the document
///
abstract class AppwriteClient<T> {
  /// Get document by id
  ///
  /// [documentId] is the id of the document
  ///
  /// [queries] is a list of queries to filter the documents
  ///
  /// Returns a [Result] with the document
  ///
  /// Throws an [NotFoundFailure] if the document is not found
  ///
  /// Throws an [UnauthorizedFailure] if the user is not authorized
  ///
  /// Throws an [ForbiddenFailure] if the user is not authorized
  ///
  /// Throws an [FromJsonFailure] if parsing the json fails
  ///
  Future<Result<T>> get({
    required String documentId,
    List<String>? queries,
  });

  /// Create a document
  ///
  /// [documentId] is the id of the document. If null, a new id will be generated
  ///
  /// [document] is the document to create
  ///
  /// [permissions] is a list of permissions to set for the document
  ///
  /// Returns a [Result] with the document
  ///
  /// Throws an [UnauthorizedFailure] if the user is not authorized
  ///
  /// Throws an [ForbiddenFailure] if the user is not authorized
  ///
  /// Throws an [ToJsonFailure] if serializing the document to json fails
  ///
  Future<Result<T>> create({
    String? documentId,
    required T document,
    List<String>? permissions,
  });

  /// Update a document
  ///
  /// [documentId] is the id of the document
  ///
  /// [document] is the document to update
  ///
  /// [permissions] is a list of permissions to set for the document
  ///
  /// Returns a [Result] with the document
  ///
  /// Throws an [UnauthorizedFailure] if the user is not authorized
  ///
  /// Throws an [ForbiddenFailure] if the user is not authorized
  ///
  /// Throws an [ToJsonFailure] if serializing the document to json fails
  ///
  /// Throws an [FromJsonFailure] if parsing the json fails
  ///
  /// Throws an [NotFoundFailure] if the document is not found
  ///
  Future<Result<T>> update({
    required String documentId,
    required T document,
    List<String>? permissions,
  });

  /// Delete a document
  ///
  /// [documentId] is the id of the document
  ///
  /// Returns a [Result] with void
  ///
  /// Throws an [UnauthorizedFailure] if the user is not authorized
  ///
  /// Throws an [ForbiddenFailure] if the user is not authorized
  ///
  /// Throws an [NotFoundFailure] if the document is not found
  ///
  Future<Result<void>> delete({required String documentId});

  /// Delete documents
  ///
  /// [documentIds] is a list of document ids to delete
  ///
  /// Returns a [Result] with void
  ///
  /// Throws an [UnauthorizedFailure] if the user is not authorized
  ///
  /// Throws an [ForbiddenFailure] if the user is not authorized
  ///
  Future<Result<void>> deleteMany({required List<String> documentIds});

  /// List documents
  ///
  /// [queries] is a list of queries to filter the documents
  ///
  /// Returns a [Result] with a list of documents
  ///
  /// Throws an [UnauthorizedFailure] if the user is not authorized
  ///
  /// Throws an [ForbiddenFailure] if the user is not authorized
  ///
  /// Throws an [FromJsonFailure] if parsing the json fails
  ///
  Future<Result<List<T>>> list({
    List<String>? queries,
  });

  /// List documents with pagination
  ///
  /// [offset] is the offset of the list
  ///
  /// [limit] is the limit of the list
  ///
  /// [queries] is a list of queries to filter the documents
  ///
  /// Returns a [Result] with a list of documents
  ///
  /// Throws an [UnauthorizedFailure] if the user is not authorized
  ///
  /// Throws an [ForbiddenFailure] if the user is not authorized
  ///
  /// Throws an [FromJsonFailure] if parsing the json fails
  ///
  Future<Result<void>> paginatedList(
      {required int offset, required int limit, List<String>? queries});
}
