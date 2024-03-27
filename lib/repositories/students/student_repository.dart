import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:tutor_student_client/repositories/tutors/models/tutor.dart';
import 'package:tutor_student_client/secure_storage_manager.dart';

import '../../api.dart';

class StudentRepository {
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

  Future<List<Tutor>> fetchTutors() async {
    final jwtToken = await SecureStorageManager.instance.getToken();
    Map<String, dynamic> decodedToken = JwtDecoder.decode(jwtToken!);
    final role = decodedToken["role"];
    if (role == "tutor") {
      return <Tutor>[];
    }
    final resp = await _dio.get(
      "$host/students/tutors",
      options: Options(
        headers: {
          "Authorization": "Bearer $jwtToken",
        },
      ),
    );
    final data = List<Map<String, dynamic>>.from(resp.data);
    final tutors = <Tutor>[];
    tutors.add(const Tutor(id: -1, firstname: "репетиторы", lastname: "Все"));
    for (final tutorData in data) {
      final tutor = Tutor(
        id: tutorData["id"],
        firstname: tutorData["firstname"],
        lastname: tutorData["lastname"],
      );
      tutors.add(tutor);
    }
    return tutors;
  }

  Future<List<Tutor>> fetchTutorsToAdd() async {
    final userId = await SecureStorageManager.instance.getUserId();
    final subjects = await SecureStorageManager.instance.getSubjects(userId!);
    List<int> subjectIds = <int>[];
    for (final element in subjects.entries) {
      if (element.value) {
        subjectIds.add(_subjectToId[element.key]!);
      }
    }
    final jwtToken = await SecureStorageManager.instance.getToken();
    final resp = await _dio.post(
      "$host/students/tutors",
      data: {"subject_ids": subjectIds},
      options: Options(
        headers: {
          "Authorization": "Bearer $jwtToken",
        },
      ),
    );
    final data = List<Map<String, dynamic>>.from(resp.data);
    final tutors = <Tutor>[];
    for (final tutorData in data) {
      final tutor = Tutor(
        id: tutorData["id"],
        firstname: tutorData["firstname"],
        lastname: tutorData["lastname"],
        subjects: List<String>.from(tutorData["subjects"]),
      );
      tutors.add(tutor);
    }
    return tutors;
  }

  Future<void> sendEnrollmentRequest(int tutorId) async {
    final jwtToken = await SecureStorageManager.instance.getToken();
    await _dio.post(
      "$host/enroll/$tutorId",
      options: Options(
        headers: {
          "Authorization": "Bearer $jwtToken",
        },
      ),
    );
  }

  Future<void> rescheduleLesson(
      int lessonId, String? reason, String? dateAt) async {
    final jwtToken = await SecureStorageManager.instance.getToken();
    String originalFormat = 'dd.MM.yyyy, HH:mm';
    String desiredFormat = 'yyyy-MM-dd HH:mm';
    String? formattedDateTime;
    if (dateAt != null) {
      DateTime originalDateTime = DateFormat(originalFormat).parse(dateAt);
      formattedDateTime = DateFormat(desiredFormat).format(originalDateTime);
    }
    final data = {
      "lesson_id": lessonId,
      "reason": reason,
      "status": "pending",
      "new_date_at": formattedDateTime
    };
    await _dio.post(
      "$host/reschedule/",
      data: data,
      options: Options(
        headers: {
          "Authorization": "Bearer $jwtToken",
        },
      ),
    );
  }

  Future<void> uploadTask(int taskId, FormData file) async {
    final jwtToken = await SecureStorageManager.instance.getToken();
    await _dio.post(
      "$host/hometask/$taskId",
      data: file,
      options: Options(
        headers: {
          "Authorization": "Bearer $jwtToken",
          'Content-Type': 'multipart/form-data'
        },
      ),
    );
  }
}
