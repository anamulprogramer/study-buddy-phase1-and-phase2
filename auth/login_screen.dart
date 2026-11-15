// PHASE 1 + 2 - UI screen that uses Provider state
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/common.dart';
import 'role_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController(), _pass = TextEditingController();
  bool _remember = true, _busy = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      final e = p.getString('email');
      if (e != null && mounted) _email.text = e;
    });
  }

  Future<void> _run(Future<void> Function() job) async {
    setState(() => _busy = true);
    try {
      await job();
      final p = await SharedPreferences.getInstance();
      _remember ? await p.setString('email', _email.text.trim()) : await p.remove('email');
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (e) {
      if (mounted) snack(context, authError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _forgot() async {
    if (emailRule(_email.text) != null) return snack(context, 'Enter your email first');
    final c = TextEditingController();
    final auth = context.read<AuthProvider>();
    final pw = await showDialog<String>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Reset password'),
        content: TextField(controller: c, obscureText: true, decoration: const InputDecoration(hintText: 'New password (min 6)')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(d, c.text), child: const Text('Save')),
        ],
      ),
    );
    if (pw == null) return;
    try {
      await auth.resetPassword(_email.text.trim(), pw);
      if (mounted) snack(context, 'Password updated. You can log in now.');
    } catch (e) {
      if (mounted) snack(context, authError(e));
    }
  }

  @override
  Widget build(BuildContext context) => AuthBackground(
        child: Form(
          key: _form,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const AuthHeader(icon: Icons.school, title: 'Login to Your Account', subtitle: 'Welcome back! Please login to continue'),
            AuthField(
                icon: Icons.email_outlined,
                hint: 'Email Address',
                c: _email,
                type: TextInputType.emailAddress,
                validator: emailRule),
            PasswordField(c: _pass),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                Checkbox(value: _remember, onChanged: (v) => setState(() => _remember = v ?? true)),
                const Text('Remember me'),
              ]),
              TextButton(onPressed: _forgot, child: const Text('Forgot Password?')),
            ]),
            GradientButton(
                label: 'Login',
                loading: _busy,
                onTap: () {
                  if (!_form.currentState!.validate()) return;
                  final auth = context.read<AuthProvider>();
                  _run(() => auth.login(_email.text.trim(), _pass.text));
                }),
            const OrDivider(),
            GoogleButton(onTap: () {
              final auth = context.read<AuthProvider>();
              _run(() => auth.google('student'));
            }),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("Don't have an account?"),
              TextButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RoleScreen())),
                  child: const Text('Register')),
            ]),
          ]),
        ),
      );
}
