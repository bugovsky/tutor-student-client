import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:tutor_student_client/secure_storage_manager.dart';

import '../../api.dart';
import 'models/task.dart';

class TasksRepository {
  Future<List<Task>> getTasksList() async {
    String? jwtToken = await SecureStorageManager.instance.getToken();
    Dio dio = Dio();
    final response = await dio.get(
      "$host/hometask/",
      options: Options(
        headers: {
          "Authorization": "Bearer $jwtToken",
        },
      ),
    );
    final data = List<Map<String, dynamic>>.from(response.data);
    final tasks = <Task>[];
    for (final taskData in data) {
      final tutorId = taskData['tutor_id'];
      final tutorResponse = await dio.get("$host/users/$tutorId");
      final tutorData = tutorResponse.data as Map<String, dynamic>;
      final tutor = tutorData['lastname'] as String;

      final studentId = taskData['student_id'];
      final studentResponse = await dio.get("$host/users/$studentId");
      final studentData = studentResponse.data as Map<String, dynamic>;
      final student = studentData['lastname'] as String;

      final taskId = taskData['id'];
      final status = taskData['status'];
      final title = taskData['title'];
      final description = taskData['description'];
      final deadline = taskData['deadline'];

      final task = Task(
        taskId: taskId,
        title: title,
        status: status,
        description: description,
        tutor: tutor,
        student: student,
        deadline: (deadline == null)
            ? deadline
            : DateFormat('dd.MM.yyyy, HH:mm').format(DateTime.parse(deadline)),
      );
      tasks.add(task);
    }
    return tasks;
  }

  Future<void> addTask(
      int studentId, String title, String? desc, String? deadline) async {
    final jwtToken = await SecureStorageManager.instance.getToken();
    Dio _dio = Dio();
    String originalFormat = 'dd.MM.yyyy, HH:mm';
    String desiredFormat = 'yyyy-MM-dd HH:mm';
    String? formattedDateTime;
    if (deadline != null) {
      DateTime originalDateTime = DateFormat(originalFormat).parse(deadline);
      formattedDateTime = DateFormat(desiredFormat).format(originalDateTime);
    }
    final data = {
      "student_id": studentId,
      "title": title,
      "description": desc,
      "deadline": formattedDateTime
    };
    await _dio.post(
      "$host/hometask/",
      data: data,
      options: Options(
        headers: {
          "Authorization": "Bearer $jwtToken",
        },
      ),
    );
  }
}
