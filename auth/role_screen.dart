// PHASE 1 - UI & navigation (layout, theme, widgets)
import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../widgets/common.dart';
import 'admin_login_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget card(IconData i, String t, String s, Widget next) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => next)),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: cardDeco(context, r: 22),
              child: Row(children: [
                CircleAvatar(radius: 30, backgroundColor: AppColors.primary.withOpacity(.12), child: Icon(i, size: 30, color: AppColors.primary)),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  Text(s, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 13)),
                ])),
                const CircleAvatar(radius: 17, backgroundColor: AppColors.primary, child: Icon(Icons.arrow_forward, size: 18, color: Colors.white)),
              ]),
            ),
          ),
        );

    return AuthBackground(
      showBack: false,
      child: Column(children: [
        const SizedBox(height: 30),
        const AuthHeader(icon: Icons.school, title: 'StudyBuddy', subtitle: 'Choose Your Role'),
        const SizedBox(height: 10),
        card(Icons.cast_for_education, 'Teacher', 'Manage classes & students', const RegisterScreen(role: 'teacher')),
        card(Icons.menu_book, 'Student', 'Access tasks & resources', const RegisterScreen(role: 'student')),
        card(Icons.admin_panel_settings, 'Admin', 'Control the system', const AdminLoginScreen()),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('Already have an account?'),
          TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())), child: const Text('Login')),
        ]),
      ]),
    );
  }
}
