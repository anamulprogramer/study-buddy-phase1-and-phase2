// PHASE 2 - Provider state, CRUD, validation, local storage
class Task {
  final String id, ownerId, title, subject, priority, notes;
  final String? assignedBy;
  final DateTime? due;
  final bool done;

  const Task({
    this.id = '',
    required this.ownerId,
    required this.title,
    required this.subject,
    this.priority = 'Medium',
    this.notes = '',
    this.assignedBy,
    this.due,
    this.done = false,
  });

  Task copyWith({String? id, String? ownerId, bool? done}) => Task(
      id: id ?? this.id, ownerId: ownerId ?? this.ownerId, title: title, subject: subject,
      priority: priority, notes: notes, assignedBy: assignedBy, due: due, done: done ?? this.done);

  Map<String, dynamic> toJson() => {
        'id': id, 'ownerId': ownerId, 'title': title, 'subject': subject, 'priority': priority,
        'notes': notes, 'assignedBy': assignedBy, 'due': due?.toIso8601String(), 'done': done,
      };

  factory Task.fromJson(Map<String, dynamic> m) => Task(
        id: m['id'] ?? '',
        ownerId: m['ownerId'] ?? '',
        title: m['title'] ?? '',
        subject: m['subject'] ?? 'Others',
        priority: m['priority'] ?? 'Medium',
        notes: m['notes'] ?? '',
        assignedBy: m['assignedBy'],
        due: m['due'] == null ? null : DateTime.parse(m['due']),
        done: m['done'] ?? false,
      );
}

/// One finished Pomodoro focus session.
class Session {
  final String ownerId;
  final DateTime at;
  final int minutes;
  const Session(this.ownerId, this.at, this.minutes);

  Map<String, dynamic> toJson() => {'ownerId': ownerId, 'at': at.toIso8601String(), 'minutes': minutes};
  factory Session.fromJson(Map<String, dynamic> m) => Session(m['ownerId'], DateTime.parse(m['at']), m['minutes']);
}
