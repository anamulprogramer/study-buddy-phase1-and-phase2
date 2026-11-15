// PHASE 1 + 2 - UI screen that uses Provider state
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/common.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController(), _pass = TextEditingController();
  bool _busy = false;

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    setState(() => _busy = true);
    try {
      await auth.loginAdmin(_email.text.trim(), _pass.text);
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (e) {
      if (mounted) snack(context, authError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AuthBackground(
        child: Form(
          key: _form,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const AuthHeader(icon: Icons.admin_panel_settings, title: 'Admin Login', subtitle: 'Access Admin Panel'),
            AuthField(
                icon: Icons.person_outline,
                hint: 'Admin Email',
                c: _email,
                type: TextInputType.emailAddress,
                validator: emailRule),
            PasswordField(c: _pass),
            const SizedBox(height: 8),
            GradientButton(label: 'Login', onTap: _login, loading: _busy),
            TextButton.icon(
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                icon: const Icon(Icons.home_outlined),
                label: const Text('Back to Home')),
          ]),
        ),
      );
}
