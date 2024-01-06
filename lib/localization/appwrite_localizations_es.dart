import 'appwrite_localizations.dart';

/// The translations for Spanish Castilian (`es`).
class AppwriteLocalizationsEs extends AppwriteLocalizations {
  AppwriteLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get notFound => 'No se encontraron resultados para la solicitud realizada';

  @override
  String get unauthorized => 'No tiene permisos para acceder a este recurso. Si el problema persiste, por favor contacte al administrador del sistema';

  @override
  String get forbidden => 'No tiene permisos para acceder a este recurso. Si el problema persiste, por favor contacte al administrador del sistema';

  @override
  String get fromJsonFailed => 'Error al deserializar JSON';

  @override
  String get toJsonFailed => 'Error al serializar JSON';

  @override
  String get serverFailure => 'Se ha producido un error en el servidor. Si el problema persiste, por favor contacte al administrador del sistema';
}
