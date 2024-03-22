import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tutor_student_client/repositories/students/student_repository.dart';
import 'package:tutor_student_client/repositories/tutors/models/tutor.dart';
import 'package:tutor_student_client/repositories/tutors/tutor_repository.dart';
import 'package:tutor_student_client/repositories/users/lessons_repository.dart';
import 'package:tutor_student_client/secure_storage_manager.dart';

import '../../../repositories/tutors/models/student.dart';
import '../../../repositories/users/models/lesson.dart';
import '../../tutor/widgets/add_lesson_dialog.dart';
import '../widgets/lesson_tile.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Lesson>? _lessons;
  List<Student>? _students;

  late int _selectedItem;

  List<Tutor>? _tutors;
  String? _userRole;

  @override
  void initState() {
    _getRole();
    _loadLessons();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadStudents();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadTutors();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Расписание"),
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => _logout(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_drop_down),
            onPressed: () {
              _showPopupMenu();
            },
          ),
        ],
      ),
      body: (_lessons == null || _students == null || _tutors == null)
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                                return AddLessonDialog(
                                  onResponded: _loadLessons,
                                );
                              });
                        },
                        child: const Icon(Icons.add_circle),
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                      itemCount: _lessons!.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, i) {
                        final lesson = _lessons![i];
                        return LessonTile(
                          lesson: lesson,
                          role: _userRole,
                        );
                      }),
                ),
                Row(
                  children: <Widget>[
                    if (_userRole == "student")
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ElevatedButton(
                            child: const Icon(Icons.find_in_page_rounded),
                            onPressed: () {
                              Navigator.of(context).pushNamed("/search_screen");
                            },
                          ),
                        ),
                      ),
                    if (_userRole == "tutor")
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ElevatedButton(
                            child: const Icon(Icons.mail_outline_outlined),
                            onPressed: () => Navigator.of(context)
                                .pushNamed("/respond_screen"),
                          ),
                        ),
                      ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ElevatedButton(
                          child: const Icon(Icons.task),
                          onPressed: () =>
                              Navigator.of(context).pushNamed("/tasks_screen"),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ElevatedButton(
                          child: const Icon(Icons.person),
                          onPressed: () {
                            Navigator.of(context).pushNamed("/profile");
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Future<void> _loadLessons() async {
    _lessons = await LessonsRepository().getLessonsList();
    setState(() {});
  }

  Future<void> _getRole() async {
    _userRole = await SecureStorageManager.instance.getRole();
    setState(() {});
  }

  Future<void> _logout(BuildContext context) async {
    await SecureStorageManager.instance.deleteToken();
    await SecureStorageManager.instance.deleteRole();
    await SecureStorageManager.instance.deleteUserId();
    if (context.mounted) {
      Navigator.of(context).pushNamed('/login_screen');
    }
  }

  Future<void> _loadStudents() async {
    _students = await TutorRepository().fetchStudents();
    setState(() {
      _students?.insert(0, const Student(studentId: -1, firstname: "ученики", lastname: "Все"));
    });
  }

  Future<void> _loadTutors() async {
    _tutors = await StudentRepository().fetchTutors();
    setState(() {});
  }


  void _showPopupMenu() {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(1, AppBar().preferredSize.height, 0, 0),
      items: _buildPopupMenuItems(),
    ).then((value) async {
      if (value != null) {
        setState(() {
          _selectedItem = value;
        });

        if (_selectedItem == -1) {
          _loadLessons();
        } else {
          _lessons = await LessonsRepository().getLessonsListByUserId(_userRole!, _selectedItem);
          setState(() {});
        }

        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(_selectedItem.toString()),
        //     duration: const Duration(seconds: 2),
        //     backgroundColor: Colors.indigo,
        //   ),
        // );
      }
    });
  }

  List<PopupMenuEntry<int>> _buildPopupMenuItems() {
    return _userRole == "tutor"
        ? _buildTutorPopupMenuItems()
        : _buildStudentPopupMenuItems();
  }

  List<PopupMenuEntry<int>> _buildTutorPopupMenuItems() {
    return _students!.map((student) {
      return PopupMenuItem<int>(
        value: student.studentId,
        child: Text("${student.lastname} ${student.firstname}"),
      );
    }).toList();
  }

  List<PopupMenuEntry<int>> _buildStudentPopupMenuItems() {
    return _tutors!.map((tutor) {
      return PopupMenuItem<int>(
        value: tutor.id,
        child: Text("${tutor.lastname} ${tutor.firstname}"),
      );
    }).toList();
  }
}
