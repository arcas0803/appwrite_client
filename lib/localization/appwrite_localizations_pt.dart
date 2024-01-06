import 'appwrite_localizations.dart';

/// The translations for Portuguese (`pt`).
class AppwriteLocalizationsPt extends AppwriteLocalizations {
  AppwriteLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get notFound => 'Nenhum resultado foi encontrado para a solicitação realizada';

  @override
  String get unauthorized => 'Você não tem permissão para acessar este recurso. Se o problema persistir, entre em contato com o administrador do sistema';

  @override
  String get forbidden => 'Você não tem permissão para acessar este recurso. Se o problema persistir, entre em contato com o administrador do sistema';

  @override
  String get fromJsonFailed => 'Falha ao desserializar JSON';

  @override
  String get toJsonFailed => 'Erro ao serializar JSON';

  @override
  String get serverFailure => 'Ocorreu um erro no servidor. Se o problema persistir, entre em contato com o administrador do sistema';
}
