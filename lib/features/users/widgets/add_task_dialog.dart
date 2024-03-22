import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:tutor_student_client/repositories/tutors/tutor_repository.dart';
import 'package:tutor_student_client/repositories/users/tasks_repository.dart';

import '../../../repositories/tutors/models/student.dart';

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key, required this.onResponded});

  final VoidCallback onResponded;

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  late Student selectedStudent;
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
    super.initState();
  }

  String? deadline;
  String? description;
  String? title;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : AlertDialog(
            title: const Text('Домашнее задание'),
            content: SingleChildScrollView(
                child: Column(
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
                      child: Form(
                          key: _formKey,
                          child: Column(children: [
                            TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Название'),
                                onSaved: (value) => title = value,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Укажите название";
                                  }
                                  return null;
                                }),
                            TextFormField(
                              decoration:
                                  const InputDecoration(labelText: 'Описание'),
                              onSaved: (value) => description = value,
                            ),
                          ]))),
                  TextButton(
                      onPressed: () {
                        DatePicker.showDateTimePicker(context,
                            showTitleActions: true,
                            minTime: DateTime.now(),
                            maxTime:
                                DateTime.now().add(const Duration(days: 60)),
                            onConfirm: (date) {
                          setState(() {
                            deadline =
                                DateFormat('dd.MM.yyyy, HH:mm').format(date);
                          });
                        }, currentTime: DateTime.now(), locale: LocaleType.ru);
                      },
                      child: const Text(
                        'Выберите срок сдачи (пропустите этот шаг, если домашнее задание без срока сдачи)',
                        style: TextStyle(color: Colors.blue),
                      )),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      (deadline == null)
                          ? "Без срока сдачи"
                          : "Срок сдачи:\n$deadline",
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
                  await TasksRepository().addTask(
                      selectedStudent.studentId, title!, description, deadline);
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
}
