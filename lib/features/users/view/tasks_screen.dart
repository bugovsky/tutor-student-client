import 'package:flutter/material.dart';
import 'package:tutor_student_client/repositories/users/tasks_repository.dart';
import 'package:tutor_student_client/secure_storage_manager.dart';

import '../../../repositories/users/models/task.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/task_tile.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Task>? _tasks;
  String? _userRole;

  @override
  void initState() {
    _loadTasks();
    _getRole();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Домашние задания"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushNamed("/main_screen"),
        ),
      ),
      body: Column(
        children: [
          if (_userRole == "tutor")
            Padding(
              padding: const EdgeInsets.only(),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AddTaskDialog(onResponded: _loadTasks,);
                        });
                  },
                  child: const Icon(Icons.add_circle),
                ),
              ),
            ),
          Expanded(
            child: (_tasks == null)
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                itemCount: _tasks!.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, i) {
                  final task = _tasks![i];
                  return TaskTile(
                    task: task,
                    role: _userRole,
                    onResponded: _loadTasks,
                  );
                }),
          ),
        ],
      ),
    );
  }

  Future<void> _loadTasks() async {
    _tasks = await TasksRepository().getTasksList();
    setState(() {});
  }

  Future<void> _getRole() async {
    _userRole = await SecureStorageManager.instance.getRole();
    setState(() {});
  }
}
