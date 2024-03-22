import 'package:flutter/material.dart';
import 'package:tutor_student_client/repositories/students/student_repository.dart';
import '../../../repositories/tutors/models/tutor.dart';

class TutorTile extends StatefulWidget {
  const TutorTile({
    super.key,
    required this.tutor,
  });

  final Tutor tutor;

  @override
  State<TutorTile> createState() => _TutorTileState();
}

class _TutorTileState extends State<TutorTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        "${widget.tutor.lastname} ${widget.tutor.firstname}",
      ),
      subtitle: Text(widget.tutor.subjects!.join(", ")),
      trailing: const Icon(Icons.arrow_forward_ios),
      onLongPress: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                  "${widget.tutor.lastname} ${widget.tutor.firstname} получит ваш запрос после подтверждения действия",
                  style: Theme.of(context).textTheme.bodySmall),
              actions: [
                TextButton(
                  onPressed: () async {
                    await StudentRepository().sendEnrollmentRequest(widget.tutor.id);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text("Отправить"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Отменить"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
