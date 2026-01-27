import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'app_title': 'Acceptance Acts',
      'home_title': 'Acceptance Acts',
      'new_act': 'New Act',
      'save': 'Save',
      'download': 'Download',
      'delete': 'Delete',
      'confirm_deletion': 'Confirm Deletion',
      'delete_confirmation':
          'Are you sure you want to delete this acceptance act? This action cannot be undone.',
      'cancel': 'Cancel',
      'add_invoice': 'Add Invoice',
      'category': 'Category',
      'quantity': 'Quantity',
      'sum': 'Sum',
      'invoices': 'Invoices',
      'new_acceptance_act': 'New Acceptance Act',
      'auto_name': 'Auto Name',
      'act_name': 'Act Name',
      'create': 'Create',
      'edit_invoice': 'Edit Invoice',
      'price': 'Price',
      'unit': 'Unit',
      'choose_language': 'Choose Language',
    },
    'uk': {
      'app_title': 'Акти приймання',
      'home_title': 'Акти приймання',
      'new_act': 'Новий акт',
      'save': 'Зберегти',
      'download': 'Завантажити',
      'delete': 'Видалити',
      'confirm_deletion': 'Підтвердження видалення',
      'delete_confirmation':
          'Ви впевнені, що хочете видалити цей акт приймання? Цю дію неможливо скасувати.',
      'cancel': 'Скасувати',
      'add_invoice': 'Додати рахунок',
      'category': 'Категорія',
      'quantity': 'Кількість',
      'sum': 'Сума',
      'invoices': 'Рахунки',
      'new_acceptance_act': 'Новий акт приймання',
      'auto_name': 'Автоматична назва',
      'act_name': 'Назва акта',
      'create': 'Створити',
      'edit_invoice': 'Редагувати рахунок',
      'price': 'Ціна',
      'unit': 'Підрозділ',
      'choose_language': 'Оберіть мову',
    },
  };

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String get appTitle =>
      _localizedStrings[locale.languageCode]?['app_title'] ?? 'Acceptance Acts';

  String get homeTitle =>
      _localizedStrings[locale.languageCode]?['home_title'] ??
      'Acceptance Acts';

  String get newAct =>
      _localizedStrings[locale.languageCode]?['new_act'] ?? 'New Act';

  String get save => _localizedStrings[locale.languageCode]?['save'] ?? 'Save';

  String get download =>
      _localizedStrings[locale.languageCode]?['download'] ?? 'Download';

  String get delete =>
      _localizedStrings[locale.languageCode]?['delete'] ?? 'Delete';

  String get confirmDeletion =>
      _localizedStrings[locale.languageCode]?['confirm_deletion'] ??
      'Confirm Deletion';

  String get deleteConfirmation =>
      _localizedStrings[locale.languageCode]?['delete_confirmation'] ??
      'Are you sure you want to delete this acceptance act? This action cannot be undone.';

  String get cancel =>
      _localizedStrings[locale.languageCode]?['cancel'] ?? 'Cancel';

  String get addInvoice =>
      _localizedStrings[locale.languageCode]?['add_invoice'] ?? 'Add Invoice';

  String get category =>
      _localizedStrings[locale.languageCode]?['category'] ?? 'Category';

  String get quantity =>
      _localizedStrings[locale.languageCode]?['quantity'] ?? 'Quantity';

  String get sum => _localizedStrings[locale.languageCode]?['sum'] ?? 'Sum';

  String get invoices =>
      _localizedStrings[locale.languageCode]?['invoices'] ?? 'Invoices';

  String get newAcceptanceAct =>
      _localizedStrings[locale.languageCode]?['new_acceptance_act'] ??
      'New Acceptance Act';

  String get autoName =>
      _localizedStrings[locale.languageCode]?['auto_name'] ?? 'Auto Name';

  String get actName =>
      _localizedStrings[locale.languageCode]?['act_name'] ?? 'Act Name';

  String get create =>
      _localizedStrings[locale.languageCode]?['create'] ?? 'Create';

  String? get unit => _localizedStrings[locale.languageCode]?['unit'] ?? 'Unit';

  String? get price =>
      _localizedStrings[locale.languageCode]?['price'] ?? 'Price';

  String get editInvoice =>
      _localizedStrings[locale.languageCode]?['edit_invoice'] ?? 'Edit Invoice';

  String get chooseLanguage =>
      _localizedStrings[locale.languageCode]?['choose_language'] ??
      'Choose Language';
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'uk'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
