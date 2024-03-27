import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../api.dart';
import '../../secure_storage_manager.dart';

class UserRepository {
  Future<void> createUser(firstname, lastname, email, password, role) async {
    Dio dio = Dio();
    await dio.post('$host/users/', data: {
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'password': password,
      'role': role,
    });
  }

  Future<int?> login(email, password) async {
    Dio dio = Dio();
    try {
      Response loginResponse = await dio.post('$host/login/',
          data: {
            'username': email,
            'password': password,
          },
          options: Options(contentType: Headers.formUrlEncodedContentType));

      String token = loginResponse.data['access_token'];
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      await SecureStorageManager.instance.storeToken(token);
      final userId = decodedToken["user_id"].toString();

      await SecureStorageManager.instance.storeUserId(userId);
      await SecureStorageManager.instance.storeRole(decodedToken['role']);
      final subjects = await SecureStorageManager.instance.getSubjects(userId);
      if (subjects.isEmpty) {
        Map<String, bool> subjectsFilter = {
          'Русский язык': false,
          'Литература': false,
          'Математика': false,
          'История': false,
          'Биология': false,
          'Химия': false,
          'Английский язык': false,
          'Физика': false,
        };
        SecureStorageManager.instance.storeSubjects(userId, subjectsFilter);
      }
      return loginResponse.statusCode;
    } on DioException catch(e) {
      return e.response?.statusCode;
    }
  }

  Future<void> downloadTask(int taskId, String title) async {
    Dio dio = Dio();
    final status = await Permission.storage.status;
    if (status.isGranted) {
      String dir = '/storage/emulated/0/Download/home_tasks';
      final jwtToken = await SecureStorageManager.instance.getToken();
      String filePath = '$dir/$title.pdf';
      await dio.download('$host/hometask/$taskId', filePath,
          options: Options(
            headers: {
              "Authorization": "Bearer $jwtToken",
            },
          ));
    } else {
      print("ban");
    }
  }
}
