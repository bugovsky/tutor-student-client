import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:tutor_student_client/repositories/students/student_repository.dart';
import '../../../repositories/users/models/lesson.dart';

class RescheduleLessonDialog extends StatefulWidget {
  const RescheduleLessonDialog({super.key, required this.lesson});

  final Lesson lesson;

  @override
  State<RescheduleLessonDialog> createState() => _RescheduleLessonDialogState();
}

class _RescheduleLessonDialogState extends State<RescheduleLessonDialog> {
  String? lessonTime;
  String? reason;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Редактирование расписания'),
      content: SingleChildScrollView(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                  "Выбранное занятие:\n${widget.lesson.tutor} - ${widget.lesson.subject}\n${widget.lesson.date}"),
            ),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Причина'),
                      onSaved: (value) => reason = value,
                      validator: (value) {
                        if (value!.isEmpty || value.trim().isEmpty) return "Укажите причину переноса";
                        return null;
                      }),
                )),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextButton(
                  onPressed: () {
                    DatePicker.showDateTimePicker(context,
                        showTitleActions: true,
                        minTime: DateTime.now(),
                        maxTime: DateTime.now().add(const Duration(days: 60)),
                        onConfirm: (date) {
                      setState(() {
                        lessonTime =
                            DateFormat('dd.MM.yyyy, HH:mm').format(date);
                      });
                    }, currentTime: DateTime.now(), locale: LocaleType.ru);
                  },
                  child: const Text(
                    'Выберите новое время занятия',
                    style: TextStyle(color: Colors.blue),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                (lessonTime == null)
                    ? "Будет отправлен запрос на отмену занятия"
                    : "Время урока:\n$lessonTime",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            )
          ])),
      actions: [
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
            } else {
              return;
            }
            await StudentRepository()
                .rescheduleLesson(widget.lesson.lessonId, reason, lessonTime);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('Добавить'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Отменить'),
        ),
      ],
    );
  }
}
