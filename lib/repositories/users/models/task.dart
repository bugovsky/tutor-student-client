class Task {
  const Task({
    required this.taskId,
    required this.title,
    required this.tutor,
    required this.student,
    required this.status,
    required this.description,
    required this.deadline,
  });

  final int taskId;
  final String title;
  final String student;
  final String tutor;
  final String status;
  final String? description;
  final String? deadline;
}