import 'package:flutter/material.dart';
import 'package:tutor_student_client/repositories/users/models/lesson.dart';

import '../../student/widgets/reschedule_lesson_dialog.dart';

class LessonTile extends StatelessWidget {
  const LessonTile({
    super.key,
    required this.lesson,
    required this.role,
  });

  final Lesson lesson;
  final String? role;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        (role == "student")
            ? "${lesson.tutor} - ${lesson.subject}"
            : "${lesson.student} - ${lesson.subject}",
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      subtitle: Text(lesson.date),
      trailing: const Icon(Icons.arrow_forward_ios),
      onLongPress: () async {
        if (role == "student") {
          await showDialog(
              context: context,
              builder: (BuildContext context) {
                return RescheduleLessonDialog(
                  lesson: lesson,
                );
              });
        }
      },
    );
  }
}
