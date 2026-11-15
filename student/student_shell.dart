// PHASE 1 + 2 - UI screen that uses Provider state
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../models/task.dart';
import '../../providers/task_provider.dart';
import '../../widgets/app_shell.dart';
import '../common/settings_tab.dart';
import 'analytics_tab.dart';
import 'calendar_tab.dart';
import 'home_tab.dart';
import 'task_form_screen.dart';

class StudentShell extends StatelessWidget {
  const StudentShell({super.key});

  @override
  Widget build(BuildContext context) {
    final me = context.watch<AppUser>();
    return MultiProvider(
      providers: [
        ProxyProvider<TaskProvider, List<Task>>(update: (_, t, __) => t.forUser(me.uid)),
        ProxyProvider<TaskProvider, List<Session>>(update: (_, t, __) => t.sessionsFor(me.uid)),
      ],
      child: AppShell(
        items: const [
          NavItem(Icons.home_rounded, 'Home'),
          NavItem(Icons.calendar_month, 'Calendar'),
          NavItem(Icons.bar_chart_rounded, 'Analytics'),
          NavItem(Icons.settings, 'Settings'),
        ],
        pages: const [HomeTab(), CalendarTab(), AnalyticsTab(), SettingsTab()],
        onFab: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TaskFormScreen(me: me))),
      ),
    );
  }
}
