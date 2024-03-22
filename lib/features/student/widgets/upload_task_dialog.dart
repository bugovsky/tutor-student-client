import 'dart:io';
import 'package:path/path.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:tutor_student_client/repositories/students/student_repository.dart';
import '../../../repositories/users/models/task.dart';

class UploadTaskDialog extends StatefulWidget {
  const UploadTaskDialog(
      {super.key, required this.task, required this.onResponded});

  final VoidCallback onResponded;
  final Task task;

  @override
  State<UploadTaskDialog> createState() => _UploadTaskDialogState();
}

class _UploadTaskDialogState extends State<UploadTaskDialog> {
  File? _selectedFile;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Загрузить домашнее задание'),
      content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child:
                  Text("Задание:\n${widget.task.tutor} - ${widget.task.title}"),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf'],
                  );

                  if (result != null) {
                    setState(() {
                      _selectedFile = File(result.files.single.path!);
                    });
                  }
                },
                child: Text(_selectedFile == null
                    ? 'Выберите файл'
                    : "Файл: ${basename(_selectedFile!.path)}"),
              ),
            )
          ]),
      actions: [
        TextButton(
          onPressed: () async {
            setState(() {
              _isLoading = true;
            });
            if (_selectedFile != null) {
              FormData file = FormData.fromMap({
                "file": await MultipartFile.fromFile(_selectedFile!.path,
                    filename: basename(_selectedFile!.path),
                    contentType: MediaType('application', 'pdf')),
              });
              await StudentRepository().uploadTask(widget.task.taskId, file);
              widget.onResponded();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            }
            setState(() {
              _isLoading = false;
            });
          },
          child: _isLoading
              ? const CircularProgressIndicator() // Show circular progress indicator while loading
              : const Text('Загрузить'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Отменить'),
        ),
      ],
    );
  }
}
