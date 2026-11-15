// PHASE 1 + 2 - UI screen that uses Provider state
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../models/app_user.dart';
import '../../models/task.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/common.dart';
import '../common/settings_tab.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({super.key});

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ProxyProvider<AuthProvider, List<AppUser>>(update: (_, a, __) => a.users),
          ProxyProvider<TaskProvider, List<Task>>(update: (_, t, __) => t.all),
        ],
        child: const AppShell(
          items: [
            NavItem(Icons.dashboard, 'Overview'),
            NavItem(Icons.people, 'Users'),
            NavItem(Icons.insights, 'Reports'),
            NavItem(Icons.settings, 'Settings'),
          ],
          pages: [_Overview(), _Users(), _Reports(), SettingsTab()],
        ),
      );
}

Widget _title(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 12), child: Text(t, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)));

class _Overview extends StatelessWidget {
  const _Overview();
  @override
  Widget build(BuildContext context) {
    final users = context.watch<List<AppUser>>();
    final tasks = context.watch<List<Task>>();
    int n(String r) => users.where((u) => u.role == r).length;
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      const HeroCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Admin Panel', style: TextStyle(color: Colors.white70)),
        Text('System Overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
      ])),
      const SizedBox(height: 14),
      statGrid([
        StatCard(icon: Icons.people, color: AppColors.primary, value: '${users.length}', label: 'Total Users'),
        StatCard(icon: Icons.cast_for_education, color: AppColors.warn, value: '${n('teacher')}', label: 'Teachers'),
        StatCard(icon: Icons.menu_book, color: AppColors.ok, value: '${n('student')}', label: 'Students'),
        StatCard(icon: Icons.block, color: AppColors.bad, value: '${users.where((u) => !u.active).length}', label: 'Blocked'),
        StatCard(icon: Icons.assignment, color: Colors.blue, value: '${tasks.length}', label: 'Total Tasks'),
        StatCard(icon: Icons.badge, color: Colors.teal, value: '${users.where((u) => u.idStatus == 'submitted').length}', label: 'IDs Submitted'),
      ]),
    ]);
  }
}

class _Users extends StatelessWidget {
  const _Users();
  @override
  Widget build(BuildContext context) {
    final users = context.watch<List<AppUser>>();
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      _title('Manage Users'),
      if (users.isEmpty) const EmptyState('No users yet.'),
      for (final u in users)
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: cardDeco(context, r: 16),
          child: Row(children: [
            CircleAvatar(backgroundColor: AppColors.primary.withOpacity(.12), child: Text(u.name.isEmpty ? '?' : u.name[0].toUpperCase())),
            const SizedBox(width: 12),
            Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(u.name, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text('${u.role} • ${u.email}', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
              Text(u.active ? 'Active' : 'Blocked', style: TextStyle(fontSize: 12, color: u.active ? AppColors.ok : AppColors.bad)),
            ])),
            Switch(
                value: u.active,
                onChanged: u.role == 'admin' ? null : (v) => context.read<AuthProvider>().setActive(u.uid, v)),
          ]),
        ),
    ]);
  }
}

class _Reports extends StatelessWidget {
  const _Reports();
  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<List<Task>>();
    final done = tasks.where((t) => t.done).length;
    final pct = tasks.isEmpty ? 0.0 : done / tasks.length;
    final bySubject = <String, int>{};
    for (final t in tasks) {
      bySubject[t.subject] = (bySubject[t.subject] ?? 0) + 1;
    }
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      _title('Reports'),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: cardDeco(context),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Overall completion', style: TextStyle(color: Theme.of(context).hintColor)),
          Text('${(pct * 100).round()}%', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: pct, minHeight: 8)),
          const SizedBox(height: 6),
          Text('$done of ${tasks.length} tasks completed', style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
        ]),
      ),
      const SectionHeader('Tasks by Subject'),
      if (bySubject.isEmpty) const EmptyState('No task data yet.'),
      for (final e in bySubject.entries)
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: cardDeco(context, r: 16),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('${e.value} tasks', style: const TextStyle(fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 8),
            ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: e.value / tasks.length, minHeight: 7)),
          ]),
        ),
    ]);
  }
}
