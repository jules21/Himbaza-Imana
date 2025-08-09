import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indirimbo/theme/dark_theme.dart';
import 'package:indirimbo/theme/light_theme.dart';

class ThemeProvider extends ChangeNotifier{

  bool _isDark = false;

  bool get isDark => _isDark;

  set isDark(bool isDark){
    _isDark = isDark;
    notifyListeners();
  }

  void toggleTheme(){
    isDark = !_isDark;
  }

  //get mode
  ThemeData get themeData => _isDark ? darkMode : lightMode;


}