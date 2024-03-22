import 'package:flutter/material.dart';
import 'package:tutor_student_client/features/student/widgets/upload_task_dialog.dart';

import '../../../repositories/users/models/task.dart';
import 'download_task_dialog.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.role,
    required this.onResponded,
  });

  final Task task;
  final VoidCallback onResponded;
  final String? role;

  @override
  Widget build(BuildContext context) {
    Color statusColor = _getColorByStatus(task.status);
    return ListTile(
      title: Text(
        (role == "student")
            ? "${task.tutor} - ${task.title}\n${task.description}"
            : "${task.student} - ${task.title}\n${task.description}",
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      subtitle: Text(
          (task.deadline == null)
              ? ("Без срока сдачи")
              : ("Срок сдачи: ${task.deadline}"),
          style: Theme.of(context).textTheme.bodySmall),
      trailing: const Icon(Icons.arrow_forward_ios),
      onLongPress: () async {
        if (task.status == "in progress" && role == "student") {
          await showDialog(
              context: context,
              builder: (BuildContext context) {
                return UploadTaskDialog(
                  task: task,
                  onResponded: onResponded,
                );
              });
        } else if (task.status == "done") {
          await showDialog(
              context: context,
              builder: (BuildContext context) {
                return DownloadTaskDialog(
                  task: task,
                );
              });
        }
      },
      tileColor: statusColor,
    );
  }

  Color _getColorByStatus(String status) {
    switch (status) {
      case 'in progress':
        return Colors.yellow.shade300;
      case 'expired':
        return Colors.deepOrange.shade300;
      case 'done':
        return Colors.lightGreen.shade300;
      default:
        return Colors.transparent;
    }
  }
}
