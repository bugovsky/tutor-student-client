import 'package:flutter/material.dart';
import 'package:tutor_student_client/repositories/tutors/tutor_repository.dart';
import 'package:tutor_student_client/repositories/users/models/lesson.dart';

import '../../../repositories/tutors/models/lesson_request.dart';
import '../../../repositories/tutors/models/student_request.dart';
import '../../../repositories/users/lessons_repository.dart';
import '../widgets/lesson_request_tile.dart';
import '../widgets/student_request_tile.dart';

class RespondScreen extends StatefulWidget {
  const RespondScreen({super.key});

  @override
  State<RespondScreen> createState() => _RespondScreenState();
}

class _RespondScreenState extends State<RespondScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<StudentRequest>? _studentRequests;

  List<LessonRequest>? _lessonRequests;
  Map<int, Lesson>? _lessons;

  @override
  void initState() {
    _loadLessons();
    _loadStudentRequests();
    _loadLessonRequests();
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Входящие запросы"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushNamed("/main_screen"),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(child: Text('Запись на занятия', textAlign: TextAlign.center)),
            Tab(
                child: Text('Изменения в расписании',
                    textAlign: TextAlign.center)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _studentRequests == null
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  itemCount: _studentRequests!.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, i) {
                    final studentRequest = _studentRequests![i];
                    return StudentRequestTile(
                        studentRequest: studentRequest,
                        onResponded: _loadStudentRequests);
                  }),
          _lessonRequests == null || _lessons == null
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  itemCount: _lessonRequests!.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, i) {
                    final lessonRequest = _lessonRequests![i];
                    return LessonRequestTile(
                        lessonRequest: lessonRequest,
                        onResponded: _loadLessonRequests,
                        lesson: _lessons?[lessonRequest.lessonId]);
                  }),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStudentRequests() async {
    _studentRequests = await TutorRepository().fetchStudentRequests();
    setState(() {});
  }

  Future<void> _loadLessonRequests() async {
    _lessonRequests = await TutorRepository().fetchLessonRequests();
    setState(() {});
  }

  Future<void> _loadLessons() async {
    _lessons = {
      for (var item in await LessonsRepository().getLessonsList())
        item.lessonId: item
    };
    setState(() {});
  }
}
