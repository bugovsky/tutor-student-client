import 'package:flutter/material.dart';
import '../../../repositories/tutors/models/student_request.dart';
import '../../../repositories/tutors/tutor_repository.dart';

class StudentRequestTile extends StatefulWidget {
  const StudentRequestTile({
    super.key,
    required this.studentRequest,
    required this.onResponded,
  });

  final StudentRequest studentRequest;
  final VoidCallback onResponded;

  @override
  State<StudentRequestTile> createState() => _StudentRequestTileState();
}

class _StudentRequestTileState extends State<StudentRequestTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        "${widget.studentRequest.lastname} ${widget.studentRequest.firstname}",
      ),
      trailing: const Icon(Icons.arrow_forward_ios),
      onLongPress: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                  "${widget.studentRequest.lastname} ${widget.studentRequest.firstname} "
                  "станет вашим учеником после принятия запроса",
                  style: Theme.of(context).textTheme.bodySmall),
              actions: [
                TextButton(
                  onPressed: () async {
                    await _updateEnrollmentRequest("accepted");
                  },
                  child: const Text("Принять"),
                ),
                TextButton(
                  onPressed: () async {
                    await _updateEnrollmentRequest("rejected");
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

  Future<void> _updateEnrollmentRequest(String status) async {
    await TutorRepository().respondToEnrollmentRequest(widget.studentRequest.studentId, status);
    widget.onResponded();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
