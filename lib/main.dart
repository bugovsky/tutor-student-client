import 'package:flutter/material.dart';
import 'package:tutor_student_client/router/router.dart';
import 'package:tutor_student_client/theme/theme.dart';

void main() {
  runApp(const TutorStudentApp());
}

class TutorStudentApp extends StatelessWidget {
  const TutorStudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TutorStudentApp',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          textTheme: appTheme),
      routes: routes,
    );
  }
}
