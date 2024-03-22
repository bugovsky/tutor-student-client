import 'package:flutter/material.dart';
import '../../../repositories/tutors/models/lesson_request.dart';
import '../../../repositories/tutors/tutor_repository.dart';
import '../../../repositories/users/models/lesson.dart';

class LessonRequestTile extends StatefulWidget {
  const LessonRequestTile({
    super.key,
    required this.lessonRequest,
    required this.onResponded,
    required this.lesson,
  });

  final LessonRequest lessonRequest;
  final VoidCallback onResponded;
  final Lesson? lesson;

  @override
  State<LessonRequestTile> createState() => _LessonRequestTileState();
}

class _LessonRequestTileState extends State<LessonRequestTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: (widget.lessonRequest.newDate == null)
          ? const Icon(Icons.cancel_outlined)
          : const Icon(Icons.next_plan),
      title: Text(
        "${widget.lesson?.student} - ${widget.lesson?.subject}, ${widget.lesson?.date}",
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      subtitle: (widget.lessonRequest.newDate == null)
          ? Text("Причина отмены: ${widget.lessonRequest.reason}",
              style: Theme.of(context).textTheme.bodySmall)
          : Text(
              "Причина переноса: ${widget.lessonRequest.reason}\nНовое время занятия: ${widget.lessonRequest.newDate}",
              style: Theme.of(context).textTheme.bodySmall),
      trailing: const Icon(Icons.arrow_forward_ios),
      onLongPress: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                  "После подтверждения действия расписание будет изменено",
                  style: Theme.of(context).textTheme.bodySmall),
              actions: [
                TextButton(
                  onPressed: () async {
                    await _updateLessonRequest("accepted");
                  },
                  child: const Text("Принять"),
                ),
                TextButton(
                  onPressed: () async {
                    await _updateLessonRequest("rejected");
                  },
                  child: const Text("Отклонить"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateLessonRequest(String status) async {
    await TutorRepository()
        .respondToLessonRequest(widget.lessonRequest.lessonId, status);
    widget.onResponded();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
