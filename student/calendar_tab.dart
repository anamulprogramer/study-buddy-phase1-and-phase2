// PHASE 1 + 2 - UI screen that uses Provider state
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/theme.dart';
import '../../models/app_user.dart';
import '../../models/task.dart';
import '../../providers/task_provider.dart';
import '../../widgets/common.dart';
import 'task_form_screen.dart';

class CalendarTab extends StatefulWidget {
  const CalendarTab({super.key});
  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  DateTime _focus = DateTime.now(), _sel = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final me = context.watch<AppUser>();
    final tasks = context.watch<List<Task>>();
    final day = tasks.where((t) => t.due != null && sameDay(t.due!, _sel)).toList();
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      const Text('Calendar', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      Container(
        decoration: cardDeco(context),
        padding: const EdgeInsets.all(8),
        child: TableCalendar<Task>(
          firstDay: DateTime(2020),
          lastDay: DateTime(2035),
          focusedDay: _focus,
          selectedDayPredicate: (d) => sameDay(d, _sel),
          eventLoader: (d) => tasks.where((t) => t.due != null && sameDay(t.due!, d)).toList(),
          onDaySelected: (s, f) => setState(() {
            _sel = s;
            _focus = f;
          }),
          onPageChanged: (f) => _focus = f,
          headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
          calendarStyle: CalendarStyle(
            selectedDecoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            todayDecoration: BoxDecoration(color: AppColors.primary2.withOpacity(.4), shape: BoxShape.circle),
            markerDecoration: const BoxDecoration(color: AppColors.primary2, shape: BoxShape.circle),
          ),
        ),
      ),
      SectionHeader("Tasks on ${DateFormat('MMM d').format(_sel)}"),
      if (day.isEmpty) const EmptyState('No tasks on this day. Tap + to add one.'),
      for (final t in day)
        TaskTile(
            task: t,
            extra: t.subject,
            onToggle: () => context.read<TaskProvider>().toggle(t),
            onEdit: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TaskFormScreen(me: me, task: t)))),
    ]);
  }
}
