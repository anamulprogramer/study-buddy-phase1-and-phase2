// PHASE 2 - Provider state, CRUD, validation, local storage
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../models/app_user.dart';
import 'admin/admin_shell.dart';
import 'auth/role_screen.dart';
import 'auth/verify_screen.dart';
import 'student/student_shell.dart';
import 'teacher/teacher_shell.dart';

/// Decides what to show from the current login state (Provider).
class Gate extends StatelessWidget {
  const Gate({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.ready) return const Splash();
    final p = auth.current;
    if (p == null) return const RoleScreen();
    if (!p.active) return const Splash(message: 'Your account has been blocked by an admin.', showSignOut: true);
    if (p.role != 'admin' && p.idStatus == 'pending') return VerifyScreen(user: p);
    final Widget shell = switch (p.role) {
      'teacher' => const TeacherShell(),
      'admin' => const AdminShell(),
      _ => const StudentShell(),
    };
    return Provider<AppUser>.value(value: p, child: shell);
  }
}

class Splash extends StatelessWidget {
  final String? message;
  final bool showSignOut;
  const Splash({super.key, this.message, this.showSignOut = false});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (message == null) const CircularProgressIndicator() else Padding(padding: const EdgeInsets.all(24), child: Text(message!, textAlign: TextAlign.center)),
            if (showSignOut) TextButton(onPressed: () => context.read<AuthProvider>().signOut(), child: const Text('Sign out')),
          ]),
        ),
      );
}
