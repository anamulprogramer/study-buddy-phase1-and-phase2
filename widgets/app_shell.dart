// PHASE 1 - UI & navigation (layout, theme, widgets)
import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'common.dart';

class NavItem {
  final IconData icon;
  final String label;
  const NavItem(this.icon, this.label);
}

/// Bottom navigation with an optional centre "+" button (as in the design).
class AppShell extends StatefulWidget {
  final List<NavItem> items;
  final List<Widget> pages;
  final VoidCallback? onFab;
  const AppShell({super.key, required this.items, required this.pages, this.onFab});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _i = 0;

  @override
  Widget build(BuildContext context) {
    final hasFab = widget.onFab != null;
    final half = widget.items.length ~/ 2;
    return Scaffold(
      body: SafeArea(bottom: false, child: IndexedStack(index: _i, children: widget.pages)),
      floatingActionButton: hasFab
          ? FloatingActionButton(
              onPressed: widget.onFab,
              backgroundColor: AppColors.primary,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, size: 32, color: Colors.white))
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: cardColor(context),
        shape: hasFab ? const CircularNotchedRectangle() : null,
        notchMargin: 8,
        padding: EdgeInsets.zero,
        child: Row(children: [
          for (var i = 0; i < widget.items.length; i++) ...[
            if (hasFab && i == half) const SizedBox(width: 72),
            Expanded(child: _NavBtn(item: widget.items[i], selected: _i == i, onTap: () => setState(() => _i = i))),
          ],
        ]),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final NavItem item;
  final bool selected;
  final VoidCallback onTap;
  const _NavBtn({required this.item, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final c = selected ? AppColors.primary : Theme.of(context).hintColor;
    return InkWell(
      onTap: onTap,
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(item.icon, color: c),
            Text(item.label, style: TextStyle(fontSize: 11, color: c, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
          ])),
    );
  }
}
