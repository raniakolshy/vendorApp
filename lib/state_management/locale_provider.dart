import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  // Initialisation de la locale par défaut
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  // Constructeur vide, la langue sera chargée plus tard
  LocaleProvider();

  /// Applique et sauvegarde la langue
  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners(); // Notifie les auditeurs du changement

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode); // Sauvegarde la langue
  }

  /// Charge la langue sauvegardée au démarrage
  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('locale') ?? 'en'; // Si pas de langue sauvegardée, utiliser 'en'
    _locale = Locale(code);
    notifyListeners(); // Notifie les auditeurs du changement de locale
  }
}