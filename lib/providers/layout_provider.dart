import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LayoutProvider extends ChangeNotifier {
  static const _newLayoutKey = 'new_app_layout';
  bool _usesNewLayout = true;

  LayoutProvider() {
    _loadLayout();
  }

  bool get usesNewLayout => _usesNewLayout;

  Future<void> _loadLayout() async {
    final preferences = await SharedPreferences.getInstance();
    _usesNewLayout = preferences.getBool(_newLayoutKey) ?? true;
    notifyListeners();
  }

  Future<void> toggleLayout() async {
    _usesNewLayout = !_usesNewLayout;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_newLayoutKey, _usesNewLayout);
  }
}
