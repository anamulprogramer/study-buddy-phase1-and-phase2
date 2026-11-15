// PHASE 1 + 2 - UI screen that uses Provider state
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../models/task.dart';
import '../../widgets/common.dart';

class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<List<Task>>();
    final sessions = context.watch<List<Session>>();
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final perDay = List<int>.generate(7, (i) {
      final d = monday.add(Duration(days: i));
      return sessions.where((s) => sameDay(s.at, d)).fold<int>(0, (a, s) => a + s.minutes);
    });
    final maxV = perDay.fold<int>(30, (a, b) => a > b ? a : b);
    final total = perDay.fold<int>(0, (a, b) => a + b);
    final done = tasks.where((t) => t.done).length;
    final pct = tasks.isEmpty ? 0.0 : done / tasks.length;
    final bySubject = <String, int>{};
    for (final t in tasks) {
      bySubject[t.subject] = (bySubject[t.subject] ?? 0) + 1;
    }
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      const Text('Analytics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: cardDeco(context),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Study Time This Week', style: TextStyle(color: Theme.of(context).hintColor)),
          Text('${(total / 60).toStringAsFixed(1)}h', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        height: 4 + 90 * perDay[i] / maxV,
                        decoration: BoxDecoration(gradient: AppColors.btn, borderRadius: BorderRadius.circular(6))),
                    const SizedBox(height: 4),
                    Text(days[i], style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor)),
                  ]),
                ),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: cardDeco(context),
        child: Row(children: [
          SizedBox(
              width: 80,
              height: 80,
              child: Stack(fit: StackFit.expand, children: [
                CircularProgressIndicator(value: pct, strokeWidth: 9, backgroundColor: AppColors.primary.withOpacity(.12), color: AppColors.ok),
                Center(child: Text('${(pct * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18))),
              ])),
          const SizedBox(width: 18),
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Task Progress', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            Text('$done of ${tasks.length} completed', style: TextStyle(color: Theme.of(context).hintColor)),
          ])),
        ]),
      ),
      const SectionHeader('Subject Breakdown'),
      if (bySubject.isEmpty) const EmptyState('Add tasks to see your subjects here.'),
      for (final e in bySubject.entries)
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: cardDeco(context, r: 16),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('${(e.value / tasks.length * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 8),
            ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: e.value / tasks.length, minHeight: 7)),
          ]),
        ),
    ]);
  }
}
