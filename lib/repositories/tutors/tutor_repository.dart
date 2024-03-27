import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:tutor_student_client/repositories/tutors/models/lesson_request.dart';
import 'package:tutor_student_client/repositories/tutors/models/student.dart';
import 'package:tutor_student_client/repositories/tutors/models/student_request.dart';
import 'package:tutor_student_client/secure_storage_manager.dart';

import '../../api.dart';

class TutorRepository {
  final Dio _dio = Dio();

  final Map<String, int> _subjectToId = {
    'Русский язык': 1,
    'Литература': 2,
    'Математика': 3,
    'История': 4,
    'Биология': 5,
    'Химия': 6,
    'Английский язык': 7,
    'Физика': 8,
  };

  Future<void> updateSubjects() async {
    final userId = await SecureStorageManager.instance.getUserId();
    final subjects = await SecureStorageManager.instance.getSubjects(userId!);
    List<int> addSubjects = <int>[], deleteSubjects = <int>[];
    for (final element in subjects.entries) {
      if (element.value) {
        addSubjects.add(_subjectToId[element.key]!);
      } else {
        deleteSubjects.add(_subjectToId[element.key]!);
      }
    }
    final jwtToken = await SecureStorageManager.instance.getToken();
    await _dio.post(
      "$host/tutors/subjects",
      data: {"subject_ids": addSubjects},
      options: Options(
        headers: {
          "Authorization": "Bearer $jwtToken",
        },
      ),
    );
    await _dio.delete(
      "$host/tutors/subjects",
      data: {"subject_ids": deleteSubjects},
      options: Options(
        headers: {
          "Authorization": "Bearer $jwtToken",
        },
      ),
    );
  }

  Future<List<StudentRequest>> fetchStudentRequests() async {
    final jwtToken = await SecureStorageManager.instance.getToken();
    final resp = await _dio.get(
      "$host/enroll/",
      options: Options(
        headers: {
          "Authorization": "Bearer $jwtToken",
        },
      ),
    );
    final data = List<Map<String, dynamic>>.from(resp.data);
    final studentRequests = <StudentRequest>[];
    for (final request in data) {
      final studentRequest = StudentRequest(
        studentId: request["id"],
        firstname: request["firstname"],
        lastname: request["lastname"],
      );
      studentRequests.add(studentRequest);
    }
    return studentRequests;
  }

  Future<void> respondToEnrollmentRequest(int studentId, String status) async {
    final jwtToken = await SecureStorageManager.instance.getToken();
    await _dio.patch(
      "$host/enroll/$studentId",
      data: {"status": status},
      options: Options(
        headers: {
          "Authorization": "Bearer $jwtToken",
        },
      ),
    );
  }

  Future<List<LessonRequest>> fetchLessonRequests() async {
    final jwtToken = await SecureStorageManager.instance.getToken();
    final resp = await _dio.get(
      "$host/reschedule/",
      options: Options(
        headers: {
          "Authorization": "Bearer $jwtToken",
        },
      ),
    );
    final data = List<Map<String, dynamic>>.from(resp.data);
    final lessonRequests = <LessonRequest>[];
    for (final request in data) {
      String? newDate = request["new_date_at"];
      if (newDate != null) {
        newDate =
            DateFormat("dd.MM.yyyy, HH:mm").format(DateTime.parse(newDate));
      }
      final lessonRequest = LessonRequest(
        lessonId: request["lesson_id"],
        reason: request["reason"],
        newDate: newDate,
      );
      lessonRequests.add(lessonRequest);
    }
    return lessonRequests;
  }

  Future<void> respondToLessonRequest(int lessonId, String status) async {
    final jwtToken = await SecureStorageManager.instance.getToken();
    await _dio.patch(
      "$host/reschedule/$lessonId",
      data: {"status": status},
      options: Options(
        headers: {
          "Authorization": "Bearer $jwtToken",
        },
      ),
    );
  }

  Future<List<Student>> fetchStudents() async {
    final jwtToken = await SecureStorageManager.instance.getToken();
    Map<String, dynamic> decodedToken = JwtDecoder.decode(jwtToken!);
    final role = decodedToken["role"];
    if (role == "student") {
      return <Student>[];
    }
    final resp = await _dio.get(
      "$host/tutors/students",
      options: Options(
        headers: {
          "Authorization": "Bearer $jwtToken",
        },
      ),
    );
    final data = List<Map<String, dynamic>>.from(resp.data);
    final students = <Student>[];
    //students.add(const Student(studentId: -1, firstname: "ученики", lastname: "Все"));
    for (final studentData in data) {
      final student = Student(
        studentId: studentData["id"],
        firstname: studentData["firstname"],
        lastname: studentData["lastname"],
      );
      students.add(student);
    }
    return students;
  }

  Future<void> addLesson(int studentId, String lessonName, String date) async {
    final jwtToken = await SecureStorageManager.instance.getToken();
    String originalFormat = 'dd.MM.yyyy, HH:mm';
    String desiredFormat = 'yyyy-MM-dd HH:mm';
    DateTime originalDateTime = DateFormat(originalFormat).parse(date);
    String formattedDateTime =
        DateFormat(desiredFormat).format(originalDateTime);
    final data = {
      "student_id": studentId,
      "subject_id": _subjectToId[lessonName],
      "date_at": formattedDateTime
    };
    await _dio.post(
      "$host/tutors/lesson",
      data: data,
      options: Options(
        headers: {
          "Authorization": "Bearer $jwtToken",
        },
      ),
    );
  }
}
