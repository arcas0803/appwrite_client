import 'package:appwrite_client/localization/appwrite_localizations.dart';
import 'package:appwrite_client/src/appwrite_failure.dart';
import 'package:flutter/widgets.dart';

class AppwriteFailureUtil {
  static String getFailureNameUI({
    required BuildContext context,
    required AppwriteFailure failure,
  }) {
    switch (failure) {
      case FromJsonFailure():
        return AppwriteLocalizations.of(context)!.fromJsonFailed;
      case ToJsonFailure():
        return AppwriteLocalizations.of(context)!.toJsonFailed;
      case UnauthorizedFailure():
        return AppwriteLocalizations.of(context)!.unauthorized;
      case NotFoundFailure():
        return AppwriteLocalizations.of(context)!.notFound;
      case ForbiddenFailure():
        return AppwriteLocalizations.of(context)!.forbidden;
      case ServerFailure():
        return AppwriteLocalizations.of(context)!.serverFailure;
    }
  }
}
