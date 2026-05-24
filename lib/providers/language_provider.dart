import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const List<Locale> _supportedLocales = [
    Locale('uz'),
    Locale('ru'),
    Locale('en'),
    Locale('lv'),
  ];

  Locale _locale = const Locale('uz');
  bool _isFirstTime = true;
  bool _isLoaded = false;

  Locale get locale => _locale;
  bool get isFirstTime => _isFirstTime;
  bool get isLoaded => _isLoaded;

  static List<Locale> get supportedLocales => _supportedLocales;

  LanguageProvider() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    final langCode = prefs.getString('language_code');
    final firstTime = prefs.getBool('first_time');

    if (langCode != null &&
        _supportedLocales.any(
              (locale) => locale.languageCode == langCode,
        )) {
      _locale = Locale(langCode);
    } else {
      _locale = const Locale('uz');
    }

    _isFirstTime = firstTime ?? true;
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setLanguage(Locale locale) async {
    _locale = locale;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);

    notifyListeners();
  }

  Future<void> completeFirstTime() async {
    _isFirstTime = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', false);

    notifyListeners();
  }

  Future<void> resetFirstTime() async {
    _isFirstTime = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', true);

    notifyListeners();
  }

  String getLanguageName(String code) {
    switch (code) {
      case 'uz':
        return 'O\'zbek';
      case 'ru':
        return 'Русский';
      case 'en':
        return 'English';
      case 'lv':
        return 'Latviešu';
      default:
        return 'O\'zbek';
    }
  }

  String getLanguageNativeName(String code) {
    switch (code) {
      case 'uz':
        return 'O\'zbek tili';
      case 'ru':
        return 'Русский язык';
      case 'en':
        return 'English language';
      case 'lv':
        return 'Latviešu valoda';
      default:
        return 'O\'zbek tili';
    }
  }

  String getLanguageFlag(String code) {
    switch (code) {
      case 'uz':
        return '🇺🇿';
      case 'ru':
        return '🇷🇺';
      case 'en':
        return '🇬🇧';
      case 'lv':
        return '🇱🇻';
      default:
        return '🇺🇿';
    }
  }

  String getLanguageDescription(String code) {
    switch (code) {
      case 'uz':
        return 'Davlat tili';
      case 'ru':
        return 'Русский интерфейс';
      case 'en':
        return 'International';
      case 'lv':
        return 'Valsts valoda';
      default:
        return 'Davlat tili';
    }
  }
}