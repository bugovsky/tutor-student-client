import 'package:flutter/material.dart';
import 'package:tutor_student_client/repositories/tutors/models/tutor.dart';

import '../../../repositories/students/student_repository.dart';
import '../widgets/tutor_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Tutor>? _tutors;

  @override
  void initState() {
    _loadTutors();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Найти репетитора"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushNamed("/main_screen"),
        ),
      ),
      body: (_tutors == null)
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: _tutors!.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, i) {
                final tutor = _tutors![i];
                return TutorTile(
                  tutor: tutor,
                );
              }),
    );
  }

  Future<void> _loadTutors() async {
    _tutors = await StudentRepository().fetchTutorsToAdd();
    setState(() {});
  }
}
