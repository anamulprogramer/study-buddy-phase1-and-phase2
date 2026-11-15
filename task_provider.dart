// PHASE 2 - Provider state, CRUD, validation, local storage
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

/// Task CRUD + Pomodoro sessions. Every change calls notifyListeners() so the UI updates.
class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  List<Session> _sessions = [];
  int _n = 0;

  String _id() => 't${DateTime.now().microsecondsSinceEpoch}_${_n++}';

  // ---- READ ----
  List<Task> get all => _sorted(_tasks);
  List<Task> forUser(String uid) => _sorted(_tasks.where((t) => t.ownerId == uid));
  List<Task> assignedBy(String uid) => _sorted(_tasks.where((t) => t.assignedBy == uid));
  List<Session> sessionsFor(String uid) => _sessions.where((s) => s.ownerId == uid).toList();

  List<Task> _sorted(Iterable<Task> l) {
    final far = DateTime(2100);
    return l.toList()..sort((a, b) => (a.due ?? far).compareTo(b.due ?? far));
  }

  // ---- CREATE / UPDATE ----
  /// New task when [t.id] is empty, otherwise updates the existing one.
  Future<void> save(Task t) async {
    if (t.id.isEmpty) {
      _tasks.add(t.copyWith(id: _id()));
    } else {
      final i = _tasks.indexWhere((x) => x.id == t.id);
      if (i >= 0) _tasks[i] = t;
    }
    await _commit();
  }

  /// Teacher: create one copy of [base] for every student id.
  Future<void> assign(Task base, List<String> uids) async {
    for (final u in uids) {
      _tasks.add(base.copyWith(id: _id(), ownerId: u, done: false));
    }
    await _commit();
  }

  Future<void> toggle(Task t) async {
    final i = _tasks.indexWhere((x) => x.id == t.id);
    if (i >= 0) _tasks[i] = _tasks[i].copyWith(done: !_tasks[i].done);
    await _commit();
  }

  // ---- DELETE ----
  Future<void> delete(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await _commit();
  }

  Future<void> addSession(String uid, int minutes) async {
    _sessions.add(Session(uid, DateTime.now(), minutes));
    await _commit();
  }

  // ---- storage ----
  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('tasks');
    if (raw == null) {
      _seedDemo();
      await _save();
    } else {
      _tasks = (jsonDecode(raw) as List).map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
      final s = p.getString('sessions');
      if (s != null) _sessions = (jsonDecode(s) as List).map((e) => Session.fromJson(e as Map<String, dynamic>)).toList();
    }
    notifyListeners();
  }

  void _seedDemo() {
    final n = DateTime.now(), d = DateTime(n.year, n.month, n.day);
    _tasks = [
      Task(id: 't1', ownerId: 'u_student', title: 'Data Structures Exam Prep', subject: 'CSE', priority: 'High', due: d.add(const Duration(hours: 22))),
      Task(id: 't2', ownerId: 'u_student', title: 'Software Requirement Spec', subject: 'Software Engineering', priority: 'Medium', due: d.add(const Duration(days: 1, hours: 9)), done: true),
      Task(id: 't3', ownerId: 'u_student', title: 'Cryptography Notes', subject: 'Mathematics', priority: 'Low', due: d.add(const Duration(days: 2, hours: 14))),
    ];
    _sessions = [
      Session('u_student', n, 50),
      Session('u_student', n.subtract(const Duration(days: 1)), 25),
      Session('u_student', n.subtract(const Duration(days: 2)), 75),
    ];
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('tasks', jsonEncode(_tasks.map((t) => t.toJson()).toList()));
    await p.setString('sessions', jsonEncode(_sessions.map((s) => s.toJson()).toList()));
  }

  Future<void> _commit() async {
    notifyListeners();
    await _save();
  }
}
