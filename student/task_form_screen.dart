// PHASE 1 + 2 - UI screen that uses Provider state
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../models/app_user.dart';
import '../../models/task.dart';
import '../../providers/task_provider.dart';
import '../../widgets/common.dart';

/// Create / edit / delete a task with form validation.
/// With [assign] = true (teacher) a new task is sent to students.
class TaskFormScreen extends StatefulWidget {
  final AppUser me;
  final Task? task;
  final bool assign;
  final List<AppUser> students;
  const TaskFormScreen({super.key, required this.me, this.task, this.assign = false, this.students = const []});
  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _form = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.task?.title);
  late final _notes = TextEditingController(text: widget.task?.notes);
  late String _subject = widget.task?.subject ?? subjects.first;
  late String _priority = widget.task?.priority ?? 'Medium';
  late DateTime _due = widget.task?.due ?? DateTime.now().add(const Duration(hours: 1));
  String _target = 'all';
  String? _dueError;
  bool _busy = false;

  // ---- validators (edit the rules here) ----
  String? _titleRule(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Title is required';
    if (s.length < 3) return 'Use at least 3 characters';
    if (s.length > 60) return 'Max 60 characters';
    return null;
  }

  String? _notesRule(String? v) => (v ?? '').length > 200 ? 'Max 200 characters' : null;

  Future<void> _pickDate() async {
    final d = await showDatePicker(context: context, initialDate: _due, firstDate: DateTime(2020), lastDate: DateTime(2035));
    if (d != null) setState(() => _due = DateTime(d.year, d.month, d.day, _due.hour, _due.minute));
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_due));
    if (t != null) setState(() => _due = DateTime(_due.year, _due.month, _due.day, t.hour, t.minute));
  }

  Future<void> _save() async {
    final fieldsOk = _form.currentState!.validate();
    final dueErr = (widget.task == null && _due.isBefore(DateTime.now())) ? 'Due date/time cannot be in the past' : null;
    setState(() => _dueError = dueErr);
    if (!fieldsOk || dueErr != null) return;

    final provider = context.read<TaskProvider>();
    final old = widget.task;
    final t = Task(
      id: old?.id ?? '',
      ownerId: old?.ownerId ?? widget.me.uid,
      assignedBy: old?.assignedBy ?? (widget.assign ? widget.me.uid : null),
      title: _title.text.trim(),
      subject: _subject,
      priority: _priority,
      notes: _notes.text.trim(),
      due: _due,
      done: old?.done ?? false,
    );
    setState(() => _busy = true);
    try {
      if (widget.assign && old == null) {
        final ids = _target == 'all' ? widget.students.map((s) => s.uid).toList() : [_target];
        if (ids.isEmpty) throw 'No students have registered yet.';
        await provider.assign(t, ids);
      } else {
        await provider.save(t);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) snack(context, '$e');
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final provider = context.read<TaskProvider>();
    final nav = Navigator.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Delete task?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(d, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      await provider.delete(widget.task!.id);
      nav.pop();
    }
  }

  Widget _pickTile(IconData i, String text, VoidCallback onTap) => Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
              padding: const EdgeInsets.all(14),
              decoration: cardDeco(context, r: 14),
              child: Row(children: [Icon(i, size: 20), const SizedBox(width: 8), Text(text)])),
        ),
      );

  InputDecoration _dec(String h) => InputDecoration(
      hintText: h, filled: true, fillColor: cardColor(context), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none));

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(top: 16, bottom: 6), child: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)));

  @override
  Widget build(BuildContext context) {
    final editing = widget.task != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Edit Task' : (widget.assign ? 'Assign Task' : 'Add New Task')),
        actions: [if (editing) IconButton(icon: const Icon(Icons.delete_outline), onPressed: _delete)],
      ),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.all(18), children: [
          _label('Task Title *'),
          TextFormField(controller: _title, validator: _titleRule, decoration: _dec('Complete Flutter Project')),
          if (widget.assign && !editing) ...[
            _label('Assign to'),
            DropdownButtonFormField<String>(
              value: _target,
              decoration: _dec(''),
              items: [
                const DropdownMenuItem(value: 'all', child: Text('All students')),
                for (final s in widget.students) DropdownMenuItem(value: s.uid, child: Text(s.name)),
              ],
              onChanged: (v) => setState(() => _target = v ?? 'all'),
            ),
          ],
          _label('Subject'),
          DropdownButtonFormField<String>(
            value: _subject,
            decoration: _dec(''),
            items: [for (final s in subjects) DropdownMenuItem(value: s, child: Text(s))],
            onChanged: (v) => setState(() => _subject = v ?? _subject),
          ),
          _label('Due Date & Time'),
          Row(children: [
            _pickTile(Icons.calendar_today, DateFormat('MMM d, y').format(_due), _pickDate),
            const SizedBox(width: 10),
            _pickTile(Icons.access_time, DateFormat('h:mm a').format(_due), _pickTime),
          ]),
          if (_dueError != null) Padding(padding: const EdgeInsets.only(top: 6, left: 4), child: Text(_dueError!, style: const TextStyle(color: Colors.red, fontSize: 12))),
          _label('Priority'),
          SegmentedButton<String>(
            segments: [for (final p in priorities) ButtonSegment(value: p, label: Text(p))],
            selected: {_priority},
            onSelectionChanged: (s) => setState(() => _priority = s.first),
          ),
          _label('Notes (Optional)'),
          TextFormField(controller: _notes, validator: _notesRule, maxLines: 3, maxLength: 200, decoration: _dec('Add some notes...')),
          const SizedBox(height: 16),
          GradientButton(label: editing ? 'Save Changes' : (widget.assign ? 'Assign Task' : 'Add Task'), onTap: _save, loading: _busy),
        ]),
      ),
    );
  }
}
