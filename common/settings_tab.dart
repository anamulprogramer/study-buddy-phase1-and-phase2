// PHASE 1 + 2 - UI screen that uses Provider state
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../models/app_user.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common.dart';

/// Shared by Student, Teacher and Admin.
class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final me = context.watch<AppUser>();
    final theme = context.watch<ThemeProvider>();
    final idText = switch (me.idStatus) {
      'submitted' => 'ID submitted',
      'skipped' => 'ID not uploaded',
      _ => 'ID pending',
    };
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      const Text('Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(18),
        decoration: cardDeco(context),
        child: Column(children: [
          CircleAvatar(
              radius: 38,
              backgroundColor: AppColors.primary2,
              child: Text(me.name.isEmpty ? '?' : me.name[0].toUpperCase(), style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.w700))),
          const SizedBox(height: 10),
          Text(me.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          Text(me.email, style: TextStyle(color: Theme.of(context).hintColor)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            Chip(label: Text(me.role[0].toUpperCase() + me.role.substring(1))),
            if (me.role != 'admin') Chip(label: Text(idText)),
          ]),
        ]),
      ),
      const SectionHeader('App Theme'),
      SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode)),
          ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode)),
          ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.phone_android)),
        ],
        selected: {theme.mode},
        onSelectionChanged: (s) => theme.set(s.first),
      ),
      const SizedBox(height: 24),
      OutlinedButton.icon(
        onPressed: () => context.read<AuthProvider>().signOut(),
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50), foregroundColor: AppColors.bad, shape: const StadiumBorder()),
      ),
    ]);
  }
}
