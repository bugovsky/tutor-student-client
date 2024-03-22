import 'package:flutter/material.dart';
import 'package:tutor_student_client/repositories/tutors/tutor_repository.dart';

import '../../../secure_storage_manager.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, bool>? _subjects;
  String? _userRole;
  bool _isSaving = false;

  @override
  void initState() {
    _getSubjects();
    _getRole();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Профиль"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushNamed("/main_screen"),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: (_subjects == null)
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: _subjects!.keys.map((String key) {
                      return CheckboxListTile(
                        title: Text(key),
                        value: _subjects![key],
                        onChanged: (bool? value) {
                          setState(() {
                            _subjects![key] = value!;
                          });
                        },
                      );
                    }).toList(),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30, bottom: 100),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveSubjects,
                  child: _isSaving
                      ? const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.indigo),
                        )
                      : const Text("Сохранить")),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSubjects() async {
    setState(() {
      _isSaving = true;
    });

    if (_userRole == 'student') {
      await _saveStudentSubjects();
    } else if (_userRole == 'tutor') {
      await _saveTutorSubjects();
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Профиль сохранен'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.indigo,
        ),
      );
    }

    setState(() {
      _isSaving = false;
    });
  }

  Future<void> _saveStudentSubjects() async {
    final userId = await SecureStorageManager.instance.getUserId();
    await SecureStorageManager.instance.storeSubjects(userId!, _subjects!);
  }

  Future<void> _saveTutorSubjects() async {
    final userId = await SecureStorageManager.instance.getUserId();
    await SecureStorageManager.instance.storeSubjects(userId!, _subjects!);
    await TutorRepository().updateSubjects();
  }

  Future<void> _getSubjects() async {
    final userId = await SecureStorageManager.instance.getUserId();
    _subjects = await SecureStorageManager.instance.getSubjects(userId!);
    setState(() {});
  }

  Future<void> _getRole() async {
    _userRole = await SecureStorageManager.instance.getRole();
    setState(() {});
  }
}
