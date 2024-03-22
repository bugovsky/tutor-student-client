import 'package:flutter/material.dart';
import '../../../repositories/users/models/task.dart';
import '../../../repositories/users/user_repository.dart';

class DownloadTaskDialog extends StatefulWidget {
  const DownloadTaskDialog({super.key, required this.task});

  final Task task;

  @override
  State<DownloadTaskDialog> createState() => _DownloadTaskDialogState();
}

class _DownloadTaskDialogState extends State<DownloadTaskDialog> {
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Скачать домашнее задание'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text("Задание:\n${widget.task.title}"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _downloadFile();
          },
          child: _isDownloading
              ? const CircularProgressIndicator()
              : const Text('Скачать'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Назад'),
        ),
      ],
    );
  }

  Future<void> _downloadFile() async {
    setState(() {
      _isDownloading = true;
    });
    await UserRepository().downloadTask(widget.task.taskId, widget.task.title);
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Домашнее задание скачано'),
        ),
      );
    }
    setState(() {
      _isDownloading = false;
    });
  }
}
