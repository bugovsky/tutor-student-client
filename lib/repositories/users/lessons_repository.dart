import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:tutor_student_client/secure_storage_manager.dart';

import '../../api.dart';
import 'models/lesson.dart';

class LessonsRepository {
  Future<List<Lesson>> getLessonsList() async {
    String? jwtToken = await SecureStorageManager.instance.getToken();
    Dio dio = Dio();
    final role = await SecureStorageManager.instance.getRole();
    Response? response;
    if (role == "student") {
      response = await dio.get(
        "$host/students/schedule",
        options: Options(
          headers: {
            "Authorization": "Bearer $jwtToken",
          },
        ),
      );
    } else if (role == "tutor") {
      response = await dio.get(
        "$host/tutors/schedule",
        options: Options(
          headers: {
            "Authorization": "Bearer $jwtToken",
          },
        ),
      );
    }
    final data = List<Map<String, dynamic>>.from(response?.data);
    final lessons = <Lesson>[];
    for (final lessonData in data) {
      if (lessonData['date_at'] != null) {
        final tutorId = lessonData['tutor_id'];
        final tutorResponse = await dio.get("$host/users/$tutorId");
        final tutorData = tutorResponse.data as Map<String, dynamic>;
        final tutor = tutorData['lastname'] as String;

        final studentId = lessonData['student_id'];
        final studentResponse = await dio.get("$host/users/$studentId");
        final studentData = studentResponse.data as Map<String, dynamic>;
        final student = studentData['lastname'] as String;

        final lessonId = lessonData['id'];
        final subjectResponse = await dio.get("$host/users/subject/$lessonId");
        final subjectData = subjectResponse.data as Map<String, dynamic>;
        final subject = subjectData['subject_name'] as String;
        final lesson = Lesson(
          lessonId: lessonId,
          tutor: tutor,
          student: student,
          subject: subject,
          date: DateFormat('dd.MM.yyyy, HH:mm')
              .format(DateTime.parse(lessonData['date_at'])),
        );
        lessons.add(lesson);
      }
    }
    return lessons;
  }

  Future<Lesson?> getLessonById(int lessonId) async {
    String? jwtToken = await SecureStorageManager.instance.getToken();
    Dio dio = Dio();
    final response = await dio.get(
      "$host/tutors/schedule",
      options: Options(
        headers: {
          "Authorization": "Bearer $jwtToken",
        },
      ),
    );
    final data = List<Map<String, dynamic>>.from(response.data);
    for (final lessonData in data) {
      if (lessonData['id'] == lessonId) {
        final tutorId = lessonData['tutor_id'];
        final tutorResponse = await dio.get("$host/users/$tutorId");
        final tutorData = tutorResponse.data as Map<String, dynamic>;
        final tutor = tutorData['lastname'] as String;

        final studentId = lessonData['student_id'];
        final studentResponse = await dio.get("$host/users/$studentId");
        final studentData = studentResponse.data as Map<String, dynamic>;
        final student = studentData['lastname'] as String;

        final subjectResponse = await dio.get("$host/users/subject/$lessonId");
        final subjectData = subjectResponse.data as Map<String, dynamic>;
        final subject = subjectData['subject_name'] as String;
        final lesson = Lesson(
          lessonId: lessonId,
          tutor: tutor,
          student: student,
          subject: subject,
          date: DateFormat('dd.MM.yyyy, HH:mm')
              .format(DateTime.parse(lessonData['date_at'])),
        );
        return lesson;
      }
    }
    return null;
  }

  Future<List<Lesson>> getLessonsListByUserId(String role, int userId) async {
    String? jwtToken = await SecureStorageManager.instance.getToken();
    Dio dio = Dio();
    final role = await SecureStorageManager.instance.getRole();
    Response? response;
    if (role == "student") {
      response = await dio.get(
        "$host/students/schedule/$userId",
        options: Options(
          headers: {
            "Authorization": "Bearer $jwtToken",
          },
        ),
      );
    } else if (role == "tutor") {
      response = await dio.get(
        "$host/tutors/schedule/$userId",
        options: Options(
          headers: {
            "Authorization": "Bearer $jwtToken",
          },
        ),
      );
    }
    final data = List<Map<String, dynamic>>.from(response?.data);
    final lessons = <Lesson>[];
    for (final lessonData in data) {
      if (lessonData['date_at'] != null) {
        final tutorId = lessonData['tutor_id'];
        final tutorResponse = await dio.get("$host/users/$tutorId");
        final tutorData = tutorResponse.data as Map<String, dynamic>;
        final tutor = tutorData['lastname'] as String;

        final studentId = lessonData['student_id'];
        final studentResponse = await dio.get("$host/users/$studentId");
        final studentData = studentResponse.data as Map<String, dynamic>;
        final student = studentData['lastname'] as String;

        final lessonId = lessonData['id'];
        final subjectResponse = await dio.get("$host/users/subject/$lessonId");
        final subjectData = subjectResponse.data as Map<String, dynamic>;
        final subject = subjectData['subject_name'] as String;
        final lesson = Lesson(
          lessonId: lessonId,
          tutor: tutor,
          student: student,
          subject: subject,
          date: DateFormat('dd.MM.yyyy, HH:mm')
              .format(DateTime.parse(lessonData['date_at'])),
        );
        lessons.add(lesson);
      }
    }
    return lessons;
  }
}
