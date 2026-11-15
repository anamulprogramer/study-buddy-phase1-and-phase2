// PHASE 2 - Provider state, CRUD, validation, local storage
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';

class AppException implements Exception {
  final String message;
  AppException(this.message);
  @override
  String toString() => message;
}

String authError(Object e) => e.toString();
String _hash(String p) => sha256.convert(utf8.encode(p)).toString();

/// Accounts + login session, saved on the device (demo only: not a real backend).
class AuthProvider extends ChangeNotifier {
  List<AppUser> _users = [];
  String? _uid;
  bool ready = false;

  AppUser? get current {
    for (final u in _users) {
      if (u.uid == _uid) return u;
    }
    return null;
  }

  List<AppUser> get users => List.of(_users)..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  List<AppUser> get students => users.where((u) => u.role == 'student').toList();

  List<AppUser> _seed() => [
        AppUser(uid: 'u_admin', name: 'Admin', email: 'admin@studybuddy.app', role: 'admin', idStatus: 'skipped', passHash: _hash('admin123')),
        AppUser(uid: 'u_teacher', name: 'Dr. Rahman', email: 'teacher@studybuddy.app', role: 'teacher', idStatus: 'skipped', passHash: _hash('teacher123')),
        AppUser(uid: 'u_student', name: 'Anamul Haque', email: 'student@studybuddy.app', role: 'student', idStatus: 'skipped', passHash: _hash('student123')),
      ];

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('users');
    if (raw == null) {
      _users = _seed();
      await _save();
    } else {
      _users = (jsonDecode(raw) as List).map((e) => AppUser.fromJson(e as Map<String, dynamic>)).toList();
    }
    _uid = p.getString('uid');
    ready = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('users', jsonEncode(_users.map((u) => u.toJson()).toList()));
    _uid == null ? await p.remove('uid') : await p.setString('uid', _uid!);
  }

  Future<void> _commit() async {
    notifyListeners();
    await _save();
  }

  AppUser _find(String email, String password) {
    final e = email.trim().toLowerCase();
    for (final u in _users) {
      if (u.email == e && u.passHash == _hash(password)) {
        if (!u.active) throw AppException('Your account has been blocked by an admin.');
        return u;
      }
    }
    throw AppException('Wrong email or password.');
  }

  Future<void> register({
    required String role,
    required String name,
    required String email,
    required String password,
    required String phone,
    required String idNumber,
  }) async {
    final e = email.trim().toLowerCase();
    if (role != 'student' && role != 'teacher') throw AppException('Invalid role.');
    if (_users.any((u) => u.email == e)) throw AppException('This email is already registered.');
    final u = AppUser(
        uid: 'u${DateTime.now().microsecondsSinceEpoch}', name: name, email: e, phone: phone,
        role: role, idNumber: idNumber, passHash: _hash(password));
    _users.add(u);
    _uid = u.uid;
    await _commit();
  }

  Future<void> login(String email, String password) async {
    _uid = _find(email, password).uid;
    await _commit();
  }

  Future<void> loginAdmin(String email, String password) async {
    final u = _find(email, password);
    if (u.role != 'admin') throw AppException('This account is not an admin.');
    _uid = u.uid;
    await _commit();
  }

  Future<void> google(String role) async =>
      throw AppException('Google sign-in needs an online backend. Use email login in this version.');

  Future<void> resetPassword(String email, String newPassword) async {
    if (newPassword.length < 6) throw AppException('Password must be at least 6 characters.');
    final i = _users.indexWhere((u) => u.email == email.trim().toLowerCase());
    if (i < 0) throw AppException('No account with this email.');
    _users[i] = _users[i].copyWith(passHash: _hash(newPassword));
    await _commit();
  }

  void _update(String uid, AppUser Function(AppUser) f) {
    final i = _users.indexWhere((u) => u.uid == uid);
    if (i >= 0) _users[i] = f(_users[i]);
  }

  Future<void> uploadId(String uid, File file) async {
    _update(uid, (u) => u.copyWith(idStatus: 'submitted', idCardPath: file.path));
    await _commit();
  }

  Future<void> skipId(String uid) async {
    _update(uid, (u) => u.copyWith(idStatus: 'skipped'));
    await _commit();
  }

  Future<void> setActive(String uid, bool v) async {
    _update(uid, (u) => u.copyWith(active: v));
    await _commit();
  }

  Future<void> signOut() async {
    _uid = null;
    await _commit();
  }
}
