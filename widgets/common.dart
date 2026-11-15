// PHASE 1 - UI & navigation (layout, theme, widgets)
// (validators at the bottom belong to Phase 2)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/theme.dart';
import '../models/task.dart';

bool isDark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;
Color cardColor(BuildContext c) => isDark(c) ? const Color(0xFF181243) : Colors.white;
bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
void snack(BuildContext c, String m) => ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(m)));
String? req(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;

BoxDecoration cardDeco(BuildContext c, {double r = 20}) => BoxDecoration(
      color: cardColor(c),
      borderRadius: BorderRadius.circular(r),
      boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(.10), blurRadius: 16, offset: const Offset(0, 6))],
    );

String formatDue(DateTime? d) {
  if (d == null) return 'No date';
  final n = DateTime.now();
  final diff = DateTime(d.year, d.month, d.day).difference(DateTime(n.year, n.month, n.day)).inDays;
  final time = DateFormat('h:mm a').format(d);
  if (diff == 0) return 'Today • $time';
  if (diff == 1) return 'Tomorrow • $time';
  return '${DateFormat('MMM d').format(d)} • $time';
}

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  const GradientButton({super.key, required this.label, required this.onTap, this.loading = false});

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: onTap == null ? .6 : 1,
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              gradient: AppColors.btn,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(.35), blurRadius: 14, offset: const Offset(0, 6))],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: loading ? null : onTap,
              child: SizedBox(
                height: 52,
                child: Center(
                  child: loading
                      ? const SizedBox(
                          width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ),
        ),
      );
}

OutlineInputBorder _b([Color? c]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: c ?? AppColors.primary2.withOpacity(.3)));

class AuthField extends StatelessWidget {
  final IconData icon;
  final String hint;
  final TextEditingController c;
  final bool obscure;
  final TextInputType? type;
  final Widget? suffix;
  final String? Function(String?)? validator;
  const AuthField(
      {super.key, required this.icon, required this.hint, required this.c, this.obscure = false, this.type, this.suffix, this.validator});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: c,
          obscureText: obscure,
          keyboardType: type,
          validator: validator ?? req,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            suffixIcon: suffix,
            hintText: hint,
            filled: true,
            fillColor: cardColor(context),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: _b(),
            enabledBorder: _b(),
            focusedBorder: _b(AppColors.primary),
          ),
        ),
      );
}

class PasswordField extends StatefulWidget {
  final TextEditingController c;
  const PasswordField({super.key, required this.c});
  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _hide = true;
  @override
  Widget build(BuildContext context) => AuthField(
        icon: Icons.lock_outline,
        hint: 'Password',
        c: widget.c,
        obscure: _hide,
        validator: (v) => (v == null || v.length < 6) ? 'Use at least 6 characters' : null,
        suffix: IconButton(
            onPressed: () => setState(() => _hide = !_hide),
            icon: Icon(_hide ? Icons.visibility_off_outlined : Icons.visibility_outlined)),
      );
}

class AuthBackground extends StatelessWidget {
  final Widget child;
  final bool showBack;
  const AuthBackground({super.key, required this.child, this.showBack = true});

  Widget _blob(double s) => Container(
      width: s, height: s, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary2.withOpacity(.35)));

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(children: [
          Positioned(top: -100, left: -80, child: _blob(260)),
          Positioned(bottom: -110, right: -90, child: _blob(280)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                if (showBack)
                  Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton.filledTonal(
                          onPressed: () => Navigator.maybePop(context), icon: const Icon(Icons.arrow_back))),
                child,
              ]),
            ),
          ),
        ]),
      );
}

class AuthHeader extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const AuthHeader({super.key, required this.icon, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Column(children: [
        Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.btn),
            child: Icon(icon, size: 44, color: Colors.white)),
        const SizedBox(height: 14),
        Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: Theme.of(context).hintColor)),
        const SizedBox(height: 20),
      ]);
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});
  @override
  Widget build(BuildContext context) => const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('or')), Expanded(child: Divider())]));
}

