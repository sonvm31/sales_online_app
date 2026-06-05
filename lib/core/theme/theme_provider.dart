import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier{
  static const String _themeKey = "is_dark_mode";

  ThemeMode _currTheme = ThemeMode.light;
  ThemeMode get currTheme => _currTheme;

  ThemeProvider(){
    _loadThemeFromPrefs();
  }

  Future<void> _loadThemeFromPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final bool isDark = prefs.getBool(_themeKey) ?? false;

    _currTheme = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if(_currTheme == ThemeMode.light){
      _currTheme = ThemeMode.dark;
      await prefs.setBool(_themeKey, true);
    }else {
      _currTheme = ThemeMode.light;
      await prefs.setBool(_themeKey, false);
    }
    notifyListeners();
  }
}