import 'dart:ui';
import 'package:codoky/core/config/localization/app_localizations.dart';
import 'package:codoky/core/utils/extensions/extensions.dart';

class Validators {
  static String? email(String? value, [AppLocalizations? l10n]) {
    final t = l10n ?? AppLocalizations(const Locale('vi'));
    if (value == null || value.trim().isEmpty) {
      return t.validEmailRequired;
    }
    if (!value.trim().isValidEmail()) {
      return t.validEmailInvalid;
    }
    return null;
  }

  static String? password(String? value, {int minLength = 8, AppLocalizations? l10n}) {
    final t = l10n ?? AppLocalizations(const Locale('vi'));
    if (value == null || value.isEmpty) {
      return t.validPasswordRequired;
    }
    if (value.length < minLength) {
      return t.validPasswordMinLength(minLength);
    }
    return null;
  }

  static String? confirmPassword(String? value, String? password, [AppLocalizations? l10n]) {
    final t = l10n ?? AppLocalizations(const Locale('vi'));
    if (value == null || value.isEmpty) {
      return t.validConfirmPasswordRequired;
    }
    if (value != password) {
      return t.validConfirmPasswordMismatch;
    }
    return null;
  }

  static String? required(String? value, {String fieldName = 'Trường này', AppLocalizations? l10n}) {
    final t = l10n ?? AppLocalizations(const Locale('vi'));
    if (value == null || value.trim().isEmpty) {
      return t.validFieldRequired(fieldName);
    }
    return null;
  }

  static String? phone(String? value, [AppLocalizations? l10n]) {
    final t = l10n ?? AppLocalizations(const Locale('vi'));
    if (value == null || value.trim().isEmpty) {
      return t.validPhoneRequired;
    }
    if (!value.trim().isValidPhoneNumber()) {
      return t.validPhoneInvalid;
    }
    return null;
  }

  static String? minLength(String? value, int minLength, {String fieldName = 'Trường này', AppLocalizations? l10n}) {
    final t = l10n ?? AppLocalizations(const Locale('vi'));
    if (value == null || value.isEmpty) {
      return t.validFieldRequired(fieldName);
    }
    if (value.length < minLength) {
      return t.validFieldMinLength(fieldName, minLength);
    }
    return null;
  }

  static String? maxLength(String? value, int maxLength, {String fieldName = 'Trường này', AppLocalizations? l10n}) {
    final t = l10n ?? AppLocalizations(const Locale('vi'));
    if (value != null && value.length > maxLength) {
      return t.validFieldMaxLength(fieldName, maxLength);
    }
    return null;
  }

  static String? rating(double? value, [AppLocalizations? l10n]) {
    final t = l10n ?? AppLocalizations(const Locale('vi'));
    if (value == null) {
      return t.validRatingRequired;
    }
    if (value < 1 || value > 5) {
      return t.validRatingRange;
    }
    return null;
  }
}