class GoogleButton extends StatelessWidget {
  final VoidCallback onTap;
  const GoogleButton({super.key, required this.onTap});
  @override
  Widget build(BuildContext context) => OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: const StadiumBorder(),
            backgroundColor: cardColor(context),
            side: BorderSide(color: AppColors.primary2.withOpacity(.3))),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('G', style: TextStyle(color: Color(0xFF4285F4), fontSize: 20, fontWeight: FontWeight.w900)),
          SizedBox(width: 10),
          Text('Continue with Google', style: TextStyle(fontWeight: FontWeight.w600)),
        ]),
      );
}

class HeroCard extends StatelessWidget {
  final Widget child;
  const HeroCard({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(gradient: AppColors.hero, borderRadius: BorderRadius.circular(24)),
        child: DefaultTextStyle.merge(style: const TextStyle(color: Colors.white), child: child),
      );
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value, label;
  const StatCard({super.key, required this.icon, required this.color, required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: cardDeco(context),
        child: Row(children: [
          CircleAvatar(radius: 22, backgroundColor: color.withOpacity(.15), child: Icon(icon, color: color)),
          const SizedBox(width: 12),
          Expanded(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700))),
            Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
          ])),
        ]),
      );
}

Widget statGrid(List<StatCard> cards) => GridView.count(
    crossAxisCount: 2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    mainAxisSpacing: 10,
    crossAxisSpacing: 10,
    childAspectRatio: 2.1,
    children: cards);

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionHeader(this.title, {super.key, this.action, this.onAction});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        if (action != null) TextButton(onPressed: onAction, child: Text(action!)),
      ]));
}

class EmptyState extends StatelessWidget {
  final String text;
  const EmptyState(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(22),
      decoration: cardDeco(context),
      child: Center(child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).hintColor))));
}

class PriorityPill extends StatelessWidget {
  final String p;
  const PriorityPill(this.p, {super.key});
  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (p) {
      'High' => (const Color(0xFFFFD9DE), const Color(0xFFB4202F)),
      'Low' => (const Color(0xFFDBEAFE), const Color(0xFF1D4ED8)),
      _ => (const Color(0xFFD6F5E3), const Color(0xFF14804A)),
    };
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(p, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700)));
  }
}

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback? onToggle, onEdit;
  final String? extra;
  const TaskTile({super.key, required this.task, this.onToggle, this.onEdit, this.extra});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: cardDeco(context, r: 16),
        child: Row(children: [
          GestureDetector(
              onTap: onToggle,
              child: Icon(task.done ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 28, color: task.done ? AppColors.primary : Colors.grey)),
          const SizedBox(width: 12),
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(task.title,
                style: TextStyle(fontWeight: FontWeight.w600, decoration: task.done ? TextDecoration.lineThrough : null)),
            const SizedBox(height: 3),
            Row(children: [
              const Icon(Icons.calendar_today, size: 12, color: AppColors.primary),
              const SizedBox(width: 4),
              Flexible(
                  child: Text('${formatDue(task.due)}${extra == null ? '' : ' • $extra'}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor))),
            ]),
          ])),
          PriorityPill(task.priority),
          if (onEdit != null)
            IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined, size: 20), visualDensity: VisualDensity.compact),
        ]),
      );
}

// ---- Form validators (edit the rules here) ----
final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
final _phoneRe = RegExp(r'^\+?\d{10,15}$');
String? emailRule(String? v) => (v == null || !_emailRe.hasMatch(v.trim())) ? 'Enter a valid email' : null;
String? phoneRule(String? v) => (v == null || !_phoneRe.hasMatch(v.trim())) ? 'Enter 10-15 digits' : null;
String? nameRule(String? v) => (v == null || v.trim().length < 2) ? 'Enter your full name' : null;
String? idRule(String? v) => (v == null || v.trim().length < 3) ? 'Enter a valid ID' : null;
