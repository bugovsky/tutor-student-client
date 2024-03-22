import 'package:flutter/material.dart';
import 'package:tutor_student_client/repositories/users/user_repository.dart';
import 'package:tutor_student_client/secure_storage_manager.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _password = '';
  String _userRole = 'tutor';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthentication();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Создать аккаунт',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                          decoration: const InputDecoration(labelText: 'Имя'),
                          onSaved: (value) => _firstName = value ?? '',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Поле должно быть заполнено";
                            }
                            return null;
                          }),
                      TextFormField(
                          decoration:
                              const InputDecoration(labelText: 'Фамилия'),
                          onSaved: (value) => _lastName = value ?? '',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Поле должно быть заполнено";
                            }
                            return null;
                          }),
                      TextFormField(
                          decoration: const InputDecoration(labelText: 'Почта'),
                          onSaved: (value) => _email = value ?? '',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Поле должно быть заполнено";
                            }
                            return null;
                          }),
                      TextFormField(
                          decoration:
                              const InputDecoration(labelText: 'Пароль'),
                          obscureText: true,
                          onSaved: (value) => _password = value ?? '',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Поле должно быть заполнено";
                            }
                            return null;
                          }),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 0.0),
                        child: ListTile(
                          title: const Text('Репетитор'),
                          contentPadding: EdgeInsets.zero,
                          leading: Radio<String>(
                            value: 'tutor',
                            groupValue: _userRole,
                            onChanged: (value) {
                              setState(() {
                                _userRole = value!;
                              });
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 0.0),
                        child: ListTile(
                          title: const Text('Ученик'),
                          contentPadding: EdgeInsets.zero,
                          leading: Radio<String>(
                            value: 'student',
                            groupValue: _userRole,
                            onChanged: (value) {
                              setState(() {
                                _userRole = value!;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text('Зарегистрироваться'),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/login_screen');
                        },
                        child: Text(
                          'Уже есть аккаунт? Войти',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary, // Customize color as needed
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
    } else {
      return;
    }
    try {
      await UserRepository()
          .createUser(_firstName, _lastName, _email, _password, _userRole);
      await UserRepository().login(_email, _password);
      if (mounted) {
        Navigator.of(context).pushNamed('/main_screen');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _checkAuthentication() async {
    String? jwtToken = await SecureStorageManager.instance.getToken();
    if (mounted && jwtToken != null) {
      Navigator.of(context).pushNamed('/main_screen');
    }
  }
}
