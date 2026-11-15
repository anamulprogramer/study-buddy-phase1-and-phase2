// PHASE 2 - Provider state, CRUD, validation, local storage
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode mode = ThemeMode.system;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    mode = ThemeMode.values.byName(p.getString('theme') ?? 'system');
  }

  Future<void> set(ThemeMode m) async {
    mode = m;
    notifyListeners();
    (await SharedPreferences.getInstance()).setString('theme', m.name);
  }
}
