// PHASE 1 + 2 - UI screen that uses Provider state
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../models/app_user.dart';
import '../../models/task.dart';
import '../../providers/task_provider.dart';
import '../../widgets/common.dart';
import 'pomodoro_screen.dart';
import 'task_form_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final me = context.watch<AppUser>();
    final tasks = context.watch<List<Task>>();
    final sessions = context.watch<List<Session>>();
    final done = tasks.where((t) => t.done).length;
    final pct = tasks.isEmpty ? 0.0 : done / tasks.length;
    final now = DateTime.now();
    final todayMins = sessions.where((s) => sameDay(s.at, now)).fold<int>(0, (a, s) => a + s.minutes);
    final pending = tasks.length - done;

    void openForm([Task? t]) =>
        Navigator.push(context, MaterialPageRoute(builder: (_) => TaskFormScreen(me: me, task: t)));

    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      HeroCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Icon(Icons.menu, color: Colors.white),
            const Text('StudyBuddy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Badge(label: Text('$pending'), isLabelVisible: pending > 0, child: const Icon(Icons.notifications_none, color: Colors.white)),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Hello,', style: TextStyle(fontSize: 14, color: Colors.white70)),
              Text('${me.name} 👋', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const Text('Study Smart, Achieve More ✨', style: TextStyle(fontSize: 13, color: Colors.white70)),
            ])),
            const Icon(Icons.school, size: 64, color: Colors.white24),
          ]),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white.withOpacity(.14), borderRadius: BorderRadius.circular(18)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Keep Going!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const Text("You're doing great today!", style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(value: pct, minHeight: 8, backgroundColor: Colors.white24, color: AppColors.ok))),
                const SizedBox(width: 10),
                Text('${(pct * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w700)),
              ]),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 14),
      statGrid([
        StatCard(icon: Icons.assignment, color: AppColors.primary, value: '${tasks.length}', label: 'Total Tasks'),
        StatCard(icon: Icons.check_circle, color: AppColors.ok, value: '$done', label: 'Completed'),
        StatCard(icon: Icons.schedule, color: AppColors.warn, value: '$pending', label: 'Pending'),
        StatCard(icon: Icons.hourglass_bottom, color: Colors.blue, value: '${(todayMins / 60).toStringAsFixed(1)}h', label: 'Study Time'),
      ]),
      const SectionHeader('Upcoming Tasks'),
      if (tasks.isEmpty) const EmptyState('No tasks yet. Tap + to add your first one.'),
      for (final t in tasks.take(5))
        TaskTile(
            task: t,
            extra: t.subject,
            onToggle: () => context.read<TaskProvider>().toggle(t),
            onEdit: () => openForm(t)),
      const SizedBox(height: 10),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: cardDeco(context),
            child: Column(children: [
              const Text('Study Progress', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              SizedBox(
                  width: 90,
                  height: 90,
                  child: Stack(fit: StackFit.expand, children: [
                    CircularProgressIndicator(value: pct, strokeWidth: 9, backgroundColor: AppColors.primary.withOpacity(.12), color: AppColors.ok),
                    Center(child: Text('${(pct * 100).round()}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
                  ])),
              const SizedBox(height: 8),
              Text('Overall Progress', style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
            ]),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: cardDeco(context),
            child: Column(children: [
              const Text('Pomodoro Timer', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              const Text('25:00', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
              Text('Focus Time', style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
              const SizedBox(height: 12),
              GradientButton(
                  label: '▶ Start',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PomodoroScreen(uid: me.uid)))),
            ]),
          ),
        ),
      ]),
      const SizedBox(height: 14),
      HeroCard(
        child: Row(children: [
          const Text('🏆', style: TextStyle(fontSize: 40)),
          const SizedBox(width: 12),
          const Expanded(child: Text('Study Smart\nAchieve More', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
          FilledButton.tonal(onPressed: () => openForm(), child: const Text("Let's Go")),
        ]),
      ),
    ]);
  }
}
