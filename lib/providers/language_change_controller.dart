import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageChangeProvider with ChangeNotifier {
  Locale? _appLocale;
  Locale? get appLocale => _appLocale;

  int selectedIndex;

  LanguageChangeProvider({required this.selectedIndex, required context}) {
    initSelectedLanguage(context);
  }

  Future<void> initSelectedLanguage(BuildContext context) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? languageCode = sp.getString('language_code');

    if (context.mounted) {
      if (languageCode == null) {
        _appLocale = getCurrentAppLocale(context);
        await sp.setString('language_code', _appLocale!.languageCode);
        languageCode = _appLocale!.languageCode;
        print(sp.getString('language_code'));
      }
    }

    if (languageCode == 'en') {
      selectedIndex = 0;
      _appLocale = const Locale('en');
    } else if (languageCode == 'es') {
      selectedIndex = 1;
      _appLocale = const Locale('es');
    } else if (languageCode == 'ca') {
      selectedIndex = 2;
      _appLocale = const Locale('ca');
    } else if (languageCode == 'de') {
      selectedIndex = 3;
      _appLocale = const Locale('de');
    } else if (languageCode == 'sv') {
      selectedIndex = 4;
      _appLocale = const Locale('sv');
    } else {
      selectedIndex = 0;
      _appLocale = const Locale('en');
    }
    print(selectedIndex);
    notifyListeners();
  }

  void changeLanguage(Locale type, int index, BuildContext context) async {
    if (context.mounted) {
      context.setLocale(type);
      print(index);
      selectedIndex = index;
      SharedPreferences sp = await SharedPreferences.getInstance();
      _appLocale = type;
      print(_appLocale!.languageCode);

      if (type == const Locale('en')) {
        await sp.setString('language_code', 'en');
      } else if (type == const Locale('es')) {
        await sp.setString('language_code', 'es');
      } else if (type == const Locale('ca')) {
        await sp.setString('language_code', 'ca');
      } else if (type == const Locale('de')) {
        await sp.setString('language_code', 'de');
      } else if (type == const Locale('sv')) {
        await sp.setString('language_code', 'sv');
      }

      notifyListeners();
    }
  }

  Locale getCurrentAppLocale(BuildContext context) {
    return View.of(context).platformDispatcher.locale;
  }
}
