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
import '../student/task_form_screen.dart';

class TeacherShell extends StatelessWidget {
  const TeacherShell({super.key});

  @override
  Widget build(BuildContext context) {
    final me = context.watch<AppUser>();
    return MultiProvider(
      providers: [
        ProxyProvider<TaskProvider, List<Task>>(update: (_, t, __) => t.all),
        ProxyProvider<AuthProvider, List<AppUser>>(update: (_, a, __) => a.students),
      ],
      child: Builder(
        builder: (c) => AppShell(
          items: const [
            NavItem(Icons.home_rounded, 'Home'),
            NavItem(Icons.assignment, 'Tasks'),
            NavItem(Icons.groups, 'Students'),
            NavItem(Icons.settings, 'Settings'),
          ],
          pages: const [_TeacherHome(), _TeacherTasks(), _TeacherStudents(), SettingsTab()],
          onFab: () => Navigator.push(
              c, MaterialPageRoute(builder: (_) => TaskFormScreen(me: me, assign: true, students: c.read<List<AppUser>>()))),
        ),
      ),
    );
  }
}

List<Task> _mine(BuildContext c) {
  final me = c.watch<AppUser>();
  return c.watch<List<Task>>().where((t) => t.assignedBy == me.uid).toList();
}

Widget _tiles(BuildContext c, List<Task> list) {
  final me = c.watch<AppUser>();
  final students = c.watch<List<AppUser>>();
  final names = {for (final s in students) s.uid: s.name};
  if (list.isEmpty) return const EmptyState('Nothing assigned yet. Tap + to assign a task.');
  return Column(children: [
    for (final t in list)
      TaskTile(
          task: t,
          extra: names[t.ownerId] ?? t.subject,
          onEdit: () => Navigator.push(
              c, MaterialPageRoute(builder: (_) => TaskFormScreen(me: me, assign: true, task: t, students: students)))),
  ]);
}

class _TeacherHome extends StatelessWidget {
  const _TeacherHome();
  @override
  Widget build(BuildContext context) {
    final me = context.watch<AppUser>();
    final students = context.watch<List<AppUser>>();
    final mine = _mine(context);
    final done = mine.where((t) => t.done).length;
    final pct = mine.isEmpty ? 0.0 : done / mine.length;
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      HeroCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Welcome back,', style: TextStyle(color: Colors.white70)),
          Text('${me.name} 👋', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          Text('Class completion ${(pct * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: pct, minHeight: 8, backgroundColor: Colors.white24, color: AppColors.ok)),
        ]),
      ),
      const SizedBox(height: 14),
      statGrid([
        StatCard(icon: Icons.groups, color: AppColors.primary, value: '${students.length}', label: 'Students'),
        StatCard(icon: Icons.assignment, color: AppColors.warn, value: '${mine.length}', label: 'Tasks Assigned'),
        StatCard(icon: Icons.check_circle, color: AppColors.ok, value: '$done', label: 'Completed'),
        StatCard(icon: Icons.pending_actions, color: AppColors.bad, value: '${mine.length - done}', label: 'Pending'),
      ]),
      const SectionHeader('Recent Assignments'),
      _tiles(context, mine.reversed.take(3).toList()),
    ]);
  }
}

class _TeacherTasks extends StatelessWidget {
  const _TeacherTasks();
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
        const Text('Assigned Tasks', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        _tiles(context, _mine(context)),
      ]);
}

class _TeacherStudents extends StatelessWidget {
  const _TeacherStudents();
  @override
  Widget build(BuildContext context) {
    final students = context.watch<List<AppUser>>();
    final all = context.watch<List<Task>>();
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      const Text('Student Progress', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      if (students.isEmpty) const EmptyState('No students have registered yet.'),
      for (final s in students)
        Builder(builder: (_) {
          final t = all.where((x) => x.ownerId == s.uid).toList();
          final d = t.where((x) => x.done).length;
          final p = t.isEmpty ? 0.0 : d / t.length;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: cardDeco(context, r: 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text('${(p * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
              ]),
              Text('${s.email} • $d/${t.length} tasks', style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
              const SizedBox(height: 8),
              ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: p, minHeight: 7)),
            ]),
          );
        }),
    ]);
  }
}
