import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:tutor_student_client/repositories/tutors/tutor_repository.dart';
import 'package:tutor_student_client/secure_storage_manager.dart';

import '../../../repositories/tutors/models/student.dart';

class AddLessonDialog extends StatefulWidget {
  const AddLessonDialog({super.key, required this.onResponded});
  final VoidCallback onResponded;

  @override
  State<AddLessonDialog> createState() => _AddLessonDialogState();
}

class _AddLessonDialogState extends State<AddLessonDialog> {
  late Student selectedStudent;
  late String dropdownSubject;
  List<String>? subjects;
  List<Student>? students;
  bool isLoading = true;

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadStudents();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadSubjects();
    });
    super.initState();
  }

  String lessonTime = DateFormat('dd.MM.yyyy, HH:mm').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : AlertDialog(
            title: const Text('Добавить урок'),
            content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: DropdownMenu<Student>(
                      label: const Text("Ученик"),
                      initialSelection: students?.first,
                      onSelected: (Student? value) {
                        setState(() {
                          selectedStudent = value!;
                        });
                      },
                      dropdownMenuEntries: students!
                          .map<DropdownMenuEntry<Student>>((Student value) {
                        return DropdownMenuEntry<Student>(
                            value: value,
                            label: "${value.lastname} ${value.firstname}");
                      }).toList(),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: DropdownMenu<String>(
                        label: const Text("Предмет"),
                        initialSelection: subjects?.first,
                        onSelected: (String? value) {
                          setState(() {
                            dropdownSubject = value!;
                          });
                        },
                        dropdownMenuEntries: subjects!
                            .map<DropdownMenuEntry<String>>((String value) {
                          return DropdownMenuEntry<String>(
                              value: value, label: value);
                        }).toList(),
                      )),
                  TextButton(
                      onPressed: () {
                        DatePicker.showDateTimePicker(context,
                            showTitleActions: true,
                            minTime: DateTime.now(),
                            maxTime:
                                DateTime.now().add(const Duration(days: 60)),
                            onConfirm: (date) {
                          setState(() {
                            lessonTime =
                                DateFormat('dd.MM.yyyy, HH:mm').format(date);
                          });
                        }, currentTime: DateTime.now(), locale: LocaleType.ru);
                      },
                      child: const Text(
                        'Выберите дату и время урока',
                        style: TextStyle(color: Colors.blue),
                      )),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "Время урока:\n$lessonTime",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  )
                ]),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  await TutorRepository().addLesson(selectedStudent.studentId, dropdownSubject, lessonTime);
                  widget.onResponded();
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

  Future<void> _loadStudents() async {
    students = await TutorRepository().fetchStudents();
    setState(() {
      selectedStudent = students!.first;
      isLoading = false;
    });
  }

  Future<void> _loadSubjects() async {
    final userId = await SecureStorageManager.instance.getUserId();
    final subjectMap = await SecureStorageManager.instance.getSubjects(userId!);
    final filteredSubjects = subjectMap.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    setState(() {
      subjects = filteredSubjects;
      dropdownSubject = "${subjects?.first}";
    });
  }
}
