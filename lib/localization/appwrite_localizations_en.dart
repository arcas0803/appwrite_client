import 'appwrite_localizations.dart';

/// The translations for English (`en`).
class AppwriteLocalizationsEn extends AppwriteLocalizations {
  AppwriteLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get notFound => 'No results were found for the request made';

  @override
  String get unauthorized => 'You do not have permissions to access this resource. If the problem persists, please contact your system administrator';

  @override
  String get forbidden => 'You do not have permissions to access this resource. If the problem persists, please contact your system administrator';

  @override
  String get fromJsonFailed => 'Failed to deserialize JSON';

  @override
  String get toJsonFailed => 'Error serializing JSON';

  @override
  String get serverFailure => 'A server error has occurred. If the problem persists, please contact your system administrator';
}
