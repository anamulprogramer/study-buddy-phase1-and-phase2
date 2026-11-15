// PHASE 1 + 2 - UI screen that uses Provider state
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/common.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  final String role;
  const RegisterScreen({super.key, required this.role});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(), _email = TextEditingController(), _phone = TextEditingController();
  final _id = TextEditingController(), _pass = TextEditingController();
  bool _busy = false;

  String get _cap => widget.role[0].toUpperCase() + widget.role.substring(1);

  Future<void> _run(Future<void> Function() job) async {
    setState(() => _busy = true);
    try {
      await job();
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (e) {
      if (mounted) snack(context, authError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _register() {
    if (!_form.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    _run(() => auth.register(
        role: widget.role,
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _pass.text,
        phone: _phone.text.trim(),
        idNumber: _id.text.trim()));
  }

  @override
  Widget build(BuildContext context) => AuthBackground(
        child: Form(
          key: _form,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            AuthHeader(
                icon: widget.role == 'teacher' ? Icons.cast_for_education : Icons.menu_book,
                title: '$_cap Registration',
                subtitle: 'Join StudyBuddy as a $_cap'),
            AuthField(icon: Icons.person_outline, hint: 'Full Name', c: _name, validator: nameRule),
            AuthField(
                icon: Icons.email_outlined,
                hint: '$_cap Email Address',
                c: _email,
                type: TextInputType.emailAddress,
                validator: emailRule),
            AuthField(icon: Icons.phone_outlined, hint: 'Phone Number', c: _phone, type: TextInputType.phone, validator: phoneRule),
            AuthField(icon: Icons.badge_outlined, hint: '$_cap ID', c: _id, validator: idRule),
            PasswordField(c: _pass),
            const SizedBox(height: 4),
            GradientButton(label: 'Register', onTap: _register, loading: _busy),
            const OrDivider(),
            GoogleButton(onTap: () {
              final auth = context.read<AuthProvider>();
              _run(() => auth.google(widget.role));
            }),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('Already have an account?'),
              TextButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                  child: const Text('Login')),
            ]),
          ]),
        ),
      );
}
