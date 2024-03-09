import 'package:tutor_student_client/features/student/view/search_screen.dart';
import 'package:tutor_student_client/features/users/view/main_screen.dart';
import 'package:tutor_student_client/features/users/view/tasks_screen.dart';

import '../features/tutor/view/respond_screen.dart';
import '../features/users/view/auth_screen.dart';
import '../features/users/view/login_screen.dart';
import '../features/users/view/profile_screen.dart';

final routes = {
  '/': (context) => const AuthScreen(),
  '/login_screen': (context) => const LoginScreen(),
  '/main_screen': (context) => const MainScreen(),
  '/profile': (context) => const ProfileScreen(),
  '/search_screen': (context) => const SearchScreen(),
  '/respond_screen': (context) => const RespondScreen(),
  '/tasks_screen': (context) => const TasksScreen(),
};
