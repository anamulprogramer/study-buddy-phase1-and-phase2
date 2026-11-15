// PHASE 1 + 2 - UI screen that uses Provider state
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../providers/task_provider.dart';
import '../../widgets/common.dart';

class PomodoroScreen extends StatefulWidget {
  final String uid;
  const PomodoroScreen({super.key, required this.uid});
  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  static const modes = [('Focus', 25), ('Short Break', 5), ('Long Break', 15)];
  int _mode = 0;
  late int _left = modes[0].$2 * 60;
  Timer? _t;

  int get _total => modes[_mode].$2 * 60;

  void _toggle() {
    if (_t != null) {
      _t!.cancel();
      setState(() => _t = null);
      return;
    }
    setState(() => _t = Timer.periodic(const Duration(seconds: 1), (_) {
          if (_left > 1) {
            setState(() => _left--);
          } else {
            _finish();
          }
        }));
  }

  void _finish() {
    _t?.cancel();
    final mins = modes[_mode].$2;
    final focus = _mode == 0;
    setState(() {
      _t = null;
      _left = _total;
    });
    if (focus) context.read<TaskProvider>().addSession(widget.uid, mins);
    snack(context, focus ? 'Great focus! $mins minutes saved.' : 'Break over. Back to focus!');
  }

  void _setMode(int i) {
    _t?.cancel();
    setState(() {
      _t = null;
      _mode = i;
      _left = modes[i].$2 * 60;
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mm = (_left ~/ 60).toString().padLeft(2, '0'), ss = (_left % 60).toString().padLeft(2, '0');
    return Scaffold(
      backgroundColor: AppColors.deep,
      appBar: AppBar(title: const Text('Pomodoro Timer', style: TextStyle(color: Colors.white)), iconTheme: const IconThemeData(color: Colors.white)),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(
              width: 260,
              height: 260,
              child: Stack(fit: StackFit.expand, children: [
                CircularProgressIndicator(value: 1 - _left / _total, strokeWidth: 12, backgroundColor: Colors.white12, color: AppColors.primary2),
                Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('$mm:$ss', style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.w800)),
                  Text(modes[_mode].$1, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                ])),
              ])),
          const SizedBox(height: 28),
          IconButton.filled(
              iconSize: 40,
              style: IconButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.all(16)),
              onPressed: _toggle,
              icon: Icon(_t != null ? Icons.pause : Icons.play_arrow)),
          const SizedBox(height: 28),
          Wrap(spacing: 10, children: [
            for (var i = 0; i < modes.length; i++)
              ChoiceChip(
                  label: Text('${modes[i].$2}m ${modes[i].$1}'), selected: _mode == i, onSelected: (_) => _setMode(i)),
          ]),
          const SizedBox(height: 24),
          const Text('🏆 You are doing great!', style: TextStyle(color: Colors.white70)),
        ]),
      ),
    );
  }
}
